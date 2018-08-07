if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_get_MetaClassID') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qweb_ecf_get_MetaClassID
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE FUNCTION [dbo].qweb_ecf_get_MetaClassID 
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






