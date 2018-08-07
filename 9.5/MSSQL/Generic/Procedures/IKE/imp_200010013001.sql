/******************************************************************************
**  Name: imp_200010013001
**  Desc: IKE Title must exist
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010013001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010013001]
GO

CREATE PROCEDURE dbo.imp_200010013001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Title must exist */

BEGIN 

DECLARE	@v_elementval 		VARCHAR(4000),
	@v_errcode 		INT,
	@v_errlevel 		INT,
	@v_msg 			VARCHAR(4000),
	@v_bookkey  INT,
    @v_count  INT
    set @v_bookkey=dbo.imp_get_bookkey_from_row(@i_batch,@i_row)
    select @v_count=count(*)
      from book
      where bookkey=@v_bookkey
	IF @v_count=0
      BEGIN
        set @v_msg='Tile must exists to be updated'
        EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, 3, 2
      END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200010013001] to PUBLIC 
GO
