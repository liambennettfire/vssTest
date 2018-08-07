if exists (select * from dbo.sysobjects where id = object_id(N'dbo.ips_bi_title_info_view') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view dbo.ips_bi_title_info_view
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE view dbo.ips_bi_title_info_view
as
select 
convert (char (13),dbo.rpt_get_isbn (t.bookkey,17))as 'ean',
convert (char (4),substring(dbo.rpt_get_group_level_2 (t.bookkey,'S'),1,4)) as 'pubnumid', /*Pub Partner Short Desc*/
convert (varchar (30),t.titleprefix) as 'titleprefix',
convert (varchar (250),t.title) as 'title',
convert (varchar (250),t.titleprefixandtitle) as 'titlewithprefix',
convert (varchar (250),t.subtitle) as 'subtitle',
convert (varchar (30), substring(dbo.rpt_get_author (t.bookkey,1,0,'X'),1,30)) as 'authorlastfirst',
case uspricebest when '' then convert(decimal(18,0),0) else convert (decimal (18,2),uspricebest) end as 'uspricebest',
convert (datetime, dbo.rpt_get_best_pub_date (t.bookkey,1)) as 'pubdate',
convert (varchar(15), substring(dbo.rpt_get_misc_value (t.bookkey, 35, ''),1,10))as 'ipsavailabilitydate',
convert (varchar (25), substring (dbo.rpt_get_bisac_status (t.bookkey, 'D'),1,25)) as 'bisacstatusdesc',
convert (char (3),substring(dbo.rpt_get_bisac_status (t.bookkey, 'B'),1,3)) as 'bisacstatuscode',
convert (char (1),substring (dbo.rpt_get_misc_value (t.bookkey, 6, ''),1,1)) as 'lsiyn',
convert (char (5),substring (dbo.rpt_get_discount (t.bookkey, 'D'),1,5)) as 'discountdesc',
convert (char (9),substring (dbo.rpt_get_discount (t.bookkey, 'E'),1,9)) as 'discountexternalcode',
convert (varchar (35),substring (dbo.rpt_get_misc_value (t.bookkey, 5, 'long'),1,35)) as 'prodreturndispdesc',
convert (char (1),substring (dbo.rpt_get_misc_value (t.bookkey, 5, 'externalcode'),1,1)) as 'prodreturndispexternalcode',
convert (varchar (35),substring (dbo.rpt_get_misc_value (t.bookkey, 3, 'long'),1,35)) as 'cartonreturndispdesc',
convert (char (1),substring (dbo.rpt_get_misc_value (t.bookkey, 3, 'externalcode'),1,1)) as 'cartonreturndispexternalcode',

case dbo.rpt_get_carton_qty (t.bookkey, 1) when '' then convert(int,0) else convert (int,dbo.rpt_get_carton_qty (t.bookkey, 1)) end
as 'cartonqty',

convert (varchar (35),substring (dbo.rpt_get_group_level_4 (t.bookkey,'F'),1,45)) as 'imprint',
convert (varchar (250),substring (dbo.rpt_get_bisac_subject (t.bookkey,1,'D'),1,250)) as 'bisacsubjectdesc',
convert (char (1),substring (dbo.rpt_get_bisac_subject (t.bookkey,1,'B'),1,9)) as 'bisacsubjectcode',

case dbo.rpt_get_price (t.bookkey,21,6, 'B')  when '' then convert(decimal(18,0),0) 
else convert (decimal (18,2),dbo.rpt_get_price (t.bookkey,21,6, 'B')) end as 'clientcost',

case dbo.rpt_get_misc_value (t.bookkey, 27, '')  when '' then convert(int,0) 
else convert (int,dbo.rpt_get_misc_value (t.bookkey, 27, '')) end as 'itemid',

convert (char (1),substring ('Y',1,1)) as 'ipsyn',
convert (varchar (50),substring (dbo.rpt_get_format (t.bookkey, 'D'),1,50))as 'formatdesc',
convert (varchar (25),substring (dbo.rpt_get_format (t.bookkey, 'B'),1,25))as 'formatbisaccode',
convert (varchar (50),substring (dbo.rpt_get_format (t.bookkey, '1'),1,50))as 'formataltdesc1',
convert (varchar (30),substring (dbo.rpt_get_media (t.bookkey, 'D'),1,30))as 'mediadesc',
convert (varchar (4),substring (dbo.rpt_get_media (t.bookkey, 'B'),1,4))as 'mediabisaccode',
convert (varchar (30),substring (dbo.rpt_get_media (t.bookkey, '1'),1,30))as 'mediaaltdesc1',

case dbo.rpt_get_misc_value (t.bookkey, 10, '')   when '' then convert(smallint,0) 
else convert (smallint,dbo.rpt_get_misc_value (t.bookkey, 10, '')) end as 'reorderpoint',

convert (varchar (4), substring (dbo.rpt_get_misc_value (t.bookkey, 2, ''),1, 
patindex ('% -%',dbo.rpt_get_misc_value (t.bookkey, 2, '')))) as 'brandcatcode',

convert (varchar (30), substring (dbo.rpt_get_misc_value (t.bookkey, 2, ''), 
patindex ('%-%',dbo.rpt_get_misc_value (t.bookkey, 2, ''))+2,30)) as 'brandcatdesc',

convert (varchar (10), substring (dbo.rpt_get_series_volume (t.bookkey),1,10)) as 'volumenumber',
convert (varchar (10), substring (dbo.rpt_get_edition (t.bookkey, 'N'),1,10)) as 'editionnumber',
convert (varchar (100), substring (dbo.rpt_remove_prefix (dbo.rpt_get_series (t.bookkey,'D')),1,100)) as 'series',
convert (varchar (50), substring (dbo.rpt_get_isbn (t.bookkey,21),1,50)) as 'upc',
convert (char (10), substring (dbo.rpt_get_isbn (t.bookkey,10),1,10)) as 'isbn',
convert (varchar (20),replace (dbo.rpt_get_replaces_isbn (t.bookkey), '-','')) as 'replacesisbn',
convert (varchar (20),replace (dbo.rpt_get_replaced_by_isbn (t.bookkey), '-','')) as 'replacedbyisbn',
substring (dbo.rpt_get_misc_value (t.bookkey, 32, 'long'),1,1) as 'priceonproductyn', --confirm miscid!!
convert (datetime, dbo.rpt_get_best_key_date (t.bookkey,1,20003)) as 'onsaledate', /*On Sale Date*/
substring (dbo.rpt_get_misc_value (t.bookkey, 12, 'long'),1,1) as 'canpriceonproductyn',

case canadianpricebest when '' then convert(decimal(18,0),0) else 
convert (decimal (18,2),canadianpricebest) end as 'canadianpricebest',

convert (char (20), substring (dbo.rpt_get_product_availability (t.bookkey, 'D'),1,20)) as 'productavailabilitydesc',
convert (char (20), substring (dbo.rpt_get_product_availability (t.bookkey, 'B'),1,20)) as 'productavailabilitybisaccode',

case pagecountbest when '' then convert(int,0) else 
convert (int,pagecountbest) end as 'pagecount',

convert (char(1),substring (dbo.ips_frontlist_yesno (t.bookkey),1,1)) as 'frontlistyn',
convert (varchar (50), substring (dbo.rpt_get_group_level_2 (t.bookkey, '1'),1,50)) as 'publishingpartnerdesc',
convert (char (4), substring (dbo.rpt_get_group_level_2 (t.bookkey, 'S'),1,4)) as 'publishingpartnercode',
convert (varchar (50), substring (dbo.rpt_get_group_level_3 (t.bookkey, '1'),1,50)) as 'publisherdesc',
convert (varchar (7), substring (dbo.rpt_get_group_level_3 (t.bookkey, 'S'),1,7)) as 'publishercode',
convert (varchar (5), substring (dbo.rpt_get_group_level_2 (t.bookkey, '1'),1,5)) as 'imprintdesc',
convert (char (4), substring (dbo.rpt_get_group_level_2 (t.bookkey, 'S'),1,4)) as 'imprintcode',
convert (varchar (30), substring (seasonyearbest,1,30)) as 'seasondesc',
convert (datetime,dbo.rpt_get_best_key_date (t.bookkey,1,30)) as boundbookdate, 
convert (datetime,dbo.rpt_get_best_key_date (t.bookkey,1,47)) as warehousedate,
convert (datetime, dbo.rpt_get_best_ship_date (t.bookkey,1,4))as 'bestshipdate'
from rpt_title_info_view t


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON dbo.ips_bi_title_info_view  TO public
GO



