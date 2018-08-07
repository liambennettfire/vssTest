/******************************************************************************
**  Name: imp_300012062001
**  Desc: IKE Add/Replace Book Weight
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012062001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012062001]
GO

CREATE PROCEDURE dbo.imp_300012062001 
  
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

/* Add/Replace Book Weight */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    INT,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_new_bookweight  float,
  @v_cur_bookweight  float,
  @v_bookkey     INT,
  @v_count    INT
  
BEGIN
  SET @v_count = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Book Weight Update...'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED BOOK WEIGHT    */
  SELECT @v_elementval =  originalvalue, @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey

/* GET CURRENT CURRENT BOOK WEIGHT VALUE    */
  SELECT @v_count = COUNT(*)
    FROM booksimon  
    WHERE bookkey = @v_bookkey

	begin try
		SET @v_new_bookweight = CONVERT(float,@v_elementval)
	end try
	begin catch
		SET @v_new_bookweight = 0
		SET @v_errmsg='The Book Weight was not a FLOAT (number with a decimal pont) for this title .... update skipped'
		SET @i_level=2				
		EXECUTE imp_write_feedback @i_batch, @i_row,@v_elementkey , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
		RETURN
	end catch
  

  IF @v_count = 1
    BEGIN
      SELECT @v_cur_bookweight = COALESCE(bookweight,0)
        FROM booksimon
        WHERE bookkey=@v_bookkey 

      IF @v_cur_bookweight <> @v_elementval
        BEGIN
          UPDATE booksimon
            SET  bookweight = @v_new_bookweight,
                 lastuserid = @i_userid,
                 lastmaintdate = GETDATE()
            WHERE bookkey = @v_bookkey
            SET @o_writehistoryind = 1
            SET @v_errmsg = 'Book Weight updated'
        END
      else
        begin
          SET @v_errmsg = 'Book Weight unchanged'
        end
    END
    IF @v_count = 0
      BEGIN
        INSERT INTO booksimon (bookkey,bookweight,lastuserid,lastmaintdate)
          VALUES(@v_bookkey,@v_new_bookweight,@i_userid,GETDATE())
        SET @o_writehistoryind = 1
        SET @v_errmsg = 'Book Weight added'
     END

  EXECUTE imp_write_feedback @i_batch, @i_row,@v_elementkey , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012062001] to PUBLIC 
GO
