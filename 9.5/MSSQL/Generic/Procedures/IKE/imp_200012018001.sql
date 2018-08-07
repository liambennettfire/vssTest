/******************************************************************************
**  Name: imp_200012018001
**  Desc: IKE Check is Valid Pub Year (4-digit)
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200012018001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200012018001]
GO

CREATE PROCEDURE dbo.imp_200012018001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Check is Valid Pub Year (4-digit) */

BEGIN 

DECLARE @v_elementval 		VARCHAR(4000),
	@v_errcode 		INT,
	@v_valid_date 		INT,
	@v_errlevel 		INT,
	@v_msg 			VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000),
	@v_num			int
BEGIN
	SET @v_num = 0
	SET @v_errcode = 0
	SET @v_errlevel = 0
	SET @v_valid_date = 0
	SET @v_msg = 'valid pub month'

	SELECT @v_elementdesc = elementdesc
	FROM imp_element_defs
	WHERE elementkey =  @i_elementkey

	SELECT @v_elementval = COALESCE(originalvalue,'')
	FROM imp_batch_detail 
	WHERE  batchkey = @i_batch
			AND row_id = @i_row
			AND elementkey =  @i_elementkey
			AND elementseq =  @i_elementseq
			
	IF IsNumeric(@v_elementval) = 1 AND LEN(@v_elementval) = 4 AND CONVERT(INT,SUBSTRING(@v_elementval,1,1))> 0
		BEGIN
			SET @v_msg = @v_elementdesc+' is a valid year'
			SET @v_errlevel = 1
		END
	ELSE IF IsNumeric(@v_elementval) = 1 AND LEN(@v_elementval) < 4
		BEGIN
			SET @v_msg = @v_elementdesc+' value ('+@v_elementval+ ') and will not be updated because it is not valid 4 digit year'
			SET @v_errlevel = 2
		END

	ELSE 
		BEGIN
			SET @v_msg = @v_elementdesc+' value ('+@v_elementval+ ')  and will not be updated because is is not a valid year'
			SET @v_errlevel = 2
		END


	IF @v_errlevel >= @i_rpt
		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
		END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200012018001] to PUBLIC 
GO
