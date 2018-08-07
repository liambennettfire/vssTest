IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_bookkeys_from_listkey]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_bookkeys_from_listkey]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dustin Miller
-- Create date: July 1, 2013
-- Description:	
-- =============================================
CREATE PROCEDURE [qcs_get_bookkeys_from_listkey] 
	@i_listkey int,
	@i_orderpropagatefirst tinyint,
	@o_error_code integer output,
  @o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error  INT

SET @o_error_code = 0
SET @o_error_desc = ''

IF COALESCE(@i_orderpropagatefirst, 0) = 0
BEGIN
	SELECT *
	FROM qcs_get_booklist(@i_listkey, null, null, 0)

	SELECT @v_error = @@ERROR
	IF @v_error <> 0 BEGIN
		SET @o_error_code = 1
	  SET @o_error_desc = 'Error retrieving bookkeys from listkey: ' + CAST(@i_listkey as varchar)
	END
END
ELSE BEGIN
	SELECT bl.*
	FROM qcs_get_booklist(@i_listkey, null, null, 0) bl
	JOIN book b
	ON (bl.bookkey = b.bookkey)
	ORDER BY b.propagatefrombookkey DESC

	SELECT @v_error = @@ERROR
	IF @v_error <> 0 BEGIN
		SET @o_error_code = 1
	  SET @o_error_desc = 'Error retrieving bookkeys from listkey: ' + CAST(@i_listkey as varchar)
	END
END

END

GO

GRANT EXEC ON qcs_get_bookkeys_from_listkey TO PUBLIC
GO