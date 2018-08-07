IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_comments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_comments]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_comments]    Script Date: 07/16/2008 10:33:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_comments]
  (@i_copy_projectkey	integer,
  @i_copy2_projectkey	integer,
  @i_new_projectkey		integer,
  @i_userid				varchar(30),
  @i_cleardatagroups_list	varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_comments]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
******************************************************************************************
**  Change History
******************************************************************************************
**  Date:      Author:   Description:
**  -----      ------    -------------------------------------------
**  04/29/16   Colman    Case 37802: Problem with duplicate comment types in source and target projects
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
	@rowcount_var INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey	int,
	@counter		int,
	@itemtype int,
	@usageclass int,
	@v_cnt int,
	@commenttypecode int,
	@commenttypesubcode int,
	@v_maxsort  int,
	@v_sortorder  int	


if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy related projects'
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy related projects: taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

-- only want to copy comments for comment types that are defined for the new project
select @itemtype = searchitemcode, @usageclass = usageclasscode
from taqproject
where taqprojectkey = @i_new_projectkey

if @itemtype is null or @itemtype = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to copy comments because item type is not populated: taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @usageclass is null 
begin
  set @usageclass = 0
end

-- Delete any target project comments that are of the same type as those on the source and link to a 
-- qsicomment with a null commenthtml so they will be overwritten
delete from taqprojectcomments where commentkey in (
  select q.commentkey from qsicomments q
  join taqprojectcomments t on q.commentkey = t.commentkey
  where taqprojectkey = @i_new_projectkey and q.commenthtml is null
    and exists (
      select * from taqprojectcomments tt join qsicomments qq on qq.commentkey = tt.commentkey 
      where tt.taqprojectkey = @i_copy_projectkey and tt.commenttypecode = t.commenttypecode and tt.commenttypesubcode = t.commenttypesubcode
    )
)

-- Select count and first key of comments in source project with a type that does not already exist on the target project
select @newkeycount = count(*), @tobecopiedkey = min(q1.commentkey), @v_maxsort = max(sortorder)
from qsicomments q1
join taqprojectcomments t1 on q1.commentkey = t1.commentkey
where taqprojectkey = @i_copy_projectkey 
and not exists (
  select * from taqprojectcomments t2 join qsicomments q2 on q2.commentkey = t1.commentkey 
  where t2.taqprojectkey = @i_new_projectkey and t2.commenttypecode = t1.commenttypecode and t2.commenttypesubcode = t1.commenttypesubcode
)

