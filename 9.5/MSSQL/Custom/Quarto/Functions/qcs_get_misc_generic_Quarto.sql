if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_misc_generic') and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop function dbo.qcs_get_misc_generic
GO


CREATE FUNCTION dbo.qcs_get_misc_generic (@bookkey INT,
@productTag VARCHAR(50))

RETURNS @generic_misc TABLE(
    --[Id] [uniqueidentifier] NOT NULL,
    Tag  VARCHAR(50),
    [Key] VARCHAR(25),
    AlternateKey VARCHAR(25),
	Value VARCHAR(4000) NULL
	)
AS
BEGIN

		  INSERT INTO @generic_misc
		  SELECT 
         -- NEWID() AS Id,
          @productTag + '-' + 'PRDTYPE' AS Tag, 
          'DPIDXBIZPRDTYPE' AS 'Key', 
          'PRDTYPE' AS AlternateKey, 
          g.externalcode AS Value
    FROM
          bookdetail  bd
		  JOIN gentables g
		  ON bd.mediatypecode = g.datacode 
    WHERE bookkey = @bookkey AND g.tableid = 312 AND ISNULL(g.externalcode, '') <> ''
		 
		Insert into @generic_misc
		SElect 
		-- NEWID() AS Id,
          @productTag + '-' + 'GENZPPT' AS Tag, 
          'DPIDXBIZPPT' AS 'Key', 
          'ZPPT' AS AlternateKey, 
		  (case when mediatypecode = 9 then 100 -- PPT is 100% on eBooks 
		        when (Select Coalesce(finalprice, budgetprice) from bookprice where bookkey = @bookkey and pricetypecode = 31 and currencytypecode = 37 and activeind = 1) = (Select Coalesce(finalprice, budgetprice) from bookprice where bookkey = @bookkey and pricetypecode = 8 and currencytypecode = 37 and activeind = 1) THEN 0 -- standard book, 0 % taxable
				else 100 end) AS Value -- if not an ebook and price incl. tax doesn't equal price excl. tax we assume it is 100% taxable. adult colouring books or books+CD or books + something else
    FROM
          bookdetail  bd
		  where bd.bookkey = @bookkey  
		  and exists(Select 1 from bookprice where bookkey = @bookkey and pricetypecode = 31 and currencytypecode = 37 and (ISNULL(budgetprice,0) <> 0 OR ISNULL(finalprice,0) <> 0) and activeind = 1) -- RRP Including Tax price exists for GBP
		  and exists (Select 1 from bookprice where bookkey = @bookkey and pricetypecode = 8 and currencytypecode = 37 and (ISNULL(budgetprice,0) <> 0 OR ISNULL(finalprice,0) <> 0) and activeind = 1) -- MSR excluding Tax price exists for GBP
		     


	 RETURN
END
GO
GRANT SELECT ON dbo.qcs_get_misc_generic TO PUBLIC


