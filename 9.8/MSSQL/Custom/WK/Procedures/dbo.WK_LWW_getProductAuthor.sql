if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductAuthor') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProductAuthor
GO

CREATE PROCEDURE dbo.WK_LWW_getProductAuthor
--@bookkey int
AS
BEGIN

/*

(MULTISET (SELECT p.product_id intproductid,
                               pa.product_actor_id intauthorid,
                               DECODE (has_role (pa.ROLE),
                                       1, SUBSTR (pa.ROLE, 1, 224),
                                       0, ' '
                                      ) strauthortype,
                               pa.display_sequence intauthorrank
                          FROM product_actor pa
                         WHERE pa.common_product_id = p.common_product_id
                       ) AS productauthorlist
             ) 

Select * FROM bookauthor

dbo.WK_LWW_getProductAuthor 567571

*/

Select
--(CASE WHEN [dbo].[rpt_get_misc_value](bookkey, 1, 'long') IS NULL 
--OR [dbo].[rpt_get_misc_value](bookkey, 1, 'long') = '' THEN bookkey
--ELSE [dbo].[rpt_get_misc_value](bookkey, 1, 'long') END) as intproductid, 
--dbo.WK_getProductId(bookkey) as intproductid,
bookkey as intproductid,
--Create a function, pass authorkey it should return PACE actor id if exists if not the globalcontactkey
authorkey as intauthorid, --
[dbo].[rpt_get_gentables_field](134, authortypecode, 'D') as strauthortype,
sortorder as intauthorrank
FROM bookauthor
where --bookkey = @bookkey
dbo.WK_IsEligibleforLWW(bookkey) = 'Y'
ORDER BY bookkey, sortorder


END

