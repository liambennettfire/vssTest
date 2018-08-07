IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_scale_details]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_scale_details]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_scale_details]    Script Date: 07/16/2008 10:28:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qproject_copy_project_scale_details]
		(@i_copy_projectkey     integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_cleardatagroups_list	varchar(max),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/****************************************************************************************************************************
**  Name: [qproject_copy_project_scale_details]
**  Desc: This stored procedure copies the scale details from one scale to another.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Alan Katzen
**    Date: 6 March 2012
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/12/2016   Uday			   Case 37359 Allow "Copy from Project" to be a different class from project being created
**    06/06/2017   Uday			   Case 45444 
*****************************************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
	@rowcount_var INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey	int,
	@counter		int,
	@newkeycount2	int,
	@tobecopiedkey2	int,
	@newkey2		int,
	@counter2		int,
	@cleardata		char(1),
	@v_copy_rowkey int, 
	@v_copy_columnkey int,
	@v_new_rowkey int, 
	@v_new_columnkey int,
	@v_copied_rowkey	int,
	@v_copied_columnkey	int,
	@v_added_rowkey	int,
	@v_added_columnkey	int,
    @v_newprojectitemtype	INT,
    @v_newprojectusageclass	INT 	

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy scale details.'   
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy scale details (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

-- only want to copy items types that are defined for the new project
IF (@i_new_projectkey > 0)
BEGIN
  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_new_projectkey

  IF @v_newprojectitemtype is null or @v_newprojectusageclass = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy elements because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
    RETURN
  END
  
  IF @v_newprojectusageclass is null 
    SET @v_newprojectusageclass = 0
END 

DECLARE @added_rowkeys TABLE
(
	copiedrowkey	int,
	addedrowkey		int
)

DECLARE @added_columnkeys	TABLE
(
	copiedcolumnkey	int,
	addedcolumnkey	int
)

set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list,20)

select @newkeycount = count(*), @tobecopiedkey = min(q.taqdetailscalekey)
from taqprojectscaledetails q
where taqprojectkey = @i_copy_projectkey

set @counter = 1
while @counter <= @newkeycount
begin
  -- copy associated taqprojectscalerowvalues and taqprojectscalecolumnvalues
  select @v_copy_rowkey = rowkey, @v_copy_columnkey = columnkey
	from taqprojectscaledetails
	where taqprojectkey = @i_copy_projectkey
		and taqdetailscalekey = @tobecopiedkey
	
	if (@v_copy_rowkey IS NOT NULL)
	BEGIN
		SET @v_copied_rowkey = NULL
		
		select @v_copied_rowkey = copiedrowkey, @v_added_rowkey = addedrowkey
		from @added_rowkeys
		where copiedrowkey=@v_copy_rowkey
		
		if @v_copied_rowkey IS NULL
		begin
			exec get_next_key @i_userid, @v_new_rowkey output
			
			insert into taqprojectscalerowvalues
				(taqscalerowkey,taqprojectkey,scaletabkey,rowvalue1,rowvalue2,lastuserid,lastmaintdate)
			select @v_new_rowkey,@i_new_projectkey,scaletabkey,rowvalue1,rowvalue2,@i_userid, getdate()
			from taqprojectscalerowvalues
			where taqprojectkey = @i_copy_projectkey
				and taqscalerowkey = @v_copy_rowkey

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'copy/insert into taqprojectscalerowvalues failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR) +
														' and rowkey = ' + cast(@v_copy_rowkey AS VARCHAR) 
				RETURN
			END
			
			insert into @added_rowkeys
			values (@v_copy_rowkey, @v_new_rowkey)
		end
		else begin
			SET @v_new_rowkey = @v_added_rowkey
		end
  END
  ELSE BEGIN
		SET @v_new_rowkey = NULL
  END

	if (@v_copy_columnkey IS NOT NULL)
	BEGIN
		SET @v_copied_columnkey = NULL
		
		select @v_copied_columnkey = copiedcolumnkey, @v_added_columnkey = addedcolumnkey
		from @added_columnkeys
		where copiedcolumnkey=@v_copy_columnkey
		
		if @v_copied_columnkey IS NULL
		begin
			exec get_next_key @i_userid, @v_new_columnkey output

			insert into taqprojectscalecolumnvalues
				(taqscalecolumnkey,taqprojectkey,scaletabkey,columnvalue1,columnvalue2,lastuserid,lastmaintdate)
			select @v_new_columnkey,@i_new_projectkey,scaletabkey,columnvalue1,columnvalue2,@i_userid, getdate()
			from taqprojectscalecolumnvalues
			where taqprojectkey = @i_copy_projectkey
				and taqscalecolumnkey = @v_copy_columnkey

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'copy/insert into taqprojectscalecolumnvalues failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR) +
														' and columnkey = ' + cast(@v_copy_columnkey AS VARCHAR) 
				RETURN
			END
			
			insert into @added_columnkeys
			values (@v_copy_columnkey, @v_new_columnkey)
		end
		else begin
			SET @v_new_columnkey = @v_added_columnkey
		end
  END
  ELSE BEGIN
		SET @v_new_columnkey = NULL
  END

	exec get_next_key @i_userid, @newkey output

	insert into taqprojectscaledetails
		(taqdetailscalekey, taqprojectkey, rowkey, columnkey, itemcategorycode, 
		itemcode, itemdetailcode, autoapplyind, fixedchargecode, calculationtypecode, 
		thresholdspeccategorycode,thresholdspecitemcode,thresholdvalue1,thresholdvalue2,
		chargecode,fixedamount,amount,lastuserid, lastmaintdate, description)
	select @newkey, @i_new_projectkey, @v_new_rowkey, @v_new_columnkey, 
		CASE
			WHEN (COALESCE(itemcategorycode, 0) = 0 OR itemcategorycode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(616, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE itemcategorycode
		END as itemcategorycode, 
		CASE
			WHEN (COALESCE(itemcode, 0) = 0 OR itemcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(616, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = itemcategorycode))
			THEN NULL 
			ELSE itemcode
		END as itemcode,	
		CASE
			WHEN (COALESCE(itemcode, 0) = 0 OR itemcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(616, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = itemcategorycode AND datasubcode  = itemcode))
			THEN NULL 
			ELSE itemdetailcode
		END as itemdetailcode,				
		autoapplyind, fixedchargecode, 
		CASE
			WHEN (COALESCE(calculationtypecode, 0) = 0 OR calculationtypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(627, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE calculationtypecode
		END as calculationtypecode,		
		CASE
			WHEN (COALESCE(thresholdspeccategorycode, 0) = 0 OR thresholdspeccategorycode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(616, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE thresholdspeccategorycode
		END as thresholdspeccategorycode,
		CASE
			WHEN (COALESCE(thresholdspecitemcode, 0) = 0 OR thresholdspecitemcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(616, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = thresholdspeccategorycode))
			THEN NULL 
			ELSE thresholdspecitemcode
		END as thresholdspecitemcode,			 		
		thresholdvalue1,thresholdvalue2,chargecode,
		case 
			when @cleardata = 'Y' then null
			else fixedamount
		end, 
		case 
			when @cleardata = 'Y' then null
			else amount
		end, 
		@i_userid, getdate(), description
	from taqprojectscaledetails
	where taqprojectkey = @i_copy_projectkey
		and taqdetailscalekey = @tobecopiedkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqprojectdetails failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
		RETURN
	END 

	set @counter = @counter + 1

	select @tobecopiedkey = min(q.taqdetailscalekey)
	from taqprojectscaledetails q
	where taqprojectkey = @i_copy_projectkey
		and q.taqdetailscalekey > @tobecopiedkey
end

RETURN


