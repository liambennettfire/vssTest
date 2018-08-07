/******************************************************************************
**  Name: imp_200010011001
**  Desc: IKE leadkey check
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010011001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010011001]
GO

CREATE PROCEDURE dbo.imp_200010011001
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

BEGIN 
/*    START SPROC    */
SET NOCOUNT ON
/* STANDARD BATCH VARIABLES  */
DECLARE  @v_elementval     VARCHAR(4000),
  @v_errcode  INT,
  @v_count INT,
  @v_errlevel INT,
  @v_msg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000)
BEGIN
  
  select @v_count = count(*) 
    from  imp_batch_detail db, imp_element_defs ed
    where row_id=@i_row
      and db.elementkey=ed.elementkey
      and ed.leadkeyname='bookkey'
  IF @v_count = 0
    BEGIN
      set @v_msg = 'Title lacks an element with a leadkey(bookkey)'
      EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    END

END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200010011001] to PUBLIC 
GO
