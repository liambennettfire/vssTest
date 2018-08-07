/******************************************************************************
**  Name: imp_200010001002
**  Desc: IKE ISBN10 Check for Dashes
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010001002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010001002]
GO

CREATE PROCEDURE dbo.imp_200010001002 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* ISBN10 Check for Dashes  */

BEGIN 

SET NOCOUNT ON
/* STANDARD BATCH VARIABLES  */
DECLARE	@v_elementval 		VARCHAR(4000),
	@v_errcode 		INT,
	@v_errlevel 		INT,
	@v_msg 			VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000)
	

	SET @v_errlevel = 1
	SET @v_msg = 'ISBN 10 has valid characters (no dashes)'

	BEGIN

		SELECT @v_elementval =  COALESCE(originalvalue,'')
		FROM imp_batch_detail 
		WHERE batchkey = @i_batch
				AND row_id = @i_row
				AND elementseq = @i_elementseq
				AND elementkey = @i_elementkey
				


/*  VERIFY THAT THE ISBN10 IS NOT REALLY ISBN13	*/
		IF @v_elementval like '%-%'
			BEGIN
				SET @v_msg = 'ISBN10 appears to have dashes(-).  Verify your column mapping'
				SET @v_errlevel = 3
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

GRANT EXECUTE ON dbo.[imp_200010001002] to PUBLIC 
GO
