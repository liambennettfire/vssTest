IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[remove_locked_titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[remove_locked_titles]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[remove_locked_titles]
AS

DECLARE @v_count		INT


SELECT @v_count = count(*)
   FROM booklock

IF @v_count > 0 BEGIN
    DELETE FROM booklock
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

