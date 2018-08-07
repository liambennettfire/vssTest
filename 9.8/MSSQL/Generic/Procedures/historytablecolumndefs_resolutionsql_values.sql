update historytablecolumndefs
  set resolutionsql=
  'select @o_displayvalue=ltrim(rtrim(coalesce(firstname,'''')+'' ''+coalesce(lastname,'''')))
    from qsiusers
    where userkey=(select taqprojectownerkey from $replacetablename$)'
  where columnkey=101

update historytablecolumndefs
  set resolutionsql=
'Declare
  @v_type varchar(500),
  @v_subtype varchar(500)
select @v_type=datadesc
  from gentables g, $replacetablename$ t
   where g.datacode=t.commenttypecode
     and g.tableid=284
select @v_subtype=sg.datadesc
  from subgentables sg, $replacetablename$ t
   where sg.datacode=t.commenttypecode
     and sg.datasubcode=t.commenttypesubcode
     and sg.tableid=284
set @o_displayvalue=ltrim(rtrim(coalesce(@v_type,'''')+'' ''+coalesce(@v_subtype,''''))) '
  where columnkey in (111,112,113)

update historytablecolumndefs
  set resolutionsql=
'select @o_displayvalue=ltrim(rtrim(coalesce(firstname,'''')+'' ''+coalesce(lastname,'''')))
    from globalcontact
    where globalcontactkey=(select globalcontactkey from $replacetablename$) '
  where columnkey in (115,116,117)

update historytablecolumndefs
  set resolutionsql=
'select @o_displayvalue=orgentrydesc
  from orgentry
  where orgentrykey=(select top 1 orgentrykey from $replacetablename$) '
  where columnkey in (120,121)

update historytablecolumndefs
  set resolutionsql=
'Declare
  @v_tableid int,
  @v_tabledesclong varchar(500),
  @v_datadesc varchar(500),
  @v_subdatadesc varchar(500),
  @v_sub2datadesc varchar(500)
select @v_tableid=categorytableid from $replacetablename$
select @v_tabledesclong=tabledesclong
  from gentablesdesc g
  where g.tableid=@v_tableid
select @v_datadesc=datadesc
  from gentables g, $replacetablename$ t
   where g.datacode=t.categorycode
     and g.tableid=@v_tableid
select @v_subdatadesc=sg.datadesc
  from subgentables sg, $replacetablename$ t
   where sg.datacode=t.categorycode
     and sg.datasubcode=t.categorysubcode
     and sg.tableid=@v_tableid
select @v_sub2datadesc=s2g.datadesc
  from sub2gentables s2g, $replacetablename$ t
   where s2g.datacode=t.categorycode
     and s2g.datasubcode=t.categorysubcode
     and s2g.datasub2code=t.categorysub2code
     and s2g.tableid=@v_tableid
set @o_displayvalue=ltrim(rtrim(coalesce(@v_tabledesclong,'''')))
set @o_displayvalue=@o_displayvalue+'' ''+ltrim(rtrim(coalesce(@v_datadesc,'''')))
set @o_displayvalue=@o_displayvalue+'' ''+ltrim(rtrim(coalesce(@v_subdatadesc,'''')))
set @o_displayvalue=@o_displayvalue+'' ''+ltrim(rtrim(coalesce(@v_sub2datadesc,''''))) '
  where columnkey in (122,123,124,125,126)

update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc
 from $replacetablename$ t, gentables g
 where t.seasoncode=g.datacode
  and tableid=289'
 where columnkey = 130
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(seasonfirmind as varchar) from $replacetablename$' where columnkey = 131
update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc
 from $replacetablename$ t, gentables g
 where t.mediatypecode=g.datacode
  and tableid=312'
 where columnkey = 132

update historytablecolumndefs
  set resolutionsql= 
'declare @v_bookkey int
if @v_bookkey is null
  begin
    select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+sg.datadesc
      from subgentables sg, $replacetablename$ t
      where sg.datacode=t.mediatypecode
        and sg.datasubcode=t.mediatypesubcode
        and sg.tableid=312
  end
else
  begin
    select @o_displayvalue=formatname+'' ''+productnumberx+'' ''+title
      from coretitleinfo
      where bookkey=@v_bookkey
  end'
  where columnkey in (133)

update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc 
 from $replacetablename$ t, gentables g
 where t.discountcode=g.datacode
  and tableid=459'  where columnkey = 134
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(price as varchar) from $replacetablename$'  where columnkey = 135
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(initialrun as varchar) from $replacetablename$'  where columnkey = 136
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(projectdollars as varchar) from $replacetablename$' where columnkey = 137
update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc
 from $replacetablename$ t, gentables g
 where t.marketingplancode=g.datacode
  and tableid=524'
 where columnkey = 138
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(primaryformatind as varchar) from $replacetablename$' where columnkey = 139
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(isbn as varchar) from $replacetablename$' where columnkey = 140
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(isbn10 as varchar) from $replacetablename$' where columnkey = 141
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(ean as varchar) from $replacetablename$' where columnkey = 142
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(ean13 as varchar) from $replacetablename$' where columnkey = 143
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(gtin as varchar) from $replacetablename$' where columnkey = 144
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(taqprojectformatdesc as varchar) from $replacetablename$' where columnkey = 145
update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc
 from $replacetablename$ t, gentables g
 where t.isbnprefixcode=g.datacode
  and tableid=138'
 where columnkey = 147
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(gtin14 as varchar) from $replacetablename$' where columnkey = 148
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(lccn as varchar) from $replacetablename$' where columnkey = 149
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(dsmarc as varchar) from $replacetablename$' where columnkey = 150
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(itemnumber as varchar) from $replacetablename$' where columnkey = 151
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(upc as varchar) from $replacetablename$' where columnkey = 152
update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc
 from $replacetablename$ t, gentables g
 where t.eanprefixcode=g.datacode
  and tableid=138'
 where columnkey = 153
update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc
 from $replacetablename$ t, gentables g
 where t.projectrolecode=g.datacode
  and tableid=604'
 where columnkey = 154
update historytablecolumndefs
 set resolutionsql=
'select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+datadesc
 from $replacetablename$ t, gentables g
 where t.titlerolecode=g.datacode
  and tableid=605'
 where columnkey = 155
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(keyind as varchar) from $replacetablename$' where columnkey = 156
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(sortorder as varchar) from $replacetablename$' where columnkey = 157
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(indicator1 as varchar) from $replacetablename$' where columnkey = 158
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(indicator2 as varchar) from $replacetablename$' where columnkey = 159
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(quantity1 as varchar) from $replacetablename$' where columnkey = 160
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(quantity2 as varchar) from $replacetablename$' where columnkey = 161
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(relateditem2name as varchar) from $replacetablename$' where columnkey = 162
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(relateditem2status as varchar) from $replacetablename$' where columnkey = 163
update historytablecolumndefs set resolutionsql='select @o_displayvalue=coalesce(taqprojectformatdesc,'''')+'' ''+coalesce(ean13,'''')+'': ''+cast(relateditem2participants as varchar) from $replacetablename$' where columnkey = 164

--update historytablecolumndefs
--  set resolutionsql=
--'select @o_displayvalue=sg.datadesc
--   from subgentables sg, $replacetablename$ t
--   where sg.datacode=t.mediatypecode
--     and sg.datasubcode=t.mediatypesubcode
--     and sg.tableid=312 '
--  where columnkey in (133)

update historytablecolumndefs
  set resolutionsql=
'select @o_displayvalue=datadesc
  from gentables g
   where g.datacode=(select productidcode from $replacetablename$)
     and g.tableid=594'
  where columnkey in (165,166,168)


