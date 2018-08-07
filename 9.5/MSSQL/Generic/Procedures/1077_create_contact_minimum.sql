SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[create_contact_minimum]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[create_contact_minimum]
GO


CREATE PROCEDURE dbo.create_contact_minimum (
  @i_globalcontactkey int,
  @i_orgentrykeys varchar(500),
  @i_userid varchar(50),
  @o_errcode int output,
  @o_errmsg varchar(300) output 
  ) AS

begin

  declare
    @v_rowcnt int,
    @v_orglevelnum int,
    @v_orglevelkey int,
    @v_access_level int,
    @v_count int,
    @v_orgentrykey int,
    @v_parentkey int,
    @v_orgentrykeys varchar (300),
    @v_orgentrykeystr varchar(300),
    @v_exit_loop int

  set @o_errcode=0
  set @o_errmsg=''
  select @v_rowcnt = count(*) 
    from globalcontact
    where globalcontactkey=@i_globalcontactkey
  if @v_rowcnt > 0
    begin
      set @o_errcode=-1
      set @o_errmsg='globalcontactkey '+cast(@i_globalcontactkey as varchar(20))+' already exists'
      return
    end

  insert into globalcontact 
    (globalcontactkey,lastuserid,lastmaintdate)
    values
    (@i_globalcontactkey,@i_userid,getdate())
  
  -- add org entries
  select @v_access_level = orglevelnumber
    from filterorglevel , orglevel 
    where filterkey=20
       and filterorglevelkey=orglevelkey
  set @v_count = 1
  set @v_parentkey = 0
  set @v_orgentrykey = dbo.resolve_keyset (@i_orgentrykeys,@v_count)
  while @v_orgentrykey is not null or @v_count <= @v_access_level 
    begin
      select @v_orglevelkey=orglevelkey
        from orglevel
        where orglevelnumber = @v_count
      insert into globalcontactorgentry
        (globalcontactkey,orglevelkey,orgentrykey,lastuserid,lastmaintdate)
        values
        (@i_globalcontactkey,@v_orglevelkey,@v_orgentrykey,@i_userid,getdate())
      set @v_count = @v_count+1
      set @v_parentkey = @v_orgentrykey
      set @v_orgentrykey = dbo.resolve_keyset (@i_orgentrykeys,@v_count)
    end

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.create_contact_minimum TO PUBLIC 
GO


