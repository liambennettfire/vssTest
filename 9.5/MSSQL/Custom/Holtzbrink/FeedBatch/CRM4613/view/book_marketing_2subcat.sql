set quoted_identifier off 
go
set ansi_nulls on 
go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[book_marketing_2subcat]') and objectproperty(id, N'isview') = 1)
drop view [dbo].[book_marketing_2subcat]
go

create view dbo.book_marketing_2subcat(bookkey, subjectkey, sortorder, sub2description, sub2catcode, sub2externalcode, lastuserid, lastmaintdate)  as 

  select top 100 percent 
      bs.bookkey as bookkey, 
      bs.subjectkey as subjectkey, 
      bs.sortorder as sortorder, 
      sgg.datadesc as sub2description, 
      bs.categorysub2code as sub2catcode, 
      sgg.externalcode as sub2externalcode, 
      bs.lastuserid as lastuserid, 
      bs.lastmaintdate as lastmaintdate
    from dbo.booksubjectcategory bs, dbo.sub2gentables sgg
    where ((bs.categorytableid = 437) and 
            (sgg.tableid = 436) and 
            (bs.categorycode = sgg.datacode) and 
            (bs.categorysubcode = sgg.datasubcode) and 
            (bs.categorysub2code = sgg.datasub2code))
  order by bs.sortorder


go
set quoted_identifier off 
go
set ansi_nulls on 
go
grant  select ,  update ,  insert ,  delete  on [dbo].[book_marketing_2subcat]  to [public]
go
