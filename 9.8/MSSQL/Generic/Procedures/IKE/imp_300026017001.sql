/******************************************************************************
**  Name: imp_300026017001
**  Desc: IKE author title
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_300026017001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_300026017001]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[imp_300026017001] 
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

/*  AUTHOR TITLE */

DECLARE 
   @v_elementval    VARCHAR(4000),
   @v_elementkey    INT,
   @v_elementdesc     VARCHAR(4000),
   @v_errcode     INT,
   @v_errmsg     VARCHAR(4000),
   @v_authorkey     INT,
   @v_new_title    VARCHAR(75),
   @v_cur_title    VARCHAR(75)

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Author Title'
  SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)

  SELECT @v_elementval =  originalvalue,
    @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey

    SET @v_new_title = @v_elementval 
    
  SELECT @v_cur_title = COALESCE(title,'')
    FROM author
    WHERE authorkey = @v_authorkey

  IF @v_new_title <> @v_cur_title
    BEGIN
      UPDATE author
        SET title = @v_new_title,
            lastmaintdate = GETDATE()
        WHERE authorkey = @v_authorkey

      SET @o_writehistoryind = 1
    END

    IF @v_errcode >= @i_level
      BEGIN
        EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
      END
END
GO