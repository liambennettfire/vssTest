PRINT 'STORED PROCEDURE : dbo.datawarehouse_webschedule'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_webschedule') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_webschedule
end

GO

create proc dbo.datawarehouse_webschedule
@ware_bookkey int,@ware_printingkey int,
@ware_sched int,@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

/*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  --------  --------    -----------------------------------------------------
**  7/25/2017  Kusum      Case 46448 Commented out print statements
*******************************************************************************/

  DECLARE @ware_count int
  DECLARE @ware_dateline  int
  DECLARE @estdate  datetime
  DECLARE @actdate  datetime
  DECLARE @bestdate  datetime
  DECLARE @ware_role_long  varchar(40) 
  DECLARE @i_elementtypecode int
  ---DECLARE @d_estimatedate datetime
  ---DECLARE @d_actualdate datetime
  DECLARE @i_datetypecode int
  DECLARE @i_duration int 
  DECLARE @i_roletypecode  int 
  DECLARE @i_contributorkey int 
  DECLARE @c_displayname varchar(80) 
  DECLARE @i_schedstatus int
  DECLARE @c_tasknote varchar(255)

  DECLARE @nc_sqlstring NVARCHAR(4000)
  DECLARE @nc_sqlparameters NVARCHAR(4000)

  DECLARE @c_userid varchar(30)
  DECLARE @temp_actdate datetime
  DECLARE @i_actualind int
  DECLARE @d_activedate datetime
  DECLARE @d_reviseddate datetime
  DECLARE @v_cursor_sql nvarchar(max)
  DECLARE @v_scheduledatetype int
  DECLARE @v_cnt int
  DECLARE @v_found tinyint
  DECLARE @v_taqtaskkey INT
  DECLARE @v_taqelementkey INT
  
  /*7-12-04 -CRM 01463 10 new schedule...change to execute immediate, only need 1 insert instead of 20*/
  /*8-5-04 CRM 1666 : fix missing @ in @ware_count from dateline 6 to 40*/
  /*8-11-04 change to sp_execute syntax*/

  select @c_userid = 'WARE_STORED_PROC'

  BEGIN tran
	set @nc_sqlstring = N' insert into whschedule' + convert (varchar (10),@ware_sched) +
	' (bookkey, printingkey, lastuserid, lastmaintdate) VALUES (@ware_bookkey, @ware_printingkey, @c_userid , @ware_system_date)'

 /**  7/25/2017  Kusum Case 46448**/
--print '@nc_sqlstring'
--print @nc_sqlstring
		 
	set @nc_sqlparameters = '@ware_bookkey INT, @ware_printingkey INT, @c_userid  varchar (30),@ware_system_date datetime'

/**  7/25/2017  Kusum Case 46448**/
--print '@nc_sqlparameters'
--print @nc_sqlparameters

	EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_bookkey,@ware_printingkey,@c_userid ,@ware_system_date

  commit tran

