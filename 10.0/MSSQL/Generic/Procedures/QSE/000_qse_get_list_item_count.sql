IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qse_get_list_item_count]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qse_get_list_item_count]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dustin Miller
-- Create date: July 26, 2013
-- Description:	Gets the count of distinct items (such as titles) for a listkey
-- =============================================
CREATE PROCEDURE [qse_get_list_item_count] 
	@i_listkey int,
	@o_error_code integer output,
  @o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error  INT

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT COUNT(DISTINCT key1) as itemcount
FROM qse_searchresults
WHERE listkey = @i_listkey

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
	SET @o_error_code = 1
  SET @o_error_desc = 'Error retrieving item count information from qse_searchresults w/ listkey: ' + CAST(@i_listkey as varchar)
END

END

GO

GRANT EXEC ON qse_get_list_item_count TO PUBLIC
GO