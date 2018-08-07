UPDATE taqversionspeccategory 
SET speccategorydescription = NULL, scaleprojecttype = NULL, vendorcontactkey = NULL, 
  quantity = NULL, spoilagepercentage = NULL, deriveqtyfromfgqty = 0, finishedgoodind = NULL 
WHERE relatedspeccategorykey > 0
go