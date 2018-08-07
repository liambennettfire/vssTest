DECLARE
  @v_po_itemtypecode int
  
BEGIN
  SELECT @v_po_itemtypecode = datacode FROM gentables WHERE tableid = 550 and qsicode = 15
  
  UPDATE taqversioncosts
     SET taqversionspeccategorykey = 0
   WHERE taqversionformatyearkey in (select fy.taqversionformatyearkey 
                                       from taqversionformatyear fy
                                      where fy.taqprojectkey in (select taqprojectkey from taqproject
                                                                  where searchitemcode <> @v_po_itemtypecode))
     and taqversionspeccategorykey > 0

END
go
