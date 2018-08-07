if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_royalty_saleschannel_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_royalty_saleschannel_list
GO

CREATE PROCEDURE qcontract_get_royalty_saleschannel_list (
  @i_projectkey     INT,
  @i_mediacode      INT,
  @i_formatcode     INT,
  @i_ratesexistonly TINYINT,
  @o_error_code     INT OUTPUT,
  @o_error_desc     VARCHAR(2000) OUTPUT)
AS

/***************************************************************************************************
**  Name: qcontract_get_royalty_saleschannel_list
**  Desc: This stored procedure returns Contract Royalty Sales Channel list.
**
**  Auth: Kate
**  Date: 17 January 2012
**
**  Modifications:
**  --------------
**	June 12, 2015  Joshua Robinson - Add join with gentablesorglevel for orglevel filtering
****************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  


  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  IF @i_ratesexistonly = 1  --View mode
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.royaltykey, c.pricetypeforroyalty, 
      COUNT(c.royaltykey) channelsexist, COUNT(r.royaltyratekey) ratesexist
    FROM gentables g, taqprojectroyalty c, taqprojectroyaltyrates r
    WHERE g.tableid = 118 AND
        g.datacode = c.saleschannelcode AND 
        c.royaltykey = r.royaltykey AND
        c.taqprojectkey = @i_projectkey AND
        c.mediacode = @i_mediacode AND
        c.formatcode = @i_formatcode
    GROUP BY g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.royaltykey, c.pricetypeforroyalty

  ELSE  --Edit mode
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.royaltykey, c.pricetypeforroyalty, o.orgentrykey, 
      COUNT(c.royaltykey) channelsexist, COUNT(r.royaltyratekey) ratesexist
    FROM gentables g left outer join gentablesorglevel o on
		g.tableid = o.tableid and 
        g.datacode = o.datacode, taqprojectroyalty c, taqprojectroyaltyrates r 
    WHERE g.tableid = 118 AND
        g.datacode = c.saleschannelcode AND 
        c.royaltykey = r.royaltykey AND
        c.taqprojectkey = @i_projectkey AND
        c.mediacode = @i_mediacode AND
        c.formatcode = @i_formatcode
    GROUP BY g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.royaltykey, c.pricetypeforroyalty, o.orgentrykey
    UNION
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.royaltykey, c.pricetypeforroyalty, o.orgentrykey,
      COUNT(c.royaltykey) channelsexist, 0 ratesexist
    FROM gentables g left outer join gentablesorglevel o on
		g.tableid = o.tableid and 
        g.datacode = o.datacode, taqprojectroyalty c
    WHERE g.datacode = c.saleschannelcode AND 
        g.tableid = 118 AND
        c.taqprojectkey = @i_projectkey AND
        c.mediacode = @i_mediacode AND
        c.formatcode = @i_formatcode AND
        NOT EXISTS (SELECT * FROM taqprojectroyaltyrates r
        WHERE c.royaltykey = r.royaltykey AND
          c.taqprojectkey = @i_projectkey AND
          c.mediacode = @i_mediacode AND
          c.formatcode = @i_formatcode)
    GROUP BY g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.royaltykey, c.pricetypeforroyalty, o.orgentrykey
    UNION
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, 0 royaltykey, 0 pricetypeforroyalty, o.orgentrykey,
      0 channelsexist, 0 ratesexist
    FROM gentables g left outer join gentablesorglevel o on
		g.tableid = o.tableid and 
        g.datacode = o.datacode
    WHERE g.tableid = 118 AND
        NOT EXISTS (SELECT * FROM taqprojectroyalty c1
        WHERE g.datacode = c1.saleschannelcode AND 
          c1.taqprojectkey = @i_projectkey AND
          c1.mediacode = @i_mediacode AND
          c1.formatcode = @i_formatcode) AND
        NOT EXISTS (SELECT * FROM taqprojectroyaltyrates r, taqprojectroyalty c2
        WHERE g.datacode = c2.saleschannelcode AND 
          c2.royaltykey = r.royaltykey AND
          c2.taqprojectkey = @i_projectkey AND
          c2.mediacode = @i_mediacode AND
          c2.formatcode = @i_formatcode)
    ORDER BY ratesexist DESC, g.deletestatus ASC, g.sortorder ASC, g.datadesc ASC, o.orgentrykey 
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not access gentables/taqprojectroyalty tables to get Sales Channel list.'
  END 

GO

GRANT EXEC ON qcontract_get_royalty_saleschannel_list TO PUBLIC
GO

