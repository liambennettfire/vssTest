IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_gentables') AND type = 'TR')
	DROP TRIGGER dbo.core_gentables
GO

CREATE TRIGGER core_gentables ON gentables
FOR INSERT, UPDATE AS
IF UPDATE (datadesc) OR 
	UPDATE (datadescshort) OR 
	UPDATE (gen2ind) OR
	UPDATE (deletestatus)
	
BEGIN
	DECLARE @v_bookkey 	 INT,
		@v_printingkey		 INT,
		@v_tableid		     INT,
		@v_datacode		     INT,
		@v_datadesc		     VARCHAR(40),
		@v_datadescshort	 VARCHAR(20),
		@v_deletestatus    CHAR(1),
		@v_gen2ind		     TINYINT,
		@v_authorname	 	   VARCHAR(150),
		@v_illustratorname VARCHAR(150),
		@v_count           INT

	
	SELECT @v_tableid=i.tableid,
	       @v_datacode=i.datacode,  
	       @v_datadesc=i.datadesc,  
	       @v_datadescshort=i.datadescshort,  
	       @v_gen2ind=i.gen2ind,
	       @v_deletestatus=i.deletestatus
	FROM inserted i

	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	/*** NO NEED TO DO THIS HERE - just going to update existing rows ***/ 
	/*** EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1 ***/

	/*** Update appropriate columns ***/
	/*** Edition ***/
	IF @v_tableid = 200
    BEGIN
			select @v_count = 0
			select @v_count = count(*)
			from coretitleinfo
			where editioncode=@v_datacode
			 if @v_count > 0 begin
				UPDATE coretitleinfo
					SET editiondesc=@v_datadesc
				 WHERE editioncode=@v_datacode
			 end
	END

	/*** Bisac Status ***/
	IF @v_tableid = 314
     BEGIN
			select @v_count = 0
			select @v_count = count(*)
			from coretitleinfo
			where bisacstatuscode=@v_datacode
			 if @v_count > 0 begin
				UPDATE coretitleinfo
					SET bisacstatusdesc=@v_datadesc
				 WHERE bisacstatuscode=@v_datacode
		  end 
	END

	/*** Series ***/
	IF @v_tableid = 327
    BEGIN
		 select @v_count = 0
		select @v_count = count(*)
		from coretitleinfo
		where seriescode=@v_datacode
		if @v_count > 0 begin
			UPDATE coretitleinfo
				SET seriesdesc=@v_datadesc
			 WHERE seriescode=@v_datacode
		end
	END

	/*** Series ***/
	IF @v_tableid = 300
    BEGIN
	    select @v_count = 0
		select @v_count = count(*)
		from coretitleinfo
		where formatchildcode=@v_datacode
		if @v_count > 0 begin
			UPDATE coretitleinfo
				SET childformatdesc=@v_datadesc
			 WHERE formatchildcode=@v_datacode
		end
	END

	/*** Illustrator Indicator - authortypecode/gen2ind ***/
	IF @v_tableid = 134 AND update(gen2ind) BEGIN
		/*** Must update illustrator info for ALL books that they are involved with ***/
		DECLARE bookkey_cur CURSOR FOR
		SELECT ba.bookkey
		FROM bookauthor ba, author a, gentables g
		WHERE ba.authorkey = a.authorkey AND
			ba.authortypecode = @v_datacode AND
			g.tableid = 134 AND
			g.gen2ind = 1

		OPEN bookkey_cur

		FETCH NEXT FROM bookkey_cur 
		INTO @v_bookkey

		WHILE (@@FETCH_STATUS= 0)  /*LOOP*/
	    BEGIN
			  /*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
			  EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

			  /*** Get author and illustrator names ***/
			  EXEC CoreTitleInfo_get_author_illus_name @v_bookkey,@v_authorname OUTPUT,@v_illustratorname OUTPUT

			  /*** update coretitleinfo ***/
			  UPDATE coretitleinfo
			  SET illustratorname=@v_illustratorname
			  WHERE bookkey = @v_bookkey

			  /*** get next bookkey ***/
			  FETCH NEXT FROM bookkey_cur 
			  INTO @v_bookkey
	    END

		CLOSE bookkey_cur 
		DEALLOCATE bookkey_cur 
	END
	
	-- Need to keep Element Types (tableid 287) and Element Usage Classes (Subgentable 550/Datacode 7) in synch
	-- NOTE: Element Type datacode will equal Element Usage Class datasubcode
  IF @v_tableid = 287 BEGIN
    SELECT @v_count = count(*)
      FROM subgentables
     WHERE tableid = 550
       AND datacode = 7
       AND datasubcode = @v_datacode
    
    IF @v_count > 0 BEGIN
      -- usage class row already exists - just update descriptions
      UPDATE subgentables
         SET datadesc = @v_datadesc,
             datadescshort = @v_datadescshort,
             deletestatus = @v_deletestatus
       WHERE tableid = 550
         AND datacode = 7
         AND datasubcode = @v_datacode     
    END
    ELSE BEGIN
      -- need to add the usageclass row
      INSERT INTO subgentables 
      (tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,alldivisionsind,
       externalcode,datadescshort,lastuserid,lastmaintdate,numericdesc1,numericdesc2,bisacdatacode,subgen1ind,
       subgen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
       alternatedesc1,alternatedesc2,subgen3ind,qsicode)  
      SELECT 550,7,i.datacode,i.datadesc,i.deletestatus,NULL,i.sortorder,'SearchItem',NULL,NULL,
             i.datadescshort,i.lastuserid,getdate(),NULL,NULL,NULL,NULL,NULL,0,0,1,0,NULL,NULL,NULL,NULL,NULL
        FROM inserted i  
    END
    
  END
END
GO