set @counter = 1
while @counter <= @newkeycount
begin
  select @commenttypecode = commenttypecode, @commenttypesubcode = commenttypesubcode
    from taqprojectcomments 
   where commentkey = @tobecopiedkey

  -- verify if comment type is allowed for itemtype/usageclass
  select @v_cnt = count(*)
    from gentablesitemtype
   where tableid = 284
     and datacode = @commenttypecode
     and datasubcode = @commenttypesubcode
     and itemtypecode = @itemtype
     and itemtypesubcode in (@usageclass,0)

  if @v_cnt > 0 begin
	  exec get_next_key @i_userid, @newkey output

	  insert into qsicomments
		  (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
		  commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
	  select @newkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
		   commenthtml, commenthtmllite, @i_userid, getdate(), invalidhtmlind, releasetoeloquenceind
	  from qsicomments
	  where commentkey = @tobecopiedkey

	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'copy/insert into qsicomments failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
		  RETURN
	  END 

	  insert into taqprojectcomments
		  (taqprojectkey, commenttypecode, commenttypesubcode, commentkey, sortorder, lastuserid, lastmaintdate)
	  select @i_new_projectkey, commenttypecode, commenttypesubcode, @newkey, sortorder, @i_userid, getdate()
	  from taqprojectcomments
	  where taqprojectkey = @i_copy_projectkey
		  and commentkey = @tobecopiedkey

	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'copy/insert into taqprojectcomments failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
		  RETURN
	  END 
  end
  
	set @counter = @counter + 1

  -- Select next key of comment in source project with a type that does not already exist on the target project
	select @tobecopiedkey = min(q1.commentkey)
	from qsicomments q1
	join taqprojectcomments t1	on q1.commentkey = t1.commentkey
	where taqprojectkey = @i_copy_projectkey and q1.commentkey > @tobecopiedkey
  and not exists (
    select * from taqprojectcomments t2 join qsicomments q2 on q2.commentkey = t2.commentkey 
    where t2.taqprojectkey = @i_new_projectkey and t2.commenttypecode = t1.commenttypecode and t2.commenttypesubcode = t1.commenttypesubcode
  )
end


/* 4/30/12 - KW - From case 17842:
Comments (5):  copy from i_copy_projectkey; add non-existing comment types/subtypes from i_copy2_projectkey */
IF @i_copy2_projectkey > 0
BEGIN
  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q.commentkey)
  FROM qsicomments q 
    JOIN taqprojectcomments t1 ON q.commentkey = t1.commentkey
  WHERE t1.taqprojectkey = @i_copy2_projectkey AND
  NOT EXISTS (SELECT * FROM taqprojectcomments t2 
              WHERE t1.commenttypecode = t2.commenttypecode AND 
                t1.commenttypesubcode = t2.commenttypesubcode AND 
                t2.taqprojectkey = @i_copy_projectkey)

  SET @counter = 1
  SET @v_sortorder = @v_maxsort + 1

  WHILE @counter <= @newkeycount
  BEGIN
    SELECT @commenttypecode = commenttypecode, @commenttypesubcode = commenttypesubcode
    FROM taqprojectcomments 
    WHERE commentkey = @tobecopiedkey

    -- verify if comment type is allowed for itemtype/usageclass
    SELECT @v_cnt = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 284 AND
      datacode = @commenttypecode AND
      datasubcode = @commenttypesubcode AND
      itemtypecode = @itemtype AND
      itemtypesubcode IN (@usageclass,0)

    IF @v_cnt > 0 
    BEGIN
	    EXEC get_next_key @i_userid, @newkey OUTPUT

	    INSERT INTO qsicomments
		    (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
		    commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
	    SELECT @newkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
		     commenthtml, commenthtmllite, @i_userid, getdate(), invalidhtmlind, releasetoeloquenceind
	    FROM qsicomments
	    WHERE commentkey = @tobecopiedkey

	    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	    IF @error_var <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'Copy/insert into qsicomments failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
		    RETURN
	    END 

	    INSERT INTO taqprojectcomments
		    (taqprojectkey, commenttypecode, commenttypesubcode, commentkey, sortorder, lastuserid, lastmaintdate)
	    SELECT @i_new_projectkey, commenttypecode, commenttypesubcode, @newkey, @v_sortorder, @i_userid, getdate()
	    FROM taqprojectcomments
	    WHERE taqprojectkey = @i_copy_projectkey AND commentkey = @tobecopiedkey

	    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	    IF @error_var <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'Copy/insert into taqprojectcomments failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
		    RETURN
	    END 
    END
    
	  SET @counter = @counter + 1
    SET @v_sortorder = @v_sortorder + 1
  	
    SELECT @tobecopiedkey = MIN(q.commentkey)
    FROM qsicomments q 
      JOIN taqprojectcomments t1 ON q.commentkey = t1.commentkey	
    WHERE t1.taqprojectkey = @i_copy2_projectkey AND q.commentkey > @tobecopiedkey AND
      NOT EXISTS (SELECT * FROM taqprojectcomments t2 
                  WHERE t1.commenttypecode = t2.commenttypecode AND 
                    t1.commenttypesubcode = t2.commenttypesubcode AND 
                    t2.taqprojectkey = @i_copy_projectkey)
  END
END

RETURN
