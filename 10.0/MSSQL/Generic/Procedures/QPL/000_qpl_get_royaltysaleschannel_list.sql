if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_royaltysaleschannel_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_royaltysaleschannel_list
GO

CREATE PROCEDURE qpl_get_royaltysaleschannel_list (
  @i_projectkey     INT,
  @i_plstage        INT,
  @i_plversion      INT,
  @i_formatkey      INT,
  @i_roletypecode   INT,
  @i_globalcontactkey INT,
  @i_ratesexistonly TINYINT,
  @o_error_code     INT OUTPUT,
  @o_error_desc     VARCHAR(2000) OUTPUT)
AS

/***************************************************************************************************
**  Name: qpl_get_royaltysaleschannel_list
**  Desc: This stored procedure returns Royalty Sales Channel list.
**
**  Auth: Kate
**  Date: 16 November 2007
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  --------  --------    -----------------------------------------------------
**  01/09/17  Colman      Case 42178: Royalty advances by contributor
****************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  IF @i_ratesexistonly = 1
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.taqversionroyaltykey, 
        c.templatechangedind, COUNT(r.taqversionroyaltyratekey) ratesexist
    FROM gentables g, taqversionroyaltysaleschannel c, taqversionroyaltyrates r
    WHERE g.tableid = 118 AND
        g.datacode = c.saleschannelcode AND 
        c.taqversionroyaltykey = r.taqversionroyaltykey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion AND
        c.taqprojectformatkey = @i_formatkey AND
        c.roletypecode = @i_roletypecode AND
        c.globalcontactkey = @i_globalcontactkey
    GROUP BY g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.taqversionroyaltykey, c.templatechangedind
  ELSE  
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.taqversionroyaltykey, 
        c.templatechangedind, COUNT(r.taqversionroyaltyratekey) ratesexist
    FROM gentables g, taqversionroyaltysaleschannel c, taqversionroyaltyrates r
    WHERE g.tableid = 118 AND
        g.datacode = c.saleschannelcode AND 
        c.taqversionroyaltykey = r.taqversionroyaltykey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion AND
        c.taqprojectformatkey = @i_formatkey AND
        c.roletypecode = @i_roletypecode AND
        c.globalcontactkey = @i_globalcontactkey
    GROUP BY g.datacode, g.datadesc, g.deletestatus, g.sortorder, c.taqversionroyaltykey, c.templatechangedind
    UNION
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, 0 taqversionroyaltykey, 
        c.templatechangedind, 0 ratesexist
    FROM gentables g, taqversionroyaltysaleschannel c
    WHERE g.datacode = c.saleschannelcode AND 
        g.tableid = 118 AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_plversion AND
        c.taqprojectformatkey = @i_formatkey AND
        c.roletypecode = @i_roletypecode AND
        c.globalcontactkey = @i_globalcontactkey AND
        NOT EXISTS (SELECT * FROM taqversionroyaltyrates r
        WHERE c.taqversionroyaltykey = r.taqversionroyaltykey AND
            c.taqprojectkey = @i_projectkey AND
            c.plstagecode = @i_plstage AND
            c.taqversionkey = @i_plversion AND
            c.taqprojectformatkey = @i_formatkey AND
            c.roletypecode = @i_roletypecode AND
            c.globalcontactkey = @i_globalcontactkey)
    UNION
    SELECT g.datacode, g.datadesc, g.deletestatus, g.sortorder, 0 taqversionroyaltykey, 
        0 templatechangedind, 0 ratesexist
    FROM gentables g
    WHERE g.tableid = 118 AND
	    NOT EXISTS (SELECT * FROM taqversionroyaltysaleschannel c1
	    WHERE g.datacode = c1.saleschannelcode AND 
            c1.taqprojectkey = @i_projectkey AND
            c1.plstagecode = @i_plstage AND
            c1.taqversionkey = @i_plversion AND
            c1.taqprojectformatkey = @i_formatkey AND
            c1.roletypecode = @i_roletypecode AND
            c1.globalcontactkey = @i_globalcontactkey) AND
        NOT EXISTS (SELECT * FROM taqversionroyaltyrates r, taqversionroyaltysaleschannel c2
        WHERE g.datacode = c2.saleschannelcode AND 
		        c2.taqversionroyaltykey = r.taqversionroyaltykey AND
            c2.taqprojectkey = @i_projectkey AND
            c2.plstagecode = @i_plstage AND
            c2.taqversionkey = @i_plversion AND
            c2.taqprojectformatkey = @i_formatkey AND
            c2.roletypecode = @i_roletypecode AND
            c2.globalcontactkey = @i_globalcontactkey)
    ORDER BY ratesexist DESC, g.deletestatus ASC, g.sortorder ASC, g.datadesc ASC  
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not access gentables/taqversionroyaltysaleschannel tables to get Sales Channel list.'
  END 

GO

GRANT EXEC ON qpl_get_royaltysaleschannel_list TO PUBLIC
GO


