/* 
delete rows from taqversionspeccategory that have itemcategorycode = 0
these rows are not needed and were inserted from a trigger on bookdetail 
case 47015
*/

Delete from taqversionspecitems
FROM taqversionspecitems i 
JOIN taqversionspeccategory c
on i.taqversionspecategorykey = c.taqversionspecategorykey
where itemcategorycode = 0

GO

Delete from taqversionspeccategory
where itemcategorycode = 0
GO