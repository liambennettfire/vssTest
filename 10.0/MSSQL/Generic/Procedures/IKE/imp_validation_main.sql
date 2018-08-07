SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_validation_main
**  Desc: IKE main validation routine
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_validation_main]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_validation_main]
GO

CREATE PROCEDURE imp_validation_main
@i_batchkey int,
@i_templatekey int,
@i_userid varchar(50)
AS

DECLARE 
  @v_row_id int,
  @v_elementkey bigint,
  @v_elementseq int,
  @v_rulekey bigint,
  @v_collectionkey bigint,
  @v_collectionseq int,
  @v_element_value varchar(8000),
  @v_rulecall nvarchar(4000),
  @v_serverity int,
  @v_rule_serverity int,
  @v_errlevel int,
  @v_sqlerrcode int,
  @v_returncode int,
  @v_returnmsg varchar(500),
  @v_collection_rule_parmdef NVARCHAR(500),
  @v_element_rule_parmdef NVARCHAR(500),
  @v_proc_call nvarchar(500),
  @v_proc_call_ele_base nvarchar(500),
  @v_proc_call_coll_base nvarchar(500)

BEGIN
  
  set @v_element_rule_parmdef = N'@i_batch int, @i_row varchar(50), @i_elementkey bigint, @i_elementseq int, @i_templatekey int, @i_rulekey bigint, @i_rpt int' 
  set @v_proc_call_ele_base='exec imp_$$rulekey$$ @i_batch , @i_row , @i_elementkey , @i_elementseq , @i_templatekey , @i_rulekey , @i_rpt'
  set @v_collection_rule_parmdef = N'@i_batch int, @i_row varchar(50), @i_collectionkey bigint, @i_collectionseq int, @i_templatekey int, @i_rulekey bigint, @i_rpt int'
  set @v_proc_call_coll_base='exec imp_$$rulekey$$ @i_batch , @i_row , @i_collectionkey , @i_collectionseq , @i_templatekey , @i_rulekey , @i_rpt'
  select @v_serverity=processtype, @v_errlevel = rptlevel
    from imp_batch_master
    where batchkey=@i_batchkey
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
-- process elements in row
      declare elements_cur cursor FAST_FORWARD for 
        select elementkey, elementseq
          from imp_batch_detail
          where batchkey = @i_batchkey
            and row_id = @v_row_id
      open elements_cur 
      fetch elements_cur into @v_elementkey, @v_elementseq
      while @@fetch_status = 0
        begin
          select @v_element_value = originalvalue
            from imp_batch_detail
            where batchkey = @i_batchkey
              and row_id = @v_row_id
              and elementkey = @v_elementkey
              and elementseq = @v_elementseq
          declare element_rules_cur cursor FAST_FORWARD for 
            select er.rulekey
              from imp_element_rules er 
              where er.elementkey = @v_elementkey
          open element_rules_cur 
          fetch element_rules_cur into @v_rulekey 
          while @@fetch_status = 0 
            begin
              set @v_proc_call=replace(@v_proc_call_ele_base,'$$rulekey$$',cast(@v_rulekey as varchar))
              exec @v_returncode=sp_executesql @v_proc_call, @v_element_rule_parmdef,
                @i_batch = @i_batchkey,
                @i_row = @v_row_id,
                @i_elementkey = @v_elementkey,
                @i_elementseq = @v_elementseq,
                @i_templatekey = @i_templatekey,
                @i_rulekey = @v_rulekey,
                @i_rpt = @v_errlevel
              if @v_returncode <> 0
                begin
                  set @v_returnmsg='element rule failure (msg '+cast(@v_returncode as varchar(20))+')'
                  EXECUTE imp_write_feedback @i_batchkey, @v_row_id, @v_elementkey, @v_elementseq ,@v_rulekey ,@v_returnmsg , 3, 2
                end
              fetch element_rules_cur into @v_rulekey 
            end
          close element_rules_cur 
          deallocate element_rules_cur 
          fetch elements_cur into @v_elementkey, @v_elementseq
        end
      close elements_cur 
      deallocate elements_cur 
-- end processing elements in row
-- process collections in row
      declare collections_cur cursor FAST_FORWARD for 
        select distinct ce.collectionkey
          from imp_batch_detail bd, imp_collection_master cm, imp_collection_elements ce
          where bd.batchkey = @i_batchkey
            and bd.row_id = @v_row_id
            and bd.elementkey = ce.elementkey
            and ce.collectionkey = cm.collectionkey
--        order by cm.processorder
      open collections_cur 
      fetch collections_cur into @v_collectionkey
      while @@fetch_status = 0
        begin
          declare collection_rules_cur cursor FAST_FORWARD for 
            select cr.rulekey
              from imp_collection_rules cr
              where cr.collectionkey = @v_collectionkey
          open collection_rules_cur 
          fetch collection_rules_cur into @v_rulekey 
          while @@fetch_status = 0
            begin
-- process sequences of a collections
              declare collection_seq_cur cursor FAST_FORWARD for 
                select distinct bd.elementseq
                  from imp_batch_detail bd, imp_collection_elements ce
                  where ce.collectionkey = @v_collectionkey
                    and ce.elementkey = bd.elementkey
                    and bd.row_id = @v_row_id
              open collection_seq_cur 
              fetch collection_seq_cur into @v_collectionseq
              while @@fetch_status = 0
                begin
                  set @v_proc_call=replace(@v_proc_call_coll_base,'$$rulekey$$',cast(@v_rulekey as varchar))
                  exec @v_returncode=sp_executesql @v_proc_call, @v_collection_rule_parmdef,
                    @i_batch = @i_batchkey,
                    @i_row = @v_row_id,
                    @i_collectionkey = @v_collectionkey,
                    @i_collectionseq = @v_collectionseq,
                    @i_templatekey = @i_templatekey,
                    @i_rulekey = @v_rulekey,
                    @i_rpt = @v_errlevel
                  if @v_returncode <> 0
                    begin
                      set @v_returnmsg='collection rule failure (msg '+cast(@v_returncode as varchar(20))+')'
                      EXECUTE imp_write_feedback @i_batchkey, @v_row_id, null, null ,@v_rulekey , @v_returnmsg, 3,2
                    end
                  fetch collection_seq_cur into @v_collectionseq
                end
              close collection_seq_cur 
              deallocate collection_seq_cur 
              fetch collection_rules_cur into @v_rulekey
-- end processing sequences of a collections
            end
          close collection_rules_cur 
          deallocate collection_rules_cur 
          fetch collections_cur into @v_collectionkey
        end
      close collections_cur 
      deallocate collections_cur 
-- end processing collections in row
      fetch rows_cur into @v_row_id
    end
  close rows_cur 
  deallocate rows_cur 
-- end processing rows in a batch

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON imp_validation_main to PUBLIC 
GO


