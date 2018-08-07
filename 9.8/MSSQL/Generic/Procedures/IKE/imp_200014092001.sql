/******************************************************************************
**  Name: imp_200014092001
**  Desc: IKE check territory template
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

IF EXISTS (SELECT * FROM dbo.sysobjects	WHERE id = object_id(N'[dbo].[imp_200014092001]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_200014092001]
GO

CREATE PROCEDURE dbo.imp_200014092001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* check territory template */

BEGIN 

DECLARE	@v_elementval 		VARCHAR(4000),
	@v_count 		INT,
	@v_errcode 		INT,
	@v_errlevel 		INT,
	@v_msg 			  VARCHAR(4000),
	@v_template_value  VARCHAR(4000),
    @v_value1  VARCHAR(4000),
    @v_value2  VARCHAR(4000)
    
    select @v_template_value=originalvalue
      from imp_batch_detail
      where batchkey=@i_batch
        and row_id=@i_row
        and elementseq=@i_elementseq
        and elementkey=@i_elementkey

	select @v_count=COUNT(*) from taqproject where externalcode=@v_template_value
    
	IF coalesce(@v_count,0)<1
      BEGIN
        set @v_msg='Invalid Territory Right Template ('+@v_template_value+')'
        set @v_errlevel=2
        EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
      END
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200014092001] to PUBLIC 
GO
