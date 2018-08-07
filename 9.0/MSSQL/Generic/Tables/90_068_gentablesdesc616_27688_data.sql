UPDATE gentablesdesc
   SET tabledesc = 'SPECS',
       tabledesclong = 'Specification and Scale Items',
       tablemnemonic = 'SPECS',
       gentablesdesclong = 'This table holds all of the components/processes and specification details needed for P&Ls, Title/Printings, Acquisition Projects and possibly other project types.  It is a three level table - the third level is not always required.   The first level is the Component or Process for the specification; the second level is the Specification field name.  The third level, when it exists, is used as the dropdown for the specification field at level 2.',
       itemtypefilterind = 3,
       gen1indlabel = 'Multiples Allowed',
       itemtyperelatedtableid = 661
where tableid = 616
go
 
  



