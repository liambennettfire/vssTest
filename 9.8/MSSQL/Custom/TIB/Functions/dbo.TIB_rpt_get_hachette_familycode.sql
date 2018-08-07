if exists (select * from dbo.sysobjects where id = object_id(N'dbo.TIB_rpt_get_hachette_familycode') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.TIB_rpt_get_hachette_familycode 
GO
CREATE FUNCTION dbo.TIB_rpt_get_hachette_familycode
    ( @bookkey as int
    ) 
    
RETURNS varchar(20)

/*
Author: Tolga Tuncer

Description: This function will return COO from orgentry
@orglevelkey: pass the orglevelkey that stores the customid information
@customid_num: will ignore subcodes for now. Pass 1 thru 5 

Date: 10/05/2016



Here's Hachette's family code structure:
Company- First two characters
Reporting Group - position 3 & 4 -- category tableid 413
Publisher - position 5-6 -- category tableid 412 gentables
Imprint - position 7&8 -- category tableid 412 subgentables
Format - position 9 & 10 -- category tableid 414 gentables 

I think the company code is TH:

SELECT Distinct Substring(familycode, 1, 2) FROM TIB_hachette_feed_in thfi

Select Distinct familycode from TIB_hachette_feed_in

And then they have 2 reporting groups:
56: OXMOOR HOUSE
66: LIBERTY STREET


-- 197 titles have more than 1 reporting group
Select bookkey, categorytableid, COUNT(*) FROM booksubjectcategory 
where categorytableid = 413 and categorycode is not null 
GROUP BY bookkey, categorytableid
HAVING COUNT(*) > 1

Select * FROM booksubjectcategory where bookkey = 2574000 and categorytableid = 413

-- Only 4344 titles have a reporting group. 
Select Distinct bookkey FROM booksubjectcategory 
where categorytableid = 413 and categorycode is not null 

Select * FROM gentables where tableid = 412

Select * FROM subgentables where tableid = 412


SElect g.externalcode, sg.externalcode, COUNT(*)
FROM gentables g 
JOIN subgentables sg
on g.tableid = sg.tableid and g.datacode = sg.datacode
where g.tableid = 412
and g.datacode = 4
GROUP BY g.externalcode, sg.externalcode
HAVING COUNT(*) > 1





*/


BEGIN 
		DECLARE @RETURN varchar(10)
		SET @RETURN = ''

		DECLARE @orgentrykey int

		Select @Return = Case when  @customid = 1 THEN o.customid1
							  when  @customid = 2 THEN o.customid2
							  when  @customid = 3 THEN o.customid3
							  when  @customid = 4 THEN o.customid4
							  when  @customid = 5 THEN o.customid5
							  else  'Invalid customid number' end
		FROM bookorgentry bo
		JOIN orgentry o 
		on bo.orgentrykey = o.orgentrykey 
		where bo.bookkey = @bookkey and bo.orglevelkey = @orglevelkey
		

   
RETURN @RETURN

END
GO
GRANT EXECUTE ON dbo.TIB_rpt_get_hachette_familycode TO PUBLIC