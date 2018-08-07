/* CRM 2212 PM Added CAN Restrictions */
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[relatedtitles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[relatedtitles_view]
GO


CREATE VIEW relatedtitles_view AS 

select b.workkey as bookkey,b.bookkey as childbookkey,t.isbn,t.isbn10,t.title,t.format,t.seasonyearbest,
      c.edition,t.uspricebest, t.canadianpricebest,c.bisacstatus,d.bestdate1, t.canadian_restriction_long,
      t.canadian_restriction_short
from book b, whtitleinfo t, whtitleclass c, whtitledates d
where b.linklevelcode = 20
      and b.bookkey = t.bookkey
      and b.bookkey = c.bookkey
      and b.bookkey = d.bookkey
UNION
select b.bookkey as bookkey,b.workkey as childbookkey,t.isbn,t.isbn10,t.title,t.format,t.seasonyearbest,
      c.edition,t.uspricebest, t.canadianpricebest,c.bisacstatus,d.bestdate1, t.canadian_restriction_long,
      t.canadian_restriction_short
from book b, whtitleinfo t, whtitleclass c, whtitledates d
where b.linklevelcode = 20
      and b.workkey = t.bookkey
      and b.workkey= c.bookkey
      and b.workkey = d.bookkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


