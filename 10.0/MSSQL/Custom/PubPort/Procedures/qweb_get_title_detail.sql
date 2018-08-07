if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_title_detail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_get_title_detail]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qweb_get_title_detail
  @i_xml_in_parms varchar(8000),
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
    @v_docnum INT,
    @v_parentnodename varchar(100),
    @v_nodename varchar(100),
    @v_nodevalue varchar(1000)

  set @v_single_quote=char(39)
  set @v_open_quote=char(39)+'%'
  set @v_close_quote='%'+char(39)

  set @v_select_sql='select bookkey,fulltitle "title",subtitle,grouplevel2 "publisher",pubdate,Fullauthordisplayname "authorname",
        pagecount,isbn10 "isbn10",isbn13 "isbn13",ean,grouplevel3 "imprint",usretailprice "price",[format] "format",
        dbo.qweb_wh_get_titledate(ti.websitekey,ti.bookkey,' + @v_single_quote + 'Last Import Date' + @v_single_quote + ') "elolastimportdate", 
        dbo.qweb_get_contributorlist(ti.websitekey,ti.bookkey,' + @v_single_quote + 'author' + @v_single_quote + ',' + @v_single_quote + '|' + @v_single_quote + ') "authorlist",
		dbo.qweb_getLastImageRecDate(ti.bookkey) "eloCoverRefreshDate"'

  set @v_from_sql='from qweb_wh_titleinfo ti'
  set @v_where_sql=null

  EXEC sp_xml_preparedocument @v_docnum OUTPUT, @i_xml_in_parms
  set @v_parentnodename='/qweb_in_parms/keys/keydef'
  declare  c_nodes cursor for
    SELECT keyaname,keyvalue
      FROM OPENXML(@v_docnum,@v_parentnodename,1) 
      WITH (keyaname  varchar(100) 'keyname',
            keyvalue varchar(2000) 'keyvalue')
  open c_nodes
  fetch next from c_nodes into @v_nodename,@v_nodevalue
  while @@FETCH_STATUS<>-1
    begin
       if @v_where_sql is null
         begin
           set @v_where_sql=' where '
         end
       else
         begin
           set @v_where_sql=@v_where_sql+' and '
         end
         
       if lower(@v_nodename) = 'customerkey' begin
         set @v_nodevalue = 'dbo.elo_CDCimportingPress(' + @v_nodevalue + ')'
       end
                
       set @v_where_sql=@v_where_sql + ' ' + @v_nodename + ' = '+ @v_nodevalue
       fetch next from c_nodes into @v_nodename,@v_nodevalue
    end
  close c_nodes
  deallocate c_nodes

  set @v_complete_sql=@v_select_sql+@v_from_sql+@v_where_sql
  exec sp_executesql @v_complete_sql
END  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qweb_get_title_detail to public
go