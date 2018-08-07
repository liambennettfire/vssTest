/******************************************************************************
**  Name: imp_300026001001
**  Desc: IKE Update Author First Name
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026001001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026001001]
GO

CREATE PROCEDURE dbo.imp_300026001001 
  
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

/* Update Author First Name */

BEGIN 

DECLARE  @v_elementval    VARCHAR(4000),
  @v_elementkey    INT,
  @v_elementdesc     VARCHAR(4000),
  @v_authorkey    INT,
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000),
  @v_cur_firstname  VARCHAR(75)

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)

  SELECT @v_elementval =  originalvalue,
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey
  select @v_cur_firstname=coalesce(firstname,'')
    from author
    WHERE authorkey = @v_authorkey
  if @v_cur_firstname<>@v_elementval
    begin
      UPDATE author
        SET firstname = @v_elementval
        WHERE authorkey = @v_authorkey
      SET @v_errmsg = 'Author First Name Updated'

      --mk20131003>
      SET @o_writehistoryind = 1
      
    end
  else
    begin
      SET @v_errmsg = 'Author First Name Unchanged'
    end
  IF @v_errcode >= @i_level
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
    END


END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300026001001] to PUBLIC 
GO
