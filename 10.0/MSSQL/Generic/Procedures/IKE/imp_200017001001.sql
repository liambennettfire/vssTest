/******************************************************************************
**  Name: imp_200017001001
**  Desc: IKE BISAC Subject Code Validation
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_200017001001]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_200017001001]
GO

CREATE PROCEDURE dbo.imp_200017001001 @i_batch INT
	,@i_row INT
	,@i_elementkey INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_rpt INT
AS
/* BISAC Subject Code Validation */
BEGIN
	/* BISAC SUBJECT CODE VALIDATION	*/
	SET NOCOUNT ON

	DECLARE @v_elementval VARCHAR(4000)
		,@v_errlevel INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_row_count INT
		,@v_datacode INT
		,@v_datasubcode INT
		,@v_datadesc VARCHAR(40)
	
	BEGIN
		SET @v_errlevel = 0
		SET @v_row_count = 0

		SELECT @v_elementdesc = elementdesc
		FROM imp_element_defs
		WHERE elementkey = @i_elementkey

		SELECT @v_elementval = RTRIM(LTRIM(COALESCE(originalvalue, '')))
		FROM imp_batch_detail
		WHERE batchkey = @i_batch AND row_id = @i_row AND elementkey = @i_elementkey AND elementseq = @i_elementseq

		--NEW Feature ... the @v_elementval may be a semi-colon delimited string in which case we'll need to loop on each value
		DECLARE @DistinctElementVal varchar(max)

		DECLARE DistinctElementValCursor CURSOR FOR 
		SELECT part
		FROM dbo.udf_SplitString(@v_elementval, ';')

		OPEN DistinctElementValCursor

		FETCH NEXT FROM DistinctElementValCursor 
		INTO @DistinctElementVal

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC find_subgentables_mixed @DistinctElementVal
				,339
				,@v_datacode OUTPUT
				,@v_datasubcode OUTPUT
				,@v_datadesc OUTPUT

			IF @v_datacode IS NULL
			BEGIN
				SET @v_errlevel = 2
				SET @v_errmsg = 'Can not find (' + @DistinctElementVal + ') value on  User Table(339) for ' + @v_elementdesc
			END
			ELSE
			BEGIN
				SET @v_errmsg = @v_elementdesc + ' OK'
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
		
		
			FETCH NEXT FROM DistinctElementValCursor 
			INTO @DistinctElementVal
		END 
		CLOSE DistinctElementValCursor;
		DEALLOCATE DistinctElementValCursor;
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_200017001001]
	TO PUBLIC
GO


