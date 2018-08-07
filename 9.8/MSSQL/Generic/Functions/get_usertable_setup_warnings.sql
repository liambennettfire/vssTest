if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].get_usertable_setup_warnings') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].get_usertable_setup_warnings
GO


CREATE FUNCTION dbo.get_usertable_setup_warnings()

RETURNS @usertablesetupwarnings TABLE(
		tableid INT,
		datacode INT,
		datasubcode INT,
		warningmessage VARCHAR(400)		
	)
AS
BEGIN
    DECLARE @v_count  INT,
            @v_count2 INT,
            @v_count3 INT,
            @v_datacode INT,
            @v_datasubcode  INT,
            @v_datadesc VARCHAR(120),
            @v_warningmessage VARCHAR(400)

    DECLARE gentables_cur CURSOR fast_forward FOR
      SELECT datacode, datadesc 
        FROM gentables 
       WHERE tableid = 131

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 131 Territories
    SELECT @v_count = count(*)
      FROM gentables
     WHERE tableid = 131
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE gentables131_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 131  
           AND deletestatus in ('Y','y')

      OPEN gentables131_cur 

      FETCH gentables131_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Territory ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (131,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables131_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables131_cur
			DEALLOCATE gentables131_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 131
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE gentables131_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 131  
           AND exporteloquenceind = 0

      OPEN gentables131_cur 

      FETCH gentables131_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Territory ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (131,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables131_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables131_cur
			DEALLOCATE gentables131_cur 
    END

    SELECT @v_count3 = count(*)
      FROM gentables
     WHERE tableid = 131
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE gentables131_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 131  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN gentables131_cur 

      FETCH gentables131_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Territory ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (131,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables131_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables131_cur
			DEALLOCATE gentables131_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 318 Language
    SELECT @v_count = count(*)
      FROM gentables
     WHERE tableid = 318
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE gentables318_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 318  
           AND deletestatus in ('Y','y')

      OPEN gentables318_cur 

      FETCH gentables318_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Language ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (318,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables318_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables318_cur
			DEALLOCATE gentables318_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 131
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE gentables318_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 318  
           AND exporteloquenceind = 0

      OPEN gentables318_cur 

      FETCH gentables318_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Language ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (318,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables318_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables318_cur
			DEALLOCATE gentables318_cur 
    END

    SELECT @v_count3 = count(*)
      FROM gentables
     WHERE tableid = 318
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE gentables318_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 318  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN gentables318_cur 

      FETCH gentables318_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Language ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (318,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables318_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables318_cur
			DEALLOCATE gentables318_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 428 Sales Restriction
    SELECT @v_count = count(*)
      FROM gentables
     WHERE tableid = 428
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE gentables428_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 428  
           AND deletestatus in ('Y','y')

      OPEN gentables428_cur 

      FETCH gentables428_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Sales Restriction ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (428,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables428_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables428_cur
			DEALLOCATE gentables428_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 428
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE gentables428_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 428  
           AND exporteloquenceind = 0

      OPEN gentables428_cur 

      FETCH gentables428_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Sales Restriction ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (428,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables428_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables428_cur
			DEALLOCATE gentables428_cur 
    END

    SELECT @v_count3 = count(*)
      FROM gentables
     WHERE tableid = 428
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE gentables428_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 428  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN gentables428_cur 

      FETCH gentables428_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Sales Restriction ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (428,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables428_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables428_cur
			DEALLOCATE gentables428_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 460 Audience
    SELECT @v_count = count(*)
      FROM gentables
     WHERE tableid = 460
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE gentables460_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 460  
           AND deletestatus in ('Y','y')

      OPEN gentables460_cur 

      FETCH gentables460_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Audience ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (460,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables460_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables460_cur
			DEALLOCATE gentables460_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 460
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE gentables460_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 460  
           AND exporteloquenceind = 0

      OPEN gentables460_cur 

      FETCH gentables460_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Audience ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (460,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables460_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables460_cur
			DEALLOCATE gentables460_cur 
    END

    SELECT @v_count3 = count(*)
      FROM gentables
     WHERE tableid = 460
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE gentables460_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 460  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN gentables460_cur 

      FETCH gentables460_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Audience ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (460,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables460_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables460_cur
			DEALLOCATE gentables460_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 314 BISAC Status
    SELECT @v_count = count(*)
      FROM gentables
     WHERE tableid = 314
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE gentables314_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 314  
           AND deletestatus in ('Y','y')

      OPEN gentables314_cur 

      FETCH gentables314_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Status ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (314,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables314_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables314_cur
			DEALLOCATE gentables314_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 314
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE gentables314_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 314  
           AND exporteloquenceind = 0

      OPEN gentables314_cur 

      FETCH gentables314_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Status ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (314,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables314_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables314_cur
			DEALLOCATE gentables314_cur 
    END

    SELECT @v_count3 = count(*)
      FROM gentables
     WHERE tableid = 314
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE gentables314_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 314  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN gentables314_cur 

      FETCH v INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Status ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (314,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables314_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables314_cur
			DEALLOCATE gentables314_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 314 BISAC Status
    SELECT @v_count = count(*)
      FROM subgentables
     WHERE tableid = 314
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE subgentables314_cur CURSOR fast_forward FOR
        SELECT datacode,datasubcode, datadesc 
          FROM subgentables
         WHERE tableid = 314  
           AND deletestatus in ('Y','y')

      OPEN subgentables314_cur 

      FETCH subgentables314_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Status ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (314,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables314_cur INTO @v_datacode,@v_datasubcode,@v_datadesc
      END
      CLOSE subgentables314_cur
			DEALLOCATE subgentables314_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 314
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE subgentables314_cur CURSOR fast_forward FOR
        SELECT datacode,datasubcode, datadesc 
          FROM subgentables 
         WHERE tableid = 314  
           AND exporteloquenceind = 0

      OPEN subgentables314_cur 

      FETCH subgentables314_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Status ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (314,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables314_cur INTO @v_datacode,@v_datasubcode,@v_datadesc
      END
      CLOSE subgentables314_cur
			DEALLOCATE subgentables314_cur 
    END

    SELECT @v_count3 = count(*)
      FROM subgentables
     WHERE tableid = 314
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE subgentables314cur CURSOR fast_forward FOR
        SELECT datacode, datasubcode,datadesc 
          FROM subgentables 
         WHERE tableid = 314  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN subgentables314_cur 

      FETCH subgentables314_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Status ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (314,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables314_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE subgentables314_cur
			DEALLOCATE subgentables314_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 339 BISAC Subject
    SELECT @v_count = count(*)
      FROM gentables
     WHERE tableid = 339
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE gentables339_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 339  
           AND deletestatus in ('Y','y')

      OPEN gentables339_cur 

      FETCH gentables339_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Subject ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (339,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables339_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables339_cur
			DEALLOCATE gentables339_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 339
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE gentables339_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 339  
           AND exporteloquenceind = 0

      OPEN gentables339_cur 

      FETCH gentables339_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Subject ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (339,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables339_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables339_cur
			DEALLOCATE gentables339_cur 
    END

    SELECT @v_count3 = count(*)
      FROM gentables
     WHERE tableid = 339
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE gentables339_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 339  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN gentables339_cur 

      FETCH gentables339_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Subject ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (339,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables339_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables339_cur
			DEALLOCATE gentables339_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 314 BISAC Status
    SELECT @v_count = count(*)
      FROM subgentables
     WHERE tableid = 339
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE subgentables339_cur CURSOR fast_forward FOR
        SELECT datacode,datasubcode, datadesc 
          FROM subgentables
         WHERE tableid = 339  
           AND deletestatus in ('Y','y')

      OPEN subgentables339_cur 

      FETCH subgentables339_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Subject ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (339,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables339_cur INTO @v_datacode,@v_datasubcode,@v_datadesc
      END
      CLOSE subgentables339_cur
			DEALLOCATE subgentables339_cur 
    END

    SELECT @v_count2 = count(*)
      FROM subgentables
     WHERE tableid = 339
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE subgentables339_cur CURSOR fast_forward FOR
        SELECT datacode,datasubcode, datadesc 
          FROM subgentables 
         WHERE tableid = 314  
           AND exporteloquenceind = 0

      OPEN subgentables339_cur 

      FETCH subgentables339_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Subject ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (339,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables339_cur INTO @v_datacode,@v_datasubcode,@v_datadesc
      END
      CLOSE subgentables339_cur
			DEALLOCATE subgentables339_cur 
    END

    SELECT @v_count3 = count(*)
      FROM subgentables
     WHERE tableid = 314
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE subgentables339_cur CURSOR fast_forward FOR
        SELECT datacode, datasubcode,datadesc 
          FROM subgentables 
         WHERE tableid = 314  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN subgentables339_cur 

      FETCH subgentables339_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'BISAC Subject ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (314,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables339_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE subgentables339_cur
			DEALLOCATE subgentables339_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 558 Eloquence Enabled Categories
    SELECT @v_count = count(*)
      FROM gentables
     WHERE tableid = 558
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE gentables558_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 558  
           AND deletestatus in ('Y','y')

      OPEN gentables558_cur 

      FETCH gentables558_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Eloquence Enabled Categories ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (558,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables558_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables558_cur
			DEALLOCATE gentables558_cur 
    END

    SELECT @v_count2 = count(*)
      FROM gentables
     WHERE tableid = 558
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE gentables558_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 558  
           AND exporteloquenceind = 0

      OPEN gentables558_cur 

      FETCH gentables558_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Eloquence Enabled Categories ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (558,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables558_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables558_cur
			DEALLOCATE gentables558_cur 
    END

    SELECT @v_count3 = count(*)
      FROM gentables
     WHERE tableid = 558
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE gentables558_cur CURSOR fast_forward FOR
        SELECT datacode, datadesc 
          FROM gentables 
         WHERE tableid = 558  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN gentables558_cur 

      FETCH gentables558_cur INTO @v_datacode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Eloquence Enabled Categories ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (558,@v_datacode,NULL,@v_warningmessage)

        FETCH gentables558_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE gentables558_cur
			DEALLOCATE gentables558_cur 
    END

    SET @v_count = 0
    SET @v_count2 = 0
    SET @v_count3 = 0
    -- 314 BISAC Status
    SELECT @v_count = count(*)
      FROM subgentables
     WHERE tableid = 558
       AND deletestatus in ('Y','y')

    IF @v_count > 0 BEGIN
      DECLARE subgentables558_cur CURSOR fast_forward FOR
        SELECT datacode,datasubcode, datadesc 
          FROM subgentables
         WHERE tableid = 558  
           AND deletestatus in ('Y','y')

      OPEN subgentables558_cur 

      FETCH subgentables558_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Eloquence Enabled Categories ' + rtrim(@v_datadesc) + ' set to inactive.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (558,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables558_cur INTO @v_datacode,@v_datasubcode,@v_datadesc
      END
      CLOSE subgentables558_cur
			DEALLOCATE subgentables558_cur 
    END

    SELECT @v_count2 = count(*)
      FROM subgentables
     WHERE tableid = 558
       AND exporteloquenceind = 0

    IF @v_count2 > 0 BEGIN
      DECLARE subgentables558_cur CURSOR fast_forward FOR
        SELECT datacode,datasubcode, datadesc 
          FROM subgentables 
         WHERE tableid = 558  
           AND exporteloquenceind = 0

      OPEN subgentables558_cur 

      FETCH subgentables558_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Eloquence Enabled Categories ' + rtrim(@v_datadesc) + ' not set to export to eloquence.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (558,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables558_cur INTO @v_datacode,@v_datasubcode,@v_datadesc
      END
      CLOSE subgentables558_cur
			DEALLOCATE subgentables558_cur 
    END

    SELECT @v_count3 = count(*)
      FROM subgentables
     WHERE tableid = 558
       AND (eloquencefieldtag is null OR eloquencefieldtag = '')

    IF @v_count3 > 0 BEGIN
      DECLARE subgentables558_cur CURSOR fast_forward FOR
        SELECT datacode, datasubcode,datadesc 
          FROM subgentables 
         WHERE tableid = 558  
           AND (eloquencefieldtag is null OR eloquencefieldtag = '')

      OPEN subgentables558_cur 

      FETCH subgentables558_cur INTO @v_datacode,@v_datasubcode,@v_datadesc

      WHILE @@fetch_status = 0 BEGIN
        SET @v_warningmessage = 'Eloquence Enabled Categories ' + rtrim(@v_datadesc) + ' is missing eloquence field tag.'

        INSERT INTO @usertablesetupwarnings
         (tableid,datacode,datasubcode,warningmessage)
        VALUES (558,@v_datacode,@v_datasubcode,@v_warningmessage)

        FETCH subgentables558_cur INTO @v_datacode,@v_datadesc
      END
      CLOSE subgentables558_cur
			DEALLOCATE subgentables558_cur 
    END


    RETURN











END