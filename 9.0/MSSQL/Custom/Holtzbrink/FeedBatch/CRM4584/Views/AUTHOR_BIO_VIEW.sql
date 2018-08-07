if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AUTHOR_BIO_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[AUTHOR_BIO_VIEW]
GO

create view dbo.AUTHOR_BIO_VIEW(AUTHORKEY, COMMENTTYPECODE, COMMENTTYPESUBCODE, COMMENTHTMLLITE, LASTMAINTDATE, COMMENTHTTEXT, RELEASETOELOQUENCEIND) as 
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
and commenttypecode = 2

go
GRANT SELECT ON AUTHOR_BIO_VIEW TO public
go