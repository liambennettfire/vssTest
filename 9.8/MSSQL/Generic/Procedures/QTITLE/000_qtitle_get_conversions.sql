if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_conversions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_conversions
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_conversions
 (@i_bookkey              integer,
  @i_all_assets_for_work  integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_conversions
**  Desc: This stored procedure returns conversions for a title or work.
**        If @i_all_assets_for_work = 1, return all conversions for the work
**        otherwise return all conversions for the title
** 
**    Auth: Alan Katzen
**    Date: 19 August 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_workkey    INT
            
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

  IF @v_workkey > 0 BEGIN
    SELECT distinct c.*, 
           (SELECT taqelementdesc FROM taqprojectelement  
             WHERE taqelementkey = c.sourceassetkey) sourceassetdesc,
           (SELECT taqelementtypecode FROM taqprojectelement  
             WHERE taqelementkey = c.sourceassetkey) sourceassettype,
           (SELECT taqelementdesc FROM taqprojectelement  
             WHERE taqelementkey = c.targetassetkey) targetassetdesc,
           (SELECT taqelementtypecode FROM taqprojectelement  
             WHERE taqelementkey = c.targetassetkey) targetassettype,
           (SELECT productnumber FROM taqprojectelement tpe, coretitleinfo ct 
             WHERE tpe.taqelementkey = c.sourceassetkey
               AND tpe.bookkey = ct.bookkey
               AND tpe.printingkey = ct.printingkey
               AND tpe.printingkey = 1) sourceproductnumber,
           (SELECT productnumber FROM taqprojectelement tpe, coretitleinfo ct 
             WHERE tpe.taqelementkey = c.targetassetkey
               AND tpe.bookkey = ct.bookkey
               AND tpe.printingkey = ct.printingkey
               AND tpe.printingkey = 1) targetproductnumber,
           dbo.get_gentables_desc(579,c.statuscode,'long') statusdesc,
           dbo.qcontact_get_displayname(c.converter) conversionhousename,
           CASE
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) <> '' 
               THEN ltrim(rtrim(COALESCE(notes,''))) + ' / ' + ltrim(rtrim(COALESCE(errormessage,'')))
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) = '' 
               THEN ltrim(rtrim(COALESCE(notes,'')))
             ELSE 
               ltrim(rtrim(COALESCE(errormessage,'')))
           END noteserrormsg               
      FROM csconversion c, taqprojectelement tpe 
     WHERE (c.sourceassetkey = tpe.taqelementkey 
        OR c.targetassetkey = tpe.taqelementkey)
       AND tpe.printingkey = 1
       AND tpe.bookkey in (select bookkey from coretitleinfo where workkey = @v_workkey)
  END
  ELSE BEGIN
    SELECT distinct c.*, 
           (SELECT taqelementdesc FROM taqprojectelement  
             WHERE taqelementkey = c.sourceassetkey) sourceassetdesc,
           (SELECT taqelementtypecode FROM taqprojectelement  
             WHERE taqelementkey = c.sourceassetkey) sourceassettype,
           (SELECT taqelementdesc FROM taqprojectelement  
             WHERE taqelementkey = c.targetassetkey) targetassetdesc,
           (SELECT taqelementtypecode FROM taqprojectelement  
             WHERE taqelementkey = c.targetassetkey) targetassettype,
           (SELECT productnumber FROM taqprojectelement tpe, coretitleinfo ct 
             WHERE tpe.taqelementkey = c.sourceassetkey
               AND tpe.bookkey = ct.bookkey
               AND tpe.printingkey = ct.printingkey
               AND tpe.printingkey = 1) sourceproductnumber,
           (SELECT productnumber FROM taqprojectelement tpe, coretitleinfo ct 
             WHERE tpe.taqelementkey = c.targetassetkey
               AND tpe.bookkey = ct.bookkey
               AND tpe.printingkey = ct.printingkey
               AND tpe.printingkey = 1) targetproductnumber,
           dbo.get_gentables_desc(579,c.statuscode,'long') statusdesc,
           dbo.qcontact_get_displayname(c.converter) conversionhousename,
           CASE
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) <> '' 
               THEN ltrim(rtrim(COALESCE(notes,''))) + ' / ' + ltrim(rtrim(COALESCE(errormessage,'')))
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) = '' 
               THEN ltrim(rtrim(COALESCE(notes,'')))
             ELSE 
               ltrim(rtrim(COALESCE(errormessage,'')))
           END noteserrormsg               
      FROM csconversion c, taqprojectelement tpe 
     WHERE (c.sourceassetkey = tpe.taqelementkey 
        OR c.targetassetkey = tpe.taqelementkey)
       AND tpe.printingkey = 1
       AND tpe.bookkey = @i_bookkey
  END
     
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing csconversion: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_conversions TO PUBLIC
GO



