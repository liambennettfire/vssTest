select t.bookkey, t.printingkey, t.lastuserid, t.columnkey, 
       c.productnumber, c.title, c.isbnx, c.tmmheaderorg1desc, c.tmmheaderorg2desc,
       t.currentstringvalue, t.fielddesc, b.bisaccategorycode, g.datadesc new_bisaccategory, b.bisaccategorysubcode, sg.datadesc  new_bisacsubcategory,b.sortorder,
       o.bisaccategorycode old_bisaccategorycode,g2.datadesc old_bisaccategory,  o.bisaccategorysubcode old_bisaccategorysubcode, sg2.datadesc  old_bisacsubcategory,o.sortorder old_sortorder
 from titlehistory t, coretitleinfo c, bookbisaccategory b, bookbisaccategory_bkup_bisac2010 o, gentables g, subgentables sg, gentables g2, subgentables sg2
where t.lastuserid = 'FB_BISACSUBJECT_UPDATE_2010'
  and t.bookkey = c.bookkey and t.printingkey = c.printingkey
  and t.bookkey = b.bookkey and t.printingkey = b.printingkey
  and b.lastuserid = 'FB_BISACSUBJECT_UPDATE_2010'
  and b.bookkey = o.bookkey and b.printingkey = o.printingkey and b.sortorder = o.sortorder
  and t.columnkey <> 104
  and g.tableid = 339 and b.bisaccategorycode = g.datacode
  and sg.tableid = 339 and b.bisaccategorycode = sg.datacode and b.bisaccategorysubcode = sg.datasubcode
  and g2.tableid = 339 and o.bisaccategorycode = g2.datacode
  and sg2.tableid = 339 and o.bisaccategorycode = sg2.datacode and o.bisaccategorysubcode = sg2.datasubcode
order by t.bookkey asc

go