/******************************************************************************
**  Name: imp_300010046001
**  Desc: IKE Apply template
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010046001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010046001]
GO
CREATE PROCEDURE [dbo].[imp_300010046001] 
  
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

/* Apply template */

BEGIN 

DECLARE
  @v_count    INT,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_templatedesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_bookkey     INT,  
  @v_templatekey     INT, 
  @v_printingkey int,
  @v_err int,
  @v_msg varchar(300),
  @v_prop_bookkey     INT  

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Apply template '
  if @i_newtitleind=1
    begin
      SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
      SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
      SELECT @v_templatekey = cast(originalvalue as int)
        FROM imp_batch_detail 
        WHERE batchkey = @i_batch
          AND row_id = @i_row
          AND elementseq = @i_elementseq
          AND elementkey = 100010046
      --
      exec qtitle_copy_title
        @v_bookkey,
        @v_printingkey,
        @v_templatekey,
        @v_printingkey,
        null,
        null,
        @i_userid,
        null,
        @v_err output,
        @v_msg output
      if @v_err <> 0 
        begin
          EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_msg, 3, 3 
        end
      else
        begin
          select @v_templatedesc=title
            from book 
            where bookkey=@v_templatekey
          set @v_msg= 'template applied: ('+coalesce(CAST(@v_templatekey as varchar),'n/a')+' '+coalesce(@v_templatedesc,'n/a')
          EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'template applied', 1, 3 
        end
    END
END
end

