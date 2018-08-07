SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_remove_batch
**  Desc: IKE clear batch data from previous run
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_remove_batch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_remove_batch]
GO


CREATE PROCEDURE imp_remove_batch
  @i_batch_number int
AS
  
BEGIN

  delete from imp_batch_master where batchkey=@i_batch_number 
  delete from imp_batch_detail where batchkey=@i_batch_number 
  delete from imp_batch_lobs where batchkey=@i_batch_number 
  exec imp_clear_feedback @i_batch_number ,1
  exec imp_clear_feedback @i_batch_number ,2
  exec imp_clear_feedback @i_batch_number ,3

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON imp_remove_batch TO PUBLIC 
GO

