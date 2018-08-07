/******************************************************************************
**  Name: imp_200000000007
**  Desc: IKE Field Length greater than 255 - Warning
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200000000007]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200000000007]
GO

CREATE PROCEDURE dbo.imp_200000000007 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Field Length greater than 255 - Warning */

BEGIN 

SET NOCOUNT ON
/* STANDARD BATCH VARIABLES  */
DECLARE	@v_elementval 		VARCHAR(4000),
	@v_errcode 		INT,
	@v_valid_date 		INT,
	@v_errlevel 		INT,
	@v_msg 			VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000)
BEGIN
	
	SELECT @v_elementdesc = elementdesc
	FROM imp_element_defs
	WHERE elementkey =  @i_elementkey

	SELECT @v_elementval = COALESCE(originalvalue,'')
	FROM imp_batch_detail 
	WHERE  batchkey = @i_batch
			AND row_id = @i_row
			AND elementkey =  @i_elementkey
			AND elementseq =  @i_elementseq
			

	IF LEN(@v_elementval) < 256
		BEGIN
			SET @v_msg = @v_elementdesc+' length is acceptable'
			SET @v_errlevel = 1
		END
	ELSE
		BEGIN
			SET @v_msg = 'WARNING:'+@v_elementdesc+' has a length of ('+CAST (LEN(@v_elementval) AS VARCHAR(20))+').  The max column length is 255. The field will not be updated'
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

GRANT EXECUTE ON dbo.[imp_200000000007] to PUBLIC 
GO
