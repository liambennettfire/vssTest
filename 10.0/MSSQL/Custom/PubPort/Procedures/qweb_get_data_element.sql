if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_data_element]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_get_data_element]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qweb_get_data_element
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
    @v_nodevalue varchar(2000),
    @v_nodetype varchar(2000),
    @v_pos int,
    @v_obj_key int,
    @v_keyname varchar(100),
    @v_keyvalue varchar(2000),
    @v_websitekey int

  set @v_single_quote=char(39)
  set @v_open_quote=char(39)+'%'
  set @v_close_quote='%'+char(39)

  set @v_select_sql=null
  --set @v_from_sql='from qweb_wh_titleinfo ti'
  set @v_from_sql=null
  set @v_where_sql=null

  EXEC sp_xml_preparedocument @v_docnum OUTPUT, @i_xml_in_parms

  -- determine element type - for now all elements must be of the same type
  -- so check the type of the first element
  set @v_parentnodename='/qweb_in_parms/dataelement'
  SELECT @v_nodename = elementname, @v_nodetype = elementtype
    FROM OPENXML(@v_docnum,@v_parentnodename,1) 
    WITH (elementname  varchar(100) 'elementname',
          elementtype varchar(2000) 'elementtype')
  
  if lower(@v_nodetype) = 'xml' or lower(@v_nodetype) = 'html'
    begin
      -- try to find websitekey - use 1 if not found
      set @v_websitekey = 1
      set @v_parentnodename='/qweb_in_parms/keys/keydef'
      declare  c_nodes_key cursor for
        SELECT keyname,keyvalue
          FROM OPENXML(@v_docnum,@v_parentnodename,1) 
          WITH (keyname  varchar(100) 'keyname',
                keyvalue varchar(2000) 'keyvalue')
      open c_nodes_key
      fetch next from c_nodes_key into @v_keyname,@v_keyvalue
      while @@FETCH_STATUS<>-1
        begin
           if lower(@v_keyname) = 'websitekey'
             begin
               set @v_websitekey = cast(rtrim(ltrim(@v_keyvalue)) as int)
               break
             end
           fetch next from c_nodes_key into @v_keyname,@v_keyvalue
        end
      close c_nodes_key
      deallocate c_nodes_key

      select @v_obj_key = objectkey
        from qweb_config_objects
       where objectname=@v_nodename 
         and websitekey=@v_websitekey

       if @v_obj_key is not null
         begin
           select @v_count=count(*)
             from qweb_config_object_props
            where objectkey=@v_obj_key
              and proptype=@v_nodetype 

           if @v_count=0 
             begin
               set @o_error_code=-1
               set @o_error_desc='Unable to retrieve ' + @v_nodetype + ' for ' + @v_nodename
               return
             end
           else
             begin
               select propvalue
                 from qweb_config_object_props
                where objectkey=@v_obj_key 
                  and proptype=@v_nodetype 
            end
         end
       else
         begin
           set @o_error_code=-1
           set @o_error_desc='Unknown data element ' + @v_nodename
           return
         end 
    end
  else if lower(@v_nodetype) = 'data' OR lower(@v_nodetype) = 'datadistinct'
    begin
       -- create select and from
       set @v_parentnodename='/qweb_in_parms/dataelement'
       declare  c_nodes cursor for
         SELECT elementname,elementtype
           FROM OPENXML(@v_docnum,@v_parentnodename,1) 
           WITH (elementname  varchar(100) 'elementname',
                 elementtype varchar(2000) 'elementtype')
       open c_nodes
       fetch next from c_nodes into @v_nodename,@v_nodetype
       while @@FETCH_STATUS<>-1
         begin
            select @v_table=propvalue
              from qweb_config_objects o, qweb_config_object_props op
              where o.objectname=@v_nodename
                and o.objectkey=op.objectkey     
                and op.proptype='table'

            if @v_table is null OR rtrim(ltrim(@v_table)) = ''
              begin
                set @o_error_code = -1
                set @o_error_desc = 'Unable to get data for dataelement ' + @v_nodename + '.  Table Name not found.' 
                close c_nodes
                deallocate c_nodes
                return 
              end

            if @v_from_sql is null
              begin
                set @v_from_sql=' from '+@v_table
              end
            else
              begin
                -- only add table to from if it is not already there
                set @v_pos = charindex(@v_table,@v_from_sql)
                if @v_pos = 0 
                  begin
                    set @v_from_sql=@v_from_sql+' , '+@v_table
                  end
              end

            select @v_column=propvalue
              from qweb_config_objects o, qweb_config_object_props op
              where o.objectname=@v_nodename
                and o.objectkey=op.objectkey     
                and op.proptype='column'

            if @v_column is null OR rtrim(ltrim(@v_column)) = ''
              begin
                set @o_error_code = -1
                set @o_error_desc = 'Unable to get data for dataelement ' + @v_nodename + '.  Column Name not found.' 
                close c_nodes
                deallocate c_nodes
                return 
              end

            if @v_select_sql is null
              begin
                set @v_select_sql=' select'
                if lower(@v_nodetype) = 'datadistinct'
                  begin
                    set @v_select_sql=@v_select_sql+' distinct'
                  end
              end
            else
              begin
                set @v_select_sql=@v_select_sql+' , '
              end
            set @v_select_sql=@v_select_sql+' '+@v_table+'.'+@v_column

            fetch next from c_nodes into @v_nodename,@v_nodetype
         end
       close c_nodes
       deallocate c_nodes

       -- create where
       set @v_parentnodename='/qweb_in_parms/keys/keydef'
       declare  c_nodes_where cursor for
         SELECT keyname,keyvalue
           FROM OPENXML(@v_docnum,@v_parentnodename,1) 
           WITH (keyname  varchar(100) 'keyname',
                 keyvalue varchar(2000) 'keyvalue')
       open c_nodes_where
       fetch next from c_nodes_where into @v_nodename,@v_nodevalue
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
            set @v_where_sql=@v_where_sql + ' ' + @v_nodename + ' = '+ @v_nodevalue
            fetch next from c_nodes_where into @v_nodename,@v_nodevalue
         end
       close c_nodes_where
       deallocate c_nodes_where

       set @v_complete_sql=@v_select_sql+@v_from_sql+@v_where_sql
       exec sp_executesql @v_complete_sql
    end
  else
    begin
      set @o_error_code = -1
      set @o_error_desc = 'Unknown element type ' + @v_nodetype + '.' 
      return 
    end
END  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qweb_get_data_element to public
go

