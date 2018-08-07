 if exists (select * from dbo.sysobjects where id = Object_id('dbo.CoreProjectInfo_Load') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.CoreProjectInfo_Load
end

GO

CREATE PROCEDURE CoreProjectInfo_Load
AS

DECLARE 
  @v_projectkey int

BEGIN

  begin transaction
  update coreprojectinfo
    set refreshind=1
  commit

  declare project_cur cursor for 
    select  taqprojectkey
      from  taqproject

  open project_cur
  fetch project_cur into @v_projectkey
  while @@fetch_status = 0
    begin

      begin transaction
      exec coreprojectinfo_row_refresh @v_projectkey
      commit

      fetch project_cur into @v_projectkey 

    end

  close project_cur
  deallocate project_cur
  
  begin transaction
  delete coreprojectinfo
    where refreshind is not null
  commit

END
GO

set nocount on
go

exec CoreProjectInfo_Load
go

set nocount off
go  