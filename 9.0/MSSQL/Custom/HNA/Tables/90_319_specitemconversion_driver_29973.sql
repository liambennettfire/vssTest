--start fresh
delete from taqversionspecitems where taqversionspecategorykey not in (select taqversionspecategorykey from taqversionspeccategory where taqprojectkey in (select taqprojectkey from taqproject where taqprojecttype=22))
go
delete from taqversionspeccategory where taqprojectkey not in (select taqprojectkey from taqproject where taqprojecttype=22) 
go
delete from taqversionformatyear where taqprojectkey not in (select taqprojectkey from taqproject where taqprojecttype=22) 
go
delete from taqversionformat where taqprojectkey not in (select taqprojectkey from taqproject where taqprojecttype=22) 
go
delete from taqplstage where taqprojectkey not in (select taqprojectkey from taqproject where taqprojecttype=22) 
go
delete from taqversion where taqprojectkey not in (select taqprojectkey from taqproject where taqprojecttype=22) 
go
delete from qpl_multicomponent 
go

set nocount on
go
IF OBJECT_ID('#Titlelist') is not null
drop table #Titlelist
go
IF OBJECT_ID('#specsynclist') is not null
drop table #specsynclist
go
CREATE TABLE #Titlelist(
rowid int identity (1,1),
bookkey int,
printingkey int,
specind int)

DECLARE 
@i_printingkey int,
@i_bookkey int,
@i_numberrecords int, 
@i_rowcount int

INSERT INTO #Titlelist (bookkey,printingkey,specind)
--select 5950480,3
--select 1020961,1
select  p.bookkey, p.printingkey, p.specind from printing p  --top 1000 
inner join taqprojecttitle t on p.bookkey=t.bookkey and p.printingkey=t.printingkey and p.specind=1
inner join coretitleinfo c on p.bookkey=c.bookkey and p.printingkey=c.printingkey and c.mediatypecode is not null and c.mediatypesubcode is not null
and t.taqprojectkey not in (select taqprojectkey from taqversion)
	
SET @i_NumberRecords = @@ROWCOUNT
SET @i_RowCount = 1

WHILE @i_rowcount <= @i_numberrecords
BEGIN
 SELECT @i_bookkey = bookkey, @i_printingkey =printingkey 
 FROM #titlelist
 WHERE rowid = @i_rowcount 
 
 		
			--print @i_bookkey
			--print @i_printingkey 
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'printing', 'FBTCONV'
			--print 'printing done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'bindingspecs', 'FBTCONV'
			--print 'bindingspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'bindcolor', 'FBTCONV'  
			--print 'bindcolor done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'textspecs', 'FBTCONV'
			--print 'textspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'textcolor', 'FBTCONV'
			--print 'textcolor done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'illus', 'FBTCONV'
			--print 'illu done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'materialspecs', 'FBTCONV'
			--print 'materialspecs done'			
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'coverspecs', 'FBTCONV'
			--print 'coverspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'covercolor', 'FBTCONV'
			--print 'covercolor done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'secondcoverspecs', 'FBTCONV'
			--print 'coverspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'secondcovcolor', 'FBTCONV'
			--print 'covercolor done'	
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'coverinsertspecs', 'FBTCONV'
			--print 'coverspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'covinsertcolor', 'FBTCONV'
			--print 'covercolor done'			
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'casespecs', 'FBTCONV'
			--print 'casespecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'sidestamp', 'FBTCONV'
			--print 'sidestamp done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'spinestamp', 'FBTCONV'
			--print 'spinestamp done'			
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'jacketspecs', 'FBTCONV'
			--print 'jacketspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'jackcolor', 'FBTCONV'
			--print 'jackcolr done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'jacketfoilcolors', 'FBTCONV'
			--print 'jacketfoilcolor done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'component', 'FBTCONV'
			--print 'component done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'endpapers', 'FBTCONV'
			--print 'endpapers done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'endpcolor', 'FBTCONV'
			--print 'endpcolor done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'printpackagingspecs', 'FBTCONV'
			--print 'printpackagingspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'cdromspecs', 'FBTCONV'
			--print 'cdromspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'cardspecs', 'FBTCONV'
			--print 'cardspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'posterspecs', 'FBTCONV'
			--print 'posterspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'stickerspecs', 'FBTCONV'
			--print 'stickerspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'assemblyspecs', 'FBTCONV'
			--print 'assemblyspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'kitspecs', 'FBTCONV'
			--print 'kitspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'labelspecs', 'FBTCONV'
			--print 'labelspecs done'
			exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'nonbookspecs', 'FBTCONV'
			--print 'nonbookspecs done'
			
 SET @i_RowCount = @i_RowCount + 1
END

truncate table #Titlelist

--now do those without specs
INSERT INTO #Titlelist (bookkey,printingkey,specind)
--select 5950480,3
--select 1020961,1
select  p.bookkey, p.printingkey, p.specind from printing p  --top 1000
inner join taqprojecttitle t on p.bookkey=t.bookkey and p.printingkey=t.printingkey and p.specind=0
inner join coretitleinfo c on p.bookkey=c.bookkey and p.printingkey=c.printingkey and c.mediatypecode is not null and c.mediatypesubcode is not null
and t.taqprojectkey not in (select taqprojectkey from taqversion)
	
SET @i_NumberRecords = @@ROWCOUNT
SET @i_RowCount = 1

WHILE @i_rowcount <= @i_numberrecords
BEGIN
 SELECT @i_bookkey = bookkey, @i_printingkey =printingkey 
 FROM #titlelist
 WHERE rowid = @i_rowcount 

	exec dbo.qpl_sync_tables2specitems @i_bookkey, @i_printingkey, 'printing', 'FBTCONV'
 
 SET @i_RowCount = @i_RowCount + 1
END

DROP TABLE #Titlelist

set nocount off
go
			