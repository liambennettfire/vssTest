/******************************************************************************
**  Name: imp_300010030001
**  Desc: IKE workkey update
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010030001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010030001]
GO

CREATE PROCEDURE dbo.imp_300010030001 
  
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

declare
  @v_elementval    VARCHAR(4000),
  @v_new_val    int,
  @v_old_val    int,
  @v_elementkey    INT,
  @v_elementdesc     VARCHAR(4000),
  @v_bookkey    INT,
  @v_printkey    INT,
  @v_workkey    INT,
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000)

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT 
      @v_elementval =  originalvalue,
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey
      
  select @v_old_val=workkey
    from book
    where bookkey=@v_bookkey
    
  select @v_new_val=bookkey
    from isbn
    where ean13=replace(@v_elementval,'-','')
  if @v_new_val is null
    select @v_new_val=bookkey
      from isbn
      where isbn10=replace(@v_elementval,'-','')
    
  if (@v_new_val is not null and @v_old_val is null) or 
     (@v_new_val<>@v_old_val)
    begin
      UPDATE book
        SET
          workkey = cast(@v_new_val as int),
          lastuserid =  @i_userid, 
          lastmaintdate = getdate()
        where bookkey=@v_bookkey
      SET @o_writehistoryind = 1
      set @v_errmsg='workkey updated'
    end
  else
    begin
      set @v_errmsg='workkey unchanged'
    end
    
  IF @v_errcode >= @i_level
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
    END
END

