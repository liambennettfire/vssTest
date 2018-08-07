IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_categories]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_categories]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_categories]    Script Date: 07/16/2008 10:34:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_categories]
		(@i_copy_projectkey integer,
		@i_copy2_projectkey integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_cleardatagroups_list	varchar(max),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/***************************************************************************************************************************
**  Name: [qproject_copy_project_categories]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/10/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
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
	@v_maxsort  int,
	@v_sortorder  int,
	@v_newprojectitemtype int,
	@v_newprojectusageclass int		

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy categories (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy categories (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
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

select @newkeycount = count(*), @tobecopiedkey = min(q.subjectkey), @v_maxsort = max(sortorder)
from taqprojectsubjectcategory q
WHERE q.categorycode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(q.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass))
AND (COALESCE(q.categorysubcode, 0) = 0 OR q.categorysubcode IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(q.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = q.categorycode))	
AND (COALESCE(q.categorysub2code, 0) = 0 OR q.categorysub2code IN (SELECT datasub2code FROM qutl_get_gentable_itemtype_filtering(q.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = q.categorycode AND datasubcode = q.categorysubcode))	
AND taqprojectkey = @i_copy_projectkey

set @counter = 1
while @counter <= @newkeycount
begin
	exec get_next_key @i_userid, @newkey output

	insert into taqprojectsubjectcategory
			(taqprojectkey, subjectkey, categorytableid, categorycode, categorysubcode, categorysub2code,
			sortorder, lastuserid, lastmaintdate)
	select @i_new_projectkey, @newkey, categorytableid, categorycode, categorysubcode, categorysub2code, 
			sortorder, @i_userid, getdate()	
	from taqprojectsubjectcategory
	where taqprojectkey = @i_copy_projectkey
		and subjectkey = @tobecopiedkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqprojectsubjectcategory failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
		RETURN
	END 

	set @counter = @counter + 1

	select @tobecopiedkey = min(q.subjectkey)
	from taqprojectsubjectcategory q
	WHERE q.categorycode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(q.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass))
	AND (COALESCE(q.categorysubcode, 0) = 0 OR q.categorysubcode IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(q.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = q.categorycode))	
	AND (COALESCE(q.categorysub2code, 0) = 0 OR q.categorysub2code IN (SELECT datasub2code FROM qutl_get_gentable_itemtype_filtering(q.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = q.categorycode AND datasubcode = q.categorysubcode))		
	AND taqprojectkey = @i_copy_projectkey
		and q.subjectkey > @tobecopiedkey
end

/* 5/1/12 - KW - From case 17842:
Categories (6): copy from i_copy_projectkey; add non-existing categories from i_copy2_projectkey */
IF @i_copy2_projectkey > 0
BEGIN
  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(s1.subjectkey)
  FROM taqprojectsubjectcategory s1
  WHERE s1.categorycode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(s1.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass))
  AND (COALESCE(s1.categorysubcode, 0) = 0 OR s1.categorysubcode IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(s1.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = s1.categorycode))	
  AND (COALESCE(s1.categorysub2code, 0) = 0 OR s1.categorysub2code IN (SELECT datasub2code FROM qutl_get_gentable_itemtype_filtering(s1.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = s1.categorycode AND datasubcode = s1.categorysubcode))  	  
  AND s1.taqprojectkey = @i_copy2_projectkey AND
  NOT EXISTS (SELECT * FROM taqprojectsubjectcategory s2 
              WHERE s1.categorytableid = s2.categorytableid AND 
                s1.categorycode = s2.categorycode AND 
                COALESCE(s1.categorysubcode, 0) = COALESCE(s2.categorysubcode, 0) AND
                COALESCE(s1.categorysub2code, 0) = COALESCE(s2.categorysub2code, 0) AND
                s2.taqprojectkey = @i_copy_projectkey)

  SET @counter = 1
  SET @v_sortorder = coalesce(@v_maxsort,0) + 1

  WHILE @counter <= @newkeycount
  BEGIN

	  EXEC get_next_key @i_userid, @newkey OUTPUT

	  INSERT INTO taqprojectsubjectcategory
			  (taqprojectkey, subjectkey, categorytableid, categorycode, categorysubcode, categorysub2code, sortorder, lastuserid, lastmaintdate)
	  SELECT @i_new_projectkey, @newkey, categorytableid, categorycode, categorysubcode, categorysub2code, @v_sortorder, @i_userid, getdate()	
	  FROM taqprojectsubjectcategory
	  WHERE taqprojectkey = @i_copy2_projectkey AND subjectkey = @tobecopiedkey

	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Copy/insert into taqprojectsubjectcategory failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
		  RETURN
	  END 

	  SET @counter = @counter + 1
    SET @v_sortorder = @v_sortorder + 1

    SELECT @tobecopiedkey = MIN(s1.subjectkey)
    FROM taqprojectsubjectcategory s1
	WHERE s1.categorycode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(s1.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass))
    AND (COALESCE(s1.categorysubcode, 0) = 0 OR s1.categorysubcode IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(s1.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = s1.categorycode))	
    AND (COALESCE(s1.categorysub2code, 0) = 0 OR s1.categorysub2code IN (SELECT datasub2code FROM qutl_get_gentable_itemtype_filtering(s1.categorytableid, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = s1.categorycode AND datasubcode = s1.categorysubcode))	     
    AND s1.taqprojectkey = @i_copy2_projectkey AND s1.subjectkey > @tobecopiedkey AND
    NOT EXISTS (SELECT * FROM taqprojectsubjectcategory s2 
                WHERE s1.categorytableid = s2.categorytableid AND 
                  s1.categorycode = s2.categorycode AND 
                  COALESCE(s1.categorysubcode, 0) = COALESCE(s2.categorysubcode, 0) AND
                  COALESCE(s1.categorysub2code, 0) = COALESCE(s2.categorysub2code, 0) AND
                  s2.taqprojectkey = @i_copy_projectkey)

  END
END

RETURN