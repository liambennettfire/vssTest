USE [UAZ]
GO
/****** Object:  StoredProcedure [dbo].[UAZ_Web_Feed_Authors_XML_Builder]    Script Date: 6/6/2016 2:09:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jon Hess.
-- Create date: 06/6/16
-- Description:	Web Feed XML for All Authors
-- =============================================
ALTER PROCEDURE [dbo].[UAZ_Web_Feed_Authors_XML_Builder]
-- Add the parameters for the stored procedure here
@productxml XML OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		@productxml = (SELECT
			a.authorsort sortorder,
			a.authorid id,
			a.authorrole role,
			a.authorsuffix Suffix,
			a.authorfirstname FirstName,
			a.authormiddlename MiddleName,
			a.authorlastname LastName,
			a.authordegree Degree,
			a.AuthorFullName AuthorFullName,
			dbo.rpt_cdata(dbo.rpt_GET_QSI_Comment(a.authorid, 2, 0)) AS AuthorBioContact
		FROM uaz_rpt_author_info_view a
		ORDER BY a.authorsort
		FOR XML PATH ('author'), ROOT ('authors'), TYPE)

END