/******************************************************************************
**  Name: imp_200010019002
**  Desc: IKE Related Product Code validation
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010019002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010019002]
GO

CREATE PROCEDURE dbo.imp_200010019002 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS


BEGIN 

DECLARE 
	@v_errcode			INT
	,@v_errlevel		INT
	,@v_errmsg			VARCHAR(4000)
	,@v_count			INT
  	,@v_RelationCode	varchar(50)
  	,@v_elementdesc 	VARCHAR(4000)
	,@Debug				INT

	SET @Debug = 0
	
	if @Debug<>0 print 'processing imp_200010019002'

	/**************************************************************
	01) get the datacode/datasubcode for @v_RelationCode (tableID=440)
	**************************************************************/

	SELECT 
		@v_elementdesc = elementdesc
	FROM 
		imp_element_defs
	WHERE 
		elementkey =  @i_elementkey
	
	SELECT 
		@v_RelationCode=LTRIM(RTRIM(originalvalue))
	FROM 
		imp_batch_detail b
	WHERE 
		b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = 100010017
	
	IF @v_RelationCode is null
		BEGIN
			SET @v_errlevel = 3
			SET @v_errmsg = 'Related Product Code (100010017) could not be found in the xmal for this sequence'
			EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
			RETURN
		END
		
	ELSE
		BEGIN
			SELECT 
				@v_count=count(*)
			FROM 
				subgentables 
			WHERE 
				tableid=440
				and eloquencefieldtag = @v_RelationCode
				and deletestatus = 'N'
			IF @v_count<>1 
				BEGIN
					SET @v_errlevel = 3
					SET @v_errmsg = 'Can not find ('+ @v_RelationCode +') value on  User Table(428) for '+@v_elementdesc
					EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
					RETURN
				END
		END
		
		SET @v_errlevel = 1
		SET @v_errmsg = 'Related Product Code (100010017) is valid'
		EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
		
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200010019002] to PUBLIC 
GO
