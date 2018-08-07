if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[set_globalcontact_org]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[set_globalcontact_org]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE set_globalcontact_org(
  @i_author_key int,
  @i_book_key int)
 AS

begin

  declare
    @v_count int,
    @v_security_level int,
    @v_orgentry int,
    @v_orglevel int

  select @v_security_level=filterorglevelkey
    from filterorglevel
    where filterkey = 7

  declare author_cur cursor for 
    select bo.orgentrykey, bo.orglevelkey
      from bookauthor ba ,bookorgentry bo
      where ba.authorkey=@i_author_key
        and ba.bookkey = @i_book_key
        and ba.bookkey = bo.bookkey
        and bo.orglevelkey <= @v_security_level

  open author_cur
  fetch author_cur into @v_orgentry,@v_orglevel
  while @@fetch_status = 0
    begin
      select @v_count=count(*)
        from globalcontactorgentry
        where globalcontactkey=@i_author_key and
              orglevelkey = @v_orglevel

      if @v_count=0
        begin
          insert into globalcontactorgentry
            (globalcontactkey,orglevelkey,orgentrykey,lastuserid,lastmaintdate)
            values
            (@i_author_key,@v_orglevel,@v_orgentry,'auto assign',getdate())
        end

      fetch author_cur into @v_orgentry,@v_orglevel
    end

  close author_cur
  deallocate author_cur


end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

