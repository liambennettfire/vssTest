if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_royalty_contributors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_royalty_contributors
GO

CREATE PROCEDURE qcontract_get_royalty_contributors (
  @i_projectkey     INT,
  @o_error_code     INT OUTPUT,
  @o_error_desc     VARCHAR(2000) OUTPUT)
AS

/***************************************************************************************************
**  Name: qcontract_get_royalty_contributors
**  Desc: Get distinct contributors (roletypecode/globalcontactkey) for project royalties. 
**  Case: 42178
**
**  Auth: Colman
**  Date: 12 January 2017
****************************************************************************************************
**  Change History
****************************************************************************************************
**  Date:     Author:     Description:
**  --------  --------    -----------------------------------------------------
****************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  SELECT r.roletypecode, r.globalcontactkey, r.roletypecode origroletypecode, r.globalcontactkey origglobalcontactkey,
    CASE 
      WHEN r.roletypecode = 0 THEN 'ALL' 
      ELSE (SELECT datadesc FROM gentables WHERE tableid=285 and datacode=r.roletypecode) 
    END AS roletypedesc,
    CASE 
      WHEN r.globalcontactkey = 0 THEN 'ALL' 
      ELSE (SELECT displayname FROM globalcontact WHERE globalcontactkey=r.globalcontactkey) 
    END AS globalcontactdisplayname,
    MIN(royaltykey) AS royaltykey
  FROM gentables g, taqprojectroyalty r
  WHERE 
      g.tableid = 563 AND
      r.taqprojectkey = @i_projectkey
  GROUP BY r.roletypecode, r.globalcontactkey
  ORDER BY royaltykey
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get royalty contributors.'
  END 

GO

GRANT EXEC ON qcontract_get_royalty_contributors TO PUBLIC
GO


