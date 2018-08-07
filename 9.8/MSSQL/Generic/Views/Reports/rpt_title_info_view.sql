
/****** Object:  View [dbo].[rpt_title_info_view]    Script Date: 03/24/2009 13:39:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_title_info_view') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_title_info_view
GO
CREATE view [dbo].[rpt_title_info_view] as
Select
b.bookkey,
dbo.rpt_get_isbn  (b.Bookkey,16) as ean,
dbo.rpt_get_title (b.bookkey,'T') as title,
dbo.rpt_get_sub_title (b.bookkey) as subtitle,
dbo.rpt_get_format(b.Bookkey,'D') as format,
dbo.rpt_get_format(b.Bookkey,'S') as formatshort,
dbo.rpt_get_full_author_display_name (b.Bookkey) as fullauthordisplayname,
dbo.rpt_get_title (b.bookkey,'F') as titleprefixandtitle,
dbo.rpt_get_title (b.bookkey,'S') as titleandtitleprefix,
dbo.rpt_get_title (b.bookkey,'P') as titleprefix,
dbo.rpt_get_title (b.bookkey,'C') as titleandsubtitle,
dbo.rpt_get_title (b.bookkey,'U') as titleuppercase,
dbo.rpt_get_short_title (b.bookkey) as shorttitle,
p.announcedfirstprint as announcedfirstprint,
dbo.rpt_get_price (b.Bookkey,8,6,'A') as uspriceact,
dbo.rpt_get_price (b.Bookkey,8,6,'B') as uspricebest,
dbo.rpt_get_price (b.Bookkey,8,6,'E') as uspriceest,
dbo.rpt_get_price (b.Bookkey,8,11,'A') as canadianpriceact,
dbo.rpt_get_price (b.Bookkey,8,11,'B') as canadianpricebest,
dbo.rpt_get_price (b.Bookkey,8,11,'E') as canadianpriceest,
dbo.rpt_get_price (b.Bookkey,8,37,'A') as ukpriceact,
dbo.rpt_get_price (b.Bookkey,8,37,'B') as ukpricebest,
dbo.rpt_get_price (b.Bookkey,8,37,'E') as ukpriceest,
dbo.rpt_get_insert_illus (b.Bookkey,p.printingkey,'A') as insertillusact,
dbo.rpt_get_insert_illus (b.Bookkey,p.printingkey,'B') as insertillusbest,
dbo.rpt_get_insert_illus (b.Bookkey,p.printingkey,'E') as insertillusest,
dbo.rpt_get_isbn  (b.Bookkey,13) as isbn,
dbo.rpt_get_isbn  (b.Bookkey,10) as isbn10,
dbo.rpt_get_isbn  (b.Bookkey,16) as productnumber,
dbo.rpt_get_isbn  (b.Bookkey,20) as lccn,
dbo.rpt_get_isbn  (b.Bookkey,21) as upc,
dbo.rpt_get_media(b.Bookkey,'D') as media,
dbo.rpt_get_media(b.Bookkey,'S') as mediashort,
p.pagecount as pagecountact,
dbo.rpt_get_best_page_count  (b.Bookkey,p.printingkey) as pagecountbest,
p.tentativepagecount as pagecountest,
p.projectedsales as projectedsales,
dbo.rpt_get_pub_month (b.Bookkey,p.printingkey,'M') as pubmonth,
dbo.rpt_get_pub_month (b.Bookkey,p.printingkey,'S') as pubmonthshort,
dbo.rpt_get_pub_month (b.Bookkey,p.printingkey,'Y') as pubyear,
p.firstprintingqty as quantityact,
dbo.rpt_get_best_release_qty (b.Bookkey) as quantitybest,
p.tentativeqty as quantityest,
dbo.rpt_get_season (b.bookkey, 'A') as seasonyearact,
dbo.rpt_get_season (b.bookkey, 'B') as seasonyearbest,
dbo.rpt_get_season (b.bookkey, 'E') as seasonyearest,
dbo.rpt_get_trim_size (b.bookkey,p.printingkey,'A') as trimsizeact,
dbo.rpt_get_trim_size (b.bookkey,p.printingkey,'B') as trimsizebest,
dbo.rpt_get_trim_size (b.bookkey,p.printingkey,'E') as trimsizeest,
p.estprojectedsales as projectedsalesest,
dbo.rpt_get_best_projected_sales (b.bookkey, p.printingkey) as projectedsalesbest,
p.announcedfirstprint as announcedfirstprintest,
dbo.rpt_get_best_announced_1st_print (b.bookkey, p.printingkey) as announcedfirstprintbest,
dbo.rpt_get_author_all_name (b.bookkey, 5,0,'L', ';') as allauthorlastname,
dbo.rpt_get_author_all_name (b.bookkey, 5,0,'D', ';') as allauthordisplayname,
dbo.rpt_get_author_all_name (b.bookkey, 5,0,'C', ';') as allauthorcomplete,
'NA' as lastuserid,
getdate() as lastmaintdate


From book b, printing p
where b.bookkey = p.bookkey 
and p.printingkey=1
and b.standardind <> 'Y'
go
Grant All on dbo.rpt_title_info_view to Public
go