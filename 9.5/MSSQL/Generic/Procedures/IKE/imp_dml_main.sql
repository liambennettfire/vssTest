SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: Imp_DML_Main
**  Desc: IKE main routine for updating (DML) rules
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Imp_DML_Main]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Imp_DML_Main]
GO

CREATE PROCEDURE Imp_DML_Main
  @i_batchkey int,
  @i_templatekey int,
  @i_userid varchar(50),
  @o_errcode int output,
  @o_errmsg varchar(300) output
AS

DECLARE 
  @v_row_id varchar(100),
  @v_elementkey bigint,
  @v_elementseq int,
  @v_collectionkey bigint,
  @v_collectionseq int,
  @v_element_value varchar(8000),
  @v_rulecall nvarchar(4000),
  @v_serverity int,
  @v_seq int,
  @v_dmlkey bigint,
  @v_newtitleind int,
  @v_transtype varchar(30),
  @v_collection_rule_parmdef NVARCHAR(500),
  @v_dml_rule_parmdef NVARCHAR(500),
  @v_bookkey int,
  @v_printingkey int,
  @v_datetypecode int,
  @v_orgkeyset varchar(500),
  @v_default_orgkeyset varchar(500),
  @v_titlekeyset varchar(1000),
  @v_tablename varchar(100),
  @v_columnname varchar(100),
  @v_writehistoryind int,
  @v_userid varchar(50),
  @v_errcode int, 
  @v_errmsg  varchar(500),
  @v_ruledesc  varchar(500),
  @v_count int,
  @v_warnings_in_dml int,
  @v_leadcount int,
  @v_process_type int,
  @v_rptlevel int,
  @v_contactkey int, 
  @v_contactorgkeyset varchar(500),
  @v_rulekey bigint,
  @v_returncode int,
  @v_returnmsg varchar(500),
  @v_newcontactind int,
  @v_processorder int,
  @v_keysets_valid int,
  @v_proc_call nvarchar(500),
  @v_proc_call_base nvarchar(500)


BEGIN
  select @v_process_type = processtype, @v_rptlevel = rptlevel
    from imp_batch_master
    where batchkey=@i_batchkey 
  select @v_count = count(*) 
    from imp_feedback
    where serverity = 3
      and batchkey = @i_batchkey 
  if @v_process_type = 4 and @v_count > 0
    begin
      exec imp_write_feedback @i_batchkey, null,null,null, null,'Errors in batch, no updates processed', 3, 3
      return
    end
  exec imp_clear_feedback @i_batchkey,3
  set @v_userid = @i_userid  
  set @v_dml_rule_parmdef = N'@i_batch int, @i_row int, @i_dmlkey bigint, @i_titlekeyset varchar(5000), @i_contactkeyset varchar(5000),@i_templatekey int,@i_elementseq int, @i_level int, @i_userid varchar(50), @i_newtitleind int, @i_newcontactind int, @o_writehistoryind int output' 
  set @v_proc_call_base='exec imp_$$rulekey$$ @i_batch,@i_row,@i_dmlkey,@i_titlekeyset,@i_contactkeyset,@i_templatekey,@i_elementseq,@i_level,@i_userid,@i_newtitleind,@i_newcontactind,@o_writehistoryind output'
  select @v_default_orgkeyset = default_orgkeyset
    from imp_template_master
    where templatekey = @i_templatekey  
