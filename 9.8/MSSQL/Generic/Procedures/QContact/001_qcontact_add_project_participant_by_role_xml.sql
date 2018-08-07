if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_add_project_participant_by_role_xml') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_add_project_participant_by_role_xml
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_add_project_participant_by_role_xml
 (@xmlParameters     varchar(8000),
  @keys              varchar(8000),
  @newkeys           varchar(2000) output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_add_project_participant_by_role_xml
**
**  Desc: This stored procedure processes the XML string into parameters
**        and calls qcontact_add_project_participant_by_role to add Record 
**        for a Participant by Role Section.
**
**
**    Auth: Uday A. Khisty
**    Date: 10/04/14
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:          Author:        Description:
**  -----------    -----------    -------------------------------------------
**  10/19/2016     Colman         Case 40069 Participant by Role Enhancements (Shipping Locations)
*******************************************************************************/

DECLARE 
  @v_IsOpen              BIT,
  @v_DocNum              INT,
  @v_ProjectKeyAsString        VARCHAR(255),  
  @v_ProjectKey            INT,
  @v_GlobalContactKey        INT,
  @v_KeyInd              TINYINT,
  @v_AddressKey            INT,  
  @v_ParticipantNote        VARCHAR(2000), 
  @v_SortOrder            SMALLINT,
  @v_RoleCode            INT,    
  @v_GlobalContactRelationshipKey  INT,
  @v_TaqVersionFormatKey            INT,
  @v_Quantity            INT,
  @v_Indicator            TINYINT,
  @v_ShippingMethodCode        INT,
  @v_ActiveDate            DATETIME,
  @v_ParticipantByRoleDatacode    INT,
  @v_UserID              VARCHAR(30),
  @v_TempKey            INT,
  @v_TempKeyName          VARCHAR(255),
  @v_KeyValue            VARCHAR(50),
  @v_ProjectContactKeyAsString    VARCHAR(50)

  SET NOCOUNT ON

  SET @v_IsOpen = 0
  SET @v_TempKey = 0
  SET @v_TempKeyName = ''
  SET @v_KeyValue = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document'
    GOTO ExitHandler
  END  
  
  SET @v_IsOpen = 1
  
  -- Extract parameters to the calling function from passed XML
  SELECT @v_ProjectKeyAsString = ProjectKeyAsString,
      @v_GlobalContactKey = GlobalContactKey, 
      @v_KeyInd = KeyInd,
      @v_AddressKey = AddressKey,
      @v_ParticipantNote = ParticipantNote,
      @v_SortOrder = SortOrder,           
      @v_RoleCode = RoleCode,    
      @v_GlobalContactRelationshipKey = GlobalContactRelationshipKey,
      @v_TaqVersionFormatKey = TaqVersionFormatKey,
      @v_Quantity = Quantity,
      @v_Indicator = Indicator,
      @v_ShippingMethodCode = ShippingMethodCode,      
      @v_ActiveDate = ActiveDate,  
      @v_ParticipantByRoleDatacode = ParticipantByRoleDatacode,
      @v_UserID = UserID
  FROM OPENXML(@v_DocNum,  '//Parameters')
  WITH (ProjectKeyAsString VARCHAR(255) 'ProjectKey',
      GlobalContactKey int 'GlobalContactKey', 
      KeyInd tinyint 'KeyInd',
      AddressKey int 'AddressKey',
      ParticipantNote VARCHAR(2000) 'ParticipantNote',
      SortOrder smallint 'SortOrder',           
      RoleCode int 'RoleCode',  
      GlobalContactRelationshipKey int 'GlobalContactRelationshipKey',      
      TaqVersionFormatKey int 'TaqVersionFormatKey',      
      Quantity int 'Quantity',   
      Indicator tinyint 'Indicator',
      ShippingMethodCode int 'ShippingMethodCode',
      ActiveDate datetime 'ActiveDate',   
      ParticipantByRoleDatacode int 'ParticipantByRoleDatacode',
      UserID varchar(30) 'UserID')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting parameters from qcontact_add_project_participant_by_role_xml.'
    GOTO ExitHandler
  END
  
  
----DEBUG
--  PRINT 'bookkey=' + CAST(@v_BookKey AS VARCHAR)
--  PRINT 'printingkey=' + CAST(@v_PrintingKey AS VARCHAR)
--  PRINT 'bookcontactkey=' + CAST(@v_BookContactKey AS VARCHAR)
--  PRINT 'projectkey=' + CAST(@v_ProjectKey AS VARCHAR)
--  PRINT 'projectcontactkey=' + CAST(@v_ProjectContactKey AS VARCHAR)  
--  PRINT 'userid=' + @v_UserID 

  IF (@v_ProjectKeyAsString IS NOT NULL AND LEN(@v_ProjectKeyAsString) > 0 AND SUBSTRING(@v_ProjectKeyAsString,1,1) = '?')
  BEGIN
      
    IF (LEN(@v_ProjectKeyAsString) > 1)
    BEGIN
      SET @v_TempKeyName = SUBSTRING(@v_ProjectKeyAsString, 2, LEN(@v_ProjectKeyAsString) -1)
      SET @v_TempKey = dbo.key_from_key_list_string(@keys, @v_TempKeyName)
    END

  --PRINT 'tempkeyname=' + CAST(@v_TempKeyName AS VARCHAR)
  --PRINT 'tempkey=' + CAST(@v_TempKey AS VARCHAR)

    IF (@v_TempKey = 0)
    BEGIN
      EXEC next_generic_key @v_UserID, @v_TempKey output, @o_error_code output, @o_error_desc
      SET @v_ProjectKeyAsString = CONVERT(VARCHAR(255), @v_TempKey)

      IF (LEN(@v_TempKeyName) > 0)
      BEGIN
        SET @keys = @keys + @v_TempKeyName + ',' + @v_ProjectKeyAsString + ','
        IF @newkeys IS NULL BEGIN
          SET @newkeys = ''
        END
        SET @newkeys = @newkeys + @v_TempKeyName + ',' + @v_ProjectKeyAsString + ','
      END
    END
    ELSE 
    BEGIN
      SET @v_ProjectKeyAsString = CONVERT(VARCHAR(120), @v_TempKey)
    END
  END

  SET @v_ProjectKey = CONVERT(INT, @v_ProjectKeyAsString)

  /** Call procedure that will delete Element and Task records **/
  EXEC qcontact_add_project_participant_by_role @v_ProjectKey, @v_GlobalContactKey, @v_KeyInd, @v_AddressKey, @v_ParticipantNote, 
                           @v_SortOrder, @v_RoleCode, @v_GlobalContactRelationshipKey, @v_Quantity, @v_Indicator, 
                           @v_ShippingMethodCode, @v_ActiveDate, @v_ParticipantByRoleDatacode, @v_TaqVersionFormatKey, @v_UserID, @o_error_code output, @o_error_desc output
  
ExitHandler:

IF @v_IsOpen = 1
BEGIN
  EXEC sp_xml_removedocument @v_DocNum
  SET @v_DocNum = NULL
END
  
GO

GRANT EXEC ON qcontact_add_project_participant_by_role_xml TO PUBLIC
GO
