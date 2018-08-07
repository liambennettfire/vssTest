/******************************************************************************
**  Name: imp_load_rules
**  Desc: IKE run loader rules
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_load_rules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_load_rules]
GO

CREATE PROCEDURE imp_load_rules 
  @i_batchkey int,
  @i_templatekey int,
  @i_userid varchar
AS
BEGIN
  declare
    @v_rule_call nvarchar(4000),
    @v_load_rule_parmdef nvarchar(2000),
    @v_row_id int,
    @v_rulekey bigint,
    @v_elementseq int,
    @v_processorder int,
    @v_returnmsg varchar(500),
    @v_returncode int,
    @v_proc_call nvarchar(500),
    @v_proc_call_base nvarchar(500)

  set @v_load_rule_parmdef = N'@i_batchkey int, @i_row int, @i_elementseq int, @i_templatekey int, @i_rulekey bigint, @i_level int,@i_userid varchar(50)' 
  set @v_proc_call_base='exec imp_$$rulekey$$ @i_batchkey, @i_row , @i_elementseq , @i_templatekey , @i_rulekey , @i_level ,@i_userid'
  declare rows_cur cursor FAST_FORWARD for 
    select distinct row_id
      from imp_batch_detail
      where batchkey = @i_batchkey
      order by row_id
  open rows_cur 
  fetch rows_cur into @v_row_id 
  while @@fetch_status=0 
    begin
      declare load_seq_cur cursor FAST_FORWARD for
        select distinct bd.elementseq
          from imp_batch_detail bd
          where bd.batchkey=@i_batchkey
            and bd.row_id=@v_row_id
          order by bd.elementseq
      open load_seq_cur
      fetch load_seq_cur into @v_elementseq
      while @@fetch_status=0 
        begin
          declare load_rules_cur cursor FAST_FORWARD for
            select distinct lm.loadkey,lm.processorder
            from imp_load_master lm, imp_load_elements le, imp_batch_detail bd
            where lm.loadkey=le.loadkey
              and le.elementkey=bd.elementkey
              and bd.batchkey=@i_batchkey
              and bd.row_id=@v_row_id
              and bd.elementseq=@v_elementseq
            order by lm.processorder
          open load_rules_cur 
          fetch load_rules_cur into @v_rulekey,@v_processorder 
          WHILE @@fetch_status=0
            begin  
              set @v_proc_call=replace(@v_proc_call_base,'$$rulekey$$',cast(@v_rulekey as varchar))
              exec @v_returncode=sp_executesql @v_proc_call, @v_load_rule_parmdef,
                    @i_batchkey = @i_batchkey,
                    @i_row = @v_row_id,
                    @i_elementseq = @v_elementseq,
                    @i_templatekey = @i_templatekey,
                    @i_rulekey = @v_rulekey,
                    @i_level = 1,
                    @i_userid = @i_userid
              if @v_returncode <> 0
                begin
                  set @v_returnmsg='loader rule failure (msg '+cast(@v_returncode as varchar(20))+')'
                  EXECUTE imp_write_feedback @i_batchkey, @v_row_id, null, @v_elementseq ,@v_rulekey , @v_returnmsg, 3,1
                end
              fetch load_rules_cur into @v_rulekey,@v_processorder 
            end 
          close load_rules_cur 
          deallocate load_rules_cur 
          fetch load_seq_cur into @v_elementseq
        end
      close load_seq_cur 
      deallocate load_seq_cur 

      fetch rows_cur into @v_row_id 
    end
  close rows_cur 
  deallocate rows_cur 

END
go