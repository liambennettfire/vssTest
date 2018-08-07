/******************************************************************************
**  Name: imp_100012016001
**  Desc: IKE Generate Pub Month & Year from Pub Date
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012016001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012016001]
GO

CREATE PROCEDURE dbo.imp_100012016001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Generate Pub Month & Year from Pub Date */

BEGIN 

DECLARE @v_elementval    	VARCHAR(4000),
	@v_elementdesc		VARCHAR(4000),
	@v_elementkey 		BIGINT,
	@v_errcode 		INT,
	@v_errmsg 		VARCHAR(4000),
	@v_pubyear 		INT,
	@v_pubmonthcode 	INT,
	@v_pubdate_act		VARCHAR(4000),
	@v_pubdate_est		VARCHAR(4000),
	@v_pubdate		DATETIME,
    @v_pubmonth     varchar(50),
    @v_new_seq    int,
    @v_errlevel   int,
    @v_msg    varchar(500),
    @v_effdate  datetime

BEGIN

  	SET @v_errcode = 1
	SET @v_errmsg = 'Generated Pub Month and Pub Year from Pub Date'
	SET @v_pubdate_act = NULL
	SET @v_pubdate_est = NULL
	SET @v_pubmonth = 0

	SET @v_pubmonthcode = 0

	SELECT @v_pubdate_act = originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batchkey
		    and row_id = @i_row
		    and elementseq = @i_elementseq
		    and elementkey = 100020005

	SELECT @v_pubdate_est = originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batchkey
		    and row_id = @i_row
		    and elementseq = @i_elementseq
		    and elementkey = 100020006


	IF @v_pubdate_act IS NOT NULL
		BEGIN
			SET @v_pubdate = dbo.resolve_date (@v_pubdate_act)
			SET @v_elementkey = 100020005
		END
	ELSE
		BEGIN
			SET @v_pubdate = dbo.resolve_date (@v_pubdate_est)
			SET @v_elementkey = 100020006
		END



	SET @v_pubmonthcode = DATEPART(month,@v_pubdate)
	SET @v_pubyear = DATEPART(year,@v_pubdate)
  

	INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	VALUES (@i_batchkey,@i_row,100012017,@v_new_seq,'U.S. Dollars','loader_rule_100012016001',getdate())

	INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	VALUES (@i_batchkey,@i_row,100012018,@v_new_seq,@v_effdate,'loader_rule_100012016001',getdate())


	IF @v_errlevel >= @i_level 
		BEGIN
			EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 1
		END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012016001] to PUBLIC 
GO
