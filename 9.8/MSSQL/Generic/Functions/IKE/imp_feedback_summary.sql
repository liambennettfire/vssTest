SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************
**  Name: imp_feedback_summary
**  Desc: IKE returns a summary for the feedback for a give batch
**  Auth: Bennett     
**  Date: 5/26/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/26/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.imp_feedback_summary') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.imp_feedback_summary
GO

create FUNCTION [dbo].[imp_feedback_summary]
    ( @i_batchkey int)

RETURNS varchar(MAX)

BEGIN 

  DECLARE 
    @o_msg varchar(max),
    @v_new_line varchar(10),
    @v_batchdesc varchar(200),
    @v_templatekey int,
    @v_processlevel int,
    @v_lastuserid varchar(50),
    @v_feedbackmsg varchar(500),
    @v_row_id int,
    @v_count int,
    @v_loader_count int,
    @v_validation_count int,
    @v_DML_count int
    

  set @v_new_line=CHAR(13)+CHAR(10)

  select @v_batchdesc=batchdesc,@v_templatekey=templatekey,@v_processlevel=processtype,@v_lastuserid=latsuserid
    from imp_batch_master
     where batchkey=@i_batchkey
  if @v_batchdesc is null 
    begin
      set @o_msg='No batch for '+cast(@i_batchkey as varchar)
      RETURN @o_msg
    end
    
  -- header info
  set @o_msg='Batch '+cast(@i_batchkey as varchar)+@v_new_line
  set @o_msg=@o_msg+'  '+@v_batchdesc+@v_new_line
  set @o_msg=@o_msg+'  '+'templatekey '+CAST(@v_templatekey as varchar)+@v_new_line
  set @o_msg=@o_msg+'  '+'process level '+CAST(@v_processlevel as varchar)+@v_new_line
  select @v_count=max(row_id)
    from imp_batch_detail 
    where batchkey=@i_batchkey
  set @o_msg=@o_msg+'  '+'total titles '+CAST(@v_count as varchar)+@v_new_line
  select @v_count=count(*)
    from imp_feedback 
    where batchkey=@i_batchkey
      and serverity=2
      and rulekey is not null
  set @o_msg=@o_msg+'  '+'total warnings '+CAST(@v_count as varchar)+@v_new_line
  select @v_count=count(*)
    from imp_feedback 
    where batchkey=@i_batchkey
      and serverity=3
      and rulekey is not null
  set @o_msg=@o_msg+'  '+'total errors '+CAST(@v_count as varchar)+@v_new_line
  set @o_msg=@o_msg+@v_new_line
      
  -- distinct warnings and errors
  set @o_msg=@o_msg+'Distinct Errors and Warnings'+@v_new_line
  declare  cur_lines cursor fast_forward for
    select distinct feedbackmsg 
      from imp_feedback
      where batchkey=@i_batchkey
        and serverity>1
        and feedbackmsg not like 'Errors in row%'
        and rulekey is not null
  open cur_lines
  fetch cur_lines into @v_feedbackmsg
  while @@FETCH_STATUS=0
    begin
      set @o_msg=@o_msg+'  '+@v_feedbackmsg+@v_new_line
      fetch cur_lines into @v_feedbackmsg
    end
  close cur_lines
  deallocate cur_lines
  set @o_msg=@o_msg+@v_new_line
     
  --'failure to map' errors
  set @o_msg=@o_msg+'Element mapping issues'+@v_new_line
  declare  cur_lines cursor fast_forward for
    select distinct feedbackmsg 
      from imp_feedback
      where batchkey=@i_batchkey
        and serverity>1
        and feedbackmsg like 'failure to map%'
  open cur_lines
  fetch cur_lines into @v_feedbackmsg
  while @@FETCH_STATUS=0
    begin
      set @o_msg=@o_msg+'  '+@v_feedbackmsg+@v_new_line
      fetch cur_lines into @v_feedbackmsg
    end
  close cur_lines
  deallocate cur_lines
  set @o_msg=@o_msg+@v_new_line

  -- rows not updated
  set @o_msg=@o_msg+'Rows not updated'+@v_new_line
  declare  cur_lines cursor fast_forward for
    select distinct feedbackmsg,row_id 
      from imp_feedback
      where batchkey=@i_batchkey
        and serverity>1
        and feedbackmsg like 'Errors in row%'
      order by row_id
  open cur_lines
  fetch cur_lines into @v_feedbackmsg,@v_row_id
  while @@FETCH_STATUS=0
    begin
      set @o_msg=@o_msg+'  '+@v_feedbackmsg+@v_new_line
      fetch cur_lines into @v_feedbackmsg,@v_row_id
    end
  close cur_lines
  deallocate cur_lines
  
  select @v_loader_count = MAX(row_id) from imp_feedback where batchkey=@i_batchkey and imp_agent=1
  select @v_validation_count = MAX(row_id) from imp_feedback where batchkey=@i_batchkey and imp_agent=2
  select @v_DML_count = MAX(row_id) from imp_feedback where batchkey=@i_batchkey and imp_agent=3
  if @v_validation_count<>@v_DML_count
    begin
      set @o_msg=@o_msg
           +'Batch may have terminated early. Max rows = '
           +coalesce(cast(@v_loader_count as varchar),'na')+'/'
           +coalesce(cast(@v_validation_count as varchar),'na')+'/'
           +coalesce(cast(@v_DML_count as varchar),'na')+@v_new_line
    end
  set @o_msg=@o_msg+@v_new_line

  RETURN @o_msg
END

