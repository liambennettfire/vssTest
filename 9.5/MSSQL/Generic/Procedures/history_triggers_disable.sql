IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[history_triggers_disable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[history_triggers_disable]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[history_triggers_disable] 
  
AS

declare
  @v_triggername varchar(100),
  @v_tablename varchar(100),
  @v_sqlbase nvarchar(500),
  @v_sql nvarchar(500)

BEGIN 

  set @v_sqlbase='DISABLE TRIGGER $$Trigger ON $$Table;'
  declare c_trigs cursor fast_forward for
    select s2.name "tablename",s1.name "triggername"
      from sysobjects s1, sysobjects s2, syscomments sc
      where s1.type = 'TR'
        and s1.parent_obj=s2.id
        and s1.id=sc.id
        and cast(sc.text as varchar(8000)) like '%history_sp%'
  open c_trigs
  fetch c_trigs into @v_tablename,@v_triggername
  while @@fetch_status=0
    begin
      set @v_sql=replace(@v_sqlbase,'$$Trigger',@v_triggername)
      set @v_sql=replace(@v_sql,'$$Table',@v_tablename)
      exec sp_executesql @v_sql 
--      print @v_sql
      fetch c_trigs into @v_tablename,@v_triggername
    end
  close c_trigs
  deallocate c_trigs

end
go


