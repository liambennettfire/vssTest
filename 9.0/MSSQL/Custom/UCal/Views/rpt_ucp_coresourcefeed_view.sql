if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_ucp_coresourcefeed_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_ucp_coresourcefeed_view]
GO


CREATE view [dbo].[rpt_ucp_coresourcefeed_view] as
Select
dbo.rpt_get_misc_value (b.bookkey,202,'') as 'Title Group ID',
dbo.rpt_get_isbn  (b.Bookkey,17) as ISBN13,
'Web PDF' as 'Asset Type',
'Yes' as 'Eligible for Distribution',
dbo.rpt_get_title (b.bookkey,'T') as title,
dbo.rpt_get_sub_title (b.bookkey) as subtitle,
dbo.rpt_get_group_level_2 (b.bookkey,1) as Publisher,
dbo.rpt_get_group_level_3 (b.bookkey,1) as Imprint,
dbo.rpt_get_ucp_author (b.bookkey,1,12,'F') as 'Contributor 1 First Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'M') as 'Contributor 1 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') as 'Contributor 1 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'P') as 'Contributor 1 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'S') as 'Contributor 1 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'T') as 'Contributor 1 Role',
dbo.rpt_get_book_comment (b.bookkey,3,64,3) as 'Contributor 1 Bio',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'F') as 'Contributor 2 First Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'M') as 'Contributor 2 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'L') as 'Contributor 2 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'P') as 'Contributor 2 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'S') as 'Contributor 2 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'T') as 'Contributor 2 Role',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'F') as 'Contributor 3 First Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'M') as 'Contributor 3 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'L') as 'Contributor 3 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'P') as 'Contributor 3 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'S') as 'Contributor 3 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'T') as 'Contributor 3 Role',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'F') as 'Contributor 4 First Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'M') as 'Contributor 4 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'L') as 'Contributor 4 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'P') as 'Contributor 4 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'S') as 'Contributor 4 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'T') as 'Contributor 4 Role',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'F') as 'Contributor 5 First Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'M') as 'Contributor 5 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'L') as 'Contributor 5 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'P') as 'Contributor 5 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'S') as 'Contributor 5 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'T') as 'Contributor 5 Role',
'Retail' as 'Price Business Model Flag',
'USD' as 'Currency Code',
dbo.rpt_get_price (b.Bookkey,8,6,'A')as 'Price 1',
45 as 'Discount Percentage',
CASE 
 WHEN b.territoriescode = 1 THEN 'World'
 ELSE 'Rest of World'
END AS 'Region(s) with Exclusive Rights',
' ' as 'Not for Sale Regions',
convert(varchar(max),dbo.rpt_get_countries_with_exclusive_rights(b.bookkey,b.territoriescode,'B')) as 'Countries with Exclusive Rights',
convert(varchar(max),dbo.rpt_get_not_for_sale_countries(b.bookkey,b.territoriescode,'B')) as 'Not For Sale Countries',
'ALL' as 'Rights Business Model Flag',
dbo.get_BestPubDate(b.bookkey,p.printingkey) as 'Publication Date',
dbo.rpt_get_best_key_date(b.bookkey,p.printingkey,20003) as 'Street Date',
dbo.rpt_get_bisac_subject(b.bookkey,1,'D') as 'Bisac Code(s)',
dbo.rpt_get_Series(b.bookkey,'D') as 'Series',
dbo.rpt_get_series_volume(b.bookkey) as 'Series Number',
dbo.rpt_get_edition_number(b.bookkey,'D') as 'Edition Number',
dbo.rpt_get_page_count(b.bookkey,p.printingkey,'B') as 'Page Count',
CASE WHEN (d.languagecode IS NOT NULL AND d.languagecode > 0) THEN dbo.rpt_get_language(b.bookkey,'D')
     ELSE 'English'
