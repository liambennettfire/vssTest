SET NOCOUNT ON

DECLARE
  @v_count INT,
  @v_taqprojectkey INT,
  @v_columnkey INT
  

BEGIN
	DECLARE cur_cleanup CURSOR FOR
	 select distinct taqprojectkey 
	   from taqproject
	  where taqprojectkey in (select distinct gpokey from gposection where gpokey not in (select gpokey from gpo))	
	  order by taqprojectkey ASC
	  
	  
	OPEN cur_cleanup
  
	FETCH NEXT FROM cur_cleanup INTO @v_taqprojectkey

	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
	    print 'taqprojectkey'
	    print @v_taqprojectkey
		select @v_count = COUNT(*) from taqprojecttask where taqprojectkey = @v_taqprojectkey
		if @v_count > 0 begin
			delete from taqprojecttask where taqprojectkey = @v_taqprojectkey
		end
		
		
		select @v_count = COUNT(*) from taqprojectrelationship where taqprojectkey2 = @v_taqprojectkey
		if @v_count > 0 begin
			delete from taqprojectrelationship where taqprojectkey2 = @v_taqprojectkey
		end
		
		
		select @v_count = COUNT(*) from taqproductnumbers where taqprojectkey = @v_taqprojectkey
		if @v_count > 0 begin
			delete from taqproductnumbers where taqprojectkey = @v_taqprojectkey
		end
		
		select @v_count = COUNT(*) from taqprojectorgentry where taqprojectkey = @v_taqprojectkey
		if @v_count > 0 begin
			delete from taqprojectorgentry where taqprojectkey = @v_taqprojectkey
		end
		
		select @v_count = COUNT(*) from taqprojectcontact where taqprojectkey = @v_taqprojectkey
		if @v_count > 0 begin
			delete from taqprojectcontact where taqprojectkey = @v_taqprojectkey
		end
		
		select @v_count = COUNT(*) from taqprojectcontactrole where taqprojectkey = @v_taqprojectkey
		if @v_count > 0 begin
			delete from taqprojectcontactrole where taqprojectkey = @v_taqprojectkey
		end
		
		select @v_count = COUNT(*) from taqproject where taqprojectkey = @v_taqprojectkey
		if @v_count > 0 begin
			delete from taqproject where taqprojectkey = @v_taqprojectkey
		end

		FETCH NEXT FROM cur_cleanup INTO @v_taqprojectkey
	END
	
	CLOSE cur_cleanup 
	DEALLOCATE cur_cleanup 
END
go