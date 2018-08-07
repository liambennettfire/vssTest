/******************************************************************************
**  Name: imp_100013009001
**  Desc: IKE  US Retail Final break out
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100013009001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100013009001]
GO

CREATE PROCEDURE dbo.imp_100013009001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* US Retail Final break out */

BEGIN 

DECLARE  @v_errcode 	INT,
	@v_new_seq 	INT,
	@v_new_value 	VARCHAR(4000),
	@v_effdate	VARCHAR(4000),	
	@v_errlevel 	INT,
	@v_msg 		VARCHAR(4000),
	@v_pricetype	VARCHAR(40)

BEGIN
	SET @v_errcode = 0
	SET @v_errlevel = 0
	SET @v_msg = 'US Price Final expanded'

	SELECT @v_new_value = originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batchkey
		    and row_id = @i_row
		    and elementseq = @i_elementseq
		    and elementkey = 100013009

	SELECT @v_effdate = originalvalue
	FROM imp_batch_detail
	WHERE batchkey = @i_batchkey
		    and row_id = @i_row
		    and elementseq = @i_elementseq
		    and elementkey = 100013011


	SELECT @v_new_seq = COALESCE(MAX(elementseq),0)+1
	FROM imp_batch_detail
	WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100013023


	SELECT @v_pricetype = datacode
	FROM imp_element_defs
	WHERE elementkey = 100013009

	SELECT @v_pricetype = g.datadesc
	FROM imp_element_defs e, gentables g
	WHERE g.tableid = 306 and e.datacode = g.datacode and e.elementkey = 100013009	


	INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
    	VALUES (@i_batchkey,@i_row,100013023,@v_new_seq,@v_new_value ,'loader_rule_100013009001',getdate())

	INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
    	VALUES (@i_batchkey,@i_row,100013024,@v_new_seq,@v_pricetype ,'loader_rule_100013009001',getdate())

	INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	VALUES (@i_batchkey,@i_row,100013026,@v_new_seq,'U.S. Dollars','loader_rule_100013009001',getdate())

	INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	VALUES (@i_batchkey,@i_row,100013028,@v_new_seq,@v_effdate,'loader_rule_100013009001',getdate())


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

GRANT EXECUTE ON dbo.[imp_100013009001] to PUBLIC 
GO
