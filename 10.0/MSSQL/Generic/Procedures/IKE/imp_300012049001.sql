/******************************************************************************
**  Name: imp_300012049001
**  Desc: IKE Actual Trim Length
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/24/2016    Kusum       Case 37305 - Default trimsizeunitofmeasure to inches 
**                                if not set on clientdefaults
*******************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_300012049001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_300012049001]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[imp_300012049001] 	@i_batch INT,@i_row INT,@i_dmlkey BIGINT,@i_titlekeyset VARCHAR(500),@i_contactkeyset VARCHAR(500),
	@i_templatekey INT,@i_elementseq INT,@i_level INT,@i_userid VARCHAR(50),@i_newtitleind INT,@i_newcontactind INT,@o_writehistoryind INT OUTPUT 
AS

BEGIN
	DECLARE 
		@v_elementval VARCHAR(4000),
		@v_errcode INT, 
		@v_errmsg VARCHAR(4000),
		@v_elementdesc VARCHAR(4000),
		@v_elementkey BIGINT,
		@v_lobcheck VARCHAR(4000),
		@v_lobkey INT,
		@v_bookkey INT,
		@v_printingkey INT,
		@v_UnitsOfMeasure INT,
		@i_width VARCHAR(4000),
		@i_options INT

	BEGIN
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Actual Trim Length Unchanged'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset, 2)
		SET @i_width = ''

		SELECT @v_elementval = COALESCE(RTRIM(LTRIM(originalvalue)), ''),@v_elementkey = b.elementkey
		  FROM imp_batch_detail b,imp_DML_elements d
		 WHERE b.batchkey = @i_batch 
		   AND b.row_id = @i_row
		   AND b.elementseq = @i_elementseq
		   AND b.elementkey = d.elementkey
		   AND d.DMLkey = @i_dmlkey
		   
		SELECT @i_options = optionvalue FROM clientoptions  WHERE optionid = 7

		IF COALESCE(@i_options, 0) = 0
			SELECT @i_width = COALESCE(trimsizelength, '') FROM printing WHERE bookkey = @v_bookkey	AND printingkey = @v_printingkey
		ELSE
			SELECT @i_width = COALESCE(tmmactualtrimlength, '') FROM printing WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

		/*see if there is a units element in batch_detail -- if not use the one in clientdefualts
		The value in element 100012058--TrimUnitMeasure needs to be in this format:
		  ... Grams = 1
		  ... Inches = 2
		  ... Pounds = 3
		  ... Millimeters = 4
		  ... Ounces = 5
		*/
		
		SELECT @v_UnitsOfMeasure = COALESCE(datacode,0)
		  FROM imp_batch_detail INNER JOIN gentables	on gentables.datadesc = RTRIM(LTRIM(imp_batch_detail.originalvalue))and tableid=613
		 WHERE imp_batch_detail.batchkey = @i_batch
		   AND imp_batch_detail.row_id = @i_row
		   AND imp_batch_detail.elementseq = @i_elementseq
		   AND imp_batch_detail.elementkey = 100012058--TrimUnitMeasure
		
		IF COALESCE(@v_UnitsOfMeasure,0) = 0 
			SELECT @v_UnitsOfMeasure=COALESCE(clientdefaultvalue,0) FROM clientdefaults WHERE clientdefaultid = 49
		
		IF COALESCE(@v_UnitsOfMeasure,0) = 0 
			SET @v_UnitsOfMeasure = 2 -- default to inches if not set on clientdefaults


		IF @i_width <> @v_elementval BEGIN
			SET @v_errmsg = 'Actual Trim Length Updated'

			IF COALESCE(@i_options, 0) = 0 BEGIN
				UPDATE printing
				   SET trimsizelength = substring(@v_elementval, 1, 10),trimsizeunitofmeasure = @v_unitsofmeasure,lastuserid = @i_userid,lastmaintdate = GETDATE()
				WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

				SET @o_writehistoryind = 1
			END
			ELSE
			BEGIN
				UPDATE printing
				   SET tmmactualtrimlength = substring(@v_elementval, 1, 10),trimsizeunitofmeasure = @v_unitsofmeasure,lastuserid = @i_userid,lastmaintdate = GETDATE()
				 WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

				SET @o_writehistoryind = 1
			END
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

GRANT EXECUTE ON dbo.[imp_300012049001] TO PUBLIC
GO

