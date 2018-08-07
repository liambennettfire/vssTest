 if exists (select * from dbo.sysobjects where id = Object_id('dbo.CoreContactInfo_Load') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.CoreContactInfo_Load
end

GO

CREATE PROCEDURE CoreContactInfo_Load
AS

DECLARE 
  @v_contactkey int

BEGIN

  begin transaction
  update corecontactinfo
    set refreshind=1
  commit

  declare contact_cur cursor for 
    select  globalcontactkey
      from  globalcontact 

  open contact_cur 
  fetch contact_cur into @v_contactkey
  while @@fetch_status = 0
    begin

      begin transaction
      exec corecontactinfo_row_refresh @v_contactkey
      commit

      fetch contact_cur into @v_contactkey 

    end

  close contact_cur 
  deallocate contact_cur 
  
  begin transaction
  delete corecontactinfo
    where refreshind is not null
  commit

END
GO

set nocount on
go

exec CoreContactInfo_Load
go 

set nocount off
go  