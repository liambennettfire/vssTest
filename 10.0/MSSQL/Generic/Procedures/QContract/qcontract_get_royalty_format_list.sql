if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_royalty_format_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_royalty_format_list
GO

CREATE PROCEDURE qcontract_get_royalty_format_list (  
  @i_projectkey integer,
  @i_roletypecode integer,
  @i_globalcontactkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qcontract_get_royalty_format_list
**  Desc: This stored procedure returns distinct formats for the Contract Royalty control.
**
**  Auth: Kate
**  Date: January 17 2012
***************************************************************************************************
**  Change History
***************************************************************************************************
**  Date:     Author:     Description:
**  --------  --------    -----------------------------------------------------
**  01/13/17  Colman      Case 42178: Royalty advances by contributor
***************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_error  INT,
  @v_royaltykey INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Because of how the royalty data is structured, we need a dummy saleschannelcode=0 row for the "All FORMATS" row initially, 
  -- when no rates have yet been entered for any sales channels. Delete this dummy row once data exists for at least one sales channel for "All Formats"
  SELECT @v_count = COUNT(*) 
  FROM taqprojectroyalty 
  WHERE taqprojectkey = @i_projectkey AND roletypecode = @i_roletypecode AND globalcontactkey = @i_globalcontactkey AND mediacode = 0 AND formatcode = 0 AND saleschannelcode > 0
  
  IF @v_count > 0
  BEGIN
    DELETE FROM taqprojectroyalty
    WHERE taqprojectkey = @i_projectkey AND roletypecode = @i_roletypecode AND globalcontactkey = @i_globalcontactkey AND mediacode = 0 AND formatcode = 0 AND saleschannelcode = 0
  END  
  
  -- Insert the initial "ALL FORMATS" row for this project if it doesn't already exist
  SELECT @v_count = COUNT(*) 
  FROM taqprojectroyalty 
  WHERE taqprojectkey = @i_projectkey AND roletypecode = @i_roletypecode AND globalcontactkey = @i_globalcontactkey AND mediacode = 0
  
  IF @v_count = 0
  BEGIN
    EXEC get_next_key 'qsidba', @v_royaltykey OUTPUT
    
    INSERT INTO taqprojectroyalty
      (royaltykey, taqprojectkey, roletypecode, globalcontactkey, mediacode, formatcode, saleschannelcode, pricetypeforroyalty, lastuserid, lastmaintdate)
    VALUES
      (@v_royaltykey, @i_projectkey, @i_roletypecode, @i_globalcontactkey, 0, 0, 0, 1, 'INITIAL', getdate())
      
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not insert initial row to taqprojectroyalty table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
    END 
  END
  
  SELECT @v_count = COUNT(*) 
  FROM taqprojectroyalty 
  WHERE taqprojectkey = @i_projectkey AND roletypecode = @i_roletypecode AND globalcontactkey = @i_globalcontactkey AND mediacode > 0
  
  SELECT DISTINCT r.mediacode, r.formatcode, r.roletypecode, r.globalcontactkey, p.avgroyaltyenteredind, 
    CASE
      WHEN r.mediacode = 0 AND r.formatcode = 0 THEN 999999
      ELSE COALESCE(g.sortorder,0)
    END gen_order, 
    CASE
      WHEN r.mediacode = 0 AND r.formatcode = 0 THEN 999999
      ELSE COALESCE(s.sortorder,0)
    END sub_order,
    CASE @v_count 
      WHEN 0 THEN 'All Formats' 
      ELSE CASE WHEN r.mediacode = 0 AND r.formatcode = 0 THEN 'All Other Formats'
      ELSE s.datadesc
      END
    END formatdesc
  FROM taqprojectroyalty r
    LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = r.mediacode
    LEFT OUTER JOIN subgentables s ON s.tableid = 312 AND s.datacode = r.mediacode AND s.datasubcode = r.formatcode
    JOIN taqproject p ON p.taqprojectkey = r.taqprojectkey
  WHERE r.taqprojectkey = @i_projectkey AND r.roletypecode = @i_roletypecode AND r.globalcontactkey = @i_globalcontactkey
  ORDER BY gen_order, sub_order, formatdesc

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqprojectroyalty table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qcontract_get_royalty_format_list TO PUBLIC
GO
