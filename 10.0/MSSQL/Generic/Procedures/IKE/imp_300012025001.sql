/******************************************************************************
**  Name: imp_300012025001
**  Desc: IKE Spine Size Update
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
		WHERE id = object_id(N'[dbo].[imp_300012025001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300012025001]
GO

CREATE PROCEDURE dbo.imp_300012025001 
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

BEGIN
	DECLARE 
		@v_elementval VARCHAR(4000)
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_lobcheck VARCHAR(20)
		,@v_lobkey INT
		,@v_bookkey INT
		,@v_printingkey INT
		,@v_UnitsOfMeasure INT
		,@v_cur_spinesize VARCHAR(15)
		,@v_new_spinesize VARCHAR(15)

	BEGIN
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Spine Size Unchanged'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset, 2)

		SELECT @v_elementval = COALESCE(originalvalue, '')
			,@v_elementkey = b.elementkey
		FROM imp_batch_detail b
			,imp_DML_elements d
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = d.elementkey
			AND d.DMLkey = @i_dmlkey

		/*see if there is a units element in batch_detail -- if not use the one in clientdefualts
		The value in element 100012059--SpineUnitMeasure needs to be in this format:
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
			AND imp_batch_detail.elementkey = 100012059--SpineUnitMeasure
	
		IF @v_UnitsOfMeasure is null SELECT @v_UnitsOfMeasure=clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 50
		
		SELECT @v_new_spinesize = @v_elementval

		SELECT @v_cur_spinesize = COALESCE(spinesize, '')
		FROM printing
		WHERE bookkey = @v_bookkey
			AND printingkey = @v_printingkey

		IF @v_new_spinesize <> @v_cur_spinesize
		BEGIN
			UPDATE printing
			SET spinesize = @v_new_spinesize
				,spinesizeunitofmeasure = @v_UnitsOfMeasure
				,lastuserid = @i_userid
				,lastmaintdate = getdate()
			WHERE bookkey = @v_bookkey
				AND printingkey = 1

			SET @v_errmsg = 'Spine Size Updated'
			SET @o_writehistoryind = 1
		END

		IF @v_errcode < 2
		BEGIN
			EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@i_level,3
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300012025001]
	TO PUBLIC
GO

