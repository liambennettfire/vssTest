/******************************************************************************
**  Name: imp_300026040001
**  Desc: IKE author addrs 1
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026040001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026040001]
GO

CREATE PROCEDURE dbo.imp_300026040001
  
  @i_batch int, 
  @i_row int , 
  @i_dmlkey bigint, 
  @i_titlekeyset varchar(500),
  @i_contactkeyset varchar(500),
  @i_templatekey int,
  @i_elementseq int,
  @i_level int,
  @i_userid varchar(50),
  @i_newtitleind int,
  @i_newcontactind int,
  @o_writehistoryind int output
AS

BEGIN 
/*    START SPROC    */
DECLARE 
  @v_elementval        varchar(4000),
  @v_elementkey        int,
  @v_errcode           int,
  @v_errmsg            varchar(4000),
  @v_elementdesc       varchar(4000),
  @v_contactkey        int,
  @v_new_val           varchar(75),
  @v_cur_val           varchar(75)
BEGIN
  set @o_writehistoryind = 0
  set @v_errcode = 1
  set @v_errmsg = 'Author (1st) Address Line 1'
  set @v_contactkey = dbo.resolve_keyset(@i_contactkeyset,1)

  SELECT @v_elementval=originalvalue,@v_elementkey=elementkey
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100026040
  set @v_new_val = @v_elementval
  SELECT @v_cur_val=address1
    FROM author
    WHERE authorkey = @v_contactkey
  IF coalesce(@v_new_val,'') <> coalesce(@v_cur_val,'') 
    begin
      UPDATE author
        SET address1 = @v_new_val
        WHERE authorkey = @v_contactkey
      set @o_writehistoryind = 1
      set @v_errcode = 1
      set @v_errmsg = @v_errmsg+' updated'
    end
  ELSE
    begin
      set @v_errcode = 1
      set @v_errmsg = @v_errmsg+' unchanged'
    end

  exec imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3

END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300026040001] to PUBLIC 
GO
