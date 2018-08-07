/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_driver]    Script Date: 11/19/2010 16:49:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_driver]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_driver]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_driver] 
	@update_mode	char(1),		--'A' to update all fields, populated or blank in PSS, 'B' to update only blank fields in PSS
	@userid			varchar(30) = 'sapimport'	--allow value to be passed, set to sapimport if not passed

AS
BEGIN


declare     @v_error  INT,
	@v_rowcount INT,
	@minbookkey			int,
	@minrowid			int,
	@numrows			int,
	@counter			int,
	@o_error_code   integer ,
	@o_error_desc   varchar(2000),
	@qsibatchkey		int,
	@qsijobkey			int,
	@count				int


SET @o_error_code = 0	
SET @o_error_desc = ''  

SET NOCOUNT ON

set @qsibatchkey = null
set @qsijobkey = null

select @count = count(*)
from qsijob q
where jobtypecode = 3
and statuscode = 1

if @count > 0 begin
	exec write_qsijobmessage @qsibatchkey output, @qsijobkey output, 3,0,null,null,'QSIADMIN',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output
	if @o_error_code = 1 begin
		set @o_error_code = 0
	end
	set @o_error_code = -1
	set @o_error_desc = 'There is a qsijob record indicating this job is running.  Job will not run again until previous job completes or qsijob record is cleaned up.  (jobtypecode = 3, statuscode = 3)'
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,0,null,null,'QSIADMIN',0,0,0,5,@o_error_desc,'error',@o_error_code output, @o_error_desc output
	RETURN
end

exec write_qsijobmessage @qsibatchkey output, @qsijobkey output, 3,0,null,null,'QSIADMIN',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output
if @o_error_code = 1 begin
	set @o_error_code = 0
end

create table #tmp_bookkeys
(bookkey		int		not null,
row_id			int		not null)

insert into #tmp_bookkeys
select distinct convert(int, bookkey), row_id
from hmco_import_into_pss
where is_processed = 'N' 
or is_processed is null

select @minrowid = min(row_id), @numrows = count(distinct row_id)
from #tmp_bookkeys 

if @numrows is null or @numrows = 0
begin
	SET @o_error_desc = 'There are no changes to process.'
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,0,null,null,'QSIADMIN',0,0,0,6,'job completed - There are no changes to process','completed',@o_error_code output, @o_error_desc output
	RETURN
end

set @counter = 1

while @counter <= @numrows
begin
	select @minbookkey = bookkey
	from #tmp_bookkeys 
	where row_id = @minrowid

	exec hmco_import_from_SAP_detail @minbookkey, @minrowid, @update_mode, @userid, @o_error_code output, @o_error_desc output

	set @v_error = @@ERROR

	IF @o_error_code = -2 BEGIN		--error code if record was not written for bookkey, write msg and continue with other bookkeys

		update hmco_import_into_pss
		set comments = convert(varchar(30),getdate(),21) + ': ' + @o_error_desc
		where bookkey = @minbookkey
		and row_id = @minrowid

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 or @v_rowcount = 0 BEGIN 
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update the import comment for this bookkey.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,0,null,null,'QSIADMIN',@minbookkey,@minrowid,0,4,@o_error_desc,null,@o_error_code output, @o_error_desc output

	end

	IF @o_error_code = -1 BEGIN
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,0,null,null,'QSIADMIN',@minbookkey,@minrowid,0,5,@o_error_desc,null,@o_error_code output, @o_error_desc output

		RETURN
	END    

	IF @v_error <> 0 BEGIN
		set @o_error_code = -1
		set @o_error_desc = 'Error executing import from sap detail procedure.  Error #' + cast(@v_error as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,0,null,null,'QSIADMIN',@minbookkey,@minrowid,0,5,@o_error_desc,null,@o_error_code output, @o_error_desc output
		RETURN
	END    

	select @minrowid = min(row_id)
	from #tmp_bookkeys
	where row_id > @minrowid

	set @counter = @counter + 1
end

exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,0,null,null,'QSIADMIN',0,0,0,6,'job completed','completed',@o_error_code output, @o_error_desc output

END


