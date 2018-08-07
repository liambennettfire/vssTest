if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_partner_assets_to_resend') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_partner_assets_to_resend
GO

CREATE FUNCTION dbo.qtitle_get_partner_assets_to_resend
(
  @i_partnercontactkey INT
) 
RETURNS VARCHAR(2000)

/*******************************************************************************************************
**  Name: qtitle_get_partner_assets_to_resend
**  Desc: This function returns a string containing all element type codes of assets 
**        to be resent for the given partnercontactkey.
**
**  Auth: Kate
**  Date: October 29 2012
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_elementtype  INT,
    @v_elementtypestring  VARCHAR(2000),
    @v_metadata_element VARCHAR(30)
  
  SET @v_elementtypestring = ''
  
  SELECT @v_metadata_element = CONVERT(VARCHAR,datacode)
  FROM gentables 
  WHERE tableid = 287 AND qsicode = 3  
  
  DECLARE assets_cursor CURSOR FOR
    SELECT DISTINCT taqelementtypecode
    FROM customerpartnerassets cpa, taqprojectelementpartner ep, taqprojectelement e 
    WHERE ep.assetkey = e.taqelementkey AND 
      ep.partnercontactkey = cpa.partnercontactkey AND
      e.taqelementtypecode  = cpa.assettypecode AND
      ep.partnercontactkey = @i_partnercontactkey AND
      ep.resendind = 1 AND
      ep.cspartnerstatuscode IN (SELECT datacode FROM gentables WHERE tableid = 639 AND qsicode = 5) 

  OPEN assets_cursor

  FETCH NEXT FROM assets_cursor INTO @v_elementtype

  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF @v_elementtypestring = ''
      SET @v_elementtypestring = CONVERT(VARCHAR, @v_elementtype)
    ELSE
      SET @v_elementtypestring = @v_elementtypestring + ',' + CONVERT(VARCHAR, @v_elementtype)
      
    FETCH NEXT FROM assets_cursor INTO @v_elementtype
  END

  CLOSE assets_cursor
  DEALLOCATE assets_cursor
  
  IF CHARINDEX(@v_metadata_element, @v_elementtypestring) = 0
    SET @v_elementtypestring = @v_metadata_element + ',' + @v_elementtypestring
    
  RETURN @v_elementtypestring
  
END
GO

GRANT EXEC ON dbo.qtitle_get_partner_assets_to_resend TO PUBLIC
GO
