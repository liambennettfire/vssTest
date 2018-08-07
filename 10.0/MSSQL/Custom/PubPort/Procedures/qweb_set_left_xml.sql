if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_leftbar_xml]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_leftbar_xml]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE dbo.qweb_leftbar_xml
  @i_websitekey int
AS

BEGIN 
  Declare
    @v_Txtpointer binary(16),
    @v_xml_part varchar(2000),
    @v_bisacedesc varchar(500),
    @v_subbisacedesc varchar(500),
    @v_datacode int,
    @v_datasubcode int,
    @v_objectkey int,
    @v_objectname varchar(50),
    @v_newline varchar(20),
    @v_url varchar(500)

  set @v_url = 'ContentCallbackUrl = "~/Controls/SubjectList/LoadSubjectListChildNode.aspx?de_subject_code=xxx_code"'
  
  set @v_objectname='de_leftbar_xml'
  set @v_newline=char(13)+char(10)
--  set @v_newline=''

  select @v_objectkey=objectkey
    from qweb_config_objects
    where objectname=@v_objectname

  update qweb_config_object_props
    set propvalue=''
    where objectkey = @v_objectkey
      and proptype = 'xml'

  select @v_Txtpointer = textptr(propvalue)
    from qweb_config_object_props
    where objectkey = @v_objectkey
     and proptype = 'xml'

  set @v_xml_part='<Nodes>'+@v_newline
  updatetext qweb_config_object_props.propvalue @v_Txtpointer null 0 @v_xml_part

  declare c_bisac insensitive cursor for
    select distinct subjectcode,subjectdesc
      from qweb_wh_titlesubjects
      where websitekey=@i_websitekey
      order by subjectdesc
  open c_bisac
  fetch from c_bisac into @v_datacode,@v_bisacedesc
  while @@fetch_status = 0
    begin
      set @v_bisacedesc=rtrim(replace(@v_bisacedesc,'&','&amp;'))

      set @v_url=replace(@v_url,'xxx_code',@v_datacode)
      set @v_xml_part='  <TreeViewNode Text="'+@v_bisacedesc+'" '+@v_url+' >'+@v_newline
      set @v_url = 'ContentCallbackUrl = "~/Controls/SubjectList/LoadSubjectListChildNode.aspx?de_subject_code=xxx_code"'
      updatetext qweb_config_object_props.propvalue @v_Txtpointer null 0 @v_xml_part

      set @v_xml_part=' </TreeViewNode>'+@v_newline
      updatetext qweb_config_object_props.propvalue @v_Txtpointer null 0 @v_xml_part
      
      fetch from c_bisac into @v_datacode,@v_bisacedesc
    end
    close c_bisac
    deallocate c_bisac

  set @v_xml_part='</Nodes>'+@v_newline
  updatetext qweb_config_object_props.propvalue @v_Txtpointer null 0 @v_xml_part

  update qweb_config_object_props
    set lastuserid='xmlupd',lastmaintdate=getdate() 
    where objectkey=@v_objectkey
END  



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qweb_leftbar_xml to public
go