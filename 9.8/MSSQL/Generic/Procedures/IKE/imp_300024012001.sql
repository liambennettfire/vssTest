/******************************************************************************
**  Name: imp_300024012001
**  Desc: IKE Globalcontact middle name
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300024012001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300024012001]
GO

CREATE PROCEDURE dbo.imp_300024012001 
  
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

/* Globalcontact middle name */

BEGIN 

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_old_val    VARCHAR(4000),
  @v_elementkey    INT,
  @v_elementdesc     VARCHAR(4000),
  @v_globalcontactkey    INT,
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000),
  @v_cur_middlename  VARCHAR(75)

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_globalcontactkey = dbo.resolve_keyset(@i_contactkeyset,1)

  SELECT 
      @v_elementval =  originalvalue,
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey
  select @v_old_val=middlename
    from globalcontact
    where globalcontactkey = @v_globalcontactkey
  if coalesce(@v_elementval,'')<>coalesce(@v_old_val,'')
    begin
      UPDATE globalcontact
        SET middlename = @v_elementval
        WHERE globalcontactkey = @v_globalcontactkey
      SET @o_writehistoryind = 1
      set @v_errmsg='Globalcontact middle name updated'
    end
  else
    begin
      set @v_errmsg='Globalcontact middle name unchanged'
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

GRANT EXECUTE ON dbo.[imp_300024012001] to PUBLIC 
GO
