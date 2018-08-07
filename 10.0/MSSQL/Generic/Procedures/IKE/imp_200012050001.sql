/******************************************************************************
**  Name: imp_200012050001
**  Desc: IKE Check for Valid Format Description 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/19/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_200012050001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_200012050001]
GO

CREATE PROCEDURE dbo.imp_200012050001 @i_batch INT
	,@i_row INT
	,@i_elementkey INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_rpt INT
AS
/* Check for Valid Format Description */
BEGIN
	/*  FORMAT DESCRIPTION VALIDATION	*/
	SET NOCOUNT ON

	DECLARE @v_format VARCHAR(4000)
		,@v_media VARCHAR(100)
		,@v_media_code INT 
		,@v_errcode INT
		,@v_errlevel INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_row_count INT
		,@v_datacode INT
		,@v_datasubcode INT
		,@v_datadesc VARCHAR(MAX)

	BEGIN
		SET @v_errlevel = 0
		SET @v_row_count = 0

		SELECT @v_elementdesc = elementdesc
		FROM imp_element_defs
		WHERE elementkey = @i_elementkey

		SELECT @v_media = COALESCE(originalvalue, '')
		FROM imp_batch_detail
		WHERE batchkey = @i_batch
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey IN (100012051)
			
		
		EXEC dbo.find_gentables_mixed 
			@v_media
			,312
			,@v_media_code OUTPUT
			,@v_datadesc OUTPUT		

		SELECT @v_format = COALESCE(originalvalue, '')
		FROM imp_batch_detail
		WHERE batchkey = @i_batch
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100012050

		--PRINT @v_media
		--PRINT @v_format
		--PRINT 312
		--PRINT @v_datacode
		--PRINT @v_datasubcode
		--PRINT @v_datadesc

		EXEC dbo.find_subgentables_mixed @v_format
			,312
			,@v_media_code OUTPUT
			,@v_datasubcode OUTPUT
			,@v_datadesc OUTPUT

		IF @v_datasubcode IS NULL
		BEGIN
			SET @v_errlevel = 2
			SET @v_errmsg = 'Can not find (' + @v_format + ') value on  User Table(312) for Format Description .  Format was not updated'
		END
		ELSE
		BEGIN
			SET @v_errmsg = 'Format OK'
			SET @v_errlevel = 1
		END

		IF @v_errlevel >= @i_rpt
		BEGIN
			EXECUTE imp_write_feedback @i_batch
				,@i_row
				,@i_elementkey
				,@i_elementseq
				,@i_rulekey
				,@v_errmsg
				,@v_errlevel
				,2
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_200012050001]
	TO PUBLIC
GO


