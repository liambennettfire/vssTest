/******************************************************************************
**  Name: imp_100012033001
**  Desc: IKE ONIX: Load Title from TitleWithoutprefix/TitleText
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012033001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012033001]
GO

CREATE PROCEDURE dbo.imp_100012033001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* ONIX: Load Title from TitleWithoutprefix/TitleText */

BEGIN 

DECLARE  
  @v_errcode int,
  @v_titletype varchar(4000),
  @v_titleprefix varchar(4000),
  @v_titlewithoutprefix varchar(4000),
  @v_titletext varchar(4000),
  @v_title varchar(4000),
  @v_cnt int,
  @v_errlevel int,
  @v_msg varchar(500)
BEGIN
  set @v_errlevel=1
  set @v_msg='Load ONIX Title info'
  --
  select @v_titletype=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012033
      and elementseq=@i_elementseq
  select @v_titleprefix=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012034
      and elementseq=@i_elementseq
  select @v_titlewithoutprefix=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012035
      and elementseq=@i_elementseq
  select @v_titletext=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012036
      and elementseq=@i_elementseq

  if @v_titletext is not null
    begin
      set @v_title=@v_titletext
    end
  else
    begin
     if @v_titlewithoutprefix is not null
       begin
         set @v_title=@v_titlewithoutprefix
       end
     else
       begin
         set @v_msg='missing title info'
         set @v_errlevel=2
       end
    end
  --
  if @v_errlevel=1 and @v_titletype is not null
    begin
      if @v_titletype = '01'
        begin
          select @v_cnt=count(*)
            from imp_batch_detail
            where batchkey=@i_batchkey
              and row_id=@i_row
              and elementkey=100012028
              and elementseq=@i_elementseq
          if @v_cnt=0
            begin
              insert into imp_batch_detail
                (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
                values
               (@i_batchkey,@i_row,@i_elementseq,100012028,@v_titleprefix ,@i_userid,getdate()) 
            end
          select @v_cnt=count(*)
            from imp_batch_detail
            where batchkey=@i_batchkey
              and row_id=@i_row
              and elementkey=100012027
              and elementseq=@i_elementseq
          if @v_cnt=0
            begin
              insert into imp_batch_detail
                (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
                values
               (@i_batchkey,@i_row,@i_elementseq,100012027,@v_title ,@i_userid,getdate()) 
            end
        end
      if @v_titletype = '05'
        begin
          select @v_cnt=count(*)
            from imp_batch_detail
            where batchkey=@i_batchkey
              and row_id=@i_row
              and elementkey=100012024
              and elementseq=@i_elementseq
          if @v_cnt=0
            begin
              insert into imp_batch_detail
                (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
                values
               (@i_batchkey,@i_row,@i_elementseq,100012024,@v_title ,@i_userid,getdate()) 
            end
        end
    end
  else
    begin
      set @v_errlevel=3
      set @v_msg='Failure to load title '+coalesce(@v_title,'n/a')
    end

  IF @v_errlevel >= @i_level
    begin
      exec imp_write_feedback @i_batchkey, @i_row, 100012033, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
    END
  --
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012033001] to PUBLIC 
GO
