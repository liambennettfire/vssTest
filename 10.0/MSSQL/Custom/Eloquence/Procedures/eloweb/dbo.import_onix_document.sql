IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'Import_Onix_Document')
	BEGIN
		PRINT 'Dropping Procedure Import_Onix_Document'
		DROP  Procedure  Import_Onix_Document
	END

GO

PRINT 'Creating Procedure Import_Onix_Document'
GO
CREATE Procedure Import_Onix_Document
	/* Param List */
    @OnixDocument text = null,
    @CompanyOrgID int,
    @ImprintOrgID int = null
AS

/******************************************************************************
**		File: 
**		Name: Import_Onix_Document
**		Desc: 
**
**		This stored procedure is the main stored procedure for importing
**		an onix document into the eloquence system.
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




GO

GRANT EXEC ON Import_Onix_Document TO PUBLIC

GO
