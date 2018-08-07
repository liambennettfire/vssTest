/******************************************************************************
**  Name: imp_300012072001
**  Desc: IKE Grade High
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012072001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012072001]
GO

CREATE PROCEDURE dbo.imp_300012072001 
  
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

/* Grade High */

BEGIN 

DECLARE
  @v_elementval    varchar(10),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_Grade_org    varchar(10),
  @v_bookkey     INT

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Grade High'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT @v_elementval =  COALESCE(originalvalue,' ')
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100012072
  select @v_Grade_org=Gradehigh
    from bookdetail
    where bookkey=@v_bookkey

  IF @v_Grade_org <> @v_elementval or
     (@v_Grade_org is null and @v_elementval is not null)  
    BEGIN
      UPDATE bookdetail
        SET Gradehigh= @v_elementval,
            lastuserid = @i_userid,
            lastmaintdate = getdate()
        WHERE bookkey = @v_bookkey
      SET @o_writehistoryind = 1
      SET @v_errmsg = @v_errmsg +' updated'
    END
  else
    begin
      SET @o_writehistoryind = 0
      SET @v_errmsg = @v_errmsg +' unchanged'
    end

  EXECUTE imp_write_feedback @i_batch, @i_row, '100012072', @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3     
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012072001] to PUBLIC 
GO
