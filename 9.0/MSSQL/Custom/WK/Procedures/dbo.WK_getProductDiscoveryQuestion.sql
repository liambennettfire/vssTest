if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductDiscoveryQuestion') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductDiscoveryQuestion
GO
CREATE PROCEDURE dbo.WK_getProductDiscoveryQuestion
@bookkey int
AS
BEGIN
/*

answerField	CSIString
idField	CSIString
questionField	CSIString
sequenceField	CSIShort


Select * FROM DiscoveryQuestions
Join qsicomments

Select * FROM titlehistory
ORDER BY lastmaintdate DESC

Select 
discoverykey as [idField],
(Select commenttext from qsicomments where commentkey = dq.questioncommentkey and commenttypecode = 9 and commenttypesubcode = 1)
as questionField,
(Select commenttext from qsicomments where commentkey = dq.answercommentkey and commenttypecode = 9 and commenttypesubcode = 2)
as answerField,
sortorder as sequenceField
FROM DiscoveryQuestions dq
WHERE dq.bookkey = @bookkey
ORDER BY sortorder


SElect * FROM qsicomments
WHERE commenttext like '%Question%'
OR commenttext like '%Answer%'

Select * FROM book
where title like 'DELETE Biophysical%'


Select * FROM DiscoveryQuestions
WHERE bookkey = 923044

dbo.WK_getProductDiscoveryQuestion 923044

*/
Select 
discoverykey as [idField],
(Select commenttext from qsicomments where commentkey = dq.questioncommentkey and commenttypecode = 5 and commenttypesubcode = 1)
as questionField,
(Select commenttext from qsicomments where commentkey = dq.answercommentkey and commenttypecode = 5 and commenttypesubcode = 2)
as answerField,
sortorder as sequenceField
FROM DiscoveryQuestions dq
WHERE dq.bookkey = @bookkey
ORDER BY sortorder


END
