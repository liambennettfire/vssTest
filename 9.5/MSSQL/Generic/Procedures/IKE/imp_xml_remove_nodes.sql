SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
**  Name: imp_xml_remove_nodes
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_xml_remove_nodes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_xml_remove_nodes]
GO

CREATE PROCEDURE dbo.imp_xml_remove_nodes
  @i_bathckey int,
  @i_node_name varchar(80),
  @o_errcode int,
  @o_errmsg varchar(500)

AS

BEGIN

DECLARE
  @v_node_id int,
  @v_sub_node_id int,
  @v_full_nodename varchar(500)

  SET NOCOUNT ON;

  set @v_full_nodename=dbo.imp_full_nodename(@i_bathckey,@i_node_name)
  set @v_node_id=dbo.imp_id_from_full_nodename(@i_bathckey,@i_node_name)

  select top 1 @v_sub_node_id=id
    from imp_xml_load
    where parentid=@v_node_id
  while @v_sub_node_id is not null
    begin
      --find sub node with no child and delete
      print 'this proc has never been called'
    end


END
GO
