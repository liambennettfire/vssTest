if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[find_gentables_mixed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[find_gentables_mixed]
GO

CREATE PROCEDURE [dbo].[find_gentables_mixed](
  @v_value 	varchar(40),
  @v_tableid 	int,
  @o_datacode 		INT		OUTPUT,
  @o_datadesc		varchar(40)		OUTPUT,
  @search_column varchar(50)=NULL) 
AS

declare 
  @v_count int,
  @DEBUG INT
  
  SET @DEBUG=0
  SET @o_datacode=null


IF @DEBUG>0 print '@search_column = ' + @search_column
IF @DEBUG>0 print '@v_value = ' + @v_value
IF @DEBUG>0 print '-- find by datadesc first'
if @search_column is null or @search_column = 'datadesc'
begin
	select @v_count=count(*) 
	  from gentables
	  where tableid=@v_tableid
		and datadesc=@v_value
	if @v_count=1
	  begin
		select
			@o_datacode=datacode,
			@o_datadesc=datadesc
		  from gentables
		  where tableid=@v_tableid
			and datadesc=@v_value
		IF @DEBUG>0 print 'FOUND in datadesc:';print coalesce(@o_datacode,'*NULL*')
	  end
	if @o_datacode is not null
	  return
end 
  
IF @DEBUG>0 print '-- find by externalcode'
if @search_column is null or @search_column = 'externalcode'
begin
	select @v_count=count(*) 
	  from gentables
	  where tableid=@v_tableid
		and externalcode=@v_value
	if @v_count=1
	  begin
		select
			@o_datacode=datacode,
			@o_datadesc=datadesc
		  from gentables
		  where tableid=@v_tableid
			and externalcode=@v_value
		IF @DEBUG>0 print 'FOUND in externalcode:';print coalesce(@o_datacode,'*NULL*')
	  end
	if @o_datacode is not null
	  return
end 
  
IF @DEBUG>0 print '-- find by onixcode'
if @search_column is null or @search_column = 'onixcode'
begin
	select @v_count=count(*) 
	  from gentables g, gentables_ext e
	  where g.tableid=@v_tableid
		and g.tableid=e.tableid
		and g.datacode=e.datacode
		and onixcode=@v_value
	if @v_count=1
	  begin
		select
			@o_datacode=g.datacode,
			@o_datadesc=g.datadesc
		  from gentables g, gentables_ext e
		  where g.tableid=@v_tableid
			and g.tableid=e.tableid
			and g.datacode=e.datacode
			and onixcode=@v_value
		IF @DEBUG>0 print 'FOUND in onixcode:';print coalesce(@o_datacode,'*NULL*')
	  end
end 

IF @DEBUG>0 print '-- find by eloquencefieldtag'
if @search_column is null or @search_column = 'eloquencefieldtag'
begin
	select @v_count=count(*) 
	  from gentables
	  where tableid=@v_tableid
		and eloquencefieldtag=@v_value
	if @v_count=1
	  begin
		select
			@o_datacode=datacode,
			@o_datadesc=datadesc
		  from gentables
		  where tableid=@v_tableid
			and eloquencefieldtag=@v_value
		
		IF @DEBUG>0 print 'FOUND in eloquencefieldtag:';print coalesce(@o_datacode,'*NULL*')
	  end
		IF @DEBUG>0 print '@o_datacode = ' + cast(@o_datacode as varchar(max))
		IF @DEBUG>0 print '@o_datadesc = ' + cast(@o_datadesc as varchar(max))
	if @o_datacode is not null
	  return
end  
go  



