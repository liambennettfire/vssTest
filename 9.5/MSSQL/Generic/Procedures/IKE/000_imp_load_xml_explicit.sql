SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_load_xml_explicit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_load_xml_explicit]
GO

CREATE PROCEDURE dbo.imp_load_xml_explicit
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
  @v_elementseq_adj int,
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
  @v_parent_node int,
  @v_parent_name varchar(500),
  @v_xq_node varchar(500),
  @v_xq_value varchar(500),
  @v_xq_sql nvarchar(max),
  @v_xq_xml_list xml,
  @v_xq_xml_single xml,
  @v_xq_value_single nvarchar(500),
  @v_xq_cursor_parmdef NVARCHAR(500),
  @v_xq_value_parmdef NVARCHAR(500),
  @v_all_node varchar(500),
  @v_work_node varchar(500),
  @v_front_node varchar(500),
  @v_middle_node varchar(500),
  @v_last_node varchar(500),
  @v_lastchar_pntr int,
  @v_lastchar int,
  @v_iLoopMax int,
  @v_iLoopCount int,
  @v_ProductsNodeName as varchar(255),
  @v_RootNodeName as varchar(255),
  @DEBUG as int
 
begin


/******************************************************************************
**  Name: imp_load_xml_explicit
**  Desc: IKE load expliicit xml routine
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
	6/24/2016	 JDoe		 Case 37887:
							 fix for only one multiSequence import (Ie. If multiple 
								booksubjectcategory elements to import for one title, 
								it was previously only importing the LAST node value 
								because it was inserting every 100017001 element as 
								elementseq=1 instead of 1,2,3 etc)

	6/27/2016	JDOE		Case 38020:
							Removed misleading 'MISSING XML PATH:' entries because 
								the second section finds the XML paths
							Also added call to sp_xml_removedocument per 
								https://msdn.microsoft.com/en-us/library/ms187367.aspx
*******************************************************************************/

  set @DEBUG=0
  set @v_row_id=1
  set @v_parmdef = N'@o_xml xml' 
  set @v_readxml_parmdef = N'@o_xmldoc nvarchar(max) output' 
  set @v_readxml_sql='SELECT  @o_xmldoc=xmlData FROM(SELECT * FROM OPENROWSET (BULK ''' + @i_input_file + ''' , SINGLE_CLOB) AS XMLDATA) AS FileImport (XMLDATA)'
  
  
  set @v_xml=@i_SourceXML
  IF @v_xml IS NULL 
  BEGIN
	exec @v_returncode=sp_executesql @v_readxml_sql, @v_readxml_parmdef,@o_xmldoc = @v_xmldoc output
	set @v_xml=convert(xml,@v_xmldoc,2)
  END
   
  set @v_sql=N'declare c_products cursor FAST_FORWARD for SELECT T.c.query(''.'') AS result FROM @o_xml.nodes('+char(39)+@i_root_path+char(39)+') T(c)'
--if @DEBUG<>0 print @v_sql
  exec @v_returncode=sp_executesql @v_sql, @v_parmdef, @o_xml = @v_xml
  
  if @v_returncode <> 0
    begin
      set @v_returnmsg='XML read rule failure (msg '+cast(@v_returncode as varchar(20))+')'
      set @o_errcode=@v_returncode
      set @o_errmsg=@v_returnmsg
      EXECUTE imp_write_feedback @i_batchkey, null, null, null ,null , @v_returnmsg, 3,2
      return
    end
  set @v_worknode_pos=datalength(@i_root_path)-PATINDEX ('%/%',REVERSE(@i_root_path))+1
  set @v_working_root_node=substring(@i_root_path,@v_worknode_pos,500)
  set @v_exception_rule_parmdef = N'@i_batchkey int, @i_row_id int, @i_elementseq int, @io_elementkey int output' 

  declare c_template cursor for
    select elementkey,columnname,transmnemonic,mapkey
      from imp_template_detail
      where templatekey=@i_templatekey
        and coalesce(rowinsertind,0)=0
        and coalesce(seqinsertind,0)=0

  -- check for missing XML path references
  open c_template
  fetch c_template into @v_elementkey,@v_columnname,@v_column_mnemonic,@v_mapkey
  while @@fetch_status=0
    begin
	  -- mk>201020806
	  -- find the overlapping nodes of @i_root_path & @v_columnname and trim that value off of @i_root_path
	  -- exmaple:
	  -- ... if @i_root_path = /ONIXmessage/product and @v_columnname = /product/titleinfo/isbn13
	  -- ... then the overlapping node is "/product" ... this needs to be stripped
	  
	  SET @v_RootNodeName=@i_root_path
	  SET @v_ProductsNodeName = SUBSTRING(@v_columnname,0,CHARINDEX('/',@v_columnname,2))
	  IF len(@v_ProductsNodeName)>0 SET @v_RootNodeName = REPLACE(@v_RootNodeName,@v_ProductsNodeName,'')
	  
      set @v_xq_cursor_parmdef = N'@o_count int output,@i_xml xml'
      set @v_xq_sql=N'SELECT @o_count=count(T.c.query(''.'')) FROM @i_xml.nodes('''+@v_RootNodeName+@v_columnname+''') T(c);'
      --set @v_xq_sql=N'SELECT count(T.c.query(''.'')) FROM @i_xml.nodes('''+'/ONIXmessage'+@v_columnname+''') T(c);'
      --if @DEBUG<>0 print @v_xq_sql
      exec @v_returncode=sp_executesql @v_xq_sql, @v_xq_cursor_parmdef, @o_count = @v_count output,@i_xml = @v_xml
    --  if @v_count=0
    --    begin			
    --      set @o_errcode=1
    --      set @o_errmsg='missing xml path: '+@v_columnname
		  
		  --if @DEBUG<>0 print char(13)+char(10)
    --      if @DEBUG<>0 print upper(@o_errmsg)
    --      if @DEBUG<>0 print '@v_ProductsNodeName = ' + coalesce(@v_ProductsNodeName,'*NULL*')
		  --if @DEBUG<>0 print '@v_columnname= ' + coalesce(@v_columnname,'*NULL*')          
	   --   if @DEBUG<>0 print @v_RootNodeName+@v_columnname
	      
    --      EXECUTE imp_write_feedback @i_batchkey, null, null, null, null , @o_errmsg, 1, 1
    --      set @o_errcode=0
    --      set @o_errmsg=null
    --    end
      fetch c_template into @v_elementkey,@v_columnname,@v_column_mnemonic,@v_mapkey
    end  
  close c_template


  --load data 
  open c_products
  fetch c_products into @v_xml_product
  while @@fetch_status = 0
    begin
      set @v_xml_doc=cast(@v_xml_product as nvarchar(max))
      EXEC sp_xml_preparedocument @v_DocHandle OUTPUT, @v_xml_doc

      set @v_xml_doc='<?xml version="1.0" encoding="ISO-8859-1" ?> '+@v_xml_doc
      open c_template
      fetch c_template into @v_elementkey,@v_columnname,@v_column_mnemonic,@v_mapkey
      while @@fetch_status=0
        begin
          -- break out node names
          --   the goal is to all but the last node in @v_xq_node and the last two in @v_xq_value
          set @v_all_node = replace(@v_columnname+'/','//','/')
          set @v_work_node = null
          set @v_front_node = ''
          set @v_middle_node = ''
          set @v_last_node = ''
          set @v_lastchar_pntr=charindex('/',@v_all_node,2) 
          while @v_lastchar_pntr<>0 
            begin
              set @v_work_node = substring(@v_all_node,1,@v_lastchar_pntr-1)
              set @v_all_node = substring(@v_all_node,@v_lastchar_pntr,len(@v_all_node))
              if @v_work_node is not null
                begin
                  set @v_front_node=@v_front_node+@v_middle_node
                  set @v_middle_node=@v_last_node
                  set @v_last_node=@v_work_node
                end
              set @v_lastchar_pntr=charindex('/',@v_all_node,2)
            end
          set @v_xq_node=@v_front_node+@v_middle_node
          set @v_xq_value=@v_middle_node+@v_last_node
          
          set @v_elementseq=1

          set @v_xq_cursor_parmdef = N'@i_xml xml'
          set @v_xq_sql=
            N'declare c_nodes cursor fast_forward for
               SELECT T.c.query(''.'') AS result
               FROM   @i_xml.nodes('''+@v_xq_node+''') T(c);'
               
          if @DEBUG<>0 print '@v_elementkey = ' + cast (@v_elementkey as varchar(max))
          if @DEBUG<>0 print '@v_xq_sql = ' + coalesce (@v_xq_sql, '')
          
          exec @v_returncode=sp_executesql @v_xq_sql, @v_xq_cursor_parmdef, @i_xml = @v_xml_product
          open c_nodes
          fetch c_nodes into @v_xq_xml_single
          while @@fetch_status=0
            begin
				set @v_iLoopCount=0
				set @v_iLoopMax=0
				set @v_xq_cursor_parmdef = N'@o_count int output,@i_xq_xml_single xml'
				set @v_xq_sql=N'SELECT @o_count=count(T.c.query(''.'')) FROM @i_xq_xml_single.nodes(''' + @v_xq_value + ''') T(c);'
				exec @v_returncode=sp_executesql @v_xq_sql, @v_xq_cursor_parmdef, @o_count = @v_iLoopMax output,@i_xq_xml_single = @v_xq_xml_single
				
				--if @v_elementkey = 100012069 print cast (@v_xq_xml_single as varchar(max))

				--print @v_xq_sql + ' ... @v_count = ' + cast(@v_iLoopMax as varchar(max))
				
				while @v_iLoopCount < @v_iLoopMax
				begin
					set @v_element_value=null
					set @v_xq_value_parmdef = N'@o_element_value varchar(max) output, @i_xq_xml_single xml'
					set @v_xq_value_single=N'select @o_element_value=@i_xq_xml_single.value(''('+@v_xq_value+')[' + cast((@v_iLoopCount + 1) as varchar(3)) + ']'',''varchar(max)'');'
					
					BEGIN TRY
						exec sp_executesql @v_xq_value_single,@v_xq_value_parmdef,
						@o_element_value = @v_element_value output,
						@i_xq_xml_single = @v_xq_xml_single
					END TRY
					BEGIN CATCH
						SELECT
							ERROR_NUMBER() AS ErrorNumber
							,ERROR_SEVERITY() AS ErrorSeverity
							,ERROR_STATE() AS ErrorState
							,ERROR_PROCEDURE() AS ErrorProcedure
							,ERROR_LINE() AS ErrorLine
							,ERROR_MESSAGE() AS ErrorMessage;
					END CATCH
					
					--print '@v_xq_value = ' + cast(@v_xq_value as varchar(max))
					--
					select @v_lobind=lobind
					from imp_element_defs
					where elementkey=@v_elementkey
					
					----------------------------------------------------------------------------------------------------------------
					--marcus 1.29.2013
					EXECUTE imp_Batch_Detail_Insert
 						@i_batchkey
						,@v_row_id
						,@v_elementkey
						,@v_elementseq
						,@v_element_value
						,@i_userid
						,@v_iLoopCount
						,@v_mapkey
						,@v_lobind
						,@o_errcode OUTPUT
						,@o_errmsg OUTPUT
					----------------------------------------------------------------------------------------------------------------
					set @v_iLoopCount=@v_iLoopCount+1
					-- JDOE 6/24/2016 see comment below
					set @v_elementseq = @v_elementseq + 1
				end
				--                  
--	JDOE 6/24/2016 move this two lines above --			set @v_elementseq = @v_elementseq + 1
				fetch c_nodes into @v_xq_xml_single
            end
          close c_nodes
          deallocate c_nodes
          
          fetch c_template into @v_elementkey,@v_columnname,@v_column_mnemonic,@v_mapkey
        end
      close c_template 
	  -- JDOE 6/27/2017 added sp_xml_removedocument per https://msdn.microsoft.com/en-us/library/ms187367.aspx
	  EXEC sp_xml_removedocument @v_DocHandle
      set @v_row_id=@v_row_id+1
      fetch c_products into @v_xml_product
    end
  close c_products
  deallocate c_products
  deallocate c_template 

	set @o_errcode=0
	set @o_errmsg=null

	exec imp_load_inserts @i_batchkey,@i_templatekey,@i_userid,@o_errcode output,@o_errmsg output
	set @o_errcode=0
	set @o_errmsg=null

	exec imp_load_rules @i_batchkey,@i_templatekey,@i_userid

end
grant execute on dbo.imp_load_xml_explicit to public