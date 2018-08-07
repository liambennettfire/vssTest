/******************************************************************************
**  Name: imp_300026018001
**  Desc: IKE Set author displayname to auto generate
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026018001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026018001]
GO

CREATE PROCEDURE dbo.imp_300026018001 
  
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

/* Set author displayname to auto generate */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
   @v_elementkey    INT,
   @v_elementdesc     VARCHAR(4000),
   @v_errcode     INT,
   @v_errmsg     VARCHAR(4000),
   @v_authorkey     INT,
   @v_autoind     INT,
   @v_autoind_org     INT

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Author displayname to auto generate'
  SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)
--print '12018 '+@i_contactkeyset
  SELECT @v_elementval =  originalvalue, @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey

  SET @v_autoind = cast(@v_elementval  as int)
    
  SELECT @v_autoind_org = autodisplayind
    FROM globalcontact
    WHERE globalcontactkey = @v_authorkey

  IF coalesce(@v_autoind_org,0) <> coalesce(@v_autoind,0)
    BEGIN
      UPDATE globalcontact
        SET
          autodisplayind = @v_autoind,
          lastuserid = @i_userid,
          lastmaintdate = GETDATE()
        WHERE globalcontactkey = @v_authorkey
      SET @o_writehistoryind = 1
      SET @v_errmsg = 'Author auto displayname set'
    END
  else
    begin
      SET @v_errmsg = 'Author auto displayname unchnaged'
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

GRANT EXECUTE ON dbo.[imp_300026018001] to PUBLIC 
GO
