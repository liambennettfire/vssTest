INSERT INTO gentablesdesc
  (tableid, tabledesc, tabledesclong, location, gentablesdesclong, 
  tablemnemonic, userupdatableind, userupdate, lockind, 
  activeind, fakeentryind, subjectcategoryind, subgenallowed, sub2genallowed, requiredlevels, updatedescallowed,
  itemtypefilterind, hideonixfields, elofieldidlevel, elofieldid, productdetailind, filterorglevelkey, 
  gentext1label,
  usedivisionind, sourcetablecode)
VALUES
  (687, 'PmtMeth', 'Payment Method', 'gentables', 'Used for Contracts to determine what method of payment is being recorded – whether it is a royalty advance or some other kind of fee or bonus.', 
  'PaymentMethod', 1, NULL, 0, 
  1, 0, 0, 0, 0, 1, 1,
  1, 1, 0, NULL, 0, NULL, 
  NULL,
  0, 0)
go