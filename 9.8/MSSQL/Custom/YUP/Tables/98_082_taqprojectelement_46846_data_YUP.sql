
delete from taqproductnumbers
 where elementkey =  19290127
go

 delete FROM taqprojectelement  
  WHERE taqelementtypecode = 20001 
    AND bookkey = 18353757
    AND printingkey = 1
    AND taqelementkey = 19290127
go
