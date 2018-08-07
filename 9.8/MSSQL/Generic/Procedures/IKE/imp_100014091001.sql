/******************************************************************************
**  Name: imp_100014091001
**  Desc: IKE Territory load form space delimited list
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100014092001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100014091001]
GO

CREATE PROCEDURE dbo.imp_100014091001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Territory load form space delimited list */

BEGIN 

DECLARE  @v_errcode 	INT,
	@v_list_seq 	INT,
	@v_list_value 	VARCHAR(max),
	@v_errlevel 	INT,
	@v_msg 		VARCHAR(4000),
	@v_pricetype	VARCHAR(40)

BEGIN
	SET @v_errcode = 0
	SET @v_errlevel = 0
	SET @v_msg = 'Territories from list'

	SELECT @v_list_value = originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batchkey
		    and row_id = @i_row
		    and elementseq = @i_elementseq
		    and elementkey = 100014091

  delete imp_territory where batchkey=@i_batchkey and row_id=@i_row


  IF @v_errlevel >= @i_level 
    BEGIN
      EXECUTE imp_write_feedback @i_batchkey, @i_row, null, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 1
    END

END

end



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100014091001] to PUBLIC 
GO