-- process rows in a batch
  declare rows_cur cursor FAST_FORWARD for 
    select distinct row_id
      from imp_batch_detail
      where batchkey = @i_batchkey
      order by row_id
  open rows_cur 
  fetch rows_cur into @v_row_id
  while @@fetch_status = 0
    begin
     set @v_keysets_valid=1
     select @v_count = count(*) 
        from imp_feedback
        where serverity = 3
          and batchkey = @i_batchkey 
          and row_id = @v_row_id
      if @v_process_type = 3 and @v_count > 0
        begin
          set @v_errmsg = 'Errors in row '+coalesce(@v_row_id,'n/a')+' can not process updates'
          exec imp_write_feedback @i_batchkey, @v_row_id,null,null, null, @v_errmsg, 3, 3
        end
      else
        begin
          select @v_leadcount=count(*)
            from imp_batch_detail bd, imp_element_defs ed
            where bd.batchkey = @i_batchkey
              and bd.row_id = @v_row_id
              and bd.elementkey = ed.elementkey
              and ed.leadkeyname='bookkey'
          set @v_titlekeyset=null
          if @v_leadcount>0
            begin
              exec imp_establish_title @i_batchkey,@v_row_id,@v_default_orgkeyset,@i_userid,@v_bookkey output,@v_printingkey output,@v_orgkeyset output,@v_newtitleind output, @v_errcode output,@v_errmsg output
              set @v_titlekeyset = cast(@v_bookkey as varchar(20))+','+cast(@v_printingkey as varchar(20))+','+@v_orgkeyset
            end
          if @v_titlekeyset is null
            begin
              set @v_keysets_valid=0
              EXECUTE imp_write_feedback @i_batchkey, @v_row_id, null, null ,null, 'title key value problem', 2, 3
            end
       -- process sequences in row
          declare seq_cur cursor FAST_FORWARD for 
          select distinct coalesce(elementseq,0)
            from imp_batch_detail
            where batchkey = @i_batchkey
              and row_id = @v_row_id
            order by coalesce(elementseq,0)
          open seq_cur 
          fetch seq_cur into @v_seq
          while @@fetch_status = 0
            begin
              select @v_leadcount=count(*)
                from imp_batch_detail bd, imp_element_defs ed
                where bd.batchkey = @i_batchkey
                  and bd.row_id = @v_row_id
                  and bd.elementseq = @v_seq
                  and bd.elementkey = ed.elementkey
                  and ed.leadkeyname='authorkey'

              --mk20140805> setting @v_contactorgkeyset & @v_newcontactind to null for every sequence iteration
              -- ... these are reset by imp_establish_contact as needed
              set @v_contactorgkeyset=null
              set @v_newcontactind=null

              if @v_leadcount>0 and @v_keysets_valid=1
                begin
                  exec imp_establish_contact @i_batchkey, @v_row_id, @v_seq , @v_orgkeyset, @i_userid, @v_contactorgkeyset output, @v_newcontactind output, @o_errcode output, @o_errmsg output
                  if @v_contactorgkeyset is null
                    begin
                      set @v_keysets_valid=0
                      EXECUTE imp_write_feedback @i_batchkey, @v_row_id, null, null ,null, 'contact key value problem', 2, 3
                   end
                end
           -- process dml in sequence
              declare dml_cur cursor FAST_FORWARD for 
                select distinct dm.processorder,dm.dmlkey
                  from imp_dml_master dm, imp_dml_elements de, imp_batch_detail bd
                  where bd.batchkey = @i_batchkey
                    and bd.row_id = @v_row_id
                    and elementseq = @v_seq
                    and bd.elementkey = de.elementkey
                    and dm.dmlkey=de.dmlkey
                    --and dm.rulekey=r.rulekey
                  order by dm.processorder,dm.dmlkey
              open dml_cur 
              fetch dml_cur into @v_processorder,@v_dmlkey
              while @@fetch_status = 0 
                begin
                  set @v_returncode = 0
                  select  @v_rulekey = dm.rulekey
                    from imp_dml_master dm
                    where dm.dmlkey = @v_dmlkey 
                  select @v_warnings_in_dml = count(*)
                    from imp_dml_elements de, imp_feedback f
                    where de.dmlkey=@v_dmlkey
                      and de.elementkey=f.elementkey
                      and f.batchkey=@i_batchkey
                      and f.row_id=@v_row_id
                      and f.elementseq=@v_seq
                      and f.serverity=2
                  if @v_warnings_in_dml = 0 and @v_keysets_valid=1
                    begin
                      set @v_proc_call=replace(@v_proc_call_base,'$$rulekey$$',cast(@v_rulekey as varchar))
