if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionroyalty_contributors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionroyalty_contributors
GO

CREATE PROCEDURE qpl_get_taqversionroyalty_contributors (
  @i_projectkey     INT,
  @i_plstage        INT,
  @i_plversion      INT,
  @o_error_code     INT OUTPUT,
  @o_error_desc     VARCHAR(2000) OUTPUT)
AS

/***************************************************************************************************
**  Name: qpl_get_taqversionroyalty_contributors
**  Desc: Get distinct contributors (roletypecode/globalcontactkey) on version royalties. 
**  Case: 42178
**
**  Auth: Colman
**  Date: 12 January 2017
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  --------  --------    -----------------------------------------------------
****************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  SELECT c.roletypecode, c.globalcontactkey, c.roletypecode origroletypecode, c.globalcontactkey origglobalcontactkey,
    CASE WHEN c.roletypecode = 0 THEN 'ALL' ELSE (SELECT datadesc FROM gentables WHERE tableid=285 and datacode=c.roletypecode) END AS roletypedesc,
    CASE WHEN c.globalcontactkey = 0 THEN 'ALL' ELSE (SELECT displayname FROM globalcontact WHERE globalcontactkey=c.globalcontactkey) END AS globalcontactdisplayname,
    MIN(taqversionroyaltykey) AS taqversionroyaltykey
  FROM gentables g, taqversionroyaltysaleschannel c
  WHERE 
      g.tableid = 563 AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion
  GROUP BY c.roletypecode, c.globalcontactkey
  ORDER BY taqversionroyaltykey
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get royalty contributors.'
  END 

GO

GRANT EXEC ON qpl_get_taqversionroyalty_contributors TO PUBLIC
GO


