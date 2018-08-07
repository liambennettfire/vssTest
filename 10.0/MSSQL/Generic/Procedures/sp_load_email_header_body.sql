if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[load_email_header_body]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop PROCEDURE [dbo].[load_email_header_body]
GO
create PROCEDURE [dbo].[load_email_header_body]
  @i_filename varchar(400),
  @i_pathname varchar(400)

AS
Declare
  @v_headerfile varchar(400),
  @v_bodyfile varchar(400),
  @v_header varchar(max),
  @v_body varchar(max),
  @v_fromaddress varchar(500),
  @v_subjectline varchar(500),
  @v_beginpoint int,
  @v_endpoint int,
  @v_webrequestkey int,
  @v_newline varchar(10)

BEGIN

  set @v_bodyfile = @i_pathname+@i_filename 
  set @v_body = dbo.file_to_varcharmax(@v_bodyfile)

  set @v_headerfile=replace(@v_bodyfile,'text_plain','header')
  set @v_header = dbo.file_to_varcharmax(@v_headerfile)

  set @v_newline=char(13)+char(10)
  -- find from address line
  set @v_beginpoint= charindex('From: ',@v_header)
  set @v_beginpoint=@v_beginpoint+datalength('From: ')
  set @v_endpoint= charindex(@v_newline,@v_header,@v_beginpoint)
  set @v_fromaddress=substring(@v_header,@v_beginpoint,@v_endpoint-@v_beginpoint+1)
  set @v_fromaddress=replace(@v_fromaddress,char(10),'')
  set @v_fromaddress=replace(@v_fromaddress,char(13),'')

  -- find subject line
  set @v_beginpoint= charindex('Subject: ',@v_header)
  set @v_beginpoint=@v_beginpoint+datalength('Subject: ')
  set @v_endpoint= charindex(@v_newline,@v_header,@v_beginpoint)
  set @v_subjectline=substring(@v_header,@v_beginpoint,@v_endpoint-@v_beginpoint+1)
  set @v_subjectline=replace(@v_subjectline,char(10),'')
  set @v_subjectline=replace(@v_subjectline,char(13),'')
  
  -- insert into email table
  update keys set generickey=generickey+1
  select @v_webrequestkey=generickey from keys
  insert into webrequest
    (webrequestkey,fromaddress,subjectline,emailbody,processind,loaddate,lastuserid,lastmaintdate)
    values
    (@v_webrequestkey,@v_fromaddress,@v_subjectline,@v_body,0,getdate(),'email load',getdate())

END
go