END as 'Language',
dbo.rpt_get_book_comment(b.bookkey,3,7,3) as 'Short Description',
dbo.rpt_get_book_comment(b.bookkey,3,8,3) as 'Long Description',
dbo.rpt_get_book_comment (b.bookkey,3,52,3) as 'Table of Contents',
dbo.rpt_get_misc_value (b.bookkey,196,'') as 'Flexible Field 1'
From book b, printing p,bookdetail d
where b.bookkey = p.bookkey 
and b.bookkey = d.bookkey
and p.printingkey=1
and b.standardind <> 'Y'
and d.mediatypecode = 14
and (dbo.rpt_get_misc_value (b.bookkey,202,'') IS NOT NULL AND dbo.rpt_get_misc_value (b.bookkey,202,'') <> '')
and (dbo.rpt_get_isbn  (b.Bookkey,17) IS NOT NULL AND dbo.rpt_get_isbn  (b.Bookkey,17) <> '')
and  dbo.rpt_get_isbn  (b.Bookkey,17) <> '9780520952898'
and (dbo.rpt_get_title (b.bookkey,'T') IS NOT NULL AND dbo.rpt_get_title (b.bookkey,'T') <> '')
and (dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') IS NOT NULL AND dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') <> '')
and (dbo.get_BestPubDate(b.bookkey,p.printingkey) IS NOT NULL AND dbo.get_BestPubDate(b.bookkey,p.printingkey) <> '')
and (dbo.rpt_get_bisac_subject(b.bookkey,1,'D') IS NOT NULL AND dbo.rpt_get_bisac_subject(b.bookkey,1,'D') <> '')
and (dbo.rpt_get_misc_value (b.bookkey,196,'') = 'P' OR dbo.rpt_get_misc_value (b.bookkey,196,'') = 'PE')
and b.territoriescode > 0 


UNION SELECT

dbo.rpt_get_misc_value (b.bookkey,202,'') as 'Title Group ID',
dbo.rpt_get_isbn  (b.Bookkey,17) as ISBN13,
'Web PDF' as 'Asset Type',
'Yes' as 'Eligible for Distribution',
dbo.rpt_get_title (b.bookkey,'T') as title,
dbo.rpt_get_sub_title (b.bookkey) as subtitle,
dbo.rpt_get_group_level_2 (b.bookkey,1) as Publisher,
dbo.rpt_get_group_level_3 (b.bookkey,1) as Imprint,
dbo.rpt_get_ucp_author (b.bookkey,1,12,'F') as 'Contributor 1 First Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'M') as 'Contributor 1 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') as 'Contributor 1 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'P') as 'Contributor 1 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'S') as 'Contributor 1 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'T') as 'Contributor 1 Role',
dbo.rpt_get_book_comment (b.bookkey,3,64,3) as 'Contributor 1 Bio',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'F') as 'Contributor 2 First Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'M') as 'Contributor 2 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'L') as 'Contributor 2 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'P') as 'Contributor 2 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'S') as 'Contributor 2 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'T') as 'Contributor 2 Role',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'F') as 'Contributor 3 First Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'M') as 'Contributor 3 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'L') as 'Contributor 3 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'P') as 'Contributor 3 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'S') as 'Contributor 3 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'T') as 'Contributor 3 Role',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'F') as 'Contributor 4 First Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'M') as 'Contributor 4 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'L') as 'Contributor 4 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'P') as 'Contributor 4 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'S') as 'Contributor 4 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'T') as 'Contributor 4 Role',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'F') as 'Contributor 5 First Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'M') as 'Contributor 5 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'L') as 'Contributor 5 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'P') as 'Contributor 5 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'S') as 'Contributor 5 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'T') as 'Contributor 5 Role',
'Library' as 'Price Business Model Flag',
'USD' as 'Currency Code',
dbo.rpt_get_price (b.Bookkey,30,6,'A')as 'Price 1',
45 as 'Discount Percentage',
CASE 
 WHEN b.territoriescode = 1 THEN 'World'
 ELSE 'Rest of World'
END AS 'Region(s) with Exclusive Rights',
'' as 'Not for Sale Regions',
convert (varchar(max),dbo.rpt_get_countries_with_exclusive_rights(b.bookkey,b.territoriescode,'B')) as 'Countries with Exclusive Rights',
convert (varchar(max),dbo.rpt_get_not_for_sale_countries(b.bookkey,b.territoriescode,'B')) as 'Not For Sale Countries',
'ALL' as 'Rights Business Model Flag',
dbo.get_BestPubDate(b.bookkey,p.printingkey) as 'Publication Date',
dbo.rpt_get_best_key_date(b.bookkey,p.printingkey,20003) as 'Street Date',
dbo.rpt_get_bisac_subject(b.bookkey,1,'D') as 'Bisac Code(s)',
dbo.rpt_get_Series(b.bookkey,'D') as 'Series',
dbo.rpt_get_series_volume(b.bookkey) as 'Series Number',
dbo.rpt_get_edition_number(b.bookkey,'D') as 'Edition Number',
dbo.rpt_get_page_count(b.bookkey,p.printingkey,'B') as 'Page Count',
CASE WHEN (d.languagecode IS NOT NULL AND d.languagecode > 0) THEN dbo.rpt_get_language(b.bookkey,'D')
     ELSE 'English'
