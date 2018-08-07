IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'feed_out_kaplan_pos')
BEGIN
 DROP  Procedure  feed_out_kaplan_pos
END

GO



create proc dbo.feed_out_kaplan_pos
AS


	DECLARE @i_validcomptypecount int,
			@i_gpokey int,
			@v_gponumber varchar(10),
			@v_pocurrentstatus varchar(1),
			@i_jobkey int,
			@i_qsijobmessagekey	int,
			@i_feedkapheaderkey int

			-- Get key form keys table
			Select @i_jobkey = generickey
			from keys
			
			-- Set next key
			update keys 
			set generickey = @i_jobkey + 1

			--5.3.1.	Log start time of insert job
			Insert into qsijob (qsijobkey, qsibatchkey, jobtypecode,jobtypesubcode, jobdesc,startdatetime, runuserid, statuscode, lastuserid, lastmaintdate)
			Values (@i_jobkey, @i_jobkey, 3,1,'Kaplan PO Oracle Feed', getdate(), 'qsiadmin', 1, 'qsijob',getdate())
				--*Status Codes: 1 = Started, 2 = Aborted, 3 = Completed

BEGIN


	DECLARE cursor_po INSENSITIVE CURSOR
	FOR

	Select pokey, g.gponumber, poh.pocurrentstatus
	from postatushistory poh, gpo g
	where poh.pokey = g.gpokey
	and poh.potypekey = 1
	and (poh.pocurrentstatus = 'F' and poh.poprevstatus = 'P'
		 or poh.pocurrentstatus = 'F' and poh.poprevstatus = 'A'
		 or poh.pocurrentstatus = 'F' and g.gpochangenum is null)
	and postatuschangeddate > (Select max(stopdatetime) 
						 from qsijob 
						 where jobtypecode = 3 
						   and jobtypesubcode = 1)
	group by pokey, g.gponumber, poh.pocurrentstatus

	UNION

	Select g.gpokey, a.gponumber, g.gpostatus
	from additionalpotooracle a, gpo g
	where a.gponumber = g.gponumber
		and	createdate > (Select max(stopdatetime) 
					   from qsijob 
					   where jobtypecode = 3 
						 and jobtypesubcode = 1)
	FOR READ ONLY

	OPEN cursor_po


		If @@FETCH_STATUS = -2
		begin


		--insert into qsijobmessages
		-- no purchase orders found to send based on given date range

		-- Get key form keys table
		Select @i_qsijobmessagekey = generickey
		from keys
		
		-- Set next key
		update keys 
		set generickey = @i_qsijobmessagekey + 1

	        Insert into qsijobmessages (qsijobmessagekey, qsijobkey, referencekey1, referencekey2, messagetypecode,  messagelongdesc, 
		    lastuserid, lastmaintdate)
	        Select @i_qsijobmessagekey, @i_jobkey, 0, 0, 2, 'No POs were sent since they did not meet the criteria.',
		    'qsijob', Getdate()

		-- set job aborted status
		update qsijob
		set stopdatetime = getdate(),
			statuscode = 2 -- aborted       
		where qsijobkey = @i_jobkey
	
		--RETURN

		end



	FETCH NEXT FROM cursor_po
	INTO @i_gpokey, @v_gponumber,@v_pocurrentstatus

	while (@@FETCH_STATUS<>-1 )
	begin
		IF (@@FETCH_STATUS<>-2)
		begin



		Select @i_validcomptypecount = count(*) 
		from gposection 
		where gpokey = @i_gpokey
		and key3 in (Select compkey from comptype where externalcode is not null)

		If @i_validcomptypecount < 1
			begin


			-- Get key form keys table
			Select @i_qsijobmessagekey = generickey
			from keys
			
			-- Set next key
			update keys 
			set generickey = @i_qsijobmessagekey + 1

				Insert into qsijobmessages (qsijobmessagekey, qsijobkey, referencekey1, referencekey2, messagetypecode,  messagelongdesc, 
				lastuserid, lastmaintdate)
				Select @i_qsijobmessagekey, @i_jobkey, 0, 0, 2, 'PO# ' + @v_gponumber + ' will not be sent because there were no valid component types',
				'qsijob', Getdate()
			
			end
		Else if (@i_validcomptypecount > 1 or @i_validcomptypecount = 1)
			begin


			-- Get key form keys table
			Select @i_feedkapheaderkey = generickey
			from keys
			
			-- Set next key
			update keys 
			set generickey = @i_feedkapheaderkey + 1


			-- we have winner, start to feed into Feed_Kaplan_Oracle_* tables

			-- proc: insert row into Feed_Kaplan_Oracle_Header for all po's
			-- STOP HERE if current po status is VOID

			exec dbo.Feed_Kaplan_Oracle_Header_Insert 
			@i_jobkey,   --@i_batchkey int, 
			@i_gpokey,   --@i_gpokey int,
			@i_feedkapheaderkey, -- @i_feedkapheaderkey int
			@i_validcomptypecount

			If @v_pocurrentstatus <> 'V'
		
			-- proc: insert row into Feed_Kaplan_Oracle_Paper for po's 
			--	when there is a print component (compkey = 3)
			--	and where each material spec has a reservedind = True

			exec dbo.Feed_Kaplan_Oracle_Paper_Insert 
			@i_jobkey,
			@i_gpokey, 
			@i_feedkapheaderkey

			-- proc: insert row into Feed_Kaplan_PO_Line for each component
			--  sum up FIXED and RUN costs for last 2 columns

			exec dbo.Feed_Kaplan_Oracle_PO_List_Insert 
			@i_jobkey, 
			@i_gpokey, 
			@i_feedkapheaderkey
						
			end


	FETCH NEXT FROM cursor_po
	INTO @i_gpokey, @v_gponumber,@v_pocurrentstatus

        
	end

end

	exec Feed_Kaplan_Write_Output @i_jobkey


	close cursor_po
	deallocate cursor_po

	-- set job complete status
	update qsijob
	set stopdatetime = getdate(),
	    statuscode = 3       
	where qsijobkey = @i_jobkey

END