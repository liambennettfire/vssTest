IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'outbox_preprocess_procedure')
	BEGIN
		PRINT 'Dropping Procedure outbox_preprocess_procedure'
		DROP  Procedure  outbox_preprocess_procedure
	END

GO

PRINT 'Creating Procedure outbox_preprocess_procedure'
GO
CREATE Procedure outbox_preprocess_procedure
( @o_error_code                 int         output
)
AS
	set @o_error_code = 1;
GO

GRANT EXEC ON outbox_preprocess_procedure TO PUBLIC
GO



