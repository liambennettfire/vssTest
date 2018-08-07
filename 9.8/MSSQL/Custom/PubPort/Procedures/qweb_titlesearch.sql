if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qweb_titlesearch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qweb_titlesearch
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qweb_titlesearch
  @i_criteria_xml varchar(8000),
  @o_error_code int output,
  @o_error_desc varchar(2000) output
AS

BEGIN 
 DECLARE 
    @v_count int,
    @v_single_quote char(1),
    @v_open_quote char(2),
    @v_close_quote char(2),
    @v_complete_sql nvarchar(2000),
    @v_select_sql varchar(2000),
    @v_from_sql varchar(2000),
    @v_where_sql varchar(2000),
    @v_table varchar(2000),
    @v_column varchar(2000),
    @v_search_join varchar(2000),
    @v_docnum INT,
    @v_parentnodename varchar(100),
    @v_nodename varchar(100),
    @v_nodevalue varchar(1000)

  set @v_single_quote=char(39)
  set @v_open_quote=char(39)+'%'
  set @v_close_quote='%'+char(39)

  set @v_select_sql='select qweb_wh_titleinfo.bookkey,1 "printingkey",qweb_wh_titleinfo.fulltitle "title",qweb_wh_titleinfo.subtitle,qweb_wh_titleinfo.grouplevel2 "publisher",qweb_wh_titleinfo.pubdate,qweb_wh_titleinfo.Fullauthordisplayname "authorname",
        qweb_wh_titleinfo.pagecount,qweb_wh_titleinfo.isbn10 "isbn10",qweb_wh_titleinfo.grouplevel3 "imprint",qweb_wh_titleinfo.usretailprice "price",COALESCE(CAST(qweb_wh_titleinfo.usretailprice as float),0.00) "pricenum",qweb_wh_titleinfo.[format] "format",
        qweb_wh_titleinfo.ean "ean",qweb_wh_titleinfo.isbn13 "isbn13" '
  set @v_from_sql='from qweb_wh_titleinfo '
  set @v_where_sql=null

  EXEC sp_xml_preparedocument @v_docnum OUTPUT, @i_criteria_xml
  set @v_parentnodename='/qweb_in_parms/titlesearch/criteria'
  declare  c_nodes cursor for
    SELECT criterianame,criteriavalue
      FROM OPENXML(@v_docnum,@v_parentnodename,1) 
      WITH (criterianame  varchar(100) 'criterianame',
            criteriavalue varchar(2000) 'criteriavalue')
  open c_nodes
  fetch next from c_nodes into @v_nodename,@v_nodevalue
  while @@FETCH_STATUS<>-1
    begin
       select @v_table=propvalue
         from qweb_config_objects o, qweb_config_object_props op
         where o.objectname=@v_nodename
           and o.objectkey=op.objectkey     
           and op.proptype='table'
       select @v_column=propvalue
         from qweb_config_objects o, qweb_config_object_props op
         where o.objectname=@v_nodename
           and o.objectkey=op.objectkey     
           and op.proptype='column'
       select @v_search_join=propvalue
         from qweb_config_objects o, qweb_config_object_props op
         where o.objectname=@v_nodename
           and o.objectkey=op.objectkey     
           and op.proptype='search_join'
--       if @v_search_join is null
--         begin
--           set @v_search_join 'contains'
--         end
       if @v_where_sql is null
         begin
           set @v_where_sql=' where '
         end
       else
         begin
           set @v_where_sql=@v_where_sql+' and '
         end
       if @v_search_join='starts_with'
         begin
           set @v_where_sql=@v_where_sql+' '+@v_table+'.'+@v_column+' like '+@v_open_quote+@v_nodevalue+@v_single_quote
         end
       else
         if @v_search_join='equals'
           begin
             set @v_where_sql=@v_where_sql+' '+@v_table+'.'+@v_column+' = '+@v_single_quote+@v_nodevalue+@v_single_quote
           end
         else --'contains'
           begin
              set @v_where_sql=@v_where_sql+' '+@v_table+'.'+@v_column+' like '+@v_open_quote+@v_nodevalue+@v_close_quote
           end
--       -- add join info if qweb_wh_titlecontributors table is involved
--       if @v_table='qweb_wh_titlecontributors' and charindex('qweb_wh_titlecontributors',@v_from_sql)=0
--         begin
--           set @v_from_sql=@v_from_sql+',qweb_wh_titlecontributors'
--           set @v_where_sql=@v_where_sql+' and qweb_wh_titleinfo.bookkey=qweb_wh_titlecontributors.bookkey '
--         end 

--       -- add join info if qweb_wh_titlesubjects table is involved
--       if @v_table='qweb_wh_titlesubjects' and charindex('qweb_wh_titlesubjects',@v_from_sql)=0
--         begin
--           set @v_from_sql=@v_from_sql+',qweb_wh_titlesubjects'
--           set @v_where_sql=@v_where_sql+' and qweb_wh_titleinfo.bookkey=qweb_wh_titlesubjects.bookkey '
--         end 

       -- add join info if table other than main table is involved
       if @v_table<>'qweb_wh_titleinfo'
         begin
           if charindex(@v_table,@v_from_sql)=0
             begin
               set @v_from_sql=@v_from_sql+','+@v_table
               set @v_where_sql=@v_where_sql+' and qweb_wh_titleinfo.bookkey='+@v_table+'.bookkey '
             end 
         end
       fetch next from c_nodes into @v_nodename,@v_nodevalue
    end
  close c_nodes
  deallocate c_nodes

  set @v_complete_sql=@v_select_sql+@v_from_sql+@v_where_sql

--print @v_complete_sql

  exec sp_executesql @v_complete_sql

end

  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


grant execute on qweb_titlesearch to public
go