SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[find_subgentables_mixed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[find_subgentables_mixed]
GO

create PROCEDURE [dbo].[find_subgentables_mixed](
  @v_value 	varchar(120),
  @v_tableid 	int,
  @io_datacode 		INT		OUTPUT,
  @o_datasubcode 		INT		OUTPUT,
  @o_datadesc		varchar(50)		OUTPUT,
  @search_column varchar(50)=NULL) 
AS

declare 
  @v_count int
  
-- find by datadesc first  
  if @search_column is null or @search_column = 'datadesc'
    begin
      select
        @io_datacode=datacode,
        @o_datasubcode=datasubcode,
        @o_datadesc=datadesc
        from subgentables
        where tableid=@v_tableid
            and datadesc=@v_value
            and (@io_datacode is null or datacode=@io_datacode)
    end
  if @o_datasubcode is not null return
  
-- find by externalcode
if @search_column is null or @search_column = 'externalcode'
  begin
    select
      @io_datacode=datacode,
      @o_datasubcode=datasubcode,
      @o_datadesc=datadesc
      from subgentables
      where tableid=@v_tableid
        and externalcode=@v_value
        and (@io_datacode is null or datacode=@io_datacode)
  end      
 if @o_datasubcode is not null return
   
-- find by onixcode
if @search_column is null or @search_column = 'onixcode'
  begin
    select
      @io_datacode=g.datacode,
      @o_datasubcode=g.datasubcode,
      @o_datadesc=g.datadesc
      from subgentables g, subgentables_ext e
        where g.tableid=@v_tableid
          and g.tableid=e.tableid
          and g.datacode=e.datacode
          and g.datasubcode=e.datasubcode
          and onixsubcode=@v_value
          and (@io_datacode is null or g.datacode=@io_datacode)
  end
if @o_datasubcode is not null return
  
-- find by bisacdatacode
if @search_column is null or @search_column = 'bisacdatacode'
  begin
    select
      @io_datacode=datacode,
      @o_datasubcode=datasubcode,
      @o_datadesc=datadesc
      from subgentables
      where tableid=@v_tableid
        and bisacdatacode=@v_value
        and (@io_datacode is null or datacode=@io_datacode)
  end
if @o_datasubcode is not null return


-- find by externalcode
if @search_column is null or @search_column = 'externalcode'
  begin
    select
      @io_datacode=datacode,
      @o_datasubcode=datasubcode,
      @o_datadesc=datadesc
      from subgentables
      where tableid=@v_tableid
        and datacode=@io_datacode
        and externalcode=@v_value
       and (@io_datacode is null or datacode=@io_datacode)
  end
if @o_datasubcode is not null return

-- find by onixcode
if @search_column is null or @search_column = 'onixcode'
  begin
    select
      @io_datacode=g.datacode,
      @o_datasubcode=g.datasubcode,
      @o_datadesc=g.datadesc
      from subgentables g, subgentables_ext e
      where g.tableid=@v_tableid
        and g.tableid=e.tableid
        and g.datacode=e.datacode
        and g.datasubcode=e.datasubcode
        and g.datacode=@io_datacode
        and onixsubcode=@v_value
        and (@io_datacode is null or g.datacode=@io_datacode)
end



