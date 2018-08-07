/******************************************************************************
**  Name: imp_200010019001
**  Desc: IKE Related Product validation
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010019001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010019001]
GO

CREATE PROCEDURE dbo.imp_200010019001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

BEGIN 

DECLARE 
	@v_errcode			INT
	,@v_errlevel 		INT
	,@v_errmsg			VARCHAR(4000)
	,@v_count			INT
	,@Debug				INT

	SET @Debug = 0
	SET @v_errcode = 0
	SET @v_errlevel = 0
	SET @v_errmsg = 'Related Products'
	
	if @Debug<>0 print 'processing imp_200010019001'
  
	/**************************************************************
	INSTRUCTIONS:
	01) Make sure all Related Products nodes for the current sequence have data
	02) These VALUES are in these element keys 100010017 & 100010018 & 100010019 for current @i_elementseq and are found in imp_batch_detail
	**************************************************************/  
  
	SELECT @v_count=count(*)
	FROM imp_batch_detail b
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = 100010017
	IF @v_count<>1 
		BEGIN
			SET @v_errlevel = 3
			SET @v_errmsg = 'Related Product Code (100010017) could not be found in the xmal for this sequence'
			EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
			RETURN
		END

	SELECT @v_count=count(*)
	FROM imp_batch_detail b
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = 100010018
	IF @v_count<>1 
		BEGIN
			SET @v_errlevel = 3
			SET @v_errmsg = 'Related ProductID type (100010018) could not be found in the xmal for this sequence'
			EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
			RETURN
		END
		
	SELECT @v_count=count(*)
	FROM imp_batch_detail b
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = 100010019
	IF @v_count<>1 
		BEGIN
			SET @v_errlevel = 3
			SET @v_errmsg = 'Related ProductID value (100010019) could not be found in the XML for this sequence'
			EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
			RETURN
		END   
	
	SET @v_errlevel = 1
	SET @v_errmsg = 'Related Product Sequence (100010017, 100010018, and 100010019) is valid'
	EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200010019001] to PUBLIC 
GO
