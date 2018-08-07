DISABLE TRIGGER core_gentables ON gentables;
go

DECLARE @v_count INT,
        @v_datacode	INT,
        @v_datadesc VARCHAR(40),
        @v_titleacq_itemtypecode	INT,
        @v_titleacq_itemtypesubcode INT,
        @v_datacode_titleacq	INT,
        @v_pltemplates_datacode	INT,
        @v_pltemplates_datasubcode INT,
        @v_datacode_pltemplates	INT,
        @v_spectemplates_datacode	INT,
        @v_spectemplates_datasubcode INT,
        @v_datacode_spectemplates	INT,
        @v_printings_datacode	INT,
        @v_printings_datasubcode INT,
        @v_datacode_printings	INT,
        @v_works_datacode	INT,
        @v_works_datasubcode INT,
        @v_datacode_works	INT,
        @v_gen1ind	INT
        


BEGIN

	UPDATE gentables SET gen1ind = 0 WHERE tableid = 521

	DECLARE projecttype_cursor CURSOR FOR
		SELECT datacode FROM gentables WHERE tableid=521 ORDER BY datacode

	OPEN projecttype_cursor;

	FETCH NEXT FROM projecttype_cursor INTO @v_datacode

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @v_datadesc = datadesc FROM gentables WHERE tableid=521 AND datacode = @v_datacode
		
		IF @v_datadesc = 'Whole Book Purchase' OR @v_datadesc = 'Composition' OR @v_datadesc = 'Miscellaneous' BEGIN
			UPDATE gentables SET gen1ind = 1 WHERE tableid = 521 AND datacode = @v_datacode AND gen1ind = 0
			GOTO READ_NEXT;
		END
		
		SELECT @v_gen1ind = gen1ind FROM gentables WHERE tableid = 521 AND datacode = @v_datacode
		IF @v_gen1ind = 0 BEGIN
			--Itemtype filtering for Title Acquisitons on Project Type		
			SELECT @v_titleacq_itemtypecode = datacode, @v_titleacq_itemtypesubcode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1 --Title Aacquisition
			SELECT @v_count = 0
			
			SELECT @v_count = COUNT(*) FROM gentablesitemtype WHERE tableid = 521 AND itemtypecode = @v_titleacq_itemtypecode AND itemtypesubcode = @v_titleacq_itemtypesubcode
			   AND datacode = @v_datacode
			
			IF @v_count = 1 BEGIN
				UPDATE gentables SET gen1ind = 1 WHERE tableid = 521 AND datacode = @v_datacode AND gen1ind = 0
				GOTO READ_NEXT;
			END
			
			--Itemtype filtering for P&L Templates on Project Type
			SELECT @v_pltemplates_datacode = datacode, @v_pltemplates_datasubcode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 29 --User Admin/P&L Templates
			SELECT @v_count = 0
			
			SELECT @v_count = COUNT(*) FROM gentablesitemtype WHERE tableid = 521 AND itemtypecode = @v_pltemplates_datacode AND itemtypesubcode = @v_pltemplates_datasubcode
			   AND datacode = @v_datacode
			
			IF @v_count = 1 BEGIN
				UPDATE gentables SET gen1ind = 1 WHERE tableid = 521 AND datacode = @v_datacode AND gen1ind = 0
				GOTO READ_NEXT;
			END
			
			--Itemtype filtering for Spec Templates on Project Type
			SELECT @v_spectemplates_datacode = datacode, @v_spectemplates_datasubcode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 44 --User Admin/Spec Templates
			SELECT @v_count = 0
			
			SELECT @v_count = COUNT(*) FROM gentablesitemtype WHERE tableid = 521 AND itemtypecode = @v_spectemplates_datacode AND itemtypesubcode = @v_spectemplates_datasubcode
			   AND datacode = @v_datacode
			
			IF @v_count = 1 BEGIN
				UPDATE gentables SET gen1ind = 1 WHERE tableid = 521 AND datacode = @v_datacode AND gen1ind = 0
				GOTO READ_NEXT;
			END
			
			--Itemtype filtering for Printings on Project Type
			SELECT @v_printings_datacode = datacode, @v_printings_datasubcode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 40 --Printings
			SELECT @v_count = 0
			
			SELECT @v_count = COUNT(*) FROM gentablesitemtype WHERE tableid = 521 AND itemtypecode = @v_printings_datacode AND itemtypesubcode = @v_printings_datasubcode
			   AND datacode = @v_datacode
			
			IF @v_count = 1 BEGIN
				UPDATE gentables SET gen1ind = 1 WHERE tableid = 521 AND datacode = @v_datacode AND gen1ind = 0
				GOTO READ_NEXT;
			END
			
			--Itemtype filtering for Works on Project Type
			SELECT @v_works_datacode = datacode, @v_works_datasubcode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28 --Works
			SELECT @v_count = 0
			
			SELECT @v_count = COUNT(*) FROM gentablesitemtype WHERE tableid = 521 AND itemtypecode = @v_works_datacode AND itemtypesubcode = @v_works_datasubcode
			   AND datacode = @v_datacode
			
			IF @v_count = 1 BEGIN
				UPDATE gentables SET gen1ind = 1 WHERE tableid = 521 AND datacode = @v_datacode AND gen1ind = 0
				GOTO READ_NEXT;
			END
		END

		READ_NEXT:
			FETCH NEXT FROM projecttype_cursor INTO @v_datacode
	END
	
	CLOSE projecttype_cursor;
	DEALLOCATE projecttype_cursor;
END
go

ENABLE TRIGGER core_gentables ON gentables;
go