END as 'Language',
dbo.rpt_get_book_comment(b.bookkey,3,7,3) as 'Short Description',
dbo.rpt_get_book_comment(b.bookkey,3,8,3) as 'Long Description',
dbo.rpt_get_book_comment (b.bookkey,3,52,3) as 'Table of Contents',
dbo.rpt_get_misc_value (b.bookkey,196,'') as 'Flexible Field 1'
From book b, printing p,bookdetail d
where b.bookkey = p.bookkey 
and b.bookkey = d.bookkey
and p.printingkey=1
and b.standardind <> 'Y'
and d.mediatypecode = 14
and (dbo.rpt_get_misc_value (b.bookkey,202,'') IS NOT NULL AND dbo.rpt_get_misc_value (b.bookkey,202,'') <> '')
and (dbo.rpt_get_isbn  (b.Bookkey,17) IS NOT NULL AND dbo.rpt_get_isbn  (b.Bookkey,17) <> '')
and  dbo.rpt_get_isbn  (b.Bookkey,17) <> '9780520952898'
and (dbo.rpt_get_title (b.bookkey,'T') IS NOT NULL AND dbo.rpt_get_title (b.bookkey,'T') <> '')
and (dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') IS NOT NULL AND dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') <> '')
and (dbo.get_BestPubDate(b.bookkey,p.printingkey) IS NOT NULL AND dbo.get_BestPubDate(b.bookkey,p.printingkey) <> '')
and (dbo.rpt_get_bisac_subject(b.bookkey,1,'D') IS NOT NULL AND dbo.rpt_get_bisac_subject(b.bookkey,1,'D') <> '')
and (dbo.rpt_get_misc_value (b.bookkey,196,'') = 'P' OR dbo.rpt_get_misc_value (b.bookkey,196,'') = 'PE')
and b.territoriescode > 0

UNION SELECT
dbo.rpt_get_misc_value (b.bookkey,202,'') as 'Title Group ID',
dbo.rpt_get_isbn  (b.Bookkey,17) as ISBN13,
'EPUB' as 'Asset Type',
CASE WHEN 'ISBN13' = '9780520952898' THEN 'No'
     ELSE '' 
END as 'Eligible for Distribution',
dbo.rpt_get_title (b.bookkey,'T') as title,
dbo.rpt_get_sub_title (b.bookkey) as subtitle,
dbo.rpt_get_group_level_2 (b.bookkey,1) as Publisher,
dbo.rpt_get_group_level_3 (b.bookkey,1) as Imprint,
dbo.rpt_get_ucp_author (b.bookkey,1,12,'F') as 'Contributor 1 First Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'M') as 'Contributor 1 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') as 'Contributor 1 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'P') as 'Contributor 1 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'S') as 'Contributor 1 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'T') as 'Contributor 1 Role',
dbo.rpt_get_book_comment (b.bookkey,3,64,3) as 'Contributor 1 Bio',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'F') as 'Contributor 2 First Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'M') as 'Contributor 2 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'L') as 'Contributor 2 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'P') as 'Contributor 2 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'S') as 'Contributor 2 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'T') as 'Contributor 2 Role',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'F') as 'Contributor 3 First Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'M') as 'Contributor 3 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'L') as 'Contributor 3 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'P') as 'Contributor 3 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'S') as 'Contributor 3 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'T') as 'Contributor 3 Role',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'F') as 'Contributor 4 First Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'M') as 'Contributor 4 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'L') as 'Contributor 4 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'P') as 'Contributor 4 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'S') as 'Contributor 4 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'T') as 'Contributor 4 Role',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'F') as 'Contributor 5 First Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'M') as 'Contributor 5 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'L') as 'Contributor 5 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'P') as 'Contributor 5 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'S') as 'Contributor 5 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'T') as 'Contributor 5 Role',
'Retail' as 'Price Business Model Flag',
'USD' as 'Currency Code',
dbo.rpt_get_price (b.Bookkey,8,6,'A')as 'Price 1',
45 as 'Discount Percentage',
CASE 
 WHEN b.territoriescode = 1 THEN 'World'
 ELSE 'Rest of World'
