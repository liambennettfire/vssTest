IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_productnumber]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qproject_copy_project_productnumber]

/****** Object:  StoredProcedure [dbo].[qproject_copy_project_productnumber]    Script Date: 07/16/2008 10:27:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_productnumber]
  (@i_copy_projectkey   integer,
  @i_copy2_projectkey   integer,
  @i_copy_bookkey       integer,
  @i_copy_printingkey   integer,
  @i_new_projectkey     integer,
  @i_new_bookkey        integer,
  @i_new_printingkey    integer,
  @i_copy_elementkey		integer,
  @i_new_elementkey		integer,
  @i_userid				varchar(30),
  @i_cleardatagroups_list	varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/****************************************************************************************************************************
**  Name: [qproject_copy_project_productnumber]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
**
**  7/28/09 - KW - Use same procedure for copy element in projects and in titles.
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/10/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
*****************************************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var	INT,
	@rowcount_var	INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey			int,
	@counter		int,
	@cleardata		char(1),
	@v_maxsort  int,
	@v_sortorder  int,
	@v_newprojectitemtype int,
	@v_newprojectusageclass int		

if (@i_copy_projectkey is null or @i_copy_projectkey = 0) and (@i_copy_bookkey is null or @i_copy_bookkey = 0)
begin
  SET @o_error_code = -1
  SET @o_error_desc = 'copy projectkey/bookkey not passed to copy product# (' + cast(@error_var AS VARCHAR) + ')'
  RETURN
end

if (@i_new_projectkey is null or @i_new_projectkey = 0) and (@i_new_bookkey is null or @i_new_bookkey = 0)
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new projectkey/bookkey not passed to copy product# (' + cast(@error_var AS VARCHAR) + ')'  
	RETURN
end

if @i_copy_elementkey > 0
begin
  if @i_copy_projectkey > 0
	  set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list, 7)
	else
	  set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list, 17)
end
else 
begin
	set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list, 3)
end

-- only want to copy elements types that are defined for the new project
IF (@i_new_projectkey > 0)
BEGIN
  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_new_projectkey

  IF @v_newprojectitemtype is null or @v_newprojectitemtype = 0
  BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Unable to copy elements because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	  RETURN
  END

  IF @v_newprojectusageclass is null 
    SET @v_newprojectusageclass = 0
END

if @i_copy_elementkey > 0
  select @newkeycount = count(*), @tobecopiedkey = min(q.productnumberkey)
  from taqproductnumbers q
  where elementkey = @i_copy_elementkey and
        (COALESCE(q.productidcode, 0) = 0 OR q.productidcode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass)))  
else
  select @newkeycount = count(*), @tobecopiedkey = min(q.productnumberkey), @v_maxsort = max(sortorder)
  from taqproductnumbers q
  where taqprojectkey = @i_copy_projectkey AND COALESCE(elementkey,0) = 0 AND
        (COALESCE(q.productidcode, 0) = 0 OR q.productidcode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass)))   

set @counter = 1
while @counter <= @newkeycount
begin
	exec get_next_key @i_userid, @newkey output

  if @i_copy_elementkey > 0
    insert into taqproductnumbers  
      (productnumberkey, taqprojectkey, elementkey, productidcode, prefixcode, 
      productnumber, sortorder, lastuserid, lastmaintdate)
    select @newkey, @i_new_projectkey, @i_new_elementkey, productidcode, 
	CASE
	  WHEN (COALESCE(prefixcode, 0) = 0 OR prefixcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(594, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = productidcode))
	  THEN NULL 
	  ELSE prefixcode		  
	END as prefixcode,      
      CASE WHEN @cleardata = 'Y' THEN NULL ELSE productnumber END, 
      sortorder, @i_userid, getdate()
    from taqproductnumbers
    where elementkey = @i_copy_elementkey and productnumberkey = @tobecopiedkey
  else
    insert into taqproductnumbers  
      (productnumberkey, taqprojectkey, elementkey, productidcode, prefixcode, 
      productnumber, sortorder, lastuserid, lastmaintdate)
    select @newkey, @i_new_projectkey, @i_new_elementkey, productidcode, 
	  CASE
		WHEN (COALESCE(prefixcode, 0) = 0 OR prefixcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(594, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = productidcode))
		THEN NULL 
		ELSE prefixcode		  
	  END as prefixcode,  
      CASE WHEN @cleardata = 'Y' THEN NULL ELSE productnumber END, 
      sortorder, @i_userid, getdate()
    from taqproductnumbers
    where taqprojectkey = @i_copy_projectkey and productnumberkey = @tobecopiedkey
  
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqproductnumbers failed (' + cast(@error_var AS VARCHAR) + '): productnumberkey = ' + cast(@tobecopiedkey AS VARCHAR)   
		RETURN
	END 

	set @counter = @counter + 1

  if @i_copy_elementkey > 0
	  select @tobecopiedkey = min(q.productnumberkey)
	  from taqproductnumbers q
	  where elementkey = @i_copy_elementkey and q.productnumberkey > @tobecopiedkey AND
        (COALESCE(q.productidcode, 0) = 0 OR q.productidcode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass))) 	  
  else
	  select @tobecopiedkey = min(q.productnumberkey)
	  from taqproductnumbers q
	  where taqprojectkey = @i_copy_projectkey and q.productnumberkey > @tobecopiedkey AND COALESCE(elementkey,0) = 0 AND
        (COALESCE(q.productidcode, 0) = 0 OR q.productidcode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass))) 	  
end

/* 3/6/12 - KW - From case 17842:
Product Number (3): copy from i_copy_projectkey; add non-existing prod ids from i_copy2_projectkey */
IF @i_copy_elementkey > 0
  RETURN
  
