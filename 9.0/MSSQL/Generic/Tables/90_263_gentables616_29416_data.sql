--1. update gentablesdesc.gen2indlabel to 'Finished Good' for tableid 616
update gentablesdesc
set gen2indlabel = 'Finished Good'
where tableid = 616
go

--2. For each row in gentables for tableid 616
--Find the corresponding comptype row (if one exists) by matching the externalcode to compkey 
--Set gentables.gen2ind to 1 if comptype.finishedgoodind = 'Y'
update gentables
set gen2ind = 1
where tableid = 616
and externalcode is not null 
and isnumeric(externalcode) = 1
and externalcode in (select compkey from comptype where upper(finishedgoodind) = 'Y')
go

--3. Set all existing taqversionspeccategory.finishedgoodind based on the value set for the itemcategorycode gen2ind. 
--If more than one finished good component exists for a version/format, set it to true for only the first one
update taqversionspeccategory
set finishedgoodind = 1
where taqversionspecategorykey in (
  select taqversionspecategorykey from taqversionspeccategory t,
  (select taqprojectkey, taqversionkey, itemcategorycode, min(taqversionformatkey) as 'mintaqversionformatkey'
  from taqversionspeccategory
  where itemcategorycode in (select datacode from gentables where tableid = 616 and gen2ind = 1)
  group by taqprojectkey, taqversionkey, itemcategorycode, taqversionformatkey) as d
  where t.taqprojectkey = d.taqprojectkey
  and t.taqversionkey = d.taqversionkey
  and t.taqversionformatkey = d.mintaqversionformatkey
  and t.itemcategorycode = d.itemcategorycode
)
go
