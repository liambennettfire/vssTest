--set the status for finished printings --5 minutes
BEGIN
declare @i_finishedcode int,
@i_maxdatacode int

select @i_maxdatacode = max(datacode)+1 from gentables where tableid=522

IF not exists (select * from gentables where tableid=522 and datadesc='Finished')
begin
	insert into gentables (tableid,datacode,datadesc,deletestatus,sortorder, tablemnemonic,datadescshort,lastuserid,lastmaintdate,gen1ind,lockbyqsiind,lockbyeloquenceind)
	select 522,@i_maxdatacode,'Finished','N',@i_maxdatacode,'ProjectStatus','Finished','HNAV9',GETDATE(),0,0,0
	--select * from gentablesitemtype  where tableid=522
	exec [dbo].[insert_gentablesitemtype_from_gentables] 522,@i_maxdatacode,14,1,'HNAV9'
end

select @i_finishedcode = datacode from gentables where datadesc='Finished' and tableid=522

set nocount on
update taqproject
set taqprojectstatuscode= @i_finishedcode
from taqproject t inner join taqprojectprinting_view tv on t.taqprojectkey=tv.taqprojectkey
inner join printing p on tv.bookkey=p.bookkey and tv.printingkey=p.printingkey 	and p.statuscode=2
set nocount off
END

--41 minutes
--this script inserts tasks required for active printings so that when a PO project is created, these dates are automatically available (to simulate the desktop po header)
--these tasks are on the printing because they are shared across POs and may even appear in the spec details section of a PO report 
BEGIN
set nocount on
DECLARE 
	@i_taskviewkey int,
	@i_datetypecode int,
	@i_maxkey int,
	@i_finished int
	
	select @i_finished = datacode from gentables where datadesc='Finished' and tableid=522
	
	--get the taskviewkey for the autogen tasks for printings
	select @i_taskviewkey =taskviewkey from taskview where taskviewdesc = 'PO Related Printing Dates - Component PO'
	
	IF coalesce(@i_taskviewkey,0)<>0
	BEGIN	
		--now loop through each task on that view and insert them into the title\printing if the task doesn't already exist
		DECLARE taqprojectprinting_view_cur CURSOR FOR
			SELECT DISTINCT datetypecode from taskviewdatetype where taskviewkey = @i_taskviewkey
				
		OPEN taqprojectprinting_view_cur

		FETCH NEXT FROM taqprojectprinting_view_cur INTO @i_datetypecode

		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			
			--for each task, insert into any title that doesn't have it, use the partition method to create an insert statement without having to generate a unique key w/ get_next_key
			INSERT INTO taqprojecttask (taqtaskkey, datetypecode, taqprojectkey,bookkey,printingkey, scheduleind, keyind, sortorder,lastuserid,lastmaintdate)
			SELECT row_number() over(Partition by 1 order by t.taqtaskkey) + (Select generickey from keys), 			
			@i_datetypecode, NULL, tv.bookkey, tv.printingkey,1, 1, 1, 'HNAV9', GETDATE()		 			
			FROM  taqprojectprinting_view tv inner join taqversionformat tvf on tvf.taqprojectkey=tv.taqprojectkey
			inner join taqproject tp on tv.taqprojectkey =tp.taqprojectkey and tp.taqprojectstatuscode<>@i_finished
			left outer join taqprojecttask t on tv.taqprojectkey=t.taqprojectkey 
			where not exists (select * from taqprojecttask where bookkey=tv.bookkey and printingkey=tv.printingkey and datetypecode= @i_datetypecode)
		   	
		   	select @i_maxkey = null
			select @i_maxkey = max(taqtaskkey) from taqprojecttask 
	
			IF coalesce(@i_maxkey,0)> (select generickey from keys)
			begin
				update keys set generickey = @i_maxkey+1
			end
	    	    	    
        
		FETCH NEXT FROM taqprojectprinting_view_cur INTO @i_datetypecode
	  END

	  CLOSE taqprojectprinting_view_cur 
	  DEALLOCATE taqprojectprinting_view_cur
	END	
set nocount off	  
END	
	

	
	
	
