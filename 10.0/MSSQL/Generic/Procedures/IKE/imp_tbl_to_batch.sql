SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_tbl_to_batch
**  Desc: IKE load table data to imp_batch_detail
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_tbl_to_batch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_tbl_to_batch]
GO

CREATE PROCEDURE imp_tbl_to_batch
  @i_tablename varchar(100),
  @i_batch_number int,
  @i_templatekey int,
  @i_userid varchar(50)
AS

DECLARE 
  @v_sql nvarchar(4000),
  @v_tablename varchar(4000),
  @v_columnname varchar(50),
  @v_column_mnemonic varchar(50),
  @v_element_value varchar(max),
  @v_element_mapped_value varchar(4000),
  @v_parmlist nvarchar(4000),
  @v_rownum int,
  @v_elementkey int,
  @v_rulekey bigint,
  @v_rulecall nvarchar(4000),
  @v_errcode int,
  @v_errmsg varchar(500),
  @v_elementseq int,
  @v_mapkey int,
  @v_lobkey int,
  @v_lobind int,
  @v_nullind int,
  @v_ntext_length int,
  @v_column_type varchar(20),
  @v_part_offset int,
  @v_part_val varchar(4000),
  @v_temp_lob_pointer binary(16),
  @x_temp_lob_pointer binary(16),
  @v_imp_text_pointer binary(16),
  @v_imp_ntext_pointer binary(16),
  @x_imp_ntext_pointer binary(16),
  @v_imp_lob_pointer binary(16),
  @x_imp_lob_pointer binary(16),
  @v_sql_parmdef nvarchar(2000),
  @v_sql_ntext_parmdef nvarchar(2000),
  @v_load_rule_parmdef nvarchar(2000),
  @v_returncode int,
  @v_returnmsg varchar(500),
  @o_errcode int,
  @o_errmsg varchar (500)

BEGIN

  set @v_rownum = 0
  set @v_sql_parmdef = N'@x_temp_lob_pointer binary(16), @x_imp_lob_pointer binary(16)' 
  set @v_sql_ntext_parmdef = N'@x_temp_lob_pointer binary(16), @x_imp_ntext_pointer binary(16)' 
--  set @v_load_rule_parmdef = N'@i_batchkey int, @i_row varchar(50), @i_elementkey bigint, @i_elementseq int,@i_element_value varchar(5000), @i_rulekey bigint, @i_level int,@i_userid varchar(50)' 
  set @v_tablename = ltrim(rtrim(@i_tablename))
  if substring(@v_tablename,1,1)='#'
    begin
      DECLARE c_columnnames CURSOR FAST_FORWARD for
        select sc.name, st.name
          from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
          where so.name like @v_tablename+'%'
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
          order by so.name
     end
   else
    begin
      DECLARE c_columnnames CURSOR  FAST_FORWARD FOR
        select sc.name, st.name
          from sysobjects so, syscolumns sc, systypes st
          where so.name = @v_tablename
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
          order by so.name
     end
  open c_columnnames 
  fetch c_columnnames into @v_columnname,@v_column_type
  while @@fetch_status=0
    begin
      -- find element
      set @v_elementkey = null
      set @v_column_mnemonic = null
      set @v_elementseq = null
      exec imp_seq_check @v_columnname, @i_templatekey, @v_column_mnemonic output, @v_elementseq output
      select @v_elementkey = elementkey, @v_lobind = lobind,@v_nullind = importnullind
        from imp_element_defs
        where upper(@v_column_mnemonic) = upper(elementmnemonic)
      select @v_mapkey = mapkey
        from imp_template_detail
        where elementkey = @v_elementkey
			AND templatekey = @i_templatekey
      if @v_elementkey is not null and @v_column_mnemonic <> 'ignore'
        begin
          set @v_rownum = 0
          if (@v_lobind = 0 or @v_lobind is null) or (@v_column_type<>'text' and @v_column_type<>'ntext')
            begin
              set @v_sql = N'declare c_columndata cursor FAST_FORWARD for select '+@v_columnname+' from '+@v_tablename
              exec sp_executesql @v_sql
              open c_columndata
              fetch c_columndata into @v_element_value
              while @@fetch_status = 0
                begin
                  set @v_rownum = @v_rownum + 1
                  if @v_mapkey is not null  
                    begin
                      set @v_element_mapped_value = null
                      select @v_element_mapped_value = to_value
                        from imp_mapping
                        where mapkey = @v_mapkey
                          and from_value = @v_element_value 
                      if @v_element_mapped_value is not null 
                        begin
                          set @v_element_value = @v_element_mapped_value
                        end
                    end
                  if not(@v_element_value is null OR rtrim(coalesce(@v_element_value,'')) = '') OR @v_nullind = 1
                    begin
                      set @v_rulecall = null
                      set @v_rulekey = null
