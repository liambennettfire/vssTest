set quoted_identifier off 
go
set ansi_nulls on 
go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[book_content_notes]') and objectproperty(id, N'isview') = 1)
drop view [dbo].[book_content_notes]
go


create view dbo.book_content_notes(bookkey, subjectkey, sortorder, categorydescription, categorycode, categoryexternalcode, subcatdescription, subcatcode, subcatexternalcode, sub2description, sub2catcode, sub2externalcode, lastuserid, lastmaintdate)  as 

  select top 100 percent 
      bs.bookkey, 
      bs.subjectkey, 
      bs.sortorder, 
      g.datadesc, 
      g.datacode, 
      g.externalcode, 
      sg.datadesc as expression_6, 
      sg.datasubcode, 
      sg.externalcode as expression_8, 
      sgg.datadesc as expression_9, 
      sgg.datasubcode as expression_10, 
      sgg.externalcode as expression_11, 
      bs.lastuserid, 
      bs.lastmaintdate
    from dbo.gentables g, dbo.booksubjectcategory bs
       left join dbo.subgentables sg  on ((sg.tableid = bs.categorytableid) and 
              (sg.datacode = bs.categorycode) and 
              (sg.datasubcode = bs.categorysubcode))
       left join dbo.sub2gentables sgg  on (sgg.datasubcode = bs.categorysub2code)
    where ((bs.categorytableid = 433) and 
            (g.tableid = bs.categorytableid) and 
            (g.datacode = bs.categorycode))
  order by bs.sortorder

go
set quoted_identifier off 
go
set ansi_nulls on 
go
grant  select ,  update ,  insert ,  delete  on [dbo].[book_content_notes]  to [public]
go

