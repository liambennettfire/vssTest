INSERT INTO gentablesdesc
	(tableid, tabledesc, tabledesclong, tablemnemonic, userupdatableind, userupdate, filterorglevelkey,location,
	lockind, gentablesdesclong, subjectcategoryind, subgenallowed, sub2genallowed, requiredlevels,
	updatedescallowed, activeind, itemtypefilterind, fakeentryind, usedivisionind, sourcetablecode,
  hideonixfields,elofieldidlevel,elofieldid,productdetailind)
	VALUES
	(661, 'SPECVAL', 'Specification Value Location', 'SPECVAL', 0, 'N', NULL,'gentables',
      1, 'A Firebrand controlled table used by the Specification Item table (616) at the item type level to determine for each item type how to get the specification value. This is system table that will not be shown in user admin. The function qproject_get_specitem_by_printingview will us this information as well as the specification section.',
      0, 0, 0, 1,  
      0, 1, 0, 1, 0,0,
      1,0,NULL,0)
	GO