--  DECLARE warehousesched INSENSITIVE CURSOR FOR
--	  select distinct taqprojectelement.taqelementtypecode, taqprojecttask.activedate, taqprojecttask.reviseddate,taqprojecttask.actualind,
--			  taqprojecttask.datetypecode, taqprojecttask.duration, taqprojecttask.rolecode, 
--			  globalcontact.globalcontactkey, globalcontact.displayname,  taqprojecttask.taqtasknote
--		from taqprojecttask 
--		join taqprojectelement on taqprojectelement.bookkey = taqprojecttask.bookkey
--		join WHCSCHEDULETYPE on WHCSCHEDULETYPE.scheduletypecode = taqprojectelement.taqelementtypecode
--		left join globalcontact on taqprojecttask.globalcontactkey = globalcontact.globalcontactkey
--		  where ( WHCSCHEDULETYPE.linenumber = @ware_sched)
--		  and ( isnull(taqprojecttask.bookkey,0) = @ware_bookkey  )
--		  and ( isnull(taqprojecttask.printingkey,0) = @ware_printingkey  )
--		  --and (taqprojecttask.globalcontactkey is not null)  -- Case #11652
--	  order by taqprojecttask.datetypecode

  DECLARE warehousesched INSENSITIVE CURSOR FOR 
    SELECT DISTINCT t.taqelementkey,e.taqelementtypecode,t.activedate,t.reviseddate,t.actualind,
      t.datetypecode,t.duration,t.rolecode,
      t.globalcontactkey,
      g.displayname,t.taqtasknote
      FROM taqprojecttaskelement_view t
      LEFT OUTER JOIN globalcontact g ON t.globalcontactkey = g.globalcontactkey,
           whcscheduletype w, taqprojectelement e
      WHERE t.taqelementkey = e.taqelementkey
        AND e.bookkey = t.bookkey
        AND e.taqelementtypecode = w.scheduletypecode
        AND e.printingkey = t.printingkey
        AND t.overridetableind = 0
        AND w.linenumber = @ware_sched
        AND (isnull(t.bookkey,0) = @ware_bookkey)
        AND (isnull(t.printingkey,0) = @ware_printingkey)
        ORDER BY t.datetypecode

  OPEN warehousesched

  FETCH NEXT FROM warehousesched
  INTO @v_taqelementkey,@i_elementtypecode,@d_activedate,@d_reviseddate,@i_actualind,
    @i_datetypecode,@i_duration,@i_roletypecode,@i_contributorkey,
    @c_displayname,@c_tasknote

--  print '@i_elementtypecode'
--  print @i_elementtypecode
--  print '@i_datetypecode'
--  print @i_datetypecode
--  print '@i_duration'
--  print @i_duration
--  print '@i_roletypecode'
--  print @i_roletypecode
--  print '@i_contributorkey'
--  print @i_contributorkey
--  print '@c_displayname'
--  print @c_displayname
--  print '@d_reviseddate'
--  print @d_reviseddate

  select @i_schedstatus= @@FETCH_STATUS

  while (@i_schedstatus<>-1 ) begin
	  IF (@i_schedstatus<>-2) begin
	    -- reset 
	    SET @actdate = null
	    SET @estdate = null

		-- Case 13381 added a ‘Revised Date’. This date is not editable. Notes from case description:
        -- The Active Date will continue to be the date which is maintained, however, the system will automatically 
        -- set the ‘Revised’ date equal to the active date IF the Actual checkbox is NOT checked. 
        -- In this way, the user will be able to see revised schedule in its entirety, 
        -- showing what the last assumptions were prior to setting the actual date.

		IF @i_actualind = 1 BEGIN
		  ----select @estdate = @d_estimatedate
		  select @actdate = @d_activedate
		  select @estdate = @d_reviseddate
		  ----select @temp_actdate = @d_actualdate
		  ----select @ware_dateline = 0
	    END
	    ELSE BEGIN
  		  select @estdate = @d_reviseddate
		END
--print '@d_reviseddate'
--print @d_reviseddate
		SELECT @bestdate = @d_activedate

		if @i_roletypecode is null begin
			select @i_roletypecode = 0
		end

		if @i_roletypecode > 0 begin
			exec gentables_longdesc 285,@i_roletypecode, @ware_role_long OUTPUT
		end
		else begin	
		  select @ware_role_long = ''
		end

      /*  change select of 20 individual whschedule to 1 sp_Execute syntax */
		select @ware_count = 0
		select @ware_dateline = 0
		set @nc_sqlstring = N' select @ware_count = count(*)
				from whcschedule' + convert (varchar (10),@ware_sched) +
					' where scheduledatetype = @i_datetypecode'
--print '@nc_sqlstring '
--print @nc_sqlstring 
		EXEC sp_executesql @nc_sqlstring,
		 	 N'@ware_count INT OUTPUT,@i_datetypecode INT', 
		  	@ware_count OUTPUT, @i_datetypecode
