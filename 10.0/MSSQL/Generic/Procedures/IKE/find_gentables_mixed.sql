/******************************************************************************
**  Name: find_gentables_mixed
**  Desc: IKE search for gentables based on multple criteria
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/19/16      Kusum       Case 37304 - added search by alternatedesc1
*******************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[find_gentables_mixed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[find_gentables_mixed]
GO

CREATE PROCEDURE [dbo].[find_gentables_mixed](@v_value 	varchar(40),@v_tableid 	int,@o_datacode INT	OUTPUT,@o_datadesc varchar(MAX)OUTPUT,
  @search_column varchar(50)=NULL) 
AS

declare 
  @v_count int,
  @DEBUG INT
  
  SET @DEBUG=0
  SET @o_datacode=null


IF @DEBUG>0 print '@search_column = ' + @search_column
IF @DEBUG>0 print '-- find by datadesc first'
if @search_column is null or @search_column = 'datadesc' begin
	select @v_count=count(*) from gentables where tableid=@v_tableid and datadesc=@v_value
	if @v_count=1 begin
		IF @DEBUG>0 print 'FOUND in datadesc'
		select @o_datacode=datacode,@o_datadesc=datadesc from gentables where tableid=@v_tableid and datadesc=@v_value
	end
	if @o_datacode is not null return
end 
  
IF @DEBUG>0 print '-- find by externalcode'
if @search_column is null or @search_column = 'externalcode' begin
	select @v_count=count(*) from gentables where tableid=@v_tableid and externalcode=@v_value
	if @v_count=1 begin
		IF @DEBUG>0 print 'FOUND in externalcode'
		select @o_datacode=datacode,@o_datadesc=datadesc from gentables where tableid=@v_tableid and externalcode=@v_value
	end
	if @o_datacode is not null return
end 
  
IF @DEBUG>0 print '-- find by onixcode'
if @search_column is null or @search_column = 'onixcode' begin

	select @v_count=count(*) 
	  from gentables g, gentables_ext e 
	 where g.tableid=@v_tableid and g.tableid=e.tableid and g.datacode=e.datacode and onixcode=@v_value
	if @v_count=1 begin
		IF @DEBUG>0 print 'FOUND in onixcode'
		select @o_datacode=g.datacode,@o_datadesc=g.datadesc 
		  from gentables g, gentables_ext e 
		 where g.tableid=@v_tableid and g.tableid=e.tableid and g.datacode=e.datacode and onixcode=@v_value
	  end
	 if @o_datacode is not null return
end 

IF @DEBUG>0 print '-- find by eloquencefieldtag'
if @search_column is null or @search_column = 'eloquencefieldtag' begin

	select @v_count=count(*) 
	  from gentables
	 where tableid=@v_tableid and eloquencefieldtag=@v_value
	 
	if @v_count=1 begin
		IF @DEBUG>0 print 'FOUND in eloquencefieldtag'
		
		select @o_datacode=datacode, @o_datadesc=datadesc
		  from gentables
		  where tableid=@v_tableid and eloquencefieldtag=@v_value
		
		IF @DEBUG>0 print '@o_datacode = ' + cast(@o_datacode as varchar(max))
		IF @DEBUG>0 print '@o_datadesc = ' + cast(@o_datadesc as varchar(max))
	  end
	if @o_datacode is not null return
end 

IF @DEBUG>0 print '-- find by alternatedesc1'
if @search_column is null or @search_column = 'alternatedesc1' begin

	select @v_count=count(*) 
	  from gentables
	 where tableid=@v_tableid and alternatedesc1=@v_value
	 
	if @v_count=1 begin
		IF @DEBUG>0 print 'FOUND in alternatedesc1'
		
		select @o_datacode=datacode, @o_datadesc=datadesc
		  from gentables
		  where tableid=@v_tableid and alternatedesc1=@v_value
		
		IF @DEBUG>0 print '@o_datacode = ' + cast(@o_datacode as varchar(max))
		IF @DEBUG>0 print '@o_datadesc = ' + cast(@o_datadesc as varchar(max))
	  end
	if @o_datacode is not null return
end 
 
go  



