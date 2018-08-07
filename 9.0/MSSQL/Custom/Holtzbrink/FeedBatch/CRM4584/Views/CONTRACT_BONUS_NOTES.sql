if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CONTRACT_BONUS_NOTES]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CONTRACT_BONUS_NOTES]
GO
create  view DBO.CONTRACT_BONUS_NOTES(BOOKKEY, CONTRACTKEY, COMMENTTEXT, COMMENTHTML, COMMENTHTMLLITE) as 
 Select
c.bookkey,
c.contractkey,
(substring(q.commenttext,1, datalength(q.commenttext))) commenttext,
(substring(q.commenthtml, 1, datalength(q.commenthtml))) commenthtml,
(substring(q.commenthtmllite, 1, datalength(q.commenthtmllite))) commenthtmllite
From contractbook c, qsicomments q
where c.CONTRACTKEY = q.commentkey
and q.commenttypecode = 1
and q.commenttypesubcode = 3
go
GRANT SELECT ON CONTRACT_BONUS_NOTES TO public
go