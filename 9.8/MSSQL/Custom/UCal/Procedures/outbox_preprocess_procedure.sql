GO
/****** Object:  StoredProcedure [dbo].[outbox_preprocess_procedure]    Script Date: 08/08/2014 16:27:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[outbox_preprocess_procedure]
( @o_error_code                 int         output
)
AS

exec UCAL_SalesRight_OutboxPreProcess

exec dbo.UCAL_Elo_verify_onix_rules_outbox_titles

	set @o_error_code = 1;