--print @v_proc_call
                      exec @v_returncode=sp_executesql @v_proc_call, @v_dml_rule_parmdef,
                        @i_batch = @i_batchkey,
                        @i_row = @v_row_id,
                        @i_dmlkey = @v_dmlkey,
                        @i_titlekeyset = @v_titlekeyset,
                        @i_contactkeyset = @v_contactorgkeyset,
                        @i_templatekey = @i_templatekey,
                        @i_elementseq = @v_seq,
                        @i_level = @v_rptlevel,
                        @i_userid = @v_userid,
                        @i_newtitleind = @v_newtitleind,
                        @i_newcontactind = @v_newcontactind,
                        @o_writehistoryind = @v_writehistoryind output

--                      exec @v_returncode=sp_executesql @v_rulecall, @v_dml_rule_parmdef,
--                        @i_batch = @i_batchkey,
--                        @i_row = @v_row_id,
--                        @i_dmlkey = @v_dmlkey,
--                        @i_titlekeyset = @v_titlekeyset,
--                        @i_contactkeyset = @v_contactorgkeyset,
--                        @i_templatekey = @i_templatekey,
--                        @i_elementseq = @v_seq,
--                        @i_level = @v_rptlevel,
--                        @i_userid = @v_userid,
--                        @i_newtitleind = @v_newtitleind,
--                        @i_newcontactind = @v_newcontactind,
--                        @o_writehistoryind = @v_writehistoryind output

                      if @v_returncode <> 0
                        begin
                          set @v_returnmsg='dml rule failure (msg '+cast(@v_returncode as varchar(20))+')'
                          EXECUTE imp_write_feedback @i_batchkey, @v_row_id, @v_elementkey, @v_elementseq ,@v_rulekey , @v_returnmsg, 3, 3
                        end
                      set @v_rulecall=null
                    end
                  else
                    begin
                      set @v_returnmsg='update not performed:('+cast(@v_rulekey as varchar(20))+')'
                      EXECUTE imp_write_feedback @i_batchkey, @v_row_id, @v_elementkey, @v_elementseq ,@v_rulekey , @v_returnmsg, 3, 3
                    end
               -- handle title/date history                      
                  select @v_tablename = e.destinationtable,
                      @v_columnname = e.destinationcolumn,
                      @v_datetypecode = e.datetypecode
                    from imp_element_defs e, imp_dml_elements d
                    where d.dmlkey = @v_dmlkey
                      and d.elementkey =  e.elementkey
                  if @v_tablename is not null and @v_columnname is not null and coalesce(@v_writehistoryind,0)=1
                    begin
                      if @v_newtitleind = 1 or @v_newcontactind = 1
                        begin
                          set @v_transtype = 'insert'
                        end
                      else
                        begin
                          set @v_transtype = 'update'
                        end
                      select @v_element_value =  originalvalue
                        from imp_batch_detail b , imp_DML_elements d
                        where b.batchkey = @i_batchkey
                          and b.row_id = @v_row_id
                          and b.elementseq = @v_seq 
                          and b.elementkey = d.elementkey
                          and d.DMLkey = @v_dmlkey
                      set @v_bookkey = dbo.resolve_keyset(@v_titlekeyset,1)
                      set @v_printingkey = dbo.resolve_keyset(@v_titlekeyset,2)
                      exec qtitle_update_titlehistory 
                        @v_tablename,@v_columnname,@v_bookkey,@v_printingkey,@v_datetypecode,
                        @v_element_value,@v_transtype,@i_userid,null,null,
                        @v_errcode output, @v_errmsg output
                    end
                  fetch dml_cur into @v_processorder,@v_dmlkey
                end          
              close dml_cur 
              deallocate dml_cur 
           -- end process dml in sequence
              fetch seq_cur into @v_seq
            end
          close seq_cur 
          deallocate seq_cur 
       -- end process sequences in row
        end           
      fetch rows_cur into @v_row_id
    end
  close rows_cur 
  deallocate rows_cur 
 -- end processing rows in a batch
END


SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.Imp_DML_Main TO PUBLIC 
GO


