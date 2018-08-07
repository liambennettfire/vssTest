/******************************************************************************
**  Name: imp_100040020001
**  Desc: IKE ????
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100040020001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100040020001]
GO

CREATE PROCEDURE dbo.imp_100040020001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)

AS

/* place holder - logic in post process */

BEGIN 

  declare @x int 

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100040020001] to PUBLIC 
GO