END AS 'Region(s) with Exclusive Rights',
' '  as 'Not for Sale Regions',
convert(varchar(max),dbo.rpt_get_countries_with_exclusive_rights(b.bookkey,b.territoriescode,'B')) as 'Countries with Exclusive Rights',
convert(varchar(max),dbo.rpt_get_not_for_sale_countries(b.bookkey,b.territoriescode,'B')) as 'Not For Sale Countries',
'ALL' as 'Rights Business Model Flag',
dbo.get_BestPubDate(b.bookkey,p.printingkey) as 'Publication Date',
dbo.rpt_get_best_key_date(b.bookkey,p.printingkey,20003) as 'Street Date',
dbo.rpt_get_bisac_subject(b.bookkey,1,'D') as 'Bisac Code(s)',
dbo.rpt_get_Series(b.bookkey,'D') as 'Series',
dbo.rpt_get_series_volume(b.bookkey) as 'Series Number',
dbo.rpt_get_edition_number(b.bookkey,'D') as 'Edition Number',
dbo.rpt_get_page_count(b.bookkey,p.printingkey,'B') as 'Page Count',
CASE WHEN (d.languagecode IS NOT NULL AND d.languagecode > 0) THEN dbo.rpt_get_language(b.bookkey,'D')
     ELSE 'English'
END as 'Language',
dbo.rpt_get_book_comment(b.bookkey,3,7,3) as 'Short Description',
dbo.rpt_get_book_comment(b.bookkey,3,8,3) as 'Long Description',
dbo.rpt_get_book_comment (b.bookkey,3,52,3) as 'Table of Contents',
dbo.rpt_get_misc_value (b.bookkey,196,'') as 'Flexible Field 1'
From book b, printing p,bookdetail d
where b.bookkey = p.bookkey 
and b.bookkey = d.bookkey
and p.printingkey=1
and b.standardind <> 'Y'
and d.mediatypecode = 14
and (dbo.rpt_get_misc_value (b.bookkey,202,'') IS NOT NULL AND dbo.rpt_get_misc_value (b.bookkey,202,'') <> '')
and (dbo.rpt_get_isbn  (b.Bookkey,17) IS NOT NULL AND dbo.rpt_get_isbn  (b.Bookkey,17) <> '')
and  dbo.rpt_get_isbn  (b.Bookkey,17) <> '9780520951372'
and (dbo.rpt_get_title (b.bookkey,'T') IS NOT NULL AND dbo.rpt_get_title (b.bookkey,'T') <> '')
and (dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') IS NOT NULL AND dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') <> '')
and (dbo.get_BestPubDate(b.bookkey,p.printingkey) IS NOT NULL AND dbo.get_BestPubDate(b.bookkey,p.printingkey) <> '')
and (dbo.rpt_get_bisac_subject(b.bookkey,1,'D') IS NOT NULL AND dbo.rpt_get_bisac_subject(b.bookkey,1,'D') <> '')
and (dbo.rpt_get_misc_value (b.bookkey,196,'') = 'P' OR dbo.rpt_get_misc_value (b.bookkey,196,'') = 'PE')
and b.territoriescode > 0


UNION SELECT

dbo.rpt_get_misc_value (b.bookkey,202,'') as 'Title Group ID',
dbo.rpt_get_isbn  (b.Bookkey,17) as ISBN13,
'EPUB' as 'Asset Type',
CASE WHEN 'ISBN13' = '9780520952898' THEN 'No'
     ELSE '' 
