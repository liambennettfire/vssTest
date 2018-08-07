
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_set_qsijob_qtys]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_set_qsijob_qtys]
GO

CREATE PROCEDURE [dbo].[qcs_set_qsijob_qtys] 
	@uploadjobkey int = 0,
	@qtyprocessed int = -1,
	@qtycompleted int = -1
AS
BEGIN

IF @uploadjobkey != 0
BEGIN
	
	IF @qtyprocessed != -1
	UPDATE qsijob set qtyprocessed = @qtyprocessed where qsijobkey = @uploadjobkey 
	
	IF @qtycompleted != -1
	UPDATE qsijob set qtycompleted = @qtycompleted where qsijobkey = @uploadjobkey 
	

END


END
GO

GRANT EXEC ON [qcs_set_qsijob_qtys] TO PUBLIC
GO


