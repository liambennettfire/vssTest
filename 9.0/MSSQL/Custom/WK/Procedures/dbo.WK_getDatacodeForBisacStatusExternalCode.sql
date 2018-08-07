if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getDatacodeForBisacStatusExternalCode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getDatacodeForBisacStatusExternalCode
GO

CREATE PROCEDURE dbo.WK_getDatacodeForBisacStatusExternalCode
@externalCode varchar(512),
@tableid varchar(512)
AS

BEGIN

select datacode from gentables where tableid = @tableid and externalcode = @externalCode

END
