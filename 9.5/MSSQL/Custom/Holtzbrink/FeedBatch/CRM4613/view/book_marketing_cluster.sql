set quoted_identifier off 
go
set ansi_nulls on 
go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[book_marketing_cluster]') and objectproperty(id, N'isview') = 1)
drop view [dbo].[book_marketing_cluster]
go


create view dbo.book_marketing_cluster(bookkey, subjectkey, sortorder, categorydescription, categorycode, categoryexternalcode, subcatdescription, subcatcode, subcatexternalcode, sub2description, sub2catcode, sub2externalcode, subshortdesc)  as 

    select 
      b1.bookkey as bookkey, 
      b1.subjectkey as subjectkey, 
      b1.sortorder as sortorder, 
      b1.categorydescription as categorydescription, 
      b1.categorycode as categorycode, 
      b1.categoryexternalcode as categoryexternalcode, 
      b1.subcatdescription as subcatdescription, 
      b1.subcatcode as subcatcode, 
      b1.subcatexternalcode as subcatexternalcode, 
      b2.sub2description as sub2description, 
      b2.sub2catcode as sub2catcode, 
      b2.sub2externalcode as sub2externalcode, 
      b1.subshortdesc as subshortdesc
    from dbo.book_marketing_1cat b1
       left join dbo.book_marketing_2subcat b2  on (b1.bookkey = b2.bookkey)

go
set quoted_identifier off 
go
set ansi_nulls on 
go
grant  select ,  update ,  insert ,  delete  on [dbo].[book_marketing_cluster]  to [public]
go
