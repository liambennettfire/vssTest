/******************************************************************************
**  Name: imp_300026051001
**  Desc: IKE Author Address 1 primary
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026051001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026051001]
GO

CREATE PROCEDURE dbo.imp_300026051001 
  
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

/* Author Address 1 primary */

BEGIN 

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_elementkey    INT,
  @v_elementdesc     VARCHAR(4000),
  @v_authorkey    INT,
  @v_globalcontactaddresskey    INT,
  @v_primaryind     INT,
  @v_primaryind_org     INT,
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000)
 
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)
  SELECT 
      @v_elementval =  originalvalue,
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d, imp_element_defs ed
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND b.elementkey = ed.elementkey
      AND d.DMLkey = @i_dmlkey

  set @v_primaryind=cast(@v_elementval as int)
  select @v_globalcontactaddresskey=globalcontactaddresskey
    from globalcontactauthor auth,globalcontactaddress addr
      where auth.scopetag='addr1'
        and auth.masterkey=@v_authorkey
        and auth.detailkey=addr.globalcontactaddresskey
  select @v_primaryind_org=primaryind
    from globalcontactaddress 
      where globalcontactaddresskey=@v_globalcontactaddresskey

  if coalesce(@v_primaryind_org,0)<>coalesce(@v_primaryind,0)
    begin
      UPDATE globalcontactaddress
        SET
          primaryind = @v_primaryind,
          lastuserid =  @i_userid, 
          lastmaintdate = getdate()
        where globalcontactaddresskey=@v_globalcontactaddresskey
      SET @o_writehistoryind = 1
      set @v_errmsg='Author Address 1 primary ind updated'
    end
  else
    begin
      set @v_errmsg='Author Address 1 primary ind unchanged'
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

GRANT EXECUTE ON dbo.[imp_300026051001] to PUBLIC 
GO
