if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_incrementalTerritoryRights_background') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_incrementalTerritoryRights_background
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_incrementalTerritoryRights_background
 (@i_backgroundprocesskey  integer,
  @o_error_code            integer output,
  @o_standardmsgcode       integer output,
  @o_standardmsgsubcode    integer output,
  @o_error_desc            varchar(2000) output
  )
AS

/*************************************************************************************************************
**  Name: qcontract_incrementalTerritoryRights_background
**  Desc:
**  Case: 47528
** 
**  Auth: Colman
**  Date: 11/1/2017
*************************************************************************************************************
**  Change History
*************************************************************************************************************
**  Date:       Author:   Description:
**  ----------  -------   --------------------------------------
*************************************************************************************************************/

DECLARE 
  @v_IDtoUse INT,
  @v_typeOfRun VARCHAR(4),
  @v_contractKey INT
  
BEGIN
  SET @o_error_code = 0
  SET @o_standardmsgcode = 0
  SET @o_standardmsgsubcode = 0
  SET @o_error_desc = ''
  
	SELECT @v_IDtoUse = key1, @v_contractKey = key2, @v_typeOfRun = textvalue1
  FROM backgroundprocess
  WHERE backgroundprocesskey = @i_backgroundprocesskey

  EXEC qcontract_incrementalTerritoryRights @v_IDtoUse, @v_typeOfRun, @o_error_code OUTPUT, @o_error_desc OUTPUT, @v_contractKey
  
END
GO

GRANT EXEC ON qcontract_incrementalTerritoryRights_background TO PUBLIC
GO
