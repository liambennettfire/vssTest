/******************************************************************************
**  Name: imp_200014058001
**  Desc: IKE Check for Valid Territory Description
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200014058001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200014058001]
GO

CREATE PROCEDURE dbo.imp_200014058001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Check for Valid Territory Description */

BEGIN 

/* TERRITORY DESCRIPTION VALIDATION	*/
SET NOCOUNT ON
DECLARE	@v_elementval 		VARCHAR(4000),
	@v_errlevel 		INT,
	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000),
	@v_row_count		INT,
	@v_datacode int,
	@v_datadesc varchar(max),
	@DEBUG INT
BEGIN
	SET @v_errlevel = 0
	SET @v_row_count = 0
	SET @DEBUG=0
	
	IF @DEBUG>0 PRINT '/* TERRITORY DESCRIPTION VALIDATION	*/'
	
	SELECT @v_elementdesc = elementdesc
	FROM imp_element_defs
	WHERE elementkey =  @i_elementkey

	SELECT @v_elementval = COALESCE(originalvalue,'')
	FROM imp_batch_detail 
	WHERE  batchkey = @i_batch
			AND row_id = @i_row
			AND elementkey =  @i_elementkey
			AND elementseq =  @i_elementseq

	

	--mk>20120816: use find_gentables_mixed instead
	--SELECT @v_row_count = COUNT(*)
	--FROM gentables
	--WHERE tableid = 131 AND datadesc = @v_elementval
	
	exec find_gentables_mixed @v_elementval,131,@v_datacode output,@v_datadesc output
	IF @DEBUG>0 PRINT 'exec find_gentables_mixed @v_elementval,131,@v_datacode output,@v_datadesc output'
	IF @DEBUG>0 print '@v_datacode = ' + cast(@v_datacode as varchar(max))
	

	IF @v_datacode = 0 
		BEGIN
			SET @v_errlevel = 2
			SET @v_errmsg = 'Can not find ('+@v_elementval+') value on  User Table(131) for Territories Description .  Territories was not updated'
		END
	ELSE
		BEGIN
			SET @v_errmsg = 'Territories OK'
			SET @v_errlevel = 1
		END
	
	IF @DEBUG>0 PRINT @v_errmsg

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

GRANT EXECUTE ON dbo.[imp_200014058001] to PUBLIC 
GO