--/* this is a load element handled below
--                      select @v_rulecall = r.rulecall, @v_rulekey = r.rulekey
--                        from imp_load_rules l, imp_rules r 
--                        where l.elementkey = @v_elementkey
--                          and l.rulekey = r.rulekey
                      if @v_rulecall is not null
                        begin
                          set @v_rulecall = null
--                          exec @v_returncode=sp_executesql @v_rulecall, @v_load_rule_parmdef, 
--                            @i_batchkey = @i_batch_number,
--                            @i_row = @v_rownum,
--                            @i_elementkey = @v_elementkey,
--                            @i_elementseq = @v_elementseq,
--                            @i_element_value = @v_element_value,
--                            @i_rulekey = @v_rulekey,
--                            @i_level = 1,
--                            @i_userid = @i_userid
--                          if @v_returncode <> 0
--                            begin
--                              set @v_returnmsg='loader rule failure (msg '+cast(@v_returncode as varchar(20))+')'
--                              EXECUTE imp_write_feedback @i_batch_number, @v_rownum, @v_elementkey, @v_elementseq ,@v_rulekey , @v_returnmsg, 3,1
--                            end
                        end
--*/                                       
                      else
                        begin
						--mk>20120926: Case: 21220 IKE comment truncation (0085 NB Internal IT)
						 if LEN(@v_element_value)>4000 
							EXECUTE imp_write_feedback @i_batch_number, @v_rownum, @v_elementkey, @v_elementseq ,@v_rulekey , 
							'[imp_tbl_to_batch] Truncation warning while inserting into imp_batch_detail : this value is larger than 4000 characters (not a problem for comments)',  1,1
							                        
                         insert into imp_batch_detail
                           (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
                           values
                           (@i_batch_number,@v_rownum,@v_elementkey,@v_elementseq,substring(@v_element_value,1,4000),@i_userid ,getdate())
                         if @v_lobind = 1
                           begin
                             update keys set generickey=generickey+1
                             select @v_lobkey = generickey from keys
                             insert into imp_batch_lobs
                               (batchkey,lobkey,textvalue)
                               values
                               (@i_batch_number,@v_lobkey,@v_element_value)
                             update imp_batch_detail
                               set originalvalue = null, lobkey = @v_lobkey
                               where batchkey=@i_batch_number
                                 and row_id=@v_rownum
                                 and elementkey=@v_elementkey
                                 and elementseq=@v_elementseq
                           end
                        end
                    end
                  set @v_element_value = null
                  fetch c_columndata into @v_element_value
                end
              close c_columndata
              deallocate c_columndata   
            end 
          if @v_lobind = 1 and (@v_column_type='text' or @v_column_type='ntext')
            begin
              set @v_sql = N'declare c_columndata cursor FAST_FORWARD for select TEXTPTR('+@v_columnname+') from '+@v_tablename
              exec sp_executesql @v_sql
              open c_columndata
              fetch c_columndata into @v_temp_lob_pointer
              while @@fetch_status = 0
                begin
                  set @v_rownum = @v_rownum + 1
                  if @v_temp_lob_pointer is not null
                    begin
                      -- generate lobkey
                      update keys set generickey=generickey+1
                      select @v_lobkey = generickey from keys
                      insert into imp_batch_detail
                        (batchkey,row_id,elementkey,elementseq,lobkey,lastuserid,lastmaintdate)
                        values
                        (@i_batch_number,@v_rownum,@v_elementkey,@v_elementseq,@v_lobkey,@i_userid,getdate())
                      insert into imp_batch_lobs
                        (batchkey,lobkey,textvalue)
                        values
                        (@i_batch_number,@v_lobkey,'')
                      if @v_column_type = 'text'
                        begin
                          select @v_imp_lob_pointer = TEXTPTR(textvalue)
                            from imp_batch_lobs
                            where lobkey = @v_lobkey
                          set @v_sql = N'UPDATETEXT imp_batch_lobs.textvalue @x_imp_lob_pointer 0 0 '+@v_tablename+'.'+@v_columnname+' @x_temp_lob_pointer'
                          exec sp_executesql @v_sql, @v_sql_parmdef,
                            @x_temp_lob_pointer = @v_temp_lob_pointer,
                            @x_imp_lob_pointer = @v_imp_lob_pointer
                        end
                      else
                        begin
                          if @v_column_type = 'ntext'
                            begin
                              update imp_batch_lobs
                                set ntextvalue = ''
                                where lobkey = @v_lobkey
                              select @v_imp_text_pointer = TEXTPTR(textvalue)
                                from imp_batch_lobs
                                where lobkey = @v_lobkey
                              select @v_imp_ntext_pointer = TEXTPTR(ntextvalue)
                                from imp_batch_lobs
                                where lobkey = @v_lobkey
                              set @v_sql = N'UPDATETEXT imp_batch_lobs.ntextvalue @x_imp_ntext_pointer 0 0 '+@v_tablename+'.'+@v_columnname+' @x_temp_lob_pointer'
                              exec sp_executesql @v_sql, @v_sql_ntext_parmdef,
                                @x_temp_lob_pointer = @v_temp_lob_pointer,
                                @x_imp_ntext_pointer = @v_imp_ntext_pointer
                              -- convert ntextvalue to textvalue
                              set @v_part_offset = 0
                              select @v_part_val = cast(substring(ntextvalue,@v_part_offset,4000) as varchar(8000)),@v_ntext_length=datalength(ntextvalue)
                                from imp_batch_lobs
                                where lobkey = @v_lobkey
                              while datalength(@v_part_val) > 0
                                begin
                                  updatetext imp_batch_lobs.textvalue @v_imp_text_pointer null null @v_part_val
                                  set @v_part_offset = @v_part_offset + 4000 -1
                                  if @v_part_offset < @v_ntext_length
                                    begin
                                      select @v_part_val = cast(substring(ntextvalue,@v_part_offset,4000) as varchar(8000))
                                        from imp_batch_lobs
                                        where lobkey = @v_lobkey
                                    end
                                  else
                                    begin
                                      set @v_part_val = ''
                                    end
                                end
                            end
                          else
                            begin
                              update imp_batch_lobs
                                set textvalue = @v_element_value
                                where lobkey = @v_lobkey
                            end
                        end
                    end
                  fetch c_columndata into @v_temp_lob_pointer
                end
              close c_columndata
              deallocate c_columndata   
            end 
        end
      else
        begin
          if  @v_column_mnemonic <> 'ignore'
            begin
              -- failure to map raw data to known elements
              set @v_errmsg = 'failure to map ['+@v_columnname+'] to known elements'
              exec imp_write_feedback @i_batch_number,null,null,null,null,@v_errmsg,3,1
            end
        end
      fetch c_columnnames into @v_columnname,@v_column_type
    end
  close c_columnnames 
  deallocate c_columnnames 

  exec imp_load_inserts @i_batch_number,@i_templatekey,@i_userid,@o_errcode output,@o_errmsg output
  exec imp_load_rules @i_batch_number,@i_templatekey,@i_userid

END
gO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON imp_tbl_to_batch to PUBLIC 
GO

