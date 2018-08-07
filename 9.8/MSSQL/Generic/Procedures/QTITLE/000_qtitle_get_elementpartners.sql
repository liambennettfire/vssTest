if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[qtitle_get_elementpartners]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.[qtitle_get_elementpartners]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

--Created By: Dustin Miller
--Last Edited: 2/8/2016
CREATE PROCEDURE [dbo].[qtitle_get_elementpartners]
(@i_bookkey			integer,
 @o_error_code		integer output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT *
	FROM [taqprojectelementpartner]
	WHERE bookkey = @i_bookkey
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve taqprojectelementpartner data from [qtitle_get_elementpartners].'
		RETURN
	END
	
GO

GRANT EXEC ON [qtitle_get_elementpartners] TO PUBLIC
GO

