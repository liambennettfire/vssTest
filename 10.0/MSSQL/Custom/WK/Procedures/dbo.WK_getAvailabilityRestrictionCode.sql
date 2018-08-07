if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getAvailabilityRestrictionCode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getAvailabilityRestrictionCode
GO

CREATE PROCEDURE dbo.WK_getAvailabilityRestrictionCode
@bookkey int

AS
BEGIN

Select territoriescode as availabilityRestrictionCode
FROM book 
WHERE bookkey = @bookkey

END





