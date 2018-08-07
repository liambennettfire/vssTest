
IF OBJECT_ID('dbo.UpdFld_XVQ_Transform_Date8_Reverse') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Transform_Date8_Reverse
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_Transform_Date8_Reverse  -- date in (non-SQL-standard) MMDDYYYY format
@pre1_post2     int,   -- pre-process = 1, post-process = 2
@datetypecode   int,
@o_data_buffer  varchar(100) output,
@o_length       int output,
@bookkey        int
AS
BEGIN
	-- Convert value in fld_buffer from non-standard MMDDYYYY to YYYYMMDD format,
	-- so can test/update with standard SQL function

	if @pre1_post2 = 1   -- just do once before validation
		set @o_data_buffer = substring(@o_data_buffer, 1+4, 4) + substring(@o_data_buffer, 1, 4)
END
GO
