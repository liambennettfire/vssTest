SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_write_feedback 
**  Desc: IKE write feedback message to table
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_write_feedback]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_write_feedback]
GO


CREATE PROCEDURE imp_write_feedback (
  @i_batchkey int,
  @i_row_id int,
  @i_elementkey bigint,
  @i_elementseq int,
  @i_rulekey bigint,
  @i_feedbackmsg varchar(500),
  @i_errlevel int,
  @i_imp_agent int
  ) AS

  -- this procedure add a row to imp_feedback 

begin

  insert into imp_feedback
    (batchkey,row_id,elementkey,elementseq,rulekey,feedbackmsg,serverity ,imp_agent)
    values
    (@i_batchkey,@i_row_id,@i_elementkey,@i_elementseq,@i_rulekey,@i_feedbackmsg,@i_errlevel,@i_imp_agent)

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GRANT EXECUTE ON imp_write_feedback to PUBLIC 
GO


