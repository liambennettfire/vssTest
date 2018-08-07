/******************************************************************************
**  Name: imp_300012013001
**  Desc: IKE Other Format
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012013001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012013001]
GO

CREATE PROCEDURE dbo.imp_300012013001 
  
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

/* Other Format */

BEGIN 

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_datacode    INT,
  @v_datacode_org    INT,
  @v_datadesc     VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_tableid    int,
  @v_count    int,
  @v_bookkey     INT,
  @v_printingkey     INT

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Other Format'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
  SET @v_tableid=300

  SELECT @v_elementval = originalvalue
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100012013
  select @v_count=count(*)
    from gentables
    where tableid=@v_tableid
      and datadesc=@v_elementval
        
  if @v_count=1
    begin
      select @v_datacode=datacode
        from gentables
        where tableid=@v_tableid
          and datadesc=@v_elementval
      select @v_datacode_org=formatchildcode
        from booksimon
        where bookkey=@v_bookkey
      if coalesce(@v_datacode_org,-1)<>coalesce(@v_datacode,-1)
        begin
          select @v_count=count(*)
            from booksimon
            where bookkey=@v_bookkey
          if @v_count=0
            begin
              insert into booksimon
                (bookkey,formatchildcode,lastmaintdate,lastuserid)
                values
                (@v_bookkey,@v_datacode,getdate(),@i_userid)
              SET @o_writehistoryind = 1
              set @v_errmsg='Other Format updated'
              EXECUTE imp_write_feedback @i_batch, @i_row, '100012013', @i_elementseq ,@i_dmlkey , @v_errmsg, 1, 3     
            end
          else
            begin
              update booksimon
                set
                  formatchildcode=@v_datacode,
                  lastmaintdate=getdate(),
                  lastuserid=@i_userid
                where bookkey=@v_bookkey
              SET @o_writehistoryind = 1
              set @v_errmsg='Other Format updated'
              EXECUTE imp_write_feedback @i_batch, @i_row, '100012013', @i_elementseq ,@i_dmlkey , @v_errmsg, 1, 3     
            end
        end
      else
        begin
          set @v_errmsg='Other Format unchanged'
          EXECUTE imp_write_feedback @i_batch, @i_row, '100012013', @i_elementseq ,@i_dmlkey , @v_errmsg, 1, 3     
        end
    end

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012013001] to PUBLIC 
GO
