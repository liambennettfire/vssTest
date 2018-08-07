IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_book') AND type = 'TR')
	DROP TRIGGER dbo.core_book
GO

CREATE TRIGGER core_book ON book
FOR INSERT, UPDATE AS
IF UPDATE (title) OR 
	UPDATE (shorttitle) OR 
	UPDATE (subtitle) OR
	UPDATE (titlestatuscode) OR 
	UPDATE (titletypecode) OR 
	UPDATE (linklevelcode) OR 
	UPDATE (standardind) OR 
	UPDATE (workkey) OR
	UPDATE (sendtoeloind) OR
  UPDATE (usageclasscode)

BEGIN
	DECLARE @v_bookkey 	INT,
		@v_printingkey	INT,
		@v_title	VARCHAR(255),
		@v_subtitle VARCHAR(255),
		@v_shorttitle VARCHAR(50),
		@v_titlestatuscode INT,
		@v_titletypecode INT,
		@v_linklevelcode INT,
		@v_standardind CHAR(1),
		@v_workkey INT,
		@v_sendtoeloind INT,
    		@v_usageclasscode INT,
    		@v_usageclassdesc VARCHAR(80)
	

    DECLARE bookkey_cur CURSOR FOR
		SELECT i.bookkey,i.title,i.subtitle,i.shorttitle,i.titlestatuscode,i.titletypecode,i.linklevelcode, i.standardind, 
			i.workkey,i.sendtoeloind,i.usageclasscode
		FROM inserted i

     OPEN bookkey_cur

     FETCH NEXT FROM bookkey_cur INTO @v_bookkey,@v_title,@v_subtitle,@v_shorttitle,@v_titlestatuscode,@v_titletypecode,@v_linklevelcode,@v_standardind,@v_workkey,@v_sendtoeloind,@v_usageclasscode 

     WHILE (@@FETCH_STATUS = 0)   /* LOOP */
     BEGIN
		/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
		EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1
		
	  IF @v_usageclasscode > 0
		 SELECT @v_usageclassdesc = datadesc
		 FROM subgentables
		 WHERE tableid = 550 AND datacode = 1 AND datasubcode = @v_usageclasscode
	  ELSE
		 SET @v_usageclasscode = 0
	
		UPDATE coretitleinfo
		SET title = @v_title, subtitle = @v_subtitle, shorttitle = @v_shorttitle,
			titlestatuscode = @v_titlestatuscode, titletypecode = @v_titletypecode,
			linklevelcode = @v_linklevelcode, standardind = @v_standardind, 
			workkey = @v_workkey, sendtoeloind = @v_sendtoeloind, itemtypecode = 1, 
		 usageclasscode = @v_usageclasscode, usageclassdesc = @v_usageclassdesc 
		WHERE bookkey = @v_bookkey

        FETCH NEXT FROM bookkey_cur INTO @v_bookkey,@v_title,@v_subtitle,@v_shorttitle,@v_titlestatuscode,@v_titletypecode,@v_linklevelcode,@v_standardind,@v_workkey,@v_sendtoeloind,@v_usageclasscode 
      END

      CLOSE bookkey_cur
      DEALLOCATE bookkey_cur
END

GO