--print '@ware_count'
--print @ware_count
--print '@i_datetypecode'
--print @i_datetypecode
		
		if  @ware_count >0 begin
			set @nc_sqlstring = N' select @ware_dateline = linenumber from whcschedule' + convert (varchar (10),@ware_sched) +
					' where scheduledatetype = @i_datetypecode'
--print '@nc_sqlstring where ware_count > 0 '
--print @nc_sqlstring 
			EXEC sp_executesql @nc_sqlstring,
		 		 N'@ware_dateline INT OUTPUT,@i_datetypecode INT', 
		  		@ware_dateline OUTPUT, @i_datetypecode
--print '@ware_dateline'
--print @ware_dateline
--print '@i_datetypecode'
--print @i_datetypecode

		end

      /*  change update of 40 individual columns per schedule to 1 sp_Execute syntax */

		  if  @ware_dateline  > 0  and @ware_dateline < 41 begin

	      BEGIN tran

			  set @nc_sqlstring = N' update whschedule' + convert (varchar (10),@ware_sched) +  ' set estdate' + 
			     convert (varchar (10),@ware_dateline) + '= @estdate, ' + 'actualdate' +
			     convert (varchar (10),@ware_dateline) + '= @actdate, ' +
			    'bestdate' + convert (varchar (10),@ware_dateline) + '= @bestdate, ' +
			    'assignedperson' + convert (varchar (10),@ware_dateline) + '= @c_displayname, ' +
			    'role' + convert (varchar (10),@ware_dateline) + '= @ware_role_long, ' +
			    'duration' + convert (varchar (10),@ware_dateline) + '= @i_duration, ' +
			    'tasknote' + convert (varchar (10),@ware_dateline) + '= @c_tasknote' + 
			    ' where bookkey= @ware_bookkey and printingkey = @ware_printingkey'

--print '@nc_sqlstring where ware_dateline > 0 '
--print @nc_sqlstring 		
		
			  set @nc_sqlparameters = '@ware_bookkey INT, @ware_printingkey INT, @estdate datetime,
				   @actdate datetime,@bestdate datetime,@c_displayname varchar(80), @ware_role_long varchar(40),
				   @i_duration INT,@c_tasknote varchar(255)'

--print '@nc_sqlparameters'
--print @nc_sqlparameters
--
--print '@@ERROR ' + cast(@@ERROR as varchar)
--print '@i_elementtypecode'
--print @i_elementtypecode
--print '@i_datetypecode'
--print @i_datetypecode
--print '@i_duration'
--print @i_duration
--print '@i_roletypecode'
--print @i_roletypecode
--print '@i_contributorkey'
--print @i_contributorkey
--print '@c_displayname'
--print @c_displayname
--print '@estdate ' + isnull(cast(@estdate as varchar),'null')
--print '@actdate ' + isnull(cast(@actdate as varchar),'null')
--print '@bestdate ' + isnull(cast(@bestdate as varchar),'null')

			  EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_bookkey, @ware_printingkey,
 				  @estdate,@actdate,@bestdate,@c_displayname, @ware_role_long,@i_duration,@c_tasknote
	      
