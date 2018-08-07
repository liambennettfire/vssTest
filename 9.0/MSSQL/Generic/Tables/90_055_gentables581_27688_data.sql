-- P&L Detail Sections conversion from pldetails

DECLARE @v_datacode		int,
        @v_detailtype varchar(50),
        @v_detailtext varchar(50),
				@v_sortorder	int,
        @v_activeind  tinyint,
        @v_deletestatus char(1),
        @v_tablemnemonic  VARCHAR(40),
        @v_datadescshort  VARCHAR(20)

begin
    
  DECLARE cur CURSOR FOR
  SELECT detailtype, detailtext, sortorder, activeind 
   FROM pldetails
   ORDER BY sortorder 
		
	OPEN cur
	
	FETCH NEXT FROM cur INTO
	@v_detailtype,@v_detailtext,@v_sortorder,@v_activeind

  SELECT @v_datacode = 0
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @v_datacode = @v_datacode + 1

    IF @v_activeind = 1 BEGIN
       SET @v_deletestatus = 'N'
    END
    ELSE BEGIN
      SET @v_deletestatus = 'Y'
    END

    SET @v_tablemnemonic = 'PLSECT'

    SELECT @v_datadescshort =
      CASE @v_detailtext
         WHEN 'Market Share' THEN 'Market Share'
         WHEN 'Sales Units' THEN 'Sales Units'
         WHEN 'Royalty' THEN 'Royalty'
         WHEN 'Marketing Costs' THEN 'Marketing Costs'
         WHEN 'Marketing Comp Copies' THEN 'Comp Copies'
         WHEN 'Subrights Income' THEN 'Subrights Income'
         WHEN 'Miscellaneous Income' THEN 'Misc. Income'
         WHEN 'Miscellaneous Costs' THEN 'Misc. Costs'
         WHEN 'Total Units Required' THEN 'Total Units Req.'
         WHEN 'Production Qty By Year' THEN 'Prod. Qty By Year'
         WHEN 'Production Specifications' THEN 'Prod. Specs'
         WHEN 'Production Costs By Prtg' THEN 'Prod. Costs By Prtg'
         WHEN 'Production Costs By Year' THEN 'Prod. Costs By Year'
         ELSE 'Comments'
      END

    print '@v_detailtext'
   print @v_detailtext
   print '@v_datadescshort'
   print @v_datadescshort


  	INSERT INTO gentables 
     (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
      numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
      eloquencefieldtag,alternatedesc1,alternatedesc2)
      VALUES (581,@v_datacode,@v_detailtext,@v_deletestatus,NULL,@v_sortorder,@v_tablemnemonic,@v_tablemnemonic,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,1,1,0,0,1,0,
      'N/A',NULL,NULL)
    
    UPDATE gentables_ext
       SET gentext1 = @v_detailtype,
           gentext2 = @v_detailtext,
           lastmaintdate = getdate()     
     WHERE tableid = 581
       AND datacode = @v_datacode
		
		FETCH NEXT FROM cur INTO
	    @v_detailtype,@v_detailtext,@v_sortorder,@v_activeind
	END
	
	CLOSE cur
	DEALLOCATE cur

end  
go