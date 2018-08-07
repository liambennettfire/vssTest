/******************************************************************************
**  Name: imp_200014090001
**  Desc: IKE check territory values
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200014090001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200014090001]
GO

CREATE PROCEDURE dbo.imp_200014090001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* check territory values */

BEGIN 

DECLARE	@v_elementval 		VARCHAR(4000),
	@v_count 		INT,
	@v_errcode 		INT,
	@v_errlevel 		INT,
	@v_msg 			  VARCHAR(4000),
	@v_territory  VARCHAR(4000),
    @v_value1  VARCHAR(4000),
    @v_value2  VARCHAR(4000)
    
    select @v_territory=originalvalue
      from imp_batch_detail
      where batchkey=@i_batch
        and row_id=@i_row
        and elementseq=@i_elementseq
        and elementkey=@i_elementkey
    
	IF @v_count>1
      BEGIN
        set @v_msg='Invalid Territory Right value for add ('+@v_territory+')'
        set @v_errlevel=3
        EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
      END
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_200014090001 to PUBLIC 
GO
