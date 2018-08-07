INSERT INTO gentablesdesc
	(tableid, tabledesc, tabledesclong, tablemnemonic, userupdatableind, userupdate, filterorglevelkey,location,
	lockind, gentablesdesclong, subjectcategoryind, subgenallowed, sub2genallowed, requiredlevels,
	updatedescallowed, activeind, itemtypefilterind, fakeentryind, usedivisionind, sourcetablecode,
  hideonixfields,elofieldidlevel,elofieldid,productdetailind,
	gentext1label,gentext2label)
	VALUES
	(584, 'Checkbox', 'Checkbox', 'Checkbox', 0, 'N', NULL,'gentables',
      1, 'This Firebrand controlled table will be used in Specifications when a checkbox is desired rather than yes/no fields. The screen will show a checkbox but save table values for Yes (datacode 1) and No (datacode 0).',
      0, 0, 0, 1,  
      0, 1, 0, NULL, 0,0,
      1,0,NULL,0,
      NULL,NULL)
	GO