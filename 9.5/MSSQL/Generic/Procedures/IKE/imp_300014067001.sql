/******************************************************************************
**  Name: imp_300014067001
**  Desc: IKE Add/Replace Edition number
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014067001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014067001]
GO

CREATE PROCEDURE dbo.imp_300014067001 
  
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

/* Add/Replace Edition number */

BEGIN 

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_orgval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_lobkey     INT,
  @v_bookkey     INT,
  @v_tableid int,
  @v_datacode int,
  @v_datacode_org int,
  @v_hit      INT
  
BEGIN
  SET @v_hit = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Edition number '
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  Title Type       */
  SELECT @v_elementval =  originalvalue,
      @v_elementkey = b.elementkey,
      @v_tableid=ed.tableid
    FROM imp_batch_detail b , imp_DML_elements d, imp_element_defs ed
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey
      AND d.elementkey = ed.elementkey

  SELECT @v_datacode_org = editionnumber
    FROM bookdetail
    WHERE bookkey=@v_bookkey 

  SELECT @v_hit = COUNT(*)
    FROM gentables
    WHERE tableid = @v_tableid
      AND datadesc = @v_elementval

  IF @v_hit = 1
    BEGIN
      SELECT @v_datacode = datacode
        FROM gentables
        WHERE tableid = @v_tableid 
          AND datadesc = @v_elementval
      IF coalesce(@v_datacode,0) <> coalesce(@v_datacode_org,0)
        BEGIN
          UPDATE bookdetail
            SET editionnumber = @v_datacode,
              lastuserid = @i_userid,
              lastmaintdate = GETDATE()
            WHERE bookkey = @v_bookkey
          SET @o_writehistoryind = 1
          SET @v_errmsg =@v_errmsg+' updated'
        END
      else
        begin
          SET @o_writehistoryind = 0
          SET @v_errmsg =@v_errmsg+' unchanged '
        end
    END
  ELSE      
    BEGIN
      SET @v_errcode = 2
      SET @v_errmsg = 'Can not find ('+@v_elementval+') value on User Table '+cast(@v_tableid as varchar)
    END
    
  IF @v_errcode < 2
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
    END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300014067001] to PUBLIC 
GO
