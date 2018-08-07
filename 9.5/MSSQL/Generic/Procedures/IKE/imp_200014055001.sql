/******************************************************************************
**  Name: imp_200014055001
**  Desc: IKE Check for Valid Edition Description
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/19/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200014055001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200014055001]
GO

CREATE PROCEDURE dbo.imp_200014055001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Check for Valid Edition Description */

BEGIN 

/* EDITION DESCRIPTION VALIDATION	*/
SET NOCOUNT ON
DECLARE	@v_elementval 		VARCHAR(4000),
	
	@v_errlevel 		INT,
	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000),
	@v_row_count		INT
BEGIN
	SET @v_errlevel = 0
	SET @v_row_count = 0
	

	SELECT @v_elementdesc = elementdesc
	FROM imp_element_defs
	WHERE elementkey =  @i_elementkey

	SELECT @v_elementval = COALESCE(originalvalue,'')
	FROM imp_batch_detail 
	WHERE  batchkey = @i_batch
			AND row_id = @i_row
			AND elementkey =  @i_elementkey
			AND elementseq =  @i_elementseq

	declare @v_value varchar(40)
	declare @v_tableid int
	declare @o_datacode INT 
	declare @o_datadesc varchar(MAX) 
	declare @search_column varchar(50) 
	
	set @v_value=@v_elementval
	set @v_tableid=200
	
	exec find_gentables_mixed @v_value,@v_tableid,@o_datacode output,@o_datadesc output
	set @v_row_count=0
	IF COALESCE(@o_datacode,0)>1 set @v_row_count=1

	--SELECT @v_row_count = COUNT(*)
	--FROM gentables
	--WHERE tableid = 200
	--		AND datadesc = @v_elementval
	
	IF @v_row_count = 0
		BEGIN
			SET @v_errlevel = 2
			SET @v_errmsg = 'Can not find ('+@v_elementval+') value on  User Table(200) for Edition Description .  Edition was not updated'
		END
	ELSE
		BEGIN
			SET @v_errmsg = 'Edition OK'
			SET @v_errlevel = 1
		END

	IF @v_errlevel >= @i_rpt
		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
		END
	
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200014055001] to PUBLIC 
GO
