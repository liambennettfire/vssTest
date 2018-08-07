/******************************************************************************
**  Name: imp_300023000001
**  Desc: IKE 
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

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_300023000001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300023000001]
GO

CREATE PROCEDURE dbo.imp_300023000001
	@i_batch INT
	,@i_row INT
	,@i_dmlkey BIGINT
	,@i_titlekeyset VARCHAR(500)
	,@i_contactkeyset VARCHAR(500)
	,@i_templatekey INT
	,@i_elementseq INT
	,@i_level INT
	,@i_userid VARCHAR(50)
	,@i_newtitleind INT
	,@i_newcontactind INT
	,@o_writehistoryind INT OUTPUT
AS
BEGIN

	DECLARE	@v_elementkey INT
	DECLARE	@DEBUG AS INT

	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'dbo.imp_300023000001'
	
	SET		@v_elementkey=100023000
	
	EXECUTE	dbo.imp_300023000001_ext 
				@v_elementkey
				,@i_batch
				,@i_row
				,@i_dmlkey
				,@i_titlekeyset
				,@i_contactkeyset
				,@i_templatekey
				,@i_elementseq
				,@i_level
				,@i_userid
				,@i_newtitleind
				,@i_newcontactind
				,@o_writehistoryind OUTPUT
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300023000001]
	TO PUBLIC
GO