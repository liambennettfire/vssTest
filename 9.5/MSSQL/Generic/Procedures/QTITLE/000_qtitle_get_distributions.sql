if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_distributions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_distributions
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_distributions
 (@i_bookkey              integer,
  @i_all_assets_for_work  integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_distributions
**  Desc: This stored procedure returns distributions for a title or work.
**        If @i_all_assets_for_work = 1, return all distributions for the work
**        otherwise return all distributions for the title
** 
**    Auth: Alan Katzen
**    Date: 18 August 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_workkey    INT,
          @v_distribute_asset_datetype INT
     
  SELECT @v_distribute_asset_datetype = datetypecode
    FROM datetype
   WHERE qsicode = 11

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting distribute asset datetype: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 
  
  IF @v_distribute_asset_datetype is null BEGIN
    SET @v_distribute_asset_datetype = 0
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

  IF @v_workkey > 0 BEGIN
    SELECT d.*, ep.resendind, e.taqelementdesc assetdesc, e.taqelementtypecode, c.productnumber, 
           dbo.get_gentables_desc(576,d.statuscode,'long') statusdesc,
           dbo.qcontact_get_displayname(d.partnercontactkey) partnername, 
           dbo.get_gentables_desc(640, ep.cspartnerstatuscode, 'long') partnerstatusdesc,                     
           CASE
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) <> '' 
               THEN ltrim(rtrim(COALESCE(notes,''))) + ' / ' + ltrim(rtrim(COALESCE(errormessage,'')))
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) = '' 
               THEN ltrim(rtrim(COALESCE(notes,'')))
             ELSE 
               ltrim(rtrim(COALESCE(errormessage,'')))
           END noteserrormsg,      
           (SELECT max(activedate) FROM taqprojecttask  
             WHERE bookkey = d.bookkey
               AND taqelementkey = d.assetkey
               AND (globalcontactkey = d.partnercontactkey OR globalcontactkey2 = d.partnercontactkey)
               AND datetypecode = @v_distribute_asset_datetype
               AND actualind = 1) lastsentdate,
           (SELECT max(activedate) FROM taqprojecttask  
             WHERE bookkey = d.bookkey
               AND taqelementkey = d.assetkey
               AND (globalcontactkey = d.partnercontactkey OR globalcontactkey2 = d.partnercontactkey)
               AND datetypecode = @v_distribute_asset_datetype
               AND COALESCE(actualind,0) = 0) nextsenddate               
      FROM csdistribution d, taqprojectelementpartner ep, taqprojectelement e, coretitleinfo c
     WHERE d.bookkey = ep.bookkey
       AND d.partnercontactkey = ep.partnercontactkey
       AND d.assetkey = ep.assetkey
       AND d.assetkey = e.taqelementkey
       AND e.bookkey = c.bookkey
       AND e.printingkey = c.printingkey
       AND e.printingkey = 1
       AND c.workkey = @v_workkey
       AND d.lastmaintdate = (SELECT max(lastmaintdate) FROM csdistribution 
                               WHERE bookkey = d.bookkey
                                 AND assetkey = d.assetkey
                                 AND partnercontactkey = d.partnercontactkey
                                 AND statuscode not in (select datacode from gentables where tableid = 576 and gen2ind = 1))
  END
  ELSE BEGIN
    SELECT d.*, ep.resendind, e.taqelementdesc assetdesc, e.taqelementtypecode, c.productnumber, 
           dbo.get_gentables_desc(576,d.statuscode,'long') statusdesc,
           dbo.qcontact_get_displayname(d.partnercontactkey) partnername,
           dbo.get_gentables_desc(640, ep.cspartnerstatuscode, 'long') partnerstatusdesc,
           CASE
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) <> '' 
               THEN ltrim(rtrim(COALESCE(notes,''))) + ' / ' + ltrim(rtrim(COALESCE(errormessage,'')))
             WHEN ltrim(rtrim(COALESCE(notes,''))) <> '' AND ltrim(rtrim(COALESCE(errormessage,''))) = '' 
               THEN ltrim(rtrim(COALESCE(notes,'')))
             ELSE 
               ltrim(rtrim(COALESCE(errormessage,'')))
           END noteserrormsg,      
           (SELECT max(activedate) FROM taqprojecttask  
             WHERE bookkey = d.bookkey
               AND taqelementkey = d.assetkey
               AND (globalcontactkey = d.partnercontactkey OR globalcontactkey2 = d.partnercontactkey)
               AND datetypecode = @v_distribute_asset_datetype
               AND actualind = 1) lastsentdate,
           (SELECT max(activedate) FROM taqprojecttask  
             WHERE bookkey = d.bookkey
               AND taqelementkey = d.assetkey
               AND (globalcontactkey = d.partnercontactkey OR globalcontactkey2 = d.partnercontactkey)
               AND datetypecode = @v_distribute_asset_datetype
               AND COALESCE(actualind,0) = 0) nextsenddate
      FROM csdistribution d, taqprojectelementpartner ep, taqprojectelement e, coretitleinfo c
     WHERE d.bookkey = ep.bookkey
       AND d.partnercontactkey = ep.partnercontactkey
       AND d.assetkey = ep.assetkey
       AND d.assetkey = e.taqelementkey                     
       AND e.bookkey = c.bookkey
       AND e.printingkey = c.printingkey
       AND e.printingkey = 1
       AND e.bookkey = @i_bookkey
       AND d.lastmaintdate = (SELECT max(lastmaintdate) FROM csdistribution
                               WHERE bookkey = d.bookkey
                                 AND assetkey = d.assetkey
                                 AND partnercontactkey = d.partnercontactkey
                                 AND statuscode not in (select datacode from gentables where tableid = 576 and gen2ind = 1))
  END
     
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing csdistribution: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_distributions TO PUBLIC
GO



