/******************************************************************************
**  Name: imp_300026013001
**  Desc: IKE Add/Replace Author Biography
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026013001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026013001]
GO

CREATE PROCEDURE dbo.imp_300026013001 
  
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

/* Add/Replace Author Biography */

BEGIN 

DECLARE @v_elementkey     INT,
  @v_source_pointer   BINARY(16),
  @v_destination_pointer   BINARY(16),
  @v_lobkey     INT,
  @v_row_count     INT,
  @v_errmsg     VARCHAR(4000),
  @v_errcode     INT,
  @v_authorkey    INT

BEGIN
  SET @v_errcode = 1
  SET @v_errmsg='Author Biography unchanged'
  SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)

  SELECT @v_elementkey = elementkey
    FROM imp_dml_elements
    WHERE dmlkey = @i_dmlkey

  SELECT @v_lobkey = lobkey
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = @v_elementkey

  SELECT @v_source_pointer = TEXTPTR(textvalue)
    FROM imp_batch_lobs
    WHERE lobkey=@v_lobkey

  SELECT @v_row_count = count(*)
    FROM author
    WHERE authorkey = @v_authorkey

  IF @v_row_count = 1
    BEGIN
      UPDATE author
        SET biography = 'x'
        WHERE authorkey = @v_authorkey
      SET @v_errmsg='Author Biography updated'
      SELECT @v_destination_pointer = TEXTPTR(biography)
        FROM author
        WHERE authorkey = @v_authorkey
      UPDATETEXT author.biography @v_destination_pointer 0 null imp_batch_lobs.textvalue @v_source_pointer 
    END
   
  IF @v_errcode >= @i_level
    BEGIN
          EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode,3
    END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300026013001] to PUBLIC 
GO
