/******************************************************************************
**  Name: imp_200000000006
**  Desc: IKE Valid Date Errors
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200000000006]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200000000006]
GO

CREATE PROCEDURE dbo.imp_200000000006 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Valid Date Errors */

BEGIN 

/* VALID DATE - ERRORS	*/
DECLARE @v_elementval		VARCHAR(4000),
  	@v_valid_date 		INT,
	@v_errlevel 		INT,
  	@v_msg	 		VARCHAR(4000),
  	@v_elementdesc 		VARCHAR(4000)
BEGIN
	SET @v_errlevel = 1
	SET @v_valid_date = 1

	SELECT @v_elementval = COALESCE(i.originalvalue,'')
	FROM imp_batch_detail i
    	WHERE i.batchkey = @i_batch
      			AND i.row_id = @i_row
      			AND i.elementkey =  @i_elementkey
      			AND i.elementseq =  @i_elementseq

 	SELECT @v_elementdesc = elementdesc
    	FROM imp_element_defs
    	WHERE elementkey = @i_elementkey

	set @v_msg = @v_elementdesc+' has a valid date'

	IF dbo.resolve_date(@v_elementval) is null
    		BEGIN
      			SET @v_errlevel = 3
      			SET @v_msg = 'FATAL ERROR (INVALID DATE): '
      			SET @v_msg = @v_msg + coalesce(@v_elementdesc, 'n/a') +': '
      			SET @v_msg = @v_msg + coalesce(@v_elementval, 'n/a') 
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

GRANT EXECUTE ON dbo.[imp_200000000006] to PUBLIC 
GO
