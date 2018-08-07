INSERT INTO gentablesdesc
	(tableid, tabledesc, tabledesclong, tablemnemonic, userupdatableind, userupdate, filterorglevelkey,location,
	lockind, gentablesdesclong, subjectcategoryind, subgenallowed, sub2genallowed, requiredlevels,
	updatedescallowed, activeind, itemtypefilterind, fakeentryind, usedivisionind, sourcetablecode,
  hideonixfields,elofieldidlevel,elofieldid,productdetailind,
	gentext1label,gentext2label)
	VALUES
	(581, 'PLSECT', 'P&L Detail Sections', 'PLSECT', 0, 'N', NULL,'gentables',
      1, 'A Firebrand controlled table used by the Version Detail window to determine whether to display this side bar/section as well as the name and positions of each section for the P&L Details.',
      0, 0, 0, 1,  
      0, 1, 2, 0, 0,0,
      1,0,NULL,0,
      'Control Name','Label')
	GO