if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_xml_node_children]') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].[qweb_get_xml_node_children]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qweb_get_xml_node_children(
  @i_xml_in_parms varchar(2000),
  @i_parentnodename  varchar(100))
  RETURNS @xmlinfo TABLE(
    o_nodename varchar(100),
    o_nodevalue varchar(100))
AS
BEGIN
  DECLARE 
    @v_count int,
    @v_docnum INT,
    @v_nodename varchar(100),
    @v_nodevalue varchar(100)
  EXEC sp_xml_preparedocument @v_docnum OUTPUT, @i_xml_in_parms
  declare  c_nodes cursor for
    SELECT elementname,elementvalue
      FROM OPENXML(@v_docnum,@i_parentnodename,1) 
      WITH (elementname  varchar(100) 'elementname',
            elementvalue varchar(2000) 'elementvalue')
  open c_nodes
  fetch next from c_nodes into @v_nodename,@v_nodevalue
  while @@FETCH_STATUS<>-1
    begin
       insert into @xmlinfo (o_nodename,o_nodevalue) values (@v_nodename,@v_nodevalue)
       fetch next from c_nodes into @v_nodename,@v_nodevalue
    end
  close c_nodes
  deallocate c_nodes
  return
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

