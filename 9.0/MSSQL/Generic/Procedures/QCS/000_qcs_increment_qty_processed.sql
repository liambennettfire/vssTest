
/****** Object:  StoredProcedure [dbo].[qcs_increment_qty_processed]    Script Date: 06/04/2013 13:59:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_increment_qty_processed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_increment_qty_processed]
GO

CREATE PROCEDURE [dbo].[qcs_increment_qty_processed] 
	@uploadjobkey int = 0,
	@sendjobkey int = 0
AS
BEGIN

DECLARE @qtyprocessed int

IF @uploadjobkey != 0
BEGIN
	SELECT @qtyprocessed = ISNULL(qtyprocessed, 0) from qsijob where qsijobkey = @uploadjobkey
	SET @qtyprocessed = @qtyprocessed + 1;
		UPDATE qsijob set qtyprocessed = @qtyprocessed where qsijobkey = @uploadjobkey 
	IF @sendjobkey != 0
	BEGIN
		UPDATE qsijob set qtyprocessed = @qtyprocessed where qsijobkey = @sendjobkey
	END

END


END
GO

GRANT EXEC ON [qcs_increment_qty_processed] TO PUBLIC
GO


