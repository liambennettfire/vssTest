INSERT INTO gentablesdesc
	(tableid, tabledesc, tabledesclong, tablemnemonic, userupdatableind, userupdate, filterorglevelkey,location,
	lockind, gentablesdesclong, subjectcategoryind, subgenallowed, sub2genallowed, requiredlevels,
	updatedescallowed, activeind, itemtypefilterind, fakeentryind, usedivisionind, sourcetablecode,
  hideonixfields,elofieldidlevel,elofieldid,productdetailind,
	gentext1label,gentext2label)
	VALUES
	(663, 'PartSect', 'Participant Section Name', 'ParticipantSectionName', 1, 'N', NULL,'gentables',
      1, 'This is a firebrand controlled table that identifies the Participant Sections used for project item types.  It will be used on the item type filter level for Role Type (table id 285) to identify which section a role type belongs in.',
      0, 0, 0, 1,  
      0, 1, 0, 1, 0,0,
      1,0,NULL,0,
      NULL,NULL)
	GO