--print '------------------------------------------'
  
	      commit tran
	
    		if @@ERROR <> 0 begin
		      BEGIN tran
			    INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
      		    	    errorseverity, errorfunction,lastuserid, lastmaintdate)
			    VALUES (convert(varchar (10), @ware_logkey)  ,convert(varchar (10),@ware_warehousekey),
			      'Unable to insert whschedule' + convert(varchar (10),@ware_sched) + ' table - for book element',
			      ('Warning/data error bookkey '+ convert(varchar (10),@ware_bookkey)),
			      'Stored procedure datawarehouse_webschedule','WARE_STORED_PROC', @ware_system_date)
		      commit tran
		    end
	    end
    end

	  FETCH NEXT FROM warehousesched
	  INTO @v_taqelementkey,@i_elementtypecode,@d_activedate,@d_reviseddate,@i_actualind,
	  @i_datetypecode,@i_duration,@i_roletypecode,@i_contributorkey,
	  @c_displayname,@c_tasknote

	  select @i_schedstatus= @@FETCH_STATUS
  end

  close warehousesched
  deallocate warehousesched

  -- tasks don't need to be tied to elements
  Set @v_cursor_sql='declare noelement_cur cursor for ' + 
                    ' select scheduledatetype, linenumber from whcschedule'+convert (varchar (10),@ware_sched)
                    
  Execute sp_ExecuteSQL @v_cursor_sql
  
  open noelement_cur

  fetch next from noelement_cur into @v_scheduledatetype,@ware_dateline
  select @i_schedstatus= @@FETCH_STATUS
  
  while (@i_schedstatus<>-1 ) begin
	  if (@i_schedstatus<>-2) begin      
		select @ware_count = 0
		set @nc_sqlstring = N' select @ware_count = count(*)
			from whschedule' + cast(@ware_sched as varchar) +
				' where bookkey = ' + cast(@ware_bookkey as varchar) + 
				' and printingkey = ' + cast(@ware_printingkey as varchar) + 
				' and estdate' + cast(@ware_dateline as varchar) + ' is null ' + 
				' and actualdate' + cast(@ware_dateline as varchar) + ' is null ' + 
				' and bestdate' + cast(@ware_dateline as varchar) + ' is null '
--print '@nc_sqlstring '
--print @nc_sqlstring 
		EXEC sp_executesql @nc_sqlstring,
	 	 N'@ware_count INT OUTPUT', 
	  	@ware_count OUTPUT
--print '@ware_count'
--print @ware_count
		
		if @ware_count > 0 begin
		  SET @v_found = 0
			  
		  -- this datetype has not been assigned an element see if there it exists outside of an element
		  select @v_cnt = count(*)
		    from taqprojecttask
		   where bookkey = @ware_bookkey
		     and printingkey = @ware_printingkey
		     and datetypecode = @v_scheduledatetype
		     and COALESCE(taqelementkey,0) = 0
					
		  if @v_cnt = 1 begin
			select @d_activedate = taqprojecttask.activedate, @i_actualind = taqprojecttask.actualind,@d_reviseddate = taqprojecttask.reviseddate,
			       @i_duration = taqprojecttask.duration, @i_roletypecode = taqprojecttask.rolecode, 
                   @i_contributorkey = globalcontact.globalcontactkey, @c_displayname = globalcontact.displayname,  
                   @c_tasknote = taqprojecttask.taqtasknote
              from taqprojecttask 
                 left join globalcontact on taqprojecttask.globalcontactkey = globalcontact.globalcontactkey
             where taqprojecttask.bookkey = @ware_bookkey
	           and taqprojecttask.printingkey = @ware_printingkey
			   and datetypecode = @v_scheduledatetype
			   and COALESCE(taqelementkey,0) = 0			    
			       
  			  SET @v_found = 1			       
		  end			
		  else if @v_cnt > 1 begin
		    -- use the key date (CHANGED)
        -- use the task with the lowest taskkey 8/23/2012 CASE#19299
		    select @v_taqtaskkey = MIN(taqtaskkey)
		      from taqprojecttask
		     where bookkey = @ware_bookkey
		       and printingkey = @ware_printingkey
		       and datetypecode = @v_scheduledatetype
		       and COALESCE(taqelementkey,0) = 0
