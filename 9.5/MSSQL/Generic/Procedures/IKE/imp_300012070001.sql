/******************************************************************************
**  Name: imp_300012070001
**  Desc: IKE Copyright Year
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012070001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012070001]
GO

CREATE PROCEDURE dbo.imp_300012070001 
  
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

/* Copyright Year */

BEGIN 

DECLARE
  @v_elementval    int,
  @v_orgval    int,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_Grade_org    float,
  @v_bookkey     INT

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Copyright Year'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT @v_elementval =  COALESCE(originalvalue,0)
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100012070
  select @v_orgval=copyrightyear
    from bookdetail
    where bookkey=@v_bookkey
    
  IF coalesce(@v_orgval,'') <> coalesce(@v_elementval,'')  
    BEGIN
      UPDATE bookdetail
        SET copyrightyear= @v_elementval,
            lastuserid = @i_userid,
            lastmaintdate = getdate()
        WHERE bookkey = @v_bookkey
      SET @o_writehistoryind = 1
      SET @v_errmsg = @v_errmsg +' updated '
    END
  else
    begin
      SET @o_writehistoryind = 0
      SET @v_errmsg = @v_errmsg +' unchanged '
    end

  EXECUTE imp_write_feedback @i_batch, @i_row, '100012070', @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3     
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012070001] to PUBLIC 
GO
