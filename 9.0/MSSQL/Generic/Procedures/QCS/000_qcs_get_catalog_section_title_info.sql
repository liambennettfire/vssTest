
GO
/****** Object:  StoredProcedure [dbo].[qcs_get_catalog_section_title_info]    Script Date: 04/26/2013 18:15:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_get_catalog_section_title_info')
DROP PROCEDURE  [qcs_get_catalog_section_title_info]
GO

CREATE PROCEDURE [dbo].[qcs_get_catalog_section_title_info] (@i_projectkey integer)
	AS

		DECLARE	@error_var int,
				@rowcount_var int,
				@errorDesc	NVARCHAR(2000)

		BEGIN

			SELECT	i.cloudproductid,
					COALESCE(tpt.quantity1, 99999) AS "Order",
					i.bookkey AS "bookkey"
			FROM	taqprojecttitle tpt,
					isbn i
			WHERE tpt.bookkey = i.bookkey
			AND tpt.taqprojectkey = @i_projectkey

			SELECT	@error_var = @@ERROR,
					@rowcount_var = @@ROWCOUNT
			IF @error_var <> 0
			BEGIN
				SET @errorDesc = 'Error retrieving catalog section title info (projectkey = ' + CAST(@i_projectkey AS varchar) + ')'
				RAISERROR(@errorDesc, 16, 1)
				RETURN
			END
		END