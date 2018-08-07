IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'insert_or_update_onix_document')
	BEGIN
		PRINT 'Dropping Procedure insert_or_update_onix_document'
		DROP  Procedure  insert_or_update_onix_document
	END

GO

PRINT 'Creating Procedure insert_or_update_onix_document'
GO
CREATE Procedure insert_or_update_onix_document
(
	@ONIXDocument ntext,
	@OrgEntryKey  int
)
AS

/******************************************************************************
**		File: 
**		Name: insert_or_update_onix_document
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
**     ----------						-----------
**
**		Auth: 
**		Date: 
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**		--------	--------			---------------------------------------
**    
*******************************************************************************/




GO

GRANT EXEC ON insert_or_update_onix_document TO PUBLIC

GO
