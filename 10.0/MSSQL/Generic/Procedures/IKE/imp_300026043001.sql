/******************************************************************************
**  Name: imp_300026043001
**  Desc: IKE author addr city
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026043001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026043001]
GO

CREATE PROCEDURE dbo.imp_300026043001 
  
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

/* Author 1 City */

BEGIN 

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_orgval    VARCHAR(4000),
  @v_elementkey    INT,
  @v_elementdesc     VARCHAR(4000),
  @v_authorkey    INT,
  @v_tableid     INT,
  @v_datacode     INT,
  @v_datacode_org     INT,
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000)
 
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)

  SELECT 
      @v_elementval =  originalvalue,
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey
  select @v_orgval=City
    from author
    where authorkey=@v_authorkey
  if coalesce(@v_orgval,'')<>coalesce(@v_elementval,'')
    begin
      UPDATE author
        SET
          City = @v_elementval,
          lastuserid =  @i_userid, 
          lastmaintdate = getdate()
        where authorkey=@v_authorkey
      SET @o_writehistoryind = 1
      set @v_errmsg='Author 1 City updated'
    end
  else
    begin
      set @v_errmsg='Author 1 City unchanged'
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

GRANT EXECUTE ON dbo.[imp_300026043001] to PUBLIC 
GO
