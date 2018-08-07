if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_MetaFieldID]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_ecf_get_MetaFieldID]
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE FUNCTION [dbo].[qweb_ecf_get_MetaFieldID] 
			(@v_MetaFieldName nvarchar(255))

RETURNS	int

AS

BEGIN

			DECLARE @RETURN			int

			SELECT 	@RETURN = MetaFieldID
			FROM MetaField
			WHERE Name = @v_MetaFieldName


RETURN @RETURN


END







