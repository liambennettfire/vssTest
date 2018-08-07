SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_load_xml 
**  Desc: IKE load xml routine
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_load_xml]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_load_xml]
GO

CREATE PROCEDURE dbo.imp_load_xml 
  @i_batchkey int,
  @i_input_file varchar(500),
  @i_root_path varchar(500),
  @i_templatekey int,
  @i_userid varchar(50),
  @o_errcode int output ,
  @o_errmsg varchar(1000) output ,
  @i_SourceXML XML = NULL
AS
declare
  @v_xmldoc varchar(max),
  @v_xml xml,
  @o_xml xml,
  @v_xml_product xml,
  @v_DocHandle int,
  @v_working_root_node varchar(300),
  @v_xml_doc nvarchar(max),
  @v_sql nvarchar(4000),
  @v_returncode int,
  @v_returnmsg varchar(500),
  @v_parmdef nvarchar(500),
  @v_row_id int,
  @v_id int,
  @v_count int,
  @v_parentid int,
  @v_nodetype int,
  @v_localname varchar(50),
  @v_prev int,
  @v_text varchar(max),
  @v_nodename varchar(50),
  @v_elementseqparentid int,
  @v_elementseq int,
  @v_elementseq_count int,
  @v_false_seq int,
  @v_mapkey int,
  @v_element_mapped_value varchar(max),
  @v_element_from_value varchar(max),
  @v_element_value varchar(max),
  @v_rulecall varchar(max),
  @v_except_rulecall nvarchar(max),
  @v_rulekey bigint,
  @v_lobkey int,
  @v_lobind int,
  @v_worknode_pos int,
  @v_columnname varchar(150),
  @v_column_mnemonic varchar(150),
  @v_elementkey bigint,
  @v_column_type int,
  @v_tablename varchar(50),
  @v_readxml_parmdef NVARCHAR(500),
  @v_exception_rule_parmdef NVARCHAR(500),
  @v_readxml_sql NVARCHAR(max),
  @v_nullind int,
  @v_errmsg varchar(500),
  @v_count2 int,
  @v_count3 int,
  @v_elementseq_adj int,
  @v_parent_node int,
  @v_parent_name varchar(500)
  
begin
  set @v_row_id=1
  set @v_parmdef = N'@o_xml xml' 
