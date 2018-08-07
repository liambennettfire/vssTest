/******************************************************************************
**  Name: imp_300012076001
**  Desc: IKE Title status
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012076001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012076001]
GO

CREATE PROCEDURE dbo.imp_300012076001 
  
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

/* Title status */

BEGIN 

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_datacode    INT,
  @v_datacode_org    INT,
  @v_datadesc     VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_count    int,
  @v_bookkey     INT,
  @v_printingkey     INT

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Title status'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)

  SELECT @v_elementval = originalvalue
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100012076
  select @v_count=count(*)
    from gentables
    where tableid=149
      and datadesc=@v_elementval
        
  if @v_count=1
    begin
      select @v_datacode=datacode
        from gentables
        where tableid=149
          and datadesc=@v_elementval
      select @v_datacode_org=titlestatuscode
        from book
        where bookkey=@v_bookkey
      if coalesce(@v_datacode_org,-1)<>coalesce(@v_datacode,-1)
        begin
          update book
            set titlestatuscode=@v_datacode
            where bookkey=@v_bookkey
          SET @o_writehistoryind = 0
          set @v_errmsg='Title status updated'
          EXECUTE imp_write_feedback @i_batch, @i_row, '100012076', @i_elementseq ,@i_dmlkey , @v_errmsg, 1, 3     
        end
      else
        begin
          set @v_errmsg='Title status unchanged'
          EXECUTE imp_write_feedback @i_batch, @i_row, '100012076', @i_elementseq ,@i_dmlkey , @v_errmsg, 1, 3     
        end
    end

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012076001] to PUBLIC 
GO
