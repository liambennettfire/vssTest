/******************************************************************************
**  Name: imp_200021000001
**  Desc: IKE Custom Code Validation
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200021000001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200021000001]
GO

CREATE PROCEDURE dbo.imp_200021000001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Custom Code Validation */

BEGIN 

DECLARE	@v_elementval 		VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000),
	@v_errlevel 		INT,
	@v_errmsg 		VARCHAR(4000),
	@v_row_count		INT,
	@v_tableid		INT,
	@v_columnname		VARCHAR(100),
	@v_templatekey		INT
BEGIN
	SET @v_errlevel = 1
	SET @v_row_count = 0
	SET @v_columnname = ''

	SELECT @v_elementval = COALESCE(originalvalue,'')
	FROM imp_batch_detail 
	WHERE  batchkey = @i_batch
			AND row_id = @i_row
			AND elementkey =  @i_elementkey
			AND elementseq =  @i_elementseq

	SELECT @v_tableid = tableid
	FROM imp_element_defs
	WHERE elementkey = @i_elementkey

	SELECT @v_templatekey = templatekey
	FROM imp_batch_master
	WHERE batchkey = @i_batch

	SELECT @v_columnname = columnname
	FROM imp_template_detail
	WHERE templatekey = @v_templatekey
			AND elementkey = @i_elementkey

	IF COALESCE(@v_columnname,'')<>''
		SET @v_elementdesc = @v_columnname
	ELSE
		SELECT @v_elementdesc = elementdesc,
				@v_tableid = tableid
		FROM imp_element_defs
		WHERE elementkey = @i_elementkey

 

	SELECT @v_row_count = COUNT(*)
	FROM gentables
	WHERE tableid = @v_tableid AND datadesc = @v_elementval


	IF @v_row_count < 1
		BEGIN
			SET @v_errlevel = 3
			SET @v_errmsg = 'Can not find ('+@v_elementval+') value on  User Table('+CONVERT(CHAR(3),@v_tableid)+') for '+@v_elementdesc
		END
	ELSE
		BEGIN
			
			SET @v_errlevel = 1
			SET @v_errmsg = COALESCE(@v_elementdesc,'')+' OK'
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

GRANT EXECUTE ON dbo.[imp_200021000001] to PUBLIC 
GO
