if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AUTHOR_NOTES_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[AUTHOR_NOTES_VIEW]
GO

create view DBO.AUTHOR_NOTES_VIEW(AUTHORKEY, COMMENTTYPECODE, COMMENTTYPESUBCODE, COMMENTHTMLLITE, LASTMAINTDATE, COMMENTHTTEXT, RELEASETOELOQUENCEIND) as 
 Select
ba.authorkey,
q.commenttypecode,
q.commenttypesubcode,
(substring(q.commenthtmllite, 1, datalength(q.commenthtmllite))) commenthtmllite,
q.lastmaintdate,
(substring(q.commenttext, 1, datalength(q.commenttext))) commenthttext,
q.releasetoeloquenceind
From author ba, qsicomments q
where ba.authorkey = q.commentkey


go
GRANT SELECT ON AUTHOR_NOTES_VIEW TO public
go
