/******************************************************************************
**  Name: imp_clear_feedback
**  Desc: IKE this procedure deletes row in imp_feedback by batch and agenttype
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_clear_feedback]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_clear_feedback]
GO


CREATE PROCEDURE imp_clear_feedback (
  @i_batchkey int,
  @i_imp_agent int
  ) AS

  -- this procedure deletes row in imp_feedback by batch and agenttype 

begin

  delete from imp_feedback
    where batchkey=@i_batchkey
      and imp_agent=@i_imp_agent

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_clear_feedback  TO PUBLIC 
GO

