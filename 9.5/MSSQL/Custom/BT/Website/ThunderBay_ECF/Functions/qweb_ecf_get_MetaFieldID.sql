USE [BT_TB_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_MetaFieldID]    Script Date: 01/27/2010 16:53:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[qweb_ecf_get_MetaFieldID] 
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








