if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_obj_children]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_get_obj_children]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qweb_get_obj_children
  @i_websitekey int,
  @i_objectname varchar(100),
  @i_objecttype varchar(100),
  @o_error_code int output,
  @o_error_desc varchar(2000) output
AS

BEGIN 
  DECLARE 
    @v_parent_obj_key int,
    @v_count int

  set @o_error_code=1
  set @o_error_desc=''

  select @v_parent_obj_key = objectkey
    from qweb_config_objects
    where objectname=@i_objectname 

  if @v_parent_obj_key is not null
    begin
      select @v_count=count(*)
        from qweb_config_objects
        where websitekey=@i_websitekey 
          and parentkey=@v_parent_obj_key 
          and objecttype=@i_objecttype 
      if @v_count=0 
        begin
          set @o_error_code=0
          set @o_error_desc='no children for this object'
        end
      else
        begin
          select objectname,objecttype
            from qweb_config_objects
            where websitekey=@i_websitekey 
              and parentkey=@v_parent_obj_key 
              and objecttype=@i_objecttype 
        end
    end
  else
    begin
      set @o_error_code=-1
      set @o_error_desc='not a parent object'
    end 

END  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qweb_get_obj_children to public
go