if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qproject_specitems_by_printingview]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[qproject_specitems_by_printingview]
GO

-- This view is no longer used - it has been replaced by the functional table dbo.qproject_get_specitems_by_printingview((@i_taqversionformatyearkey int)