--	         and keyind = 1  	
		       
			if @v_cnt = 1 begin
				select  @d_activedate = taqprojecttask.activedate, @i_actualind = taqprojecttask.actualind,@d_reviseddate = taqprojecttask.reviseddate,
				        @i_duration = taqprojecttask.duration, @i_roletypecode = taqprojecttask.rolecode, 
					    @i_contributorkey = globalcontact.globalcontactkey, @c_displayname = globalcontact.displayname,  
					    @c_tasknote = taqprojecttask.taqtasknote
                  from taqprojecttask 
                       left join globalcontact on taqprojecttask.globalcontactkey = globalcontact.globalcontactkey
                 where taqprojecttask.bookkey = @ware_bookkey
	               and taqprojecttask.printingkey = @ware_printingkey
			       and datetypecode = @v_scheduledatetype
			       and COALESCE(taqelementkey,0) = 0			    
			       and taqtaskkey = @v_taqtaskkey

    		  SET @v_found = 1			       
			 end
		  end
			  
		  if @v_found = 1 begin
	        SET @actdate = null
	        SET @estdate = null

			-- Case 13381 added a ‘Revised Date’. This date is not editable. Notes from case description:
			-- The Active Date will continue to be the date which is maintained, however, the system will automatically 
			-- set the ‘Revised’ date equal to the active date IF the Actual checkbox is NOT checked. 
			-- In this way, the user will be able to see revised schedule in its entirety, 
			-- showing what the last assumptions were prior to setting the actual date.

			IF @i_actualind = 1 BEGIN
			 ----select @estdate = @d_estimatedate
			 select @actdate = @d_activedate
			 select @estdate = @d_reviseddate
			 ----select @temp_actdate = @d_actualdate
			 ----select @ware_dateline = 0
			END
			ELSE BEGIN
  			 select @estdate = @d_reviseddate
			END

		    SELECT @bestdate = @d_activedate

			if @i_roletypecode is null begin
			    select @i_roletypecode = 0
			end
			if @i_roletypecode > 0 begin
				exec gentables_longdesc 285,@i_roletypecode, @ware_role_long OUTPUT
			end
			else begin	
				select @ware_role_long = ''
			end
			  
	        BEGIN tran

			set @nc_sqlstring = N' update whschedule' + convert (varchar (10),@ware_sched) +  ' set estdate' + 
		       convert (varchar (10),@ware_dateline) + '= @estdate, ' + 'actualdate' +
		       convert (varchar (10),@ware_dateline) + '= @actdate, ' +
		       'bestdate' + convert (varchar (10),@ware_dateline) + '= @bestdate, ' +
			   'assignedperson' + convert (varchar (10),@ware_dateline) + '= @c_displayname, ' +
			   'role' + convert (varchar (10),@ware_dateline) + '= @ware_role_long, ' +
			   'duration' + convert (varchar (10),@ware_dateline) + '= @i_duration, ' +
			   'tasknote' + convert (varchar (10),@ware_dateline) + '= @c_tasknote' + 
			   ' where bookkey= @ware_bookkey and printingkey = @ware_printingkey'

--  print '@nc_sqlstring (update) '
--  print @nc_sqlstring 		
 		
			set @nc_sqlparameters = '@ware_bookkey INT, @ware_printingkey INT, @estdate datetime,
			    @actdate datetime,@bestdate datetime,@c_displayname varchar(80), @ware_role_long varchar(40),
			    @i_duration INT,@c_tasknote varchar(255)'

			EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_bookkey, @ware_printingkey,
 			   @estdate,@actdate,@bestdate,@c_displayname, @ware_role_long,@i_duration,@c_tasknote
	        
	        commit tran
  	
    		if @@ERROR <> 0 begin
				BEGIN tran
			    INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
      		          errorseverity, errorfunction,lastuserid, lastmaintdate)
			      VALUES (convert(varchar (10), @ware_logkey)  ,convert(varchar (10),@ware_warehousekey),
			        'Unable to update whschedule' + convert(varchar (10),@ware_sched) + ' table - for book ',
			        ('Warning/data error bookkey '+ convert(varchar (10),@ware_bookkey)),
			        'Stored procedure datawarehouse_webschedule','WARE_STORED_PROC', @ware_system_date)
		        commit tran
		    end
		end
	 end
    end
    
    fetch next from noelement_cur into @v_scheduledatetype,@ware_dateline
	  select @i_schedstatus= @@FETCH_STATUS
  end
  
  close noelement_cur
  deallocate noelement_cur

GO