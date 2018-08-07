IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Feed_Kaplan_Write_Output')
BEGIN
 DROP  Procedure  Feed_Kaplan_Write_Output
END

GO

Create procedure Feed_Kaplan_Write_Output (@i_Jobkey int)
AS

/*
Recordtype1 = Record
Recordtype2 = PO Header Data
Recordtype4 = Kaplan Paper Reserve Data
Recordtype6 = PO Lines
	 Footer = /EOF/
*/

DECLARE @v_filename varchar(255),
		@v_output varchar(8000),
		@i_gpokey int,
		@i_componenttypecode int,
		@i_materialkey int,
		@i_sectionkey int,
		@NumLines int,
		@XPCmdString varchar(8000)
	

BEGIN


/**********************************************************************/
/***********************   Recordtype1 = Record   *********************/
/**********************************************************************/

		Select @v_filename = '\\mohawk\Users\PMilana\KAP\POFeed\sampleoutput\KPO102001' +'.'+ dbo.PADL(cast(@i_Jobkey as varchar),6,'0')


		Select @v_output = '1' + 
				CASE 
				WHEN CAST(DATEPART(mm,getdate())as int) < 10 THEN '0' + CAST(DATEPART(mm,getdate())as varchar)
				ELSE CAST(DATEPART(mm,getdate())as varchar)
				END +
				CASE 
				WHEN CAST(DATEPART(dd,getdate())as int) < 10 THEN '0' + CAST(DATEPART(dd,getdate())as varchar)
				ELSE CAST(DATEPART(dd,getdate())as varchar)
				END +
				CAST(datepart(yyyy,getdate()) as varchar)


	exec sp_AppendToFile @v_filename, @v_output



	DECLARE cursor_po_record INSENSITIVE CURSOR
	FOR

	Select pokey, componenttypecode
	from Feed_Kaplan_Oracle_Header
	where batchkey = @i_Jobkey 

	FOR READ ONLY

	OPEN cursor_po_record

	begin

	FETCH NEXT FROM cursor_po_record
	INTO @i_gpokey, @i_componenttypecode 

	while (@@FETCH_STATUS<>-1 )
	begin
		IF (@@FETCH_STATUS<>-2)
		begin

		/**********************************************************************/
		/******************   Recordtype2 = PO Header Data ********************/
		/**********************************************************************/

