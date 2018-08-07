if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductMarket') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getProductMarket
GO
CREATE PROCEDURE dbo.WK_getProductMarket
@bookkey int
AS
/*
Multiple New Markets could be mapped to only one old Pace market
We will end up with multiple markets in this case

select * from subgentables s join gentables 
g on s.externalcode = g.datadescshort 
where s.tableid = 433 and g.tableid = 414 
and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode

Select Distinct s.externalcode FROM booksubjectcategory bsc
JOIN subgentables s
ON s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode
JOIN gentables g
ON s.externalcode = g.datadescshort
WHERE s.tableid = 433 and g.tableid = 414
and bookkey = 909147
GO
dbo.WK_getProductMarketTest 924905
GO

dbo.WK_getProductMarket 913955


Select bookkey, count(*) FROM booksubjectcategory
WHERE categorytableid = 433
GROUP BY bookkey
ORDER BY Count(*) DESC


*/
BEGIN

CREATE TABLE #Markets (
		[idField] [int] NOT NULL,
		[codeField] varchar(20),
		[paceMarketIdField] int NOT NULL,
		[nameField] varchar(255),
		[sequenceField] int NOT NULL
	)
INSERT #Markets
Select
Cast(@bookkey as varchar(20)) + Cast(sortorder as varchar(3)) as [idField],
dbo.rpt_get_subgentables_field(433, bsc.categorycode, bsc.categorysubcode, 'E') as codeField,
(CASE WHEN EXISTS (select * from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode) THEN (Select TOP 1 g.externalcode from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY g.sortorder)
     ELSE NULL
	 END) as paceMarketIdField,
dbo.rpt_get_subgentables_field(433, bsc.categorycode, bsc.categorysubcode, '1') as nameField,
bsc.sortorder as sequenceField
--,'com.lww.pace.domain.subject.PrimaryProductMarket' as typeField
FROM booksubjectcategory bsc
WHERE bsc.categorytableid = 433
and bsc.bookkey = @bookkey
and bsc.categorycode IS NOT NULL AND bsc.categorysubcode IS NOT NULL
and (CASE WHEN EXISTS (select * from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode) THEN (Select TOP 1 g.externalcode from subgentables s join gentables g on s.externalcode = g.datadescshort where s.tableid = 433 and g.tableid = 414 and s.datacode = bsc.categorycode and s.datasubcode = bsc.categorysubcode ORDER BY g.sortorder)
     ELSE NULL
	 END) IS NOT NULL
ORDER BY bsc.sortorder


Declare @v_codefield varchar(20)
DECLARE @i_paceMarketIdField int
DECLARE @i_cnt int
DECLARE @fetchstatus int


	DECLARE c_dups INSENSITIVE CURSOR
		 FOR
			Select codeField, paceMarketIdField, Count(*) FROM #Markets
			GROUP BY codeField, paceMarketIdField
			HAVING Count(*) > 1

		  FOR READ ONLY
	
/* Open booksubjectcategory cursor for retrieval of all booksubjectcategory rows for the given bookkey and categorytablid */
/*	 << loop_inner >>*/

		OPEN c_dups


			FETCH NEXT FROM c_dups
				INTO @v_codefield, @i_paceMarketIdField, @i_cnt

			select  @fetchstatus  = @@FETCH_STATUS

			 while (@fetchstatus >-1 )
			    begin
					IF (@fetchstatus <>-2)
					   begin
					
						--DELETE THE ENTRY WITH HIGHEST SORTORDER(S)
						WHILE (Select Count(*) FROM #Markets WHERE codeField = @v_codefield and paceMarketIdField = @i_paceMarketIdField) > 1
							BEGIN
								DELETE FROM #Markets
								WHERE codeField = @v_codefield and paceMarketIdField = 	@i_paceMarketIdField
								and sequenceField = (Select TOP 1 [sequenceField] from #Markets where codeField = @v_codefield and paceMarketIdField = @i_paceMarketIdField ORDER BY sequenceField DESC)
							END
													 	

					   end 

					FETCH NEXT FROM c_dups
					INTO @v_codefield, @i_paceMarketIdField, @i_cnt
		
					select @fetchstatus  = @@FETCH_STATUS
				end 
			
			close c_dups
			deallocate c_dups 

END

Select *, 
'com.lww.pace.domain.subject.PrimaryProductMarket' as typeField
FROM #Markets m
ORDER BY sequenceField

DROP TABLE #Markets