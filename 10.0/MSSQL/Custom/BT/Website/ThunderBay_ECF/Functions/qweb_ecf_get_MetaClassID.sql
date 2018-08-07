USE [BT_TB_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_MetaClassID]    Script Date: 01/27/2010 16:53:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[qweb_ecf_get_MetaClassID] 
			(@v_MetaClassName nvarchar(255))

RETURNS	int

AS

BEGIN

			DECLARE @RETURN			int

			SELECT 	@RETURN = MetaclassID
			FROM MetaClass
			WHERE Name = @v_MetaClassName



RETURN @RETURN


END







