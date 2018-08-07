if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_wh_load]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].qweb_wh_load
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE dbo.qweb_wh_load
  @i_websitekey int,
  @i_refresh_date datetime
AS

BEGIN 
  declare @bookkey  int,
    @status    int,
    @v_logkey int,
    @v_previousjobs_inprocess int,
    @v_runnote_ptr binary(16),
    @v_errmsg varchar(2000),
    @v_newline varchar(20),
    @v_exceptionind int,
    @v_rowcount int

  set @v_newline=char(10)+char(13)
  set @v_exceptionind=0
  set @v_rowcount=0

  select @v_previousjobs_inprocess=count(*)
    from  qweb_wh_log
    where websitekey=@i_websitekey
      and inprocessind=1
  update keys 
    set generickey=generickey+1
  select @v_logkey=generickey from keys
  insert into qweb_wh_log
    (logkey,websitekey,inprocessind,runstatus,rundate,runnote)
    values
    (@v_logkey,@i_websitekey,1,'running',getdate(),' ')
  if @v_previousjobs_inprocess>0
    begin
      update qweb_wh_log
        set runstatus='aborted',
            runnote='previous job still running',
            inprocessind = 0
        where logkey=@v_logkey
      return
    end
  select @v_runnote_ptr = TEXTPTR(runnote)
    from qweb_wh_log
    where logkey=@v_logkey

  if @i_refresh_date is null
    begin
      truncate table qweb_wh_titleinfo
      truncate table qweb_wh_titlecontributors
      truncate table qweb_wh_titlecomments
      truncate table qweb_wh_titlesubjects
      declare c_ti insensitive cursor for
        select b.bookkey
          from book b, bookorgentry o
          where b.bookkey = o.bookkey and
                (o.orglevelkey = 1 and o.orgentrykey <> 23) and  -- exclude BN exclusive titles            
                b.standardind = 'N'
      for read only
    end
  else
    begin
      declare c_ti insensitive cursor for
        select b.bookkey
          from book b, bookorgentry o
          where b.bookkey = o.bookkey and
                (o.orglevelkey = 1 and o.orgentrykey <> 23) and  -- exclude BN exclusive titles            
                b.standardind = 'N' and 
                dbo.qweb_get_book_lastmaintdate(b.bookkey)>=@i_refresh_date
      for read only
    end


  open c_ti

  fetch from c_ti 
  into @bookkey

  while @@fetch_status = 0
    begin
      set @v_rowcount=@v_rowcount+1
      delete qweb_wh_titleinfo where bookkey=@bookkey and @i_websitekey=websitekey
      insert into qweb_wh_titleinfo
        select 1,* from qweb_get_titleinfo(@bookkey)
      IF @@ERROR <> 0 
        BEGIN
          set @v_errmsg='bookkey: '+cast(@bookkey as varchar)+' - error inserting qweb_wh_titleinfo ('+cast(@@ERROR as varchar)+')'+@v_newline
          UPDATETEXT qweb_wh_log.runnote @v_runnote_ptr null 0 @v_errmsg;
          set @v_exceptionind=1
        END

      delete qweb_wh_titlecontributors where bookkey=@bookkey and @i_websitekey=websitekey
      insert into qweb_wh_titlecontributors
        select 1,* from qweb_get_titlecontributors(@bookkey)
      IF @@ERROR <> 0 
        BEGIN
          set @v_errmsg='bookkey: '+cast(@bookkey as varchar)+' - error inserting qweb_get_titlecontributors ('+cast(@@ERROR as varchar)+')'+@v_newline
          UPDATETEXT qweb_wh_log.runnote @v_runnote_ptr null 0 @v_errmsg;
          set @v_exceptionind=1
        END

      delete qweb_wh_titlecomments where bookkey=@bookkey and @i_websitekey=websitekey
      insert into qweb_wh_titlecomments
        select 1,* from qweb_get_titlecomments(@bookkey)
      IF @@ERROR <> 0 
        BEGIN
          set @v_errmsg='bookkey: '+cast(@bookkey as varchar)+' - error inserting qweb_wh_titlecomments ('+cast(@@ERROR as varchar)+')'+@v_newline
          UPDATETEXT qweb_wh_log.runnote @v_runnote_ptr null 0 @v_errmsg;
          set @v_exceptionind=1
        END

      delete qweb_wh_titlesubjects where bookkey=@bookkey and @i_websitekey=websitekey
      insert into qweb_wh_titlesubjects
        select 1,* from qweb_get_titlesubjects(@bookkey)
      IF @@ERROR <> 0 
        BEGIN
          set @v_errmsg='Bookkey: '+cast(@bookkey as varchar)+' - error inserting qweb_wh_titlesubjects ('+cast(@@ERROR as varchar)+')'+@v_newline
          UPDATETEXT qweb_wh_log.runnote @v_runnote_ptr null 0 @v_errmsg;
          set @v_exceptionind=1
        END

      delete qweb_wh_titledates where bookkey=@bookkey and @i_websitekey=websitekey
      insert into qweb_wh_titledates
        (websitekey,bookkey,datecode,datedesc,bestdate)
        (select 1,bd.bookkey,dt.datetypecode,dt.description,bd.bestdate
           from bookdates bd, datetype dt
           where printingkey=1
             and bd.datetypecode=dt.datetypecode
             and bd.bestdate is not null
             and bd.bookkey=@bookkey)
      IF @@ERROR <> 0 
        BEGIN
          set @v_errmsg='Bookkey: '+cast(@bookkey as varchar)+' - error inserting qweb_wh_titledates ('+cast(@@ERROR as varchar)+')'+@v_newline
          UPDATETEXT qweb_wh_log.runnote @v_runnote_ptr null 0 @v_errmsg;
          set @v_exceptionind=1
        END

      fetch next from c_ti
        into @bookkey
    end

  close c_ti
  deallocate c_ti

  if @v_exceptionind=1
    begin
      update qweb_wh_log
        set runstatus='complete with exceptions'
        where logkey=@v_logkey
    end
  else
    begin
      update qweb_wh_log
        set runstatus='complete'
        where logkey=@v_logkey
    end

  set @v_errmsg='Book update count: '+cast(@v_rowcount as varchar)+@v_newline
  UPDATETEXT qweb_wh_log.runnote @v_runnote_ptr 0 0 @v_errmsg;


  update qweb_wh_log
    set inprocessind=0
    where logkey=@v_logkey

end
go

grant execute on qweb_wh_load to public
go