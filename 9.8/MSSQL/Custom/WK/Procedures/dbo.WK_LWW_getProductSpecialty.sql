if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductSpecialty') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProductSpecialty
GO

CREATE PROCEDURE dbo.WK_LWW_getProductSpecialty
--@bookkey int
AS
BEGIN

/*
(MULTISET (SELECT p.product_id intproductid,
                               xref.ols_id intspecialtyid,
                               pm.display_sequence intdisplaysequence,
			       pm.type strtype
                          FROM product_market pm,
                               market m,
                               ols_market_xref xref
                         WHERE pm.common_product_id = p.common_product_id
                           AND m.market_id = pm.market_id
                           AND xref.pace_id = m.market_id
                       ) AS specialtylist_spl
             ) AS productspecialty,


Select * FROM WK_ORA.WKDBA.PRODUCT_MARKET
WHERE COMMON_PRODUCT_ID = 64344
ORDER BY COMMON_PRODUCT_ID

Select * FROM WK_ORA.WKDBA.MARKET

Select * FROM dbo.WK_OLS_MARKET_XREF
ORDER BY PACE_ID


[dbo].[BookSubjectCategorySort]

Select * INTO BookSubjectCategorySort_backup
FROM [BookSubjectCategory]

dbo.WK_LWW_getProductSpecialty


*/

CREATE TABLE #Markets (
		[bookkey] [int] NOT NULL,
		[marketid] int NOT NULL,
		intdisplaysequence int
	)

--With MarketId(bookkey, intproductid, marketid, intdisplaysequence)
--With MarketId(bookkey, marketid, intdisplaysequence)
--AS
--(Select Distinct
--bookkey, 
----dbo.WK_getProductId(bookkey), 
--(CASE WHEN EXISTS (select * from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode) THEN (Select TOP 1 g.datacode from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY g.sortorder)
--     ELSE (Select TOP 1 s.datasubcode from subgentables s where s.tableid = 433 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY s.sortorder)
--	 END),
--bsc.sortorder
--FROM booksubjectcategory bsc
--WHERE categorytableid = 433
--and dbo.WK_IsEligibleforLWW(bsc.bookkey) = 'Y' 
--)


Insert into #Markets
Select Distinct
bookkey, 
--dbo.WK_getProductId(bookkey), 
(CASE WHEN EXISTS (select * from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode) THEN (Select TOP 1 g.externalcode from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY g.sortorder)
     ELSE NULL
	 END),
--(CASE WHEN EXISTS (select * from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode) THEN (Select TOP 1 g.datacode from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY g.sortorder)
--     ELSE (Select TOP 1 s.datasubcode from subgentables s where s.tableid = 433 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY s.sortorder)
--	 END),
bsc.sortorder
FROM booksubjectcategory bsc
WHERE categorytableid = 433
and dbo.WK_IsEligibleforLWW(bsc.bookkey) = 'Y' 
and (CASE WHEN EXISTS (select * from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode) THEN (Select TOP 1 g.externalcode from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY g.sortorder)
     ELSE NULL
	 END) IS NOT NULL



Declare @i_bookkey int
DECLARE @i_marketid int
DECLARE @i_cnt int
DECLARE @fetchstatus int


	DECLARE c_dups INSENSITIVE CURSOR
		 FOR
			Select bookkey, marketid, Count(*) FROM #Markets
			GROUP BY bookkey, marketid
			HAVING Count(*) > 1

		  FOR READ ONLY
	
/* Open booksubjectcategory cursor for retrieval of all booksubjectcategory rows for the given bookkey and categorytablid */
/*	 << loop_inner >>*/

		OPEN c_dups


			FETCH NEXT FROM c_dups
				INTO @i_bookkey, @i_marketid, @i_cnt

			select  @fetchstatus  = @@FETCH_STATUS

			 while (@fetchstatus >-1 )
			    begin
					IF (@fetchstatus <>-2)
					   begin
					
						--DELETE THE ENTRY WITH HIGHEST SORTORDER(S)
						WHILE (Select Count(*) FROM #Markets WHERE bookkey = @i_bookkey and marketid = 	@i_marketid) > 1
							BEGIN
								DELETE FROM #Markets
								WHERE bookkey = @i_bookkey and marketid = 	@i_marketid
								and intdisplaysequence = (Select TOP 1 intdisplaysequence from #Markets where bookkey = @i_bookkey and marketid = 	@i_marketid ORDER BY intdisplaysequence DESC)
							END
													 	

					   end 

					FETCH NEXT FROM c_dups
					INTO @i_bookkey, @i_marketid, @i_cnt
		
					select @fetchstatus  = @@FETCH_STATUS
				end 
			
			close c_dups
			deallocate c_dups
		 



Select m.bookkey as intproductid, 
m.marketid as intspecialtyid, 
m.intdisplaysequence,  
'com.lww.pace.domain.subject.PrimaryProductMarket' as strtype
FROM #Markets m
ORDER BY m.bookkey, m.intdisplaysequence

--Select m.bookkey as intproductid, 
--x.OLS_ID as intspecialtyid, 
--m.intdisplaysequence,  
--'com.lww.pace.domain.subject.PrimaryProductMarket' as strtype
--FROM #Markets m
--JOIN dbo.WK_OLS_MARKET_XREF x
--ON m.marketid = x.PACE_ID
--ORDER BY m.bookkey, m.intdisplaysequence

DROP TABLE #Markets

END

