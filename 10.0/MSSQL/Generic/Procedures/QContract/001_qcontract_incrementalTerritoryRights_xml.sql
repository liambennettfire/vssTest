if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_incrementalTerritoryRights_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_incrementalTerritoryRights_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_incrementalTerritoryRights_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************************
**  Name: qcontract_incrementalTerritoryRights_xml
**  Desc: This stored procedure will reload all territory rights
**
**  Auth: Uday A. Khisty
**  Date: February 1 2017
*******************************************************************************************
**  Change History
********************************************************************************************
**  Date:       Author:            Description:
**  -------   ------------      -----------------------------------------------------------
**  03/30/17   Uday A. Khisty   Case 44186
**  11/01/17   Colman           Case 47528 Push rights calculus to a background process
********************************************************************************************/

DECLARE 
  @v_IsOpen   BIT,
  @v_DocNum   INT,
  @v_IDtoUse INT,
  @v_typeOfRun VARCHAR(4),
  @v_contractKey INT,
  @v_backgroundprocesskey INT,
  @v_stored_proc_name     VARCHAR(120),
  @v_jobtype              INT,
  @v_run_as_backgroundprocess TINYINT
  
  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_contractKey = NULL
  SET @v_run_as_backgroundprocess = 1

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document.'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_IDtoUse = IDtoUse,
      @v_typeOfRun = typeOfRun,
	  @v_contractKey = contractKey
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (IDtoUse INT 'IDtoUse', 
      typeOfRun VARCHAR(4) 'typeOfRun',
      contractKey INT 'contractKey')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qcontract_incrementalTerritoryRights_xml.'
    GOTO ExitHandler
  END

  -- Case 47528 - push call to background process
  IF @v_run_as_backgroundprocess = 1
  BEGIN
    SET @v_stored_proc_name = 'qcontract_incrementalTerritoryRights_background'
  
    SELECT @v_jobtype = datacode FROM gentables WHERE tableid = 543 AND qsicode = 25
  
    IF @@ERROR <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error getting Job Type FROM gentables 543.'
      RETURN 
    END

	  EXEC get_next_key 'backgroundprocess', @v_backgroundprocesskey OUTPUT
	
	  INSERT INTO backgroundprocess
      (backgroundprocesskey, jobtypecode, storedprocname, reqforgetprodind, key1, key2, 
       integervalue1, integervalue2, textvalue1, createdate, lastuserid, lastmaintdate)
	  VALUES
      (@v_backgroundprocesskey, @v_jobtype, @v_stored_proc_name, 0, @v_IDtoUse, @v_contractKey,
       NULL, NULL, @v_typeOfRun, GETDATE(), NULL, GETDATE())
  END
  ELSE    
    EXEC qcontract_incrementalTerritoryRights @v_IDtoUse, @v_typeOfRun, @o_error_code OUTPUT, @o_error_desc OUTPUT, @v_contractKey
  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qcontract_incrementalTerritoryRights_xml TO PUBLIC
GO