--  set @v_xmldoc=dbo.file_to_varcharmax(@i_input_file)
  set @v_readxml_parmdef = N'@o_xmldoc nvarchar(max) output' 
  set @v_readxml_sql='SELECT  @o_xmldoc=xmlData FROM(SELECT * FROM OPENROWSET (BULK ''' + @i_input_file + ''' , SINGLE_CLOB) AS XMLDATA) AS FileImport (XMLDATA)'
  
  set @v_xml=@i_SourceXML
  IF @v_xml IS NULL 
  BEGIN
	exec @v_returncode=sp_executesql @v_readxml_sql, @v_readxml_parmdef,@o_xmldoc = @v_xmldoc output
	set @v_xml=convert(xml,@v_xmldoc,2)
  END

  set @v_sql=N'declare c_products cursor FAST_FORWARD for SELECT T.c.query(''.'') AS result FROM @o_xml.nodes('+char(39)+@i_root_path+char(39)+') T(c)'
  exec @v_returncode=sp_executesql @v_sql, @v_parmdef, @o_xml = @v_xml

  if @v_returncode <> 0
    begin
      set @v_returnmsg='XML read rule failure (msg '+cast(@v_returncode as varchar(20))+')'
      set @o_errcode=@v_returncode
      set @o_errmsg=@v_returnmsg
      EXECUTE imp_write_feedback @i_batchkey, null, null, null ,null , @v_returnmsg, 3,2
      return
    end
--******************************************
  set @v_worknode_pos=datalength(@i_root_path)-PATINDEX ('%/%',REVERSE(@i_root_path))+1
  set @v_working_root_node=substring(@i_root_path,@v_worknode_pos,500)
-- print @v_working_root_node
  set @v_exception_rule_parmdef = N'@i_batchkey int, @i_row_id int, @i_elementseq int, @io_elementkey int output' 

  open c_products
  fetch c_products into @v_xml_product
  while @@fetch_status = 0
    begin

      set @v_xml_doc=cast(@v_xml_product as nvarchar(max))
      EXEC sp_xml_preparedocument @v_DocHandle OUTPUT, @v_xml_doc

      set @v_xml_doc='<?xml version="1.0" encoding="ISO-8859-1" ?> '+@v_xml_doc

      delete from imp_xml_load
        where batchkey=@i_batchkey
      insert into imp_xml_load
        SELECT @i_batchkey 'batchkey',x.*
          FROM OPENXML (@v_DocHandle, @v_working_root_node,1) as x
--
--SELECT @i_batchkey 'batchkey',x.*
--  FROM OPENXML (@v_DocHandle, @v_working_root_node,1) as x
--
      EXEC sp_xml_removedocument @v_DocHandle

--
-- this is where the XML ommisions should be handled
--

      declare c_row cursor FAST_FORWARD for
        select id,parentid,nodetype,localname,prev,[text]
          from imp_xml_load
          where batchkey=@i_batchkey
            and nodetype=3

      open c_row
      fetch c_row into @v_id,@v_parentid,@v_nodetype,@v_localname,@v_prev,@v_text
      while @@fetch_status=0
        begin
        
--print '.........'
          select @v_nodename=localname
            from imp_xml_load
            where id=@v_parentid
              and batchkey=@i_batchkey

--
--print coalesce(cast(@v_id as varchar(max)),'')+' '+coalesce(cast(@v_parentid as varchar(max)),'')+' '+coalesce(cast(@v_nodename as varchar(max)),'')+' '+coalesce(cast(@v_nodetype as varchar(max)),'')+' '+coalesce(cast(@v_localname as varchar(max)),'')+' '+coalesce(cast(@v_text as varchar(max)),'')
--

          -- get seq number
--print @v_elementseq
          set @v_elementseq_count=0
          set @v_elementseqparentid=@v_parentid
          while @v_elementseqparentid is not null
            begin
              select @v_elementseqparentid=parentid
                from imp_xml_load
                where id=@v_elementseqparentid
                  and batchkey=@i_batchkey
              set @v_elementseq_count=@v_elementseq_count+1
              if @v_elementseq_count=1
                begin
                  set @v_elementseq=@v_elementseqparentid
                end
            end
--          set @v_elementseq=@v_elementseq-1
--
--print cast(@v_row_id as varchar)+' '+cast(@v_elementseq as varchar)+' '+@v_nodename+' - '+@v_text
--
          set @v_columnname = @v_nodename
          set @v_element_value = @v_text
          set @v_elementkey = null
          set @v_column_mnemonic = null
--          set @v_elementseq = null
--print @v_columnname
--
--          exec imp_seq_check @v_columnname, @i_templatekey, @v_column_mnemonic output, @v_false_seq output
        select @v_column_mnemonic = transmnemonic
          from imp_template_detail
          where templatekey = @i_templatekey
            and columnname = @v_columnname
        if @v_column_mnemonic is null
          begin
            set @v_column_mnemonic=@v_columnname
          end
--
--print @v_column_mnemonic
--
          select @v_elementkey = elementkey, @v_lobind = lobind,@v_nullind = importnullind
            from imp_element_defs
            where @v_column_mnemonic = elementmnemonic
--print @v_elementkey
--print @v_text
          select @v_mapkey = mapkey
            from imp_template_detail
            where elementkey = @v_elementkey
              AND templatekey = @i_templatekey
--          set @v_row_id = @v_row_id + 1
          if @v_mapkey is not null  
            begin
              set @v_element_mapped_value = null
              set @v_element_from_value = null
              select @v_element_mapped_value = to_value, @v_element_from_value = from_value
                from imp_mapping
                where mapkey = @v_mapkey
                  and from_value = @v_element_value 
              --if @v_element_mapped_value is not null 
              -- it is possible for the to_value to be null
              if @v_element_from_value is not null
                begin
                  set @v_element_value = @v_element_mapped_value
                end
            end
          if  @v_elementkey is null  or @v_column_mnemonic = 'ignore'
            begin
              if  @v_elementkey is null
                begin
                  -- failure to map raw data to known elements
                  set @v_errmsg = 'failure to map ['+@v_columnname+'] to known elements'
                  select @v_count=count(*)
                    from imp_feedback
                    where batchkey=@i_batchkey 
                      and feedbackmsg=@v_errmsg
                  if @v_count=0
                    begin
                      exec imp_write_feedback @i_batchkey,null,null,null,null,@v_errmsg,3,1
                    end
                end
            end
          else
            begin
              if (not(@v_element_value is null OR rtrim(coalesce(@v_element_value,'')) = '')
                OR @v_nullind = 1)
                begin
                  -- handle duplicate seq numbs 
                  select @v_count2=count(*) 
                    from imp_batch_detail 
                    where batchkey=@i_batchkey
                      and row_id=@v_row_id
                      and elementkey=@v_elementkey
                      and elementseq=@v_elementseq
                  set @v_elementseq_adj=@v_elementseq
                  if @v_count2>0
                    begin
                      select @v_elementseq_adj=max(elementseq)
                        from imp_batch_detail
                        where batchkey=@i_batchkey
                          and row_id=@v_row_id
                          and elementkey=@v_elementkey
                      set @v_elementseq_adj=@v_elementseq_adj+1000
                      set @v_errmsg='sequence adjustment'
                      exec imp_write_feedback @i_batchkey,null,null,null,null,@v_errmsg,1,1
                    end
                  --
                  -- deal with xml processing exception
                  -- namely repeated node names that depend on hierarchy for full definition
                  set @v_count3=0
                  select @v_count3=count(*)
                    from imp_element_exception
                    where elementkey=@v_elementkey
                      and imp_source='XML'
                      and imp_agent=1
--print @v_elementkey
                  if @v_count3=1
                    begin
                      select @v_except_rulecall=rulecall
                        from imp_element_exception
                        where elementkey=@v_elementkey
                          and imp_source='XML'
                          and imp_agent=1
                     exec @v_returncode=sp_executesql @v_except_rulecall, @v_exception_rule_parmdef,
                        @i_batchkey = @i_batchkey,
                        @i_row_id = @v_row_id,
                        @i_elementseq = @v_elementseq_adj,
                        @io_elementkey = @v_elementkey output
                      if @v_returncode <> 0
                        begin
                          set @v_returnmsg='element exception rule failure (msg '+cast(@v_returncode as varchar(20))+')'
                          EXECUTE imp_write_feedback @i_batchkey, @v_row_id, @v_elementkey, @v_elementseq ,@v_rulekey , @v_returnmsg, 3, 1
                        end
                    end
                  --
                  insert into imp_batch_detail
                   (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
                    values
                   (@i_batchkey,@v_row_id,@v_elementkey,@v_elementseq_adj,substring(@v_element_value,1,4000),@i_userid ,getdate())
                  if @v_lobind = 1
                    begin
                      update keys set generickey=generickey+1
                       select @v_lobkey = generickey from keys
                       insert into imp_batch_lobs
                         (batchkey,lobkey,textvalue)
                          values
                          (@i_batchkey,@v_lobkey,@v_element_value)
                       update imp_batch_detail
                         set
                           originalvalue = null,
                           lobkey = @v_lobkey
                         where batchkey=@i_batchkey
                           and row_id=@v_row_id
                           and elementkey=@v_elementkey
                           and elementseq=@v_elementseq_adj
                    end
                end
         end
--
          fetch c_row into @v_id,@v_parentid,@v_nodetype,@v_localname,@v_prev,@v_text
        end
      close c_row
      deallocate c_row

      set @v_row_id=@v_row_id+1
      fetch c_products into @v_xml_product
    end
  close c_products
  deallocate c_products

  exec imp_load_inserts @i_batchkey,@i_templatekey,@i_userid,@o_errcode output,@o_errmsg output
  exec imp_load_rules @i_batchkey,@i_templatekey,@i_userid

--  print @v_xmldoc
end
