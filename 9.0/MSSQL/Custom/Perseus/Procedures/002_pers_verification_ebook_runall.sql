/****** Object:  StoredProcedure [dbo].[pers_verification_ebook_runall]    Script Date: 05/17/2011 15:28:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pers_verification_ebook_runall]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pers_verification_ebook_runall]

/****** Object:  StoredProcedure [dbo].[pers_verification_ebook_runall]    Script Date: 05/17/2011 15:27:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create       PROCEDURE [dbo].[pers_verification_ebook_runall]

AS
BEGIN
/* 


*/
--ran in 5:25 for 6113 titles 
--ran in 11:10 for 12971 titles
set nocount on

DECLARE @counter int
DECLARE @minbookkey int
DECLARE @numrows int
DECLARE @verificationtypecode int

declare 
 @o_error_code      integer, 
  @o_error_desc      varchar(2000)

select @verificationtypecode = datacode
from gentables
where tableid = 556
and datadescshort = 'EB Verif'

--gather all bookkeys for relevant titles 
create  table #tmp_bookkeys
(bookkey	int)

--set rowcount 200

select *
from cs_formatverification

insert into #tmp_bookkeys
select distinct bd.bookkey
from bookdetail bd  
join book b
on bd.bookkey = b.bookkey
join customer c
on b.elocustomerkey = c.customerkey
join gentables g
on bd.mediatypecode = g.datacode
and g.tableid = 312
join subgentables sg
on bd.mediatypecode = sg.datacode
and bd.mediatypesubcode = sg.datasubcode
and sg.tableid = 312
join cs_formatverification csf
on g.eloquencefieldtag = csf.mediaelotag
where g.eloquencefieldtag = 'EP'
--join bookdates bt
--on bd.bookkey = bt.bookkey
--join datetype dt
--on bt.datetypecode = dt.datetypecode
--and dt.eloquencefieldtag like 'onix%'

--set rowcount 0

select @numrows = count(*), @minbookkey = min(bookkey) 
from #tmp_bookkeys

set @counter = 1

while @counter < = @numrows
begin
	exec [pers_verification_ebook] @minbookkey,1,@verificationtypecode,'eb-verify'

	select @counter = @counter + 1

	select @minbookkey = min(bookkey)
	from #tmp_bookkeys
	where bookkey > @minbookkey	

end

drop table #tmp_bookkeys

end

go

grant execute on pers_verification_ebook_runall to public
go