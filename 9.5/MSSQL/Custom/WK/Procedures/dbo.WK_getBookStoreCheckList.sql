if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getBookStoreCheckList') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getBookStoreCheckList
GO
CREATE PROCEDURE dbo.WK_getBookStoreCheckList
@bookkey int
/*

Select * FROM bookmisc
WHERE misckey in (14, --isA
15, --isC
17, --isB
19 --other
)

Select * FROM bookmiscitems

Select * FROM bookmiscdefaults

Select (Case WHEN misckey = 14 THEN [dbo].[rpt_get_misc_value](582161, 14, 'long')
	   END) as isAField,
(Case WHEN misckey = 17 THEN [dbo].[rpt_get_misc_value](582161, 17, 'long')
	   END) as isBField,
(Case WHEN misckey = 15 THEN [dbo].[rpt_get_misc_value](582161, 15, 'long')
	   END) as isCField,
(Case WHEN misckey = 19 THEN [dbo].[rpt_get_misc_value](582161, 19, 'long')
	   END) as otherField
FROM bookmisc
where 
misckey in (14, --isA
15, --isC
17, --isB
19 --other
)


EXEC dbo.WK_getBookStoreCheckList 123
582161


*/
AS
BEGIN

DECLARE @isAField smallint
DECLARE @isBField smallint
DECLARE @isCField smallint
DECLARE @otherField varchar(512)

SELECT @isAField = (CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 14, 'long') = 'YES' THEN 1
						WHEN [dbo].[rpt_get_misc_value](@bookkey, 14, 'long') = 'NO' THEN 0
						ELSE NULL END)
SELECT @isBField = (CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 17, 'long') = 'YES' THEN 1
						WHEN [dbo].[rpt_get_misc_value](@bookkey, 17, 'long') = 'NO' THEN 0
						ELSE NULL END)
SELECT @isCField = (CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 15, 'long') = 'YES' THEN 1
						WHEN [dbo].[rpt_get_misc_value](@bookkey, 15, 'long') = 'NO' THEN 0
						ELSE NULL END)

SELECT @otherField = [dbo].[rpt_get_misc_value](@bookkey, 19, 'long')

Select @isAField as [isAField], 
@isBField as [isBField], 
@isCField as [isCField], 
@otherField as [otherField]

END
