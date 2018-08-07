if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_reader_iterations_for_contact') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_reader_iterations_for_contact
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_reader_iterations_for_contact
 (@i_userkey     integer = -100,
  @i_contactkey  integer = 0,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qproject_get_reader_iterations_for_contact
**  Desc: This stored procedure returns Reader Iteration Details
**        from taqprojectreaderiteration table for a specific user or contact.         
**
**    Auth: Alan Katzen
**    Date: 19 March 2009
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_contactkey INT,
          @v_rolecode INT,
          @v_filetypecode INT

  IF @i_contactkey = 0 and @i_userkey = -100 BEGIN
    return
  END

  SET @v_contactkey = @i_contactkey
  
  IF @v_contactkey = 0 BEGIN
    SELECT @v_contactkey = COALESCE(globalcontactkey, 0)
      FROM globalcontact
     WHERE userid = @i_userkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing globalcontact: userkey=' + cast(@i_userkey AS VARCHAR)
    END 
  END
  
  IF @v_contactkey > 0 BEGIN
    SELECT @v_rolecode = COALESCE(datacode,0)
      FROM gentables
     WHERE tableid = 285
       and qsicode = 3
       
    IF @v_rolecode is null or @v_rolecode <= 0 BEGIN
      return
    END

    SELECT @v_filetypecode = COALESCE(datacode,0)
      FROM gentables
     WHERE tableid = 354
       and qsicode = 1
      
    SELECT c.projecttitle, c.projectparticipants, 
           dbo.qelement_get_filepath_by_filetype(r.taqelementkey, @v_filetypecode) manuscriptfilepath,
           dbo.qproject_get_misc_value(r.taqprojectkey,9) EditorialReviewMtgMonth,
           dbo.qproject_get_misc_value(r.taqprojectkey,11) EditorialReviewMtgYear,           
           e.taqelementdesc manuscriptiterationdesc, r.*
    FROM taqprojectreaderiteration r, taqprojectelement e, gentables g, coreprojectinfo c
    WHERE r.taqprojectkey = c.projectkey AND
        r.taqelementkey = e.taqelementkey AND
        e.taqelementtypecode = g.datacode AND
        g.tableid = 287 AND 
        g.qsicode = 1 AND --Manuscript
        r.taqprojectcontactrolekey in (SELECT taqprojectcontactrolekey
                                         FROM taqprojectcontact tpc, taqprojectcontactrole tpcr
                                        WHERE tpc.taqprojectkey = tpcr.taqprojectkey
                                          and tpc.taqprojectcontactkey = tpcr.taqprojectcontactkey
                                          and tpcr.rolecode = @v_rolecode
                                          and tpc.globalcontactkey = @v_contactkey) 
         

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing reader info: contactkey=' + cast(@v_contactkey AS VARCHAR) 
    END 
  END
GO
GRANT EXEC ON qproject_get_reader_iterations_for_contact TO PUBLIC
GO


