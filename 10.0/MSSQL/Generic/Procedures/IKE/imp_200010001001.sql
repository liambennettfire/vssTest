/******************************************************************************
**  Name: imp_200010001001
**  Desc: IKE ISBN10 Length Check
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010001001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010001001]
GO

CREATE PROCEDURE dbo.imp_200010001001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* ISBN10 Length Check */

BEGIN 

SET NOCOUNT ON
/* STANDARD BATCH VARIABLES  */
DECLARE	@v_elementval 		VARCHAR(4000),
	@v_errcode 		INT,
	@v_errlevel 		INT,
	@v_msg 			VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000)
/* RULE VARIABLES		*/
DECLARE @v_checkdigit		CHAR(1),
	@v_isbn9		VARCHAR(20)		

	SET @v_errlevel = 1
	SET @v_msg = 'ISBN 10 has the correct length'

	BEGIN

		SELECT @v_elementval =  COALESCE(originalvalue,'')
		FROM imp_batch_detail 
		WHERE batchkey = @i_batch
				AND row_id = @i_row
				AND elementseq = @i_elementseq
				AND elementkey = @i_elementkey
				


/*  VERIFY THAT THE ISBN10 HAS TEN CHARACTERS	*/
	IF LEN(@v_elementval)<> 10     
		BEGIN      
			SET @v_msg = 'ISBN10 is not the proper length.  Verify the isbn value'      
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

GRANT EXECUTE ON dbo.[imp_200010001001] to PUBLIC 
GO
