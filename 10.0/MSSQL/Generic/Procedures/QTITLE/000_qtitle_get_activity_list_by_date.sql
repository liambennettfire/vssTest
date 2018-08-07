if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_activity_list_by_date') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_activity_list_by_date
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_activity_list_by_date
 (@i_bookkey              integer,
  @i_taskviewkey          integer,
  @i_all_assets_for_work  integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_activity_list_by_date
**  Desc: This stored procedure returns asset activity for a title or work.
**        If @i_all_assets_for_work = 1, return all activities for the work
**        otherwise return all activities for the title
** 
**    Auth: Alan Katzen
**    Date: 20 August 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var     INT,
          @rowcount_var  INT,
          @v_workkey     INT,
          @v_taskviewkey INT,
          @v_sqlstring   NVARCHAR(max),
          @v_alldatetypesind INT


  SET @v_taskviewkey = -1
  SET @v_alldatetypesind = 0
  IF @i_taskviewkey > 0 BEGIN
    SET @v_taskviewkey = @i_taskviewkey
    
    SELECT @v_alldatetypesind = alldatetypesind
      FROM taskview
     WHERE taskviewkey = @v_taskviewkey
     
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing taskview: taskviewkey = ' + cast(@v_taskviewkey AS VARCHAR)  
    END  
  END
  IF @v_alldatetypesind is null BEGIN
    SET @v_alldatetypesind = 0
  END
  
  SET @v_workkey = 0
  IF @i_all_assets_for_work = 1 BEGIN
    SELECT @v_workkey = workkey
      FROM coretitleinfo
     WHERE bookkey = @i_bookkey
     
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error getting workkey: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
    END 
  END   

  SET @v_sqlstring = ''
  
  IF @v_workkey > 0 BEGIN
    SET @v_sqlstring = '
    SELECT tpt.*, tpe.taqelementdesc assetdesc, tpe.taqelementtypecode, c.productnumber, 
           dbo.qproject_get_dateype_label(tpt.datetypecode) taskdesc,
           dbo.qcontact_get_displayname(tpt.globalcontactkey) contact1name,                      
           dbo.qcontact_get_displayname(tpt.globalcontactkey2) contact2name,                      
           taqtasknote noteserrormsg     
      FROM taqprojecttask tpt, taqprojectelement tpe, coretitleinfo c
     WHERE tpt.taqelementkey = tpe.taqelementkey
       AND tpe.bookkey = c.bookkey
       AND tpe.printingkey = c.printingkey
       AND tpe.printingkey = 1
       AND c.workkey = ' + cast(@v_workkey AS VARCHAR) + 
       ' AND tpe.taqelementtypecode in (select datacode from gentables where tableid = 287 and gen1ind = 1)'       
  END
  ELSE BEGIN
    SET @v_sqlstring = '
    SELECT tpt.*, tpe.taqelementdesc assetdesc, tpe.taqelementtypecode, c.productnumber, 
           dbo.qproject_get_dateype_label(tpt.datetypecode) taskdesc,
           dbo.qcontact_get_displayname(tpt.globalcontactkey) contact1name,                      
           dbo.qcontact_get_displayname(tpt.globalcontactkey2) contact2name,                      
           taqtasknote noteserrormsg     
      FROM taqprojecttask tpt, taqprojectelement tpe, coretitleinfo c
     WHERE tpt.taqelementkey = tpe.taqelementkey
       AND tpe.bookkey = c.bookkey
       AND tpe.printingkey = c.printingkey
       AND tpe.printingkey = 1
       AND tpe.bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
       ' AND tpe.taqelementtypecode in (select datacode from gentables where tableid = 287 and gen1ind = 1)'       
  END
  
  IF @v_taskviewkey > 0 AND @v_alldatetypesind <= 0 BEGIN
    SET @v_sqlstring = @v_sqlstring + ' AND tpt.datetypecode in (select datetypecode from taskviewdatetype where taskviewkey = ' +  cast(@v_taskviewkey AS VARCHAR) + ')'
  END
  
  EXECUTE sp_executesql @v_sqlstring

  PRINT @v_sqlstring
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojecttask: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_activity_list_by_date TO PUBLIC
GO



