PRINT 'STORED PROCEDURE : dbo.qsrpt_instance_item_cleanup'
GO

SET QUOTED_IDENTIFIER ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.qsrpt_instance_item_cleanup') AND (type = 'P' or type = 'RF'))
BEGIN
 DROP proc dbo.qsrpt_instance_item_cleanup 
END

GO

CREATE  PROC dbo.qsrpt_instance_item_cleanup 
AS 


DECLARE @v_count INT

BEGIN
	SELECT @v_count = count(*)
     FROM qsrpt_instance_item
	 WHERE lastmaintdate <= (getdate() - 2)

	IF @v_count > 0
   BEGIN
		DELETE FROM qsrpt_instance_item
			 WHERE lastmaintdate <= (getdate() - 2)
	END
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.qsrpt_instance_item_cleanup TO PUBLIC
GO