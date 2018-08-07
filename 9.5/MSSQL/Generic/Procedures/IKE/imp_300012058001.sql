/******************************************************************************
**  Name: imp_300012058001
**  Desc: IKE trimsizeunitofmeasure
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
**  5/24/2016    Kusum       Case 37305 - Default trimsizeunitofmeasure to inches 
**                                if not set on clientdefaults
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[imp_300012058001]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_300012058001]
GO

CREATE PROCEDURE dbo.imp_300012058001 @i_batch INT,@i_row INT,@i_dmlkey BIGINT,@i_titlekeyset VARCHAR(500),@i_contactkeyset VARCHAR(500),@i_templatekey INT,
	@i_elementseq INT,@i_level INT,@i_userid VARCHAR(50),@i_newtitleind INT,@i_newcontactind INT,@o_writehistoryind INT OUTPUT
AS
BEGIN
	/*  START SPROC    */
	DECLARE 
		@v_elementval VARCHAR(4000),
		@v_errcode INT,
		@v_errmsg VARCHAR(4000),
		@v_elementdesc VARCHAR(4000),
		@v_elementkey BIGINT,
		@v_bookkey INT,
		@v_printingkey INT,
		@v_tableid INT,
		@v_datacode INT,
		@v_datacode_org INT,
		@v_datadesc VARCHAR(MAX),
		@v_hit INT

	BEGIN
		SET @v_hit = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset, 2)

		SELECT @v_elementval = LTRIM(RTRIM(originalvalue)),@v_elementkey = b.elementkey,@v_tableid = ed.tableid
		  FROM imp_batch_detail b,imp_DML_elements d,imp_element_defs ed
		 WHERE b.batchkey = @i_batch
		   AND b.row_id = @i_row
		   AND b.elementseq = @i_elementseq
		   AND d.dmlkey = @i_dmlkey
		   AND d.elementkey = b.elementkey
		   AND ed.elementkey = b.elementkey

		SELECT @v_datacode_org = COALESCE(trimsizeunitofmeasure, 0) FROM printing WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
		
		/*see if there is a units element in batch_detail -- if not use the one in clientdefualts
		The value in element 100012058--TrimUnitMeasure needs to be in this format:
		  ... Grams = 1
		  ... Inches = 2
		  ... Pounds = 3
		  ... Millimeters = 4
		  ... Ounces = 5
		*/

		EXEC find_gentables_mixed @v_elementval,@v_tableid,@v_datacode OUTPUT,@v_datadesc OUTPUT
		
		IF COALESCE(@v_datacode,0) = 0
			SELECT @v_datacode=COALESCE(clientdefaultvalue,0) FROM clientdefaults WHERE clientdefaultid = 49
		
		IF COALESCE(@v_datacode,0) = 0 
			SET @v_datacode = 2 -- default to inches if not set on clientdefaults

		IF @v_datacode IS NOT NULL AND @v_datacode_org <> @v_datacode BEGIN
			UPDATE printing
			   SET trimsizeunitofmeasure = @v_datacode,lastuserid = @i_userid,lastmaintdate = GETDATE()
			 WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey

			SET @o_writehistoryind = 1
			SET @v_errmsg = 'trimsize unit of measure updated'
		END
		ELSE BEGIN
			SET @v_errmsg = 'trimsize unit of measure unchanged'
		END

		EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@i_level,3
	END
	/*     END SPROC     */
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.[imp_300012058001]
	TO PUBLIC
GO

