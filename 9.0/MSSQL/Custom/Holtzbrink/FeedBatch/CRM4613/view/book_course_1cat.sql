set quoted_identifier off 
go
set ansi_nulls on 
go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[book_course_1cat]') and objectproperty(id, N'isview') = 1)
drop view [dbo].[book_course_1cat]
go


create view dbo.book_course_1cat(bookkey, subjectkey, sortorder, categorydescription, categorycode, categoryexternalcode, subcatdescription, subcatcode, subcatexternalcode, lastuserid, lastmaintdate, categorysub2code)  as 

  /*****
  *  warning ora2ms-4033 line: 1 col: 1: order by clause forces usage of top in view declaration.
  *****/

  select top 100 percent 
      bs.bookkey as bookkey, 
      bs.subjectkey as subjectkey, 
      bs.sortorder as sortorder, 
      g.alternatedesc1 as categorydescription, 
      bs.categorycode as categorycode, 
      g.externalcode as categoryexternalcode, 
      sg.alternatedesc1 as subcatdescription, 
      bs.categorysubcode as subcatcode, 
      sg.externalcode as subcatexternalcode, 
      bs.lastuserid as lastuserid, 
      bs.lastmaintdate as lastmaintdate, 
      bs.categorysub2code as categorysub2code
    from dbo.booksubjectcategory bs, dbo.gentables g, dbo.subgentables sg
    where ((bs.categorytableid = 436) and 
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
grant  select ,  update ,  insert ,  delete  on [dbo].[book_course_1cat]  to [public]
go

