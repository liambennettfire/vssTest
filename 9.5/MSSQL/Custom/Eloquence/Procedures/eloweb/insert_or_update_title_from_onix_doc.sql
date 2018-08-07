PRINT 'STORED PROCEDURE : qsidba.insert_or_update_title_from_onix_doc'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'insert_or_update_title_from_onix_doc')
	BEGIN
		PRINT 'Dropping Procedure insert_or_update_title_from_onix_doc'
		DROP  Procedure  qsidba.insert_or_update_title_from_onix_doc
	END

GO

PRINT 'Creating Procedure qsidba.insert_or_update_title_from_onix_doc'
GO
CREATE Procedure qsidba.insert_or_update_title_from_onix_doc
(
	@ONIXDocument text,
	@OrgEntryKey  int,
    @o_error_code int out,
    @o_error_desc char out 
)
AS

/******************************************************************************
**		File: 
**		Name: insert_or_update_title_from_onix_doc
**		Desc: 
**
**		This template can be customized:
**              
**		Return values:
** 
**		Called by:   
**              
**		Parameters:
**		Input							Output
**     ----------							-----------
**
**		Auth: 
**		Date: 
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**		--------		--------				-------------------------------------------
**    
*******************************************************************************/

BEGIN
DECLARE
  @intErr INT,
  @intRowcount INT,
  @intDoc INT,
  @bolOpen BIT

  SET NOCOUNT ON
  SET @intErr = 0
  SET @bolOpen = 0
  EXEC sp_xml_preparedocument @intDoc OUTPUT, @ONIXDocument

  SET @intErr = @@ERROR
  IF @intErr <> 0 BEGIN
    SET @intErr = 1
    GOTO ExitHandler

  END
  SET @bolOpen = 1

-- INSERT INTO person (id, firstname, lastname,address)

  SELECT * FROM OPENXML(@intDoc,  '/OnixDocument/product[a=1]')
    WITH (title varchar(50) 'b028', subtitle varchar(50) 'b029')
  
  ;


--  firstname VARCHAR(50) '@firstname',

--  lastname VARCHAR(50) '@lastname',

--  address VARCHAR(50) '@address')

ExitHandler:

  IF @bolOpen = 1 BEGIN

    EXEC sp_xml_removedocument @intDoc

  END

  RETURN @intErr


END

GO

GRANT EXEC ON qsidba.insert_or_update_title_from_onix_doc TO PUBLIC
GO

PRINT 'STORED PROCEDURE : qsidba.insert_or_update_title_from_onix_doc complete'
GO

