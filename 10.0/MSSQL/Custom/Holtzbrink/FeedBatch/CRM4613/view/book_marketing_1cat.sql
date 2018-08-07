set quoted_identifier off 
go
set ansi_nulls on 
go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[book_marketing_1cat]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[book_marketing_1cat]
GO


create view dbo.book_marketing_1cat(bookkey, subjectkey, sortorder, categorydescription, categorycode, categoryexternalcode, subcatdescription, subcatcode, subcatexternalcode, lastuserid, lastmaintdate, subshortdesc)  as 

  select top 100 percent 
      bs.bookkey as bookkey, 
      bs.subjectkey as subjectkey, 
      bs.sortorder as sortorder, 
      g.datadesc as categorydescription, 
      bs.categorycode as categorycode, 
      g.externalcode as categoryexternalcode, 
      sg.datadesc as subcatdescription, 
      bs.categorysubcode as subcatcode, 
      sg.externalcode as subcatexternalcode, 
      bs.lastuserid as lastuserid, 
      bs.lastmaintdate as lastmaintdate, 
      sg.datadescshort as subshortdesc
    from dbo.booksubjectcategory bs, dbo.gentables g, dbo.subgentables sg
    where ((bs.categorytableid = 437) and 
            (bs.categorytableid = g.tableid) and 
            (bs.categorycode = g.datacode) and 
            (bs.categorytableid = sg.tableid) and 
            (bs.categorycode = sg.datacode) and 
            (bs.categorysubcode = sg.datasubcode))
  order by bs.sortorder

go
set quoted_identifier off 
go
set ansi_nulls on 
go
grant  select ,  update ,  insert ,  delete  on [dbo].[book_marketing_1cat]  to [public]
go
