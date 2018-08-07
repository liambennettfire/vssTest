Drop view qweb_www_events_view
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[qweb_www_events_view]
AS
SELECT     w.bookkey, w.authorkey, w.eventkey, b.title, i.isbn, a.firstname, a.lastname, t.EVENTDATE, t.STARTTIME, t.ENDTIME, t.COMPANYNAME, t.ADDRESSLN1, 
                      t.ADDRESSLN2, t.ADDRESSLN3, t.CITY,
                          (SELECT     datadesc
                            FROM          dbo.gentables
                            WHERE      (t.STATECODE = datacode) AND (tableid = 160)) AS state, t.ZIP, CAST(t.EVENTDATE AS varchar) AS edate, CAST(t.STARTTIME AS varchar) AS stime, 
                      CAST(t.ENDTIME AS varchar) AS etime, CAST(w.eventnotes AS varchar(2000)) AS eventnotes, t.DEPTNAME
FROM         dbo.book AS b INNER JOIN
                      dbo.wwwtourevent AS w ON b.bookkey = w.bookkey INNER JOIN
                      dbo.isbn AS i ON w.bookkey = i.bookkey INNER JOIN
                      dbo.author AS a ON w.authorkey = a.authorkey INNER JOIN
                      dbo.tourevents AS t ON w.eventkey = t.EVENTKEY
WHERE     (w.eventkey IN
                          (SELECT     EVENTKEY
                            FROM          dbo.tourevents))
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO