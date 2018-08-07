SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[printerinventory1]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[printerinventory1]
GO


/****** Object:  View dbo.printerinventory1    Script Date: 5/22/2000 4:22:19 PM ******/
CREATE VIEW dbo.printerinventory1 
	(rawmaterialkey,vendorkey,vendor,
	 rmc,stocktypecode,stocktype,
	 rollsizecode,rollsize,sheetsizecode,
	 sheetsize,basisweightcode,basisweight,
	 paperbulk,colorcode,color,
	 opacity,matsuppliercode,onhandavailable,
	 onhandallocated,priceperhundred,onhandvalue,
	 brightness,activeind,mweightfactor)
as
  select	printerinventory.rawmaterialkey,
		 printerinventory.vendorkey,
		 vendor.name,
		 printerinventory.rmc,
		 printerinventory.stocktypecode,
		 a.datadesc,
		 printerinventory.rollsize,
		 b.datadesc,
		 printerinventory.sheetsize,
		 c.datadesc,
		 printerinventory.basisweight,
		 d.datadesc,
		 printerinventory.paperbulk,
		 printerinventory.color,
		 e.datadesc,
		 printerinventory.opacity,
		 printerinventory.matsuppliercode,
		 printerinventory.onhandavailable,
		 printerinventory.onhandallocated,
		 printerinventory.priceperhundred,
		 printerinventory.onhandvalue,
		 printerinventory.brightness,
		 printerinventory.activeind,
		 printerinventory.mweightfactor
	FROM printerinventory LEFT OUTER JOIN gentbl45 b ON printerinventory.rollsize = b.DATACODE 
	LEFT OUTER JOIN gentbl46 c ON printerinventory.sheetsize = c.DATACODE 
	LEFT OUTER JOIN gentbl47 d ON printerinventory.basisweight = d.DATACODE,   
         vendor,   
         gentbl27 a,   
         gentbl66 e  
   WHERE ( printerinventory.vendorkey = vendor.vendorkey ) and  
         ( printerinventory.color = e.DATACODE )    



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[printerinventory1]  TO [public]
GO


