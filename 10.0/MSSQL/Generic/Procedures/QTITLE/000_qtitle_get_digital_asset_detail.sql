if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_digital_asset_detail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_digital_asset_detail
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_digital_asset_detail
 (@i_elementkey           integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_digital_asset_detail
**  Desc: This stored procedure returns the detail for a specific digital 
**        asset.
** 
**    Auth: Alan Katzen
**    Date: 16 August 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_elotag_productidcode INT,
          @v_guid_productidcode INT,
          @v_eloquencetag varchar(50),
          @v_guid varchar(50)
          
          
  -- get product id datacode for eleoquence tag (qsicode = 7)
  SET @v_elotag_productidcode = 0
  SELECT @v_elotag_productidcode = datacode 
    FROM gentables
   WHERE tableid = 551
     AND qsicode = 7

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing gentables tableid = 551 (elotag): elementkey = ' + cast(@i_elementkey AS VARCHAR)  
  END 
  
  -- get eloquence tag
  SET @v_eloquencetag = null
  IF @v_elotag_productidcode > 0 BEGIN
    SELECT @v_eloquencetag = productnumber
      FROM taqproductnumbers
     WHERE elementkey = @i_elementkey
       AND productidcode = @v_elotag_productidcode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing taqproductnumbers (elotag): elementkey = ' + cast(@i_elementkey AS VARCHAR) + '/productidcode= ' + cast(@v_elotag_productidcode AS VARCHAR)
    END 
  END

  -- get product id datacode for guid (qsicode = 8)
  SET @v_guid_productidcode = 0
  SELECT @v_guid_productidcode = datacode 
    FROM gentables
   WHERE tableid = 551
     AND qsicode = 8

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing gentables tableid = 551 (guid): elementkey = ' + cast(@i_elementkey AS VARCHAR)  
  END 
  
  -- get guid
  SET @v_guid = null
  IF @v_guid_productidcode > 0 BEGIN
    SELECT @v_guid = productnumber
      FROM taqproductnumbers
     WHERE elementkey = @i_elementkey
       AND productidcode = @v_guid_productidcode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing taqproductnumbers (guid): elementkey = ' + cast(@i_elementkey AS VARCHAR) + '/productidcode= ' + cast(@v_guid_productidcode AS VARCHAR)
    END 
  END
    
  SELECT tpe.*, @v_eloquencetag eloquencetag, @v_guid assetguid,
         CASE
           WHEN tpe.bookkey > 0 
             THEN (select cloudproductid from isbn where bookkey = tpe.bookkey)
           ELSE 
             null
         END productguid,
         CASE
           WHEN tpe.bookkey > 0 
             THEN (select ean13 from isbn where bookkey = tpe.bookkey) + '_' + replace(dbo.get_gentables_desc(287,tpe.taqelementtypecode,'long'),' ','_')
           ELSE 
             null
         END defaultfilename
    FROM taqprojectelement tpe
   WHERE tpe.taqelementkey = @i_elementkey
   
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojectelement: elementkey = ' + cast(@i_elementkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_digital_asset_detail TO PUBLIC
GO