ELSE IF @i_copy_projectkey > 0 AND @i_copy2_projectkey > 0
BEGIN

  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q1.productnumberkey)
  FROM taqproductnumbers q1
  WHERE q1.taqprojectkey = @i_copy2_projectkey AND
    (COALESCE(q1.productidcode, 0) = 0 OR q1.productidcode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass))) AND 
    COALESCE(elementkey,0) = 0 AND   
    NOT EXISTS (SELECT * FROM taqproductnumbers q2 
                WHERE q1.productidcode = q2.productidcode AND q2.taqprojectkey = @i_copy_projectkey AND COALESCE(elementkey,0) = 0)

  SET @v_sortorder = @v_maxsort + 1
  SET @counter = 1
  
  WHILE @counter <= @newkeycount
  BEGIN
    EXEC get_next_key @i_userid, @newkey OUTPUT

    INSERT INTO taqproductnumbers  
      (productnumberkey, taqprojectkey, elementkey, productidcode, prefixcode, 
      productnumber, sortorder, lastuserid, lastmaintdate)
    SELECT 
      @newkey, @i_new_projectkey, @i_new_elementkey, productidcode, 
	  CASE
		WHEN (COALESCE(prefixcode, 0) = 0 OR prefixcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(594, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = productidcode))
		THEN NULL 
		ELSE prefixcode		  
	  END as prefixcode, 
      CASE WHEN @cleardata = 'Y' THEN NULL ELSE productnumber END, @v_sortorder, @i_userid, getdate()
    FROM taqproductnumbers
    WHERE taqprojectkey = @i_copy2_projectkey AND productnumberkey = @tobecopiedkey AND COALESCE(elementkey,0) = 0

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'copy/insert into taqproductnumbers failed (' + cast(@error_var AS VARCHAR) + '): productnumberkey = ' + cast(@tobecopiedkey AS VARCHAR)   
      RETURN
    END 

    SET @counter = @counter + 1
    SET @v_sortorder = @v_sortorder + 1
    
    SELECT @tobecopiedkey = MIN(q1.productnumberkey)
    FROM taqproductnumbers q1
    WHERE q1.taqprojectkey = @i_copy2_projectkey AND q1.productnumberkey > @tobecopiedkey AND
      (COALESCE(q1.productidcode, 0) = 0 OR q1.productidcode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass))) AND    
      NOT EXISTS (SELECT * FROM taqproductnumbers q2 
                  WHERE q1.productidcode = q2.productidcode AND q2.taqprojectkey = @i_copy_projectkey AND COALESCE(elementkey,0) = 0)
  END  
END

RETURN