END as 'Eligible for Distribution',
dbo.rpt_get_title (b.bookkey,'T') as title,
dbo.rpt_get_sub_title (b.bookkey) as subtitle,
dbo.rpt_get_group_level_2 (b.bookkey,1) as Publisher,
dbo.rpt_get_group_level_3 (b.bookkey,1) as Imprint,
dbo.rpt_get_ucp_author (b.bookkey,1,12,'F') as 'Contributor 1 First Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'M') as 'Contributor 1 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') as 'Contributor 1 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'P') as 'Contributor 1 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'S') as 'Contributor 1 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,1,12,'T') as 'Contributor 1 Role',
dbo.rpt_get_book_comment (b.bookkey,3,64,3) as 'Contributor 1 Bio',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'F') as 'Contributor 2 First Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'M') as 'Contributor 2 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'L') as 'Contributor 2 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'P') as 'Contributor 2 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'S') as 'Contributor 2 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,2,12,'T') as 'Contributor 2 Role',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'F') as 'Contributor 3 First Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'M') as 'Contributor 3 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'L') as 'Contributor 3 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'P') as 'Contributor 3 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'S') as 'Contributor 3 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,3,12,'T') as 'Contributor 3 Role',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'F') as 'Contributor 4 First Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'M') as 'Contributor 4 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'L') as 'Contributor 4 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'P') as 'Contributor 4 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'S') as 'Contributor 4 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,4,12,'T') as 'Contributor 4 Role',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'F') as 'Contributor 5 First Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'M') as 'Contributor 5 Middle Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'L') as 'Contributor 5 Last Name',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'P') as 'Contributor 5 Prefix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'S') as 'Contributor 5 Suffix',
dbo.rpt_get_ucp_author (b.bookkey,5,12,'T') as 'Contributor 5 Role',
'Library' as 'Price Business Model Flag',
'USD' as 'Currency Code',
dbo.rpt_get_price (b.Bookkey,30,6,'A')as 'Price 1',
45 as 'Discount Percentage',
CASE 
 WHEN b.territoriescode = 1 THEN 'World'
 ELSE 'Rest of World'
END AS 'Region(s) with Exclusive Rights',
' ' as 'Not for Sale Regions',
convert(varchar(max),dbo.rpt_get_countries_with_exclusive_rights(b.bookkey,b.territoriescode,'B')) as 'Countries with Exclusive Rights',
convert(varchar(max),dbo.rpt_get_not_for_sale_countries(b.bookkey,b.territoriescode,'B')) as 'Not For Sale Countries',
'ALL' as 'Rights Business Model Flag',
dbo.get_BestPubDate(b.bookkey,p.printingkey) as 'Publication Date',
dbo.rpt_get_best_key_date(b.bookkey,p.printingkey,20003) as 'Street Date',
dbo.rpt_get_bisac_subject(b.bookkey,1,'D') as 'Bisac Code(s)',
dbo.rpt_get_Series(b.bookkey,'D') as 'Series',
dbo.rpt_get_series_volume(b.bookkey) as 'Series Number',
dbo.rpt_get_edition_number(b.bookkey,'D') as 'Edition Number',
dbo.rpt_get_page_count(b.bookkey,p.printingkey,'B') as 'Page Count',
CASE WHEN (d.languagecode IS NOT NULL AND d.languagecode > 0) THEN dbo.rpt_get_language(b.bookkey,'D')
     ELSE 'English'
END as 'Language',
dbo.rpt_get_book_comment(b.bookkey,3,7,3) as 'Short Description',
dbo.rpt_get_book_comment(b.bookkey,3,8,3) as 'Long Description',
dbo.rpt_get_book_comment (b.bookkey,3,52,3) as 'Table of Contents',
dbo.rpt_get_misc_value (b.bookkey,196,'') as 'Flexible Field 1'
From book b, printing p,bookdetail d
where b.bookkey = p.bookkey 
and b.bookkey = d.bookkey
and p.printingkey=1
and b.standardind <> 'Y'
and d.mediatypecode = 14
and (dbo.rpt_get_misc_value (b.bookkey,202,'') IS NOT NULL AND dbo.rpt_get_misc_value (b.bookkey,202,'') <> '')
and (dbo.rpt_get_isbn  (b.Bookkey,17) IS NOT NULL AND dbo.rpt_get_isbn  (b.Bookkey,17) <> '')
and  dbo.rpt_get_isbn  (b.Bookkey,17) <> '9780520951372'
and (dbo.rpt_get_title (b.bookkey,'T') IS NOT NULL AND dbo.rpt_get_title (b.bookkey,'T') <> '')
and (dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') IS NOT NULL AND dbo.rpt_get_ucp_author (b.bookkey,1,12,'L') <> '')
and (dbo.get_BestPubDate(b.bookkey,p.printingkey) IS NOT NULL AND dbo.get_BestPubDate(b.bookkey,p.printingkey) <> '')
and (dbo.rpt_get_bisac_subject(b.bookkey,1,'D') IS NOT NULL AND dbo.rpt_get_bisac_subject(b.bookkey,1,'D') <> '')
and (dbo.rpt_get_misc_value (b.bookkey,196,'') = 'P' OR dbo.rpt_get_misc_value (b.bookkey,196,'') = 'PE')
and b.territoriescode > 0
go

GRANT SELECT ON dbo.rpt_ucp_coresourcefeed_view TO public
go

