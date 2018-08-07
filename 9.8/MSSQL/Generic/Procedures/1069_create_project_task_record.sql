SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.create_project_task_record') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.create_project_task_record 
end
go

/***********************************************************************************************************************
**  Name: [create_project_task_record]
**  Desc: 
**
**    Auth: 
**    Date: 
**
**  01/26/17  Uday      38699     Copy Printing Info When Creating a Transmittal Project
**  07/02/18  Colman    TM-570
***********************************************************************************************************************/

create PROCEDURE dbo.create_project_task_record 
@v_Task_externalid varchar(30), 
@v_projectimportkey int,
@v_taqkeyind tinyint,
@v_new_projectkey int,
@v_Task_date datetime,
@v_task_actualind tinyint,
@v_Taqtaskkey int,
@v_sort_order int output,
@v_processerrormessage varchar(255) output,
@v_cnt int output 
												
AS
declare 
@v_datetype int,
@v_newprojectitemtype   INT,
@v_newprojectusageclass	INT,
@v_itemtypecode_printing INT,
@v_usageclasscode_printing INT,
@v_itemtypecode_copyproject INT,
@v_usageclasscode_copyproject INT,
@v_isPrinting INT,
@v_new_bookkey INT, 
@v_new_printingkey INT	

		SELECT @v_itemtypecode_printing = datacode, @v_usageclasscode_printing = datasubcode 
		FROM subgentables
		WHERE tableid = 550 AND qsicode = 40

	    SET @v_isPrinting = 0  

		IF (@v_new_projectkey > 0)
		BEGIN
		  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
		  FROM taqproject
		  WHERE taqprojectkey = @v_new_projectkey
  
		  IF @v_newprojectusageclass is null 
			SET @v_newprojectusageclass = 0

		  IF @v_itemtypecode_printing = @v_newprojectitemtype AND @v_usageclasscode_printing = @v_newprojectusageclass BEGIN
			SET @v_new_projectkey = NULL
			SET @v_isPrinting = 1
			SELECT @v_new_bookkey = bookkey, @v_new_printingkey = printingkey  FROM taqprojectprinting_view WHERE taqprojectkey = @v_new_projectkey
		  END
		END

		if @v_Task_externalid is not null begin
			select @v_cnt = count(*)
			from datetype
			where externalcode = @v_Task_externalid
			
			if @v_cnt = 0 begin	
				set @v_processerrormessage = @v_processerrormessage + ' Task could not be found with external code ' + @v_Task_externalid
				update project_import
				set processerrormessage = @v_processerrormessage
				where projectimportkey = @v_projectimportkey 
			end else begin
				select @v_datetype = datetypecode, @v_taqkeyind = taqkeyind
				from datetype
				where externalcode = @v_Task_externalid

				IF @v_isPrinting = 0 BEGIN
					select @v_cnt = count(*)
					from taqprojecttask
					where taqprojectkey = @v_new_projectkey
					and datetypecode = @v_datetype

					if @v_cnt = 1 begin
						update taqprojecttask
						set activedate = @v_Task_date, originaldate = case when originaldate is null then @v_Task_date end,
							actualind = @v_task_actualind
						where taqprojectkey = @v_new_projectkey
					end
					if @v_cnt > 1 begin
						set @v_processerrormessage = @v_processerrormessage + ' Warning:  Could not update task for ' + cast(@v_datetype as varchar) + ' because multiple records exist for this date type'
						update project_import
						set processerrormessage = @v_processerrormessage
						where projectimportkey = @v_projectimportkey 
					end
					if @v_cnt = 0 begin
						exec get_next_key 'taqprojecttask', @v_Taqtaskkey output
						insert into taqprojecttask(Taqtaskkey, Taqprojectkey, Datetypecode, Activedate, actualind, Keyind, originaldate,
									Sortorder, Lastmaintdate, lastuserid)
						values(@v_Taqtaskkey, @v_new_projectkey, @v_datetype, @v_Task_date, @v_task_actualind, @v_taqkeyind, @v_Task_date,
								@v_sort_order, getdate(), 'impot')
					end
				END
				ELSE IF @v_isPrinting = 1 BEGIN
					select @v_cnt = count(*)
					from taqprojecttask
					where bookkey = @v_new_bookkey AND printingkey = @v_new_printingkey
					and datetypecode = @v_datetype

					if @v_cnt = 1 begin
						update taqprojecttask
						set activedate = @v_Task_date, originaldate = case when originaldate is null then @v_Task_date end,
							actualind = @v_task_actualind
						where bookkey = @v_new_bookkey AND printingkey = @v_new_printingkey
					end
					if @v_cnt > 1 begin
						set @v_processerrormessage = @v_processerrormessage + ' Warning:  Could not update task for ' + cast(@v_datetype as varchar) + ' because multiple records exist for this date type'
						update project_import
						set processerrormessage = @v_processerrormessage
						where projectimportkey = @v_projectimportkey 
					end
					if @v_cnt = 0 begin
						exec get_next_key 'taqprojecttask', @v_Taqtaskkey output
						insert into taqprojecttask(Taqtaskkey, bookkey, printingkey, Datetypecode, Activedate, actualind, Keyind, originaldate,
									Sortorder, Lastmaintdate, lastuserid)
						values(@v_Taqtaskkey, @v_new_bookkey, @v_new_printingkey, @v_datetype, @v_Task_date, @v_task_actualind, @v_taqkeyind, @v_Task_date,
								@v_sort_order, getdate(), 'impot')
					end
				END
			end
		end