print 'gpokey = ' + Cast(@i_gpokey as varchar)
print 'jobkey = ' + Cast(@i_Jobkey as varchar)

		Select @v_output = NULL

		Select @v_output = 
			   '2' + 
			   CAST(newupdateind as varchar) +
			   dbo.PADR(CAST(CAST(ponumber as int) as varchar),10,' ')  +
			   dbo.PADL(CAST(printingkey as varchar),4,'0') +
			   dbo.PADL(CAST(IsNull(changenum,'') as varchar),2,'0') +
			   dbo.PADR(IsNull(vendorid,''),10,' ') + 
			   dbo.PADR(IsNull(vendorsiteid,''),10,' ') + 
			   dbo.PADR(IsNull(shiptovendorid,''),10,' ') + 
			   dbo.PADR(IsNull(shiptosite,''),10,' ') + 
			   dbo.PADR(IsNull(buyername,''),30,' ') + 
			   CASE 
			   WHEN CAST(DATEPART(mm,createdon)as int) < 10 THEN '0' + CAST(DATEPART(mm,createdon)as varchar)
			   ELSE CAST(DATEPART(mm,createdon)as varchar)
			   END +
			   CASE 
			   WHEN CAST(DATEPART(dd,createdon)as int) < 10 THEN '0' + CAST(DATEPART(dd,createdon)as varchar)
			   ELSE CAST(DATEPART(dd,createdon)as varchar) END + 
			   CAST(datepart(yyyy,createdon) as varchar) +
			   CASE 
			   WHEN daterequired is null THEN '00'
			   WHEN CAST(DATEPART(mm,daterequired)as int) < 10 THEN '0' + CAST(DATEPART(mm,daterequired)as varchar)
			   ELSE CAST(DATEPART(mm,daterequired)as varchar)
			   END +
			   CASE 
			   WHEN daterequired is null THEN '000000'
			   WHEN CAST(DATEPART(dd,daterequired)as int) < 10 THEN '0' + CAST(DATEPART(dd,daterequired)as varchar) + CAST(datepart(yyyy,daterequired) as varchar) 
			   ELSE CAST(DATEPART(dd,daterequired)as varchar) + CAST(datepart(yyyy,daterequired) as varchar) 
			   END +
			   dbo.PADR(IsNull(podescription,''),240,'') +
			   isbn +
			   dbo.PADL(IsNull(itemtypecode,'0'),2,'0') +
			   dbo.PADL(CAST(finishedgoodsquantity as varchar) + '0000',14,'0') +
			   dbo.PADR(CAST(CAST(ISNULL(parentponum,'') as int) as varchar),10,' ') +
			   dbo.PADL(CAST(IsNull(parentpochangenum,'0') as varchar),2,'0') +
			   dbo.PADR(' ',200,' ')
		from Feed_Kaplan_Oracle_Header
				where pokey = @i_gpokey
				and batchkey = @i_Jobkey

		If @v_output is not null
		begin
		exec sp_AppendToFile @v_filename, @v_output
		end

		/**********************************************************************/
		/************   Recordtype4 = Kaplan Paper Reserve Data ***************/
		/**********************************************************************/
	
		DECLARE cursor_paper_record INSENSITIVE CURSOR
		FOR

		Select materialkey
		from Feed_Kaplan_Oracle_Paper
		where batchkey = @i_Jobkey 
			and pokey = @i_gpokey

		FOR READ ONLY

		OPEN cursor_paper_record

		begin

		FETCH NEXT FROM cursor_paper_record
		INTO @i_materialkey

		while (@@FETCH_STATUS<>-1 )
		begin
			IF (@@FETCH_STATUS<>-2)
			begin
			
			Select @v_output = NULL		

			Select @v_output = 
				   '4' +
				   dbo.PADL(isnull(Sequence,'0'),2,'0') +
				   dbo.PADR(IsNull(paperisbn,''),30,' ') +
				   dbo.PADL(cast(totalpaperallocation as varchar) + '0000',14,'0')
			from Feed_Kaplan_Oracle_Paper
			where pokey = @i_gpokey
			  and batchkey = @i_Jobkey
			  and materialkey = @i_materialkey

			If @v_output is not null
			begin
			exec sp_AppendToFile @v_filename, @v_output
			end

			end

		FETCH NEXT FROM cursor_paper_record
		INTO @i_materialkey
	
		end

		close cursor_paper_record
		deallocate cursor_paper_record
		
		end

		/**********************************************************************/
		/*********************   Recordtype6 = PO Lines ***********************/
		/**********************************************************************/

		DECLARE cursor_poline_record INSENSITIVE CURSOR
		FOR

		Select sectionkey
		from Feed_Kaplan_Oracle_PO_List
		where batchkey = @i_Jobkey 
			and pokey = @i_gpokey
			and finishedgoodind = 'N'

		FOR READ ONLY

		OPEN cursor_poline_record

		begin

		FETCH NEXT FROM cursor_poline_record
		INTO @i_sectionkey

		while (@@FETCH_STATUS<>-1 )
		begin
			IF (@@FETCH_STATUS<>-2)
			begin

			
			Select @v_output = NULL

			Select @v_output = 
				   '6' +
				   dbo.PADR(IsNull(itemtypecode,''),50,' ') +
				   dbo.PADR(IsNull(paperisbn,''),30,' ') +
				   dbo.PADL(unitofmeasure,4,' ') +
				   dbo.PADL(cast(quantity as varchar) + '0000',14,'0') +
				   dbo.PADL(cast(IsNull(totalfixedcost,'') as varchar) + '0000',10,'0') +
				   dbo.PADL(cast(IsNull(totalruncost,'') as varchar) + '0000',10,'0') 				    
			From Feed_Kaplan_Oracle_PO_List
			where pokey = @i_gpokey
			  and batchkey = @i_Jobkey
			  and sectionkey = @i_sectionkey
			  and finishedgoodind = 'N'

			If @v_output is not null
			begin
			exec sp_AppendToFile @v_filename, @v_output
			end		

			end	

			FETCH NEXT FROM cursor_poline_record
			INTO @i_sectionkey
		
			end
			
			close cursor_poline_record
			deallocate cursor_poline_record

			end
			end
			

	FETCH NEXT FROM cursor_po_record
	INTO @i_gpokey, @i_componenttypecode 

	end
	end



		/**********************************************************************/
		/**********************   Footer = /EOF/ ******************************/
		/**********************************************************************/	

		-- get number of lies in the file
		SET nocount ON

		SET @XPCmdString =  'find /V /C "nothingcontainsthisstring" ' + @v_filename 
		 
		CREATE TABLE #XPOutput (XPLineOut varchar(1000))
		INSERT INTO #XPOutput EXEC master..xp_cmdshell @XPCmdString
		DELETE FROM #XPOutput WHERE XPLineOut IS NULL
		 
		SELECT @NumLines =  SUBSTRING (XPLineOut, 12 + 
		len(@v_filename ) + 2, 1000) FROM #XPOutput
		

		Select @v_output = 
		'/EOF/' +
		dbo.PADL(CAST(@NumLines as varchar),6,'0') +
		CAST(datepart(yyyy,getdate()) as varchar) +
		CASE 
		WHEN CAST(DATEPART(mm,getdate())as int) < 10 THEN '0' + CAST(DATEPART(mm,getdate())as varchar)
		ELSE CAST(DATEPART(mm,getdate())as varchar)
		END +
		CASE 
		WHEN CAST(DATEPART(dd,getdate())as int) < 10 THEN '0' + CAST(DATEPART(dd,getdate())as varchar)
		ELSE CAST(DATEPART(dd,getdate())as varchar)
		END + 
		CASE WHEN datepart(hh,getdate()) < 10 then '0' + CAST(datepart(hh,getdate()) as varchar)
		ELSE CAST(datepart(hh,getdate()) as varchar)
		END +
		CASE WHEN datepart(mi,getdate()) < 10 then '0' + CAST(datepart(mi,getdate()) as varchar)
		ELSE CAST(datepart(mi,getdate()) as varchar)
		END +
		CASE WHEN datepart(ss,getdate()) < 10 then '0' + CAST(datepart(ss,getdate()) as varchar)
		ELSE CAST(datepart(s,getdate()) as varchar)
		END +
		dbo.PADL(CAST(@i_Jobkey as varchar),8,'0')		


		exec sp_AppendToFile @v_filename, @v_output


	close cursor_po_record
	deallocate cursor_po_record

END