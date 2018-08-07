if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SWAG_productnumber_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SWAG_productnumber_sp]
GO


create PROCEDURE [dbo].[SWAG_productnumber_sp]
  @i_request nvarchar(max),
  @o_return nvarchar(max) output
AS

DECLARE 
   @v_count   int,
   @v_errcode   int,
   @v_debug   int,
   @v_datacode   int,
   @v_alternatedesc2 varchar(200),
   @v_errmsg    VARCHAR(4000),
   @v_userid    VARCHAR(30),
   @v_userkey   int,
   @v_tag       varchar(50),
   @v_tag_datacode int,
   @v_Dates  varchar(50),
   @v_FromDate  varchar(50),
   @v_ToDate    varchar(50),
   @d_FromDate datetime,
   @d_ToDate datetime,
   @v_custom_sp varchar(500),
   @v_sec_err   int,
   @v_tag_err   int,
   @v_creationdate   datetime,
   @v_content   nvarchar(max),
   @v_content_single   nvarchar(max),
   @v_return    nvarchar(max),
   @v_return_work    nvarchar(max),
   @v_from int,
   @v_to int,
   @v_request_xml xml,
   @v_errcode2   int,
   @v_errmsg2   varchar(300)
   
BEGIN
  SET @v_errcode = 0
  SET @v_errmsg = ''
  SET @v_debug = 0
 
  set @v_request_xml=CAST(@i_request as XML)
    
  --extract XML values
  exec sp_xmlGetNodeValue 	null,@i_request,null,'//Firebrand/User','UserID[1]',@v_userid  OUTPUT,@v_errmsg2  OUTPUT,@v_errcode2  OUTPUT
  exec sp_xmlGetNodeValue 	null,@i_request,null,'//Firebrand/User','AuthenticationKey[1]',@v_userkey  OUTPUT,@v_errmsg2  OUTPUT,@v_errcode2  OUTPUT
  exec sp_xmlGetNodeValue 	null,@i_request,null,'//Firebrand/Feed','Tag[1]',@v_tag  OUTPUT,@v_errmsg2  OUTPUT,@v_errcode2  OUTPUT
  exec sp_xmlGetNodeValue 	null,@i_request,null,'//Firebrand/Feed','FromDate[1]',@v_FromDate  OUTPUT,@v_errmsg2  OUTPUT,@v_errcode2  OUTPUT
  exec sp_xmlGetNodeValue 	null,@i_request,null,'//Firebrand/Feed','ToDate[1]',@v_ToDate  OUTPUT,@v_errmsg2  OUTPUT,@v_errcode2  OUTPUT

  SET @d_FromDate = CONVERT(datetime,@v_FromDate)
  SET @d_ToDate = CONVERT(datetime,@v_ToDate)

  if @v_debug=1
    begin
      print 'XML input values'
      print '  userid ['+@v_userid+']'
      print '  authenticationkey ['+cast(@v_userkey as varchar)+']'
      print '  tag ['+@v_tag+']'
      print '  From ['+@v_FromDate+']'
      print '  To ['+@v_ToDate+']'
    end
    
  set @v_return_work =
'<?xml version="1.0" encoding="UTF-8"?>
<Firebrand>
   <Informationals>
      <Code>$$errorcode$$</Code>
      <Message>$$errormessage$$</Message>
   </Informationals>
   <Content>$$content$$</Content>
</Firebrand>'

  --get datacode for tag
  select @v_tag_datacode = datacode from gentables where tableid = 660 and alternatedesc1 = @v_tag

  --get content
  if @v_debug = 1 print 'data collection timing:'
  if @v_debug = 1 print sysdatetime()
  set @v_content=
  (Select content AS [text()]
    From dbo.swag_content
    Where productnumber in
      (select productnumber
         from swag_content
         where productnumber in (select x.i.value('.', 'varchar(50)') from @v_request_xml.nodes('/Firebrand/Feed/Products/ProductNumber') x(i)) or @v_request_xml is null)
      and datacode=@v_tag_datacode
    For XML PATH (''))
  if @v_debug = 1 print sysdatetime()
  if @v_debug = 1 print 'replace timing:'
  if @v_debug = 1 print sysdatetime()
  set @v_content=replace(replace(replace(replace(replace(replace(@v_content,'&gt;','>'),'&lt;','<'),'&amp;','&'),'& ','&amp; '),'&#160;',' '),'&nbsp;',' ')
  if @v_debug = 1 print sysdatetime()
	
  --create return XML
  Select @v_count=COUNT(*)
    From dbo.swag_content
    Where productnumber in
      (select productnumber
         from swag_content
         where productnumber in (select x.i.value('.', 'varchar(50)') from @v_request_xml.nodes('/Firebrand/Feed/Products/ProductNumber') x(i)) or @v_request_xml is null)
      and datacode=@v_tag_datacode
  set @v_errmsg='total titles '+coalesce(cast(@v_count as varchar),'')
  --set @v_Dates=coalesce(@v_FromDate,'.')+' '+coalesce(@v_ToDate,'.')
  --set @v_return_work=REPLACE(@v_return_work,'$$dates$$',@v_Dates)
  set @v_return_work=REPLACE(@v_return_work,'$$errorcode$$',coalesce(@v_errcode,''))
  set @v_return_work=REPLACE(@v_return_work,'$$errormessage$$',coalesce(@v_errmsg,''))
  set @v_return_work=REPLACE(@v_return_work,'$$creationdate$$',coalesce(CAST(@v_creationdate as varchar),''))
  set @v_return_work=REPLACE(@v_return_work,'$$content$$',coalesce(@v_content,''))
  set @o_Return=@v_return_work

END

GO

grant execute on dbo.SWAG_productnumber_sp to public
GO


