IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_partnerlist]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_partnerlist]
GO

CREATE FUNCTION [dbo].[qcs_get_partnerlist](@listkey int = NULL, @userkey int = NULL, @bookkey int = NULL, @allworksfortitle tinyint = 0)
RETURNS @partners TABLE (
  [CustomerKey] int,
	[Key] int, 
	[Name] varchar(255), 
	Tag varchar(25), 
	DistributionTypeCode int, 
	DistributionTypeTag varchar(25))
AS
BEGIN
	INSERT INTO @partners
	SELECT DISTINCT
	  cp.customerkey as [CustomerKey],
		gc.globalcontactkey AS [Key],
		gc.groupname AS [Name],
		CAST(gc.partnerkey AS varchar(25)) AS Tag,
		dt.datacode AS DistributionTypeCode,
		dt.eloquencefieldtag AS DistributionTypeTag
	FROM
		dbo.qcs_get_booklist(@listkey, @userkey, @bookkey, @allworksfortitle) AS b,
		customerpartner AS cp,
		globalcontact AS gc,
		globalcontactcategory AS gcc,
		gentables AS dt,
		gentables AS pt
	WHERE
		b.customerkey = cp.customerkey AND
		cp.partnercontactkey = gc.globalcontactkey AND
		gc.globalcontactkey = gcc.globalcontactkey AND
		gc.activeind = 1 AND
		gcc.tableid = 619 AND --DistributionType Category
		dt.datacode = gcc.contactcategorycode AND
		dt.tableid = 619 AND --DistributionType
		pt.datacode = gc.grouptypecode AND
		pt.tableid = 520 AND --PartnerType
		pt.qsicode = 1 --Trading Partner
		
	RETURN
END
GO

GRANT select ON dbo.qcs_get_partnerlist TO PUBLIC
GO