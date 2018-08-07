/******************************************************************************
**  Name: imp_300012061001
**  Desc: IKE Add/Replace Book Weight
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
		WHERE id = object_id(N'[dbo].[imp_300012061001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300012061001]
GO

CREATE PROCEDURE dbo.imp_300012061001 
	@i_batch INT
	,@i_row INT
	,@i_dmlkey BIGINT
	,@i_titlekeyset VARCHAR(500)
	,@i_contactkeyset VARCHAR(500)
	,@i_templatekey INT
	,@i_elementseq INT
	,@i_level INT
	,@i_userid VARCHAR(50)
	,@i_newtitleind INT
	,@i_newcontactind INT
	,@o_writehistoryind INT
OUTPUT AS

/* Add/Replace Book Weight */
BEGIN
	DECLARE 
		@v_elementval VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey INT
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_new_bookweight FLOAT
		,@v_cur_bookweight FLOAT
		,@v_bookkey INT
		,@v_printingkey INT
		,@v_UnitsOfMeasure INT
		,@Debug INT

	BEGIN
		SET @Debug=0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Book Weight unchanged'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset, 2)

		SELECT @v_elementval = originalvalue
			,@v_elementkey = b.elementkey
		FROM imp_batch_detail b
			,imp_DML_elements d
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.dmlkey = @i_dmlkey
			AND d.elementkey = b.elementkey

		/*see if there is a units element in batch_detail -- if not use the one in clientdefualts
		The value in element 100012060--BookWeightUnits needs to be in this format:
		  ... Grams = 1
		  ... Inches = 2
		  ... Pounds = 3
		  ... Millimeters = 4
		  ... Ounces = 5
		*/
		
		SELECT @v_UnitsOfMeasure = datacode
		FROM imp_batch_detail
			INNER JOIN gentables	on gentables.datadesc = RTRIM(LTRIM(imp_batch_detail.originalvalue))
									and tableid=613
		WHERE imp_batch_detail.batchkey = @i_batch
			AND imp_batch_detail.row_id = @i_row
			AND imp_batch_detail.elementseq = @i_elementseq
			AND imp_batch_detail.elementkey = 100012060--BookWeightUnits
		
		IF @v_UnitsOfMeasure is null SELECT @v_UnitsOfMeasure=clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 50

		IF @Debug<>0 PRINT '@v_UnitsOfMeasure = ' + cast(@v_UnitsOfMeasure as varchar(max))
		IF @Debug<>0 PRINT '@v_elementval = ' + cast(@v_elementval as varchar(max))
		
		SET @v_new_bookweight = CONVERT(FLOAT, @v_elementval)

		SELECT @v_cur_bookweight = COALESCE(bookweight, 0)
		FROM printing
		WHERE bookkey = @v_bookkey
			AND printingkey = @v_printingkey

		IF @v_cur_bookweight <> @v_new_bookweight
		BEGIN
			UPDATE printing
			SET bookweight = @v_new_bookweight
				,bookweightunitofmeasure = @v_unitsofmeasure
				,lastuserid = @i_userid
				,lastmaintdate = GETDATE()
			WHERE bookkey = @v_bookkey
				AND printingkey = @v_printingkey

			SET @o_writehistoryind = 1
			SET @v_errmsg = 'Book Weight updated'
		END

		EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@v_errcode,3
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300012061001]
	TO PUBLIC
GO

