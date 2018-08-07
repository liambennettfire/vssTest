/******************************************************************************
**  Name: imp_300024016001
**  Desc: IKE Globalcontact department
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300024016001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300024016001]
GO

CREATE PROCEDURE dbo.imp_300024016001 
  
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

/* Globalcontact department */

BEGIN 

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_new_val    int,
  @v_old_val    int,
  @v_elementkey    INT,
  @v_elementdesc     VARCHAR(4000),
  @v_bookkey    INT,
  @v_printkey    INT,
  @v_globalcontactkey    INT,
  @v_bookcontactkey    INT,
  @v_printingkey  int,
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000),
  @v_cur_lastname  VARCHAR(75)

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  set @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  set @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
  SET @v_globalcontactkey = dbo.resolve_keyset(@i_contactkeyset,1)
  select @v_bookcontactkey=bookcontactkey
    from bookcontact
    where bookkey=@v_bookkey
      and printingkey=@v_printingkey
      and globalcontactkey=@v_globalcontactkey

  SELECT 
      @v_elementval =  originalvalue,
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey
  select @v_new_val=datacode
    from gentables
    where datadesc=@v_elementval
  select @v_old_val=departmentcode
    from bookcontactrole
    where bookcontactkey=@v_bookcontactkey
  if coalesce(@v_new_val,'')<>coalesce(@v_old_val,'')
    begin
      UPDATE bookcontactrole
        SET
          departmentcode = @v_new_val,
          lastuserid =  @i_userid, 
          lastmaintdate = getdate()
        where bookcontactkey=@v_bookcontactkey
      SET @o_writehistoryind = 1
      set @v_errmsg='contact department updated'
    end
  else
    begin
      set @v_errmsg='contact department unchanged'
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

GRANT EXECUTE ON dbo.[imp_300024016001] to PUBLIC 
GO
