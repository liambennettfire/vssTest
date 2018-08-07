SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[create_title_minimum]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[create_title_minimum]
GO


CREATE PROCEDURE create_title_minimum (
  @i_bookkey int,
  @i_printingkey int,
  @i_orgentrykeys varchar(300),
  @i_userid varchar(50),
  @o_errcode int output,
  @o_errmsg varchar(300) output 
  ) AS

begin

  declare
    @v_rowcnt int,
    @v_isbnkey int,
    @v_vendorkey int,
    @v_orglevelnum int,
    @v_orglevelkey int,
    @v_pointer int,
    @v_count int,
    @v_orgentrykey int,
    @v_orgentrykeys varchar (300),
    @v_orgentrykeystr varchar(300),
    @v_exit_loop int

  set @o_errcode=0
  set @o_errmsg=''
  select @v_rowcnt = count(*) 
    from book
    where bookkey=@i_bookkey
  if @v_rowcnt > 0
    begin
      set @o_errcode=-1
      set @o_errmsg='bookey '+cast(@i_bookkey as varchar(20))+' already exists'
      return
    end

--book table
  insert into book
    (bookkey,workkey,linklevelcode,propagatefromprimarycode,standardind,titlesourcecode,creationdate,lastuserid,lastmaintdate)
    values
    (@i_bookkey,@i_bookkey,10,0,'N',15,getdate(),@i_userid,getdate())

--bookorgentry table
  set @v_orgentrykey=0
  set @v_orglevelnum=0
  set @v_orgentrykey=0
  while @v_orgentrykey is not null
    begin
      set @v_orglevelnum=@v_orglevelnum+1
      set @v_orgentrykey=dbo.resolve_keyset(@i_orgentrykeys,@v_orglevelnum)
      select @v_orglevelkey = orglevelkey
        from orglevel
        where orglevelnumber=@v_orglevelnum
      if @v_orgentrykey is not null
        begin
          insert into bookorgentry
           (bookkey,orgentrykey,orglevelkey,lastuserid,lastmaintdate)
           values
           (@i_bookkey,@v_orgentrykey,@v_orglevelkey,@i_userid,getdate())
        end
    end

--bookdetail table
  insert into bookdetail
    (bookkey,lastuserid,lastmaintdate)
    values
    (@i_bookkey,@i_userid,getdate())

--printing table
  insert into printing
    (bookkey,printingkey,printingnum,printingjob,creationdate,lastuserid,lastmaintdate)
    values
    (@i_bookkey,@i_printingkey,1,'1',getdate(),@i_userid,getdate())

--isbn table
  update keys set generickey=generickey+1
  select @v_isbnkey=generickey from keys
  insert into isbn
    (bookkey,isbnkey,lastuserid,lastmaintdate)
    values
    (@i_bookkey,@v_isbnkey,@i_userid,getdate())

--bindingspecs table
  set @v_vendorkey=0
  insert into bindingspecs
    (bookkey,printingkey,vendorkey,lastuserid,lastmaintdate)
    values
    (@i_bookkey,@i_printingkey,@v_vendorkey,@i_userid,getdate())

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.create_title_minimum TO PUBLIC 
GO

