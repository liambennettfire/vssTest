IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_bookrole')
BEGIN
  DROP  Procedure  datawarehouse_bookrole
END
GO

  CREATE 
    PROCEDURE dbo.datawarehouse_bookrole 
        @ware_bookkey integer,
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS
      BEGIN
          DECLARE 
            @cursor_row$ROLETYPECODE integer,
            @cursor_row$DEPTTYPECODE integer,
            @cursor_row$RESOURCEDESC varchar(255),
            @cursor_row$DISPLAYNAME varchar(100),
            @cursor_row$FIRSTNAME varchar(100),
            @cursor_row$LASTNAME varchar(100),
            @cursor_row$MIDDLENAME varchar(100),
            @cursor_row$SHORTNAME varchar(100),
            @ware_count integer,
            @ware_roleline integer,
            @ware_displayname varchar(60),
            @ware_firstname varchar(12),
            @ware_lastname varchar(20),
            @ware_resourcedesc varchar(255),
            @ware_middlename varchar(80),
            @ware_shortname varchar(10),
            @ware_displayname1 varchar(80),
            @ware_firstname1 varchar(80),
            @ware_lastname1 varchar(80),
            @ware_displayname2 varchar(80),
            @ware_firstname2 varchar(80),
            @ware_lastname2 varchar(80),
            @ware_displayname3 varchar(80),
            @ware_firstname3 varchar(80),
            @ware_lastname3 varchar(80),
            @ware_displayname4 varchar(80),
            @ware_firstname4 varchar(80),
            @ware_lastname4 varchar(80),
            @ware_displayname5 varchar(80),
            @ware_firstname5 varchar(80),
            @ware_lastname5 varchar(80),
            @ware_displayname6 varchar(80),
            @ware_firstname6 varchar(80),
            @ware_lastname6 varchar(80),
            @ware_displayname7 varchar(80),
            @ware_firstname7 varchar(80),
            @ware_lastname7 varchar(80),
            @ware_displayname8 varchar(80),
            @ware_firstname8 varchar(80),
            @ware_lastname8 varchar(80),
            @ware_displayname9 varchar(80),
            @ware_firstname9 varchar(80),
            @ware_lastname9 varchar(80),
            @ware_displayname10 varchar(80),
            @ware_firstname10 varchar(80),
            @ware_lastname10 varchar(80),
            @ware_displayname11 varchar(80),
            @ware_firstname11 varchar(80),
            @ware_lastname11 varchar(80),
            @ware_displayname12 varchar(80),
            @ware_firstname12 varchar(80),
            @ware_lastname12 varchar(80),
            @ware_displayname13 varchar(80),
            @ware_firstname13 varchar(80),
            @ware_lastname13 varchar(80),
            @ware_displayname14 varchar(80),
            @ware_firstname14 varchar(80),
            @ware_lastname14 varchar(80),
            @ware_displayname15 varchar(80),
            @ware_firstname15 varchar(80),
            @ware_lastname15 varchar(80),
            @ware_resourcedesc1 varchar(255),
            @ware_middlename1 varchar(80),
            @ware_shortname1 varchar(80),
            @ware_resourcedesc2 varchar(255),
            @ware_middlename2 varchar(80),
            @ware_shortname2 varchar(80),
            @ware_resourcedesc3 varchar(255),
            @ware_middlename3 varchar(80),
            @ware_shortname3 varchar(80),
            @ware_resourcedesc4 varchar(255),
            @ware_middlename4 varchar(80),
            @ware_shortname4 varchar(80),
            @ware_resourcedesc5 varchar(255),
            @ware_middlename5 varchar(80),
            @ware_shortname5 varchar(80),
            @ware_resourcedesc6 varchar(255),
            @ware_middlename6 varchar(80),
            @ware_shortname6 varchar(80),
            @ware_resourcedesc7 varchar(255),
            @ware_middlename7 varchar(80),
            @ware_shortname7 varchar(80),
            @ware_resourcedesc8 varchar(255),
            @ware_middlename8 varchar(80),
            @ware_shortname8 varchar(80),
            @ware_resourcedesc9 varchar(255),
            @ware_middlename9 varchar(80),
            @ware_shortname9 varchar(80),
            @ware_resourcedesc10 varchar(255),
            @ware_middlename10 varchar(80),
            @ware_shortname10 varchar(80),
            @ware_resourcedesc11 varchar(255),
            @ware_middlename11 varchar(80),
            @ware_shortname11 varchar(80),
            @ware_resourcedesc12 varchar(255),
            @ware_middlename12 varchar(80),
            @ware_shortname12 varchar(80),
            @ware_resourcedesc13 varchar(255),
            @ware_middlename13 varchar(80),
            @ware_shortname13 varchar(80),
            @ware_resourcedesc14 varchar(255),
            @ware_middlename14 varchar(80),
            @ware_shortname14 varchar(80),
            @ware_resourcedesc15 varchar(255),
            @ware_middlename15 varchar(80),
            @ware_shortname15 varchar(80),
            @ware_displayname16 varchar(80),
            @ware_firstname16 varchar(80),
            @ware_lastname16 varchar(80),
            @ware_resourcedesc16 varchar(255),
            @ware_middlename16 varchar(80),
            @ware_shortname16 varchar(80),
            @ware_displayname17 varchar(80),
            @ware_firstname17 varchar(80),
            @ware_lastname17 varchar(80),
            @ware_resourcedesc17 varchar(255),
            @ware_middlename17 varchar(80),
            @ware_shortname17 varchar(80),
            @ware_displayname18 varchar(80),
            @ware_firstname18 varchar(80),
            @ware_lastname18 varchar(80),
            @ware_resourcedesc18 varchar(255),
            @ware_middlename18 varchar(80),
            @ware_shortname18 varchar(80),
            @ware_displayname19 varchar(80),
            @ware_firstname19 varchar(80),
            @ware_lastname19 varchar(80),
            @ware_resourcedesc19 varchar(255),
            @ware_middlename19 varchar(80),
            @ware_shortname19 varchar(80),
            @ware_displayname20 varchar(80),
            @ware_firstname20 varchar(80),
            @ware_lastname20 varchar(80),
            @ware_resourcedesc20 varchar(255),
            @ware_middlename20 varchar(80),
            @ware_shortname20 varchar(80),
            @ware_displayname21 varchar(80),
            @ware_firstname21 varchar(80),
            @ware_lastname21 varchar(80),
            @ware_resourcedesc21 varchar(255),
            @ware_middlename21 varchar(80),
            @ware_shortname21 varchar(80),
            @ware_displayname22 varchar(80),
            @ware_firstname22 varchar(80),
            @ware_lastname22 varchar(80),
            @ware_resourcedesc22 varchar(255),
            @ware_middlename22 varchar(80),
            @ware_shortname22 varchar(80),
            @ware_displayname23 varchar(80),
            @ware_firstname23 varchar(80),
            @ware_lastname23 varchar(80),
            @ware_resourcedesc23 varchar(255),
            @ware_middlename23 varchar(80),
            @ware_shortname23 varchar(80),
            @ware_displayname24 varchar(80),
            @ware_firstname24 varchar(80),
            @ware_lastname24 varchar(80),
            @ware_resourcedesc24 varchar(255),
            @ware_middlename24 varchar(80),
            @ware_shortname24 varchar(80),
            @ware_displayname25 varchar(80),
            @ware_firstname25 varchar(80),
            @ware_lastname25 varchar(80),
            @ware_resourcedesc25 varchar(255),
            @ware_middlename25 varchar(80),
            @ware_shortname25 varchar(80),
            @ware_displayname26 varchar(80),
            @ware_firstname26 varchar(80),
            @ware_lastname26 varchar(80),
            @ware_resourcedesc26 varchar(255),
            @ware_middlename26 varchar(80),
            @ware_shortname26 varchar(80),
            @ware_displayname27 varchar(80),
            @ware_firstname27 varchar(80),
            @ware_lastname27 varchar(80),
            @ware_resourcedesc27 varchar(255),
            @ware_middlename27 varchar(80),
            @ware_shortname27 varchar(80),
            @ware_displayname28 varchar(80),
            @ware_firstname28 varchar(80),
            @ware_lastname28 varchar(80),
            @ware_resourcedesc28 varchar(255),
            @ware_middlename28 varchar(80),
            @ware_shortname28 varchar(80),
            @ware_displayname29 varchar(80),
            @ware_firstname29 varchar(80),
            @ware_lastname29 varchar(80),
            @ware_resourcedesc29 varchar(255),
            @ware_middlename29 varchar(80),
            @ware_shortname29 varchar(80),
            @ware_displayname30 varchar(80),
            @ware_firstname30 varchar(80),
            @ware_lastname30 varchar(80),
            @ware_resourcedesc30 varchar(255),
            @ware_middlename30 varchar(80),
            @ware_shortname30 varchar(80),
            @ware_displayname31 varchar(80),
            @ware_firstname31 varchar(80),
            @ware_lastname31 varchar(80),
            @ware_resourcedesc31 varchar(255),
            @ware_middlename31 varchar(80),
            @ware_shortname31 varchar(80),
            @ware_displayname32 varchar(80),
            @ware_firstname32 varchar(80),
            @ware_lastname32 varchar(80),
            @ware_resourcedesc32 varchar(255),
            @ware_middlename32 varchar(80),
            @ware_shortname32 varchar(80),
            @ware_displayname33 varchar(80),
            @ware_firstname33 varchar(80),
            @ware_lastname33 varchar(80),
            @ware_resourcedesc33 varchar(255),
            @ware_middlename33 varchar(80),
            @ware_shortname33 varchar(80),
            @ware_displayname34 varchar(80),
            @ware_firstname34 varchar(80),
            @ware_lastname34 varchar(80),
            @ware_resourcedesc34 varchar(255),
            @ware_middlename34 varchar(80),
            @ware_shortname34 varchar(80),
            @ware_displayname35 varchar(80),
            @ware_firstname35 varchar(80),
            @ware_lastname35 varchar(80),
            @ware_resourcedesc35 varchar(255),
            @ware_middlename35 varchar(80),
            @ware_shortname35 varchar(80),
            @ware_displayname36 varchar(80),
            @ware_firstname36 varchar(80),
            @ware_lastname36 varchar(80),
            @ware_resourcedesc36 varchar(255),
            @ware_middlename36 varchar(80),
            @ware_shortname36 varchar(80),
            @ware_displayname37 varchar(80),
            @ware_firstname37 varchar(80),
            @ware_lastname37 varchar(80),
            @ware_resourcedesc37 varchar(255),
            @ware_middlename37 varchar(80),
            @ware_shortname37 varchar(80),
            @ware_displayname38 varchar(80),
            @ware_firstname38 varchar(80),
            @ware_lastname38 varchar(80),
            @ware_resourcedesc38 varchar(255),
            @ware_middlename38 varchar(80),
            @ware_shortname38 varchar(80),
            @ware_displayname39 varchar(80),
            @ware_firstname39 varchar(80),
            @ware_lastname39 varchar(80),
            @ware_resourcedesc39 varchar(255),
            @ware_middlename39 varchar(80),
            @ware_shortname39 varchar(80),
            @ware_displayname40 varchar(80),
            @ware_firstname40 varchar(80),
            @ware_lastname40 varchar(80),
            @ware_resourcedesc40 varchar(255),
            @ware_middlename40 varchar(80),
            @ware_shortname40 varchar(80)          
          SET @ware_count = 1
          SET @ware_roleline = 0
          SET @ware_displayname = ''
          SET @ware_firstname = ''
          SET @ware_lastname = ''
          SET @ware_resourcedesc = ''
          SET @ware_middlename = ''
          SET @ware_shortname = ''
          SET @ware_displayname1 = ''
          SET @ware_firstname1 = ''
          SET @ware_lastname1 = ''
          SET @ware_displayname2 = ''
          SET @ware_firstname2 = ''
          SET @ware_lastname2 = ''
          SET @ware_displayname3 = ''
          SET @ware_firstname3 = ''
          SET @ware_lastname3 = ''
          SET @ware_displayname4 = ''
          SET @ware_firstname4 = ''
          SET @ware_lastname4 = ''
          SET @ware_displayname5 = ''
          SET @ware_firstname5 = ''
          SET @ware_lastname5 = ''
          SET @ware_displayname6 = ''
          SET @ware_firstname6 = ''
          SET @ware_lastname6 = ''
          SET @ware_displayname7 = ''
          SET @ware_firstname7 = ''
          SET @ware_lastname7 = ''
          SET @ware_displayname8 = ''
          SET @ware_firstname8 = ''
          SET @ware_lastname8 = ''
          SET @ware_displayname9 = ''
          SET @ware_firstname9 = ''
          SET @ware_lastname9 = ''
          SET @ware_displayname10 = ''
          SET @ware_firstname10 = ''
          SET @ware_lastname10 = ''
          SET @ware_displayname11 = ''
          SET @ware_firstname11 = ''
          SET @ware_lastname11 = ''
          SET @ware_displayname12 = ''
          SET @ware_firstname12 = ''
          SET @ware_lastname12 = ''
          SET @ware_displayname13 = ''
          SET @ware_firstname13 = ''
          SET @ware_lastname13 = ''
          SET @ware_displayname14 = ''
          SET @ware_firstname14 = ''
          SET @ware_lastname14 = ''
          SET @ware_displayname15 = ''
          SET @ware_firstname15 = ''
          SET @ware_lastname15 = ''
          SET @ware_resourcedesc1 = ''
          SET @ware_middlename1 = ''
          SET @ware_shortname1 = ''
          SET @ware_resourcedesc2 = ''
          SET @ware_middlename2 = ''
          SET @ware_shortname2 = ''
          SET @ware_resourcedesc3 = ''
          SET @ware_middlename3 = ''
          SET @ware_shortname3 = ''
          SET @ware_resourcedesc4 = ''
          SET @ware_middlename4 = ''
          SET @ware_shortname4 = ''
          SET @ware_resourcedesc5 = ''
          SET @ware_middlename5 = ''
          SET @ware_shortname5 = ''
          SET @ware_resourcedesc6 = ''
          SET @ware_middlename6 = ''
          SET @ware_shortname6 = ''
          SET @ware_resourcedesc7 = ''
          SET @ware_middlename7 = ''
          SET @ware_shortname7 = ''
          SET @ware_resourcedesc8 = ''
          SET @ware_middlename8 = ''
          SET @ware_shortname8 = ''
          SET @ware_resourcedesc9 = ''
          SET @ware_middlename9 = ''
          SET @ware_shortname9 = ''
          SET @ware_resourcedesc10 = ''
          SET @ware_middlename10 = ''
          SET @ware_shortname10 = ''
          SET @ware_resourcedesc11 = ''
          SET @ware_middlename11 = ''
          SET @ware_shortname11 = ''
          SET @ware_resourcedesc12 = ''
          SET @ware_middlename12 = ''
          SET @ware_shortname12 = ''
          SET @ware_resourcedesc13 = ''
          SET @ware_middlename13 = ''
          SET @ware_shortname13 = ''
          SET @ware_resourcedesc14 = ''
          SET @ware_middlename14 = ''
          SET @ware_shortname14 = ''
          SET @ware_resourcedesc15 = ''
          SET @ware_middlename15 = ''
          SET @ware_shortname15 = ''
          SET @ware_displayname16 = ''
          SET @ware_firstname16 = ''
          SET @ware_lastname16 = ''
          SET @ware_resourcedesc16 = ''
          SET @ware_middlename16 = ''
          SET @ware_shortname16 = ''
          SET @ware_displayname17 = ''
          SET @ware_firstname17 = ''
          SET @ware_lastname17 = ''
          SET @ware_resourcedesc17 = ''
          SET @ware_middlename17 = ''
          SET @ware_shortname17 = ''
          SET @ware_displayname18 = ''
          SET @ware_firstname18 = ''
          SET @ware_lastname18 = ''
          SET @ware_resourcedesc18 = ''
          SET @ware_middlename18 = ''
          SET @ware_shortname18 = ''
          SET @ware_displayname19 = ''
          SET @ware_firstname19 = ''
          SET @ware_lastname19 = ''
          SET @ware_resourcedesc19 = ''
          SET @ware_middlename19 = ''
          SET @ware_shortname19 = ''
          SET @ware_displayname20 = ''
          SET @ware_firstname20 = ''
          SET @ware_lastname20 = ''
          SET @ware_resourcedesc20 = ''
          SET @ware_middlename20 = ''
          SET @ware_shortname20 = ''
          SET @ware_displayname21 = ''
          SET @ware_firstname21 = ''
          SET @ware_lastname21 = ''
          SET @ware_resourcedesc21 = ''
          SET @ware_middlename21 = ''
          SET @ware_shortname21 = ''
          SET @ware_displayname22 = ''
          SET @ware_firstname22 = ''
          SET @ware_lastname22 = ''
          SET @ware_resourcedesc22 = ''
          SET @ware_middlename22 = ''
          SET @ware_shortname22 = ''
          SET @ware_displayname23 = ''
          SET @ware_firstname23 = ''
          SET @ware_lastname23 = ''
          SET @ware_resourcedesc23 = ''
          SET @ware_middlename23 = ''
          SET @ware_shortname23 = ''
          SET @ware_displayname24 = ''
          SET @ware_firstname24 = ''
          SET @ware_lastname24 = ''
          SET @ware_resourcedesc24 = ''
          SET @ware_middlename24 = ''
          SET @ware_shortname24 = ''
          SET @ware_displayname25 = ''
          SET @ware_firstname25 = ''
          SET @ware_lastname25 = ''
          SET @ware_resourcedesc25 = ''
          SET @ware_middlename25 = ''
          SET @ware_shortname25 = ''
          SET @ware_displayname26 = ''
          SET @ware_firstname26 = ''
          SET @ware_lastname26 = ''
          SET @ware_resourcedesc26 = ''
          SET @ware_middlename26 = ''
          SET @ware_shortname26 = ''
          SET @ware_displayname27 = ''
          SET @ware_firstname27 = ''
          SET @ware_lastname27 = ''
          SET @ware_resourcedesc27 = ''
          SET @ware_middlename27 = ''
          SET @ware_shortname27 = ''
          SET @ware_displayname28 = ''
          SET @ware_firstname28 = ''
          SET @ware_lastname28 = ''
          SET @ware_resourcedesc28 = ''
          SET @ware_middlename28 = ''
          SET @ware_shortname28 = ''
          SET @ware_displayname29 = ''
          SET @ware_firstname29 = ''
          SET @ware_lastname29 = ''
          SET @ware_resourcedesc29 = ''
          SET @ware_middlename29 = ''
          SET @ware_shortname29 = ''
          SET @ware_displayname30 = ''
          SET @ware_firstname30 = ''
          SET @ware_lastname30 = ''
          SET @ware_resourcedesc30 = ''
          SET @ware_middlename30 = ''
          SET @ware_shortname30 = ''
          SET @ware_displayname31 = ''
          SET @ware_firstname31 = ''
          SET @ware_lastname31 = ''
          SET @ware_resourcedesc31 = ''
          SET @ware_middlename31 = ''
          SET @ware_shortname31 = ''
          SET @ware_displayname32 = ''
          SET @ware_firstname32 = ''
          SET @ware_lastname32 = ''
          SET @ware_resourcedesc32 = ''
          SET @ware_middlename32 = ''
          SET @ware_shortname32 = ''
          SET @ware_displayname33 = ''
          SET @ware_firstname33 = ''
          SET @ware_lastname33 = ''
          SET @ware_resourcedesc33 = ''
          SET @ware_middlename33 = ''
          SET @ware_shortname33 = ''
          SET @ware_displayname34 = ''
          SET @ware_firstname34 = ''
          SET @ware_lastname34 = ''
          SET @ware_resourcedesc34 = ''
          SET @ware_middlename34 = ''
          SET @ware_shortname34 = ''
          SET @ware_displayname35 = ''
          SET @ware_firstname35 = ''
          SET @ware_lastname35 = ''
          SET @ware_resourcedesc35 = ''
          SET @ware_middlename35 = ''
          SET @ware_shortname35 = ''
          SET @ware_displayname36 = ''
          SET @ware_firstname36 = ''
          SET @ware_lastname36 = ''
          SET @ware_resourcedesc36 = ''
          SET @ware_middlename36 = ''
          SET @ware_shortname36 = ''
          SET @ware_displayname37 = ''
          SET @ware_firstname37 = ''
          SET @ware_lastname37 = ''
          SET @ware_resourcedesc37 = ''
          SET @ware_middlename37 = ''
          SET @ware_shortname37 = ''
          SET @ware_displayname38 = ''
          SET @ware_firstname38 = ''
          SET @ware_lastname38 = ''
          SET @ware_resourcedesc38 = ''
          SET @ware_middlename38 = ''
          SET @ware_shortname38 = ''
          SET @ware_displayname39 = ''
          SET @ware_firstname39 = ''
          SET @ware_lastname39 = ''
          SET @ware_resourcedesc39 = ''
          SET @ware_middlename39 = ''
          SET @ware_shortname39 = ''
          SET @ware_displayname40 = ''
          SET @ware_firstname40 = ''
          SET @ware_lastname40 = ''
          SET @ware_resourcedesc40 = ''
          SET @ware_middlename40 = ''
          SET @ware_shortname40 = ''
          BEGIN

            BEGIN

              DECLARE 
                @cursor_row$ROLETYPECODE$2 integer,
                @cursor_row$DEPTTYPECODE$2 integer,
                @cursor_row$RESOURCEDESC$2 varchar(8000),
                @cursor_row$DISPLAYNAME$2 varchar(8000),
                @cursor_row$FIRSTNAME$2 varchar(8000),
                @cursor_row$LASTNAME$2 varchar(8000),
                @cursor_row$MIDDLENAME$2 varchar(8000),
                @cursor_row$SHORTNAME$2 varchar(8000)              

              DECLARE 
                warehouserole CURSOR LOCAL 
                 FOR 
                  SELECT 
                      isnull(b.ROLETYPECODE, 0) AS ROLETYPECODE, 
                      isnull(b.DEPTTYPECODE, 0) AS DEPTTYPECODE, 
                      isnull(b.RESOURCEDESC, '') AS RESOURCEDESC, 
                      isnull(p.DISPLAYNAME, '') AS DISPLAYNAME, 
                      isnull(p.FIRSTNAME, '') AS FIRSTNAME, 
                      isnull(p.LASTNAME, '') AS LASTNAME, 
                      isnull(p.MIDDLENAME, '') AS MIDDLENAME, 
                      isnull(p.SHORTNAME, '') AS SHORTNAME
                    FROM dbo.BOOKCONTRIBUTOR b, dbo.PERSON p
                    WHERE ((b.CONTRIBUTORKEY = p.CONTRIBUTORKEY) AND 
                            (b.BOOKKEY = @ware_bookkey) AND 
                            (b.PRINTINGKEY = 1))
              

              OPEN warehouserole

              FETCH NEXT FROM warehouserole
                INTO 
                  @cursor_row$ROLETYPECODE$2, 
                  @cursor_row$DEPTTYPECODE$2, 
                  @cursor_row$RESOURCEDESC$2, 
                  @cursor_row$DISPLAYNAME$2, 
                  @cursor_row$FIRSTNAME$2, 
                  @cursor_row$LASTNAME$2, 
                  @cursor_row$MIDDLENAME$2, 
                  @cursor_row$SHORTNAME$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BREAK 

                  SET @ware_count = 0

                  SELECT @ware_count = count( * )
                    FROM dbo.WHCROLETYPE
                    WHERE (dbo.WHCROLETYPE.ROLETYPECODE = @cursor_row$ROLETYPECODE$2)


                  IF ((@@ROWCOUNT > 0) AND 
                          (@ware_count > 0))
                    BEGIN

                      SELECT @ware_roleline = dbo.WHCROLETYPE.LINENUMBER
                        FROM dbo.WHCROLETYPE
                        WHERE (dbo.WHCROLETYPE.ROLETYPECODE = @cursor_row$ROLETYPECODE$2)

                      IF (@@ROWCOUNT > 0)
                        BEGIN

                          SET @ware_displayname = substring(rtrim(@cursor_row$DISPLAYNAME$2), 1, 60)
                          SET @ware_firstname = substring(rtrim(@cursor_row$FIRSTNAME$2), 1, 12)
                          SET @ware_lastname = substring(rtrim(@cursor_row$LASTNAME$2), 1, 20)
                          SET @ware_middlename = @cursor_row$MIDDLENAME$2
                          SET @ware_resourcedesc = @cursor_row$RESOURCEDESC$2
                          SET @ware_shortname = @cursor_row$SHORTNAME$2

                          IF (@ware_roleline = 1)
                            BEGIN

                              SET @ware_displayname1 = @ware_displayname
                              SET @ware_firstname1 = @ware_firstname
                              SET @ware_lastname1 = @ware_lastname
                              SET @ware_middlename1 = @ware_middlename
                              SET @ware_resourcedesc1 = @ware_resourcedesc
                              SET @ware_shortname1 = @ware_shortname
                            END
                          ELSE 
                            IF (@ware_roleline = 2)
                              BEGIN
                                SET @ware_displayname2 = @ware_displayname
                                SET @ware_firstname2 = @ware_firstname
                                SET @ware_lastname2 = @ware_lastname
                                SET @ware_middlename2 = @ware_middlename
                                SET @ware_resourcedesc2 = @ware_resourcedesc
                                SET @ware_shortname2 = @ware_shortname
                              END
                            ELSE 
                              IF (@ware_roleline = 3)
                                BEGIN
                                  SET @ware_displayname3 = @ware_displayname
                                  SET @ware_firstname3 = @ware_firstname
                                  SET @ware_lastname3 = @ware_lastname
                                  SET @ware_middlename3 = @ware_middlename
                                  SET @ware_resourcedesc3 = @ware_resourcedesc
                                  SET @ware_shortname3 = @ware_shortname
                                END
                              ELSE 
                                IF (@ware_roleline = 4)
                                  BEGIN
                                    SET @ware_displayname4 = @ware_displayname
                                    SET @ware_firstname4 = @ware_firstname
                                    SET @ware_lastname4 = @ware_lastname
                                    SET @ware_middlename4 = @ware_middlename
                                    SET @ware_resourcedesc4 = @ware_resourcedesc
                                    SET @ware_shortname4 = @ware_shortname
                                  END
                                ELSE 
                                  IF (@ware_roleline = 5)
                                    BEGIN

                                      SET @ware_displayname5 = @ware_displayname
                                      SET @ware_firstname5 = @ware_firstname
                                      SET @ware_lastname5 = @ware_lastname
                                      SET @ware_middlename5 = @ware_middlename
                                      SET @ware_resourcedesc5 = @ware_resourcedesc
                                      SET @ware_shortname5 = @ware_shortname
                                    END
                                  ELSE 
                                    IF (@ware_roleline = 6)
                                      BEGIN
                                        SET @ware_displayname6 = @ware_displayname
                                        SET @ware_firstname6 = @ware_firstname
                                        SET @ware_lastname6 = @ware_lastname
                                        SET @ware_middlename6 = @ware_middlename
                                        SET @ware_resourcedesc6 = @ware_resourcedesc
                                        SET @ware_shortname6 = @ware_shortname
                                      END
                                    ELSE 
                                      IF (@ware_roleline = 7)
                                        BEGIN
                                          SET @ware_displayname7 = @ware_displayname
                                          SET @ware_firstname7 = @ware_firstname
                                          SET @ware_lastname7 = @ware_lastname
                                          SET @ware_middlename7 = @ware_middlename
                                          SET @ware_resourcedesc7 = @ware_resourcedesc
                                          SET @ware_shortname7 = @ware_shortname
                                        END
                                      ELSE 
                                        IF (@ware_roleline = 8)
                                          BEGIN
                                            SET @ware_displayname8 = @ware_displayname
                                            SET @ware_firstname8 = @ware_firstname
                                            SET @ware_lastname8 = @ware_lastname
                                            SET @ware_middlename8 = @ware_middlename
                                            SET @ware_resourcedesc8 = @ware_resourcedesc
                                            SET @ware_shortname8 = @ware_shortname
                                          END
                                        ELSE 
                                          IF (@ware_roleline = 9)
                                            BEGIN
                                              SET @ware_displayname9 = @ware_displayname
                                              SET @ware_firstname9 = @ware_firstname
                                              SET @ware_lastname9 = @ware_lastname
                                              SET @ware_middlename9 = @ware_middlename
                                              SET @ware_resourcedesc9 = @ware_resourcedesc
                                              SET @ware_shortname9 = @ware_shortname
                                            END
                                          ELSE 
                                            IF (@ware_roleline = 10)
                                              BEGIN
                                                SET @ware_displayname10 = @ware_displayname
                                                SET @ware_firstname10 = @ware_firstname
                                                SET @ware_lastname10 = @ware_lastname
                                                SET @ware_middlename10 = @ware_middlename
                                                SET @ware_resourcedesc10 = @ware_resourcedesc
                                                SET @ware_shortname10 = @ware_shortname
                                              END
                                            ELSE 
                                              IF (@ware_roleline = 11)
                                                BEGIN
                                                  SET @ware_displayname11 = @ware_displayname
                                                  SET @ware_firstname11 = @ware_firstname
                                                  SET @ware_lastname11 = @ware_lastname
                                                  SET @ware_middlename11 = @ware_middlename
                                                  SET @ware_resourcedesc11 = @ware_resourcedesc
                                                  SET @ware_shortname11 = @ware_shortname

                                                END
                                              ELSE 
                                                IF (@ware_roleline = 12)
                                                  BEGIN
                                                    SET @ware_displayname12 = @ware_displayname
                                                    SET @ware_firstname12 = @ware_firstname
                                                    SET @ware_lastname12 = @ware_lastname
                                                    SET @ware_middlename12 = @ware_middlename
                                                    SET @ware_resourcedesc12 = @ware_resourcedesc
                                                    SET @ware_shortname12 = @ware_shortname
                                                  END
                                                ELSE 
                                                  IF (@ware_roleline = 13)
                                                    BEGIN
                                                      SET @ware_displayname13 = @ware_displayname
                                                      SET @ware_firstname13 = @ware_firstname
                                                      SET @ware_lastname13 = @ware_lastname
                                                      SET @ware_middlename13 = @ware_middlename
                                                      SET @ware_resourcedesc13 = @ware_resourcedesc
                                                      SET @ware_shortname13 = @ware_shortname
                                                    END
                                                  ELSE 
                                                    IF (@ware_roleline = 14)
                                                      BEGIN
                                                        SET @ware_displayname14 = @ware_displayname
                                                        SET @ware_firstname14 = @ware_firstname
                                                        SET @ware_lastname14 = @ware_lastname
                                                        SET @ware_middlename14 = @ware_middlename
                                                        SET @ware_resourcedesc14 = @ware_resourcedesc
                                                        SET @ware_shortname14 = @ware_shortname
                                                      END
                                                    ELSE 
                                                      IF (@ware_roleline = 15)
                                                        BEGIN
                                                          SET @ware_displayname15 = @ware_displayname
                                                          SET @ware_firstname15 = @ware_firstname
                                                          SET @ware_lastname15 = @ware_lastname
                                                          SET @ware_middlename15 = @ware_middlename
                                                          SET @ware_resourcedesc15 = @ware_resourcedesc
                                                          SET @ware_shortname15 = @ware_shortname
                                                        END
                                                      ELSE 
                                                        IF (@ware_roleline = 16)
                                                          BEGIN
                                                            SET @ware_displayname16 = @ware_displayname
                                                            SET @ware_firstname16 = @ware_firstname
                                                            SET @ware_lastname16 = @ware_lastname
                                                            SET @ware_middlename16 = @ware_middlename
                                                            SET @ware_resourcedesc16 = @ware_resourcedesc
                                                            SET @ware_shortname16 = @ware_shortname
                                                          END
                                                        ELSE 
                                                          IF (@ware_roleline = 17)
                                                            BEGIN
                                                              SET @ware_displayname17 = @ware_displayname
                                                              SET @ware_firstname17 = @ware_firstname
                                                              SET @ware_lastname17 = @ware_lastname
                                                              SET @ware_middlename17 = @ware_middlename
                                                              SET @ware_resourcedesc17 = @ware_resourcedesc
                                                              SET @ware_shortname17 = @ware_shortname
                                                            END
                                                          ELSE 
                                                            IF (@ware_roleline = 18)
                                                              BEGIN
                                                                SET @ware_displayname18 = @ware_displayname
                                                                SET @ware_firstname18 = @ware_firstname
                                                                SET @ware_lastname18 = @ware_lastname
                                                                SET @ware_middlename18 = @ware_middlename
                                                                SET @ware_resourcedesc18 = @ware_resourcedesc
                                                                SET @ware_shortname18 = @ware_shortname
                                                              END
                                                            ELSE 
                                                              IF (@ware_roleline = 19)
                                                                BEGIN
                                                                  SET @ware_displayname19 = @ware_displayname
                                                                  SET @ware_firstname19 = @ware_firstname
                                                                  SET @ware_lastname19 = @ware_lastname
                                                                  SET @ware_middlename19 = @ware_middlename
                                                                  SET @ware_resourcedesc19 = @ware_resourcedesc
                                                                  SET @ware_shortname19 = @ware_shortname
                                                                END
                                                              ELSE 
                                                                IF (@ware_roleline = 20)
                                                                  BEGIN
                                                                    SET @ware_displayname20 = @ware_displayname
                                                                    SET @ware_firstname20 = @ware_firstname
                                                                    SET @ware_lastname20 = @ware_lastname
                                                                    SET @ware_middlename20 = @ware_middlename
                                                                    SET @ware_resourcedesc20 = @ware_resourcedesc
                                                                    SET @ware_shortname20 = @ware_shortname
                                                                  END
                                                                ELSE 
                                                                  IF (@ware_roleline = 21)
                                                                    BEGIN
                                                                      SET @ware_displayname21 = @ware_displayname
                                                                      SET @ware_firstname21 = @ware_firstname
                                                                      SET @ware_lastname21 = @ware_lastname
                                                                      SET @ware_middlename21 = @ware_middlename
                                                                      SET @ware_resourcedesc21 = @ware_resourcedesc
                                                                      SET @ware_shortname21 = @ware_shortname
                                                                    END
                                                                  ELSE 
                                                                    IF (@ware_roleline = 22)
                                                                      BEGIN
                                                                        SET @ware_displayname22 = @ware_displayname
                                                                        SET @ware_firstname22 = @ware_firstname
                                                                        SET @ware_lastname22 = @ware_lastname
                                                                        SET @ware_middlename22 = @ware_middlename
                                                                        SET @ware_resourcedesc22 = @ware_resourcedesc
                                                                        SET @ware_shortname22 = @ware_shortname
                                                                      END
                                                                    ELSE 
                                                                      IF (@ware_roleline = 23)
                                                                        BEGIN
                                                                          SET @ware_displayname23 = @ware_displayname
                                                                          SET @ware_firstname23 = @ware_firstname
                                                                          SET @ware_lastname23 = @ware_lastname
                                                                          SET @ware_middlename23 = @ware_middlename
                                                                          SET @ware_resourcedesc23 = @ware_resourcedesc
                                                                          SET @ware_shortname23 = @ware_shortname
                                                                        END
                                                                      ELSE 
                                                                        IF (@ware_roleline = 24)
                                                                          BEGIN
                                                                            SET @ware_displayname24 = @ware_displayname
                                                                            SET @ware_firstname24 = @ware_firstname
                                                                            SET @ware_lastname24 = @ware_lastname
                                                                            SET @ware_middlename24 = @ware_middlename
                                                                            SET @ware_resourcedesc24 = @ware_resourcedesc
                                                                            SET @ware_shortname24 = @ware_shortname
                                                                          END
                                                                        ELSE 
                                                                          IF (@ware_roleline = 25)
                                                                            BEGIN
                                                                              SET @ware_displayname25 = @ware_displayname
                                                                              SET @ware_firstname25 = @ware_firstname
                                                                              SET @ware_lastname25 = @ware_lastname
                                                                              SET @ware_middlename25 = @ware_middlename
                                                                              SET @ware_resourcedesc25 = @ware_resourcedesc
                                                                              SET @ware_shortname25 = @ware_shortname
                                                                            END
                                                                          ELSE 
                                                                            IF (@ware_roleline = 26)
                                                                             BEGIN
                                                                                SET @ware_displayname26 = @ware_displayname
                                                                                SET @ware_firstname26 = @ware_firstname
                                                                                SET @ware_lastname26 = @ware_lastname
                                                                                SET @ware_middlename26 = @ware_middlename
                                                                                SET @ware_resourcedesc26 = @ware_resourcedesc
                                                                                SET @ware_shortname26 = @ware_shortname
                                                                              END
                                                                            ELSE 
                                                                              IF (@ware_roleline = 27)
                                                                                BEGIN
                                                                                  SET @ware_displayname27 = @ware_displayname
                                                                                  SET @ware_firstname27 = @ware_firstname
                                                                                  SET @ware_lastname27 = @ware_lastname
                                                                                  SET @ware_middlename27 = @ware_middlename
                                                                                  SET @ware_resourcedesc27 = @ware_resourcedesc
                                                                                  SET @ware_shortname27 = @ware_shortname
                                                                                END
                                                                              ELSE 
                                                                                IF (@ware_roleline = 28)
                                                                                  BEGIN
                                                                                    SET @ware_displayname28 = @ware_displayname
                                                                                    SET @ware_firstname28 = @ware_firstname
                                                                                    SET @ware_lastname28 = @ware_lastname
                                                                                    SET @ware_middlename28 = @ware_middlename
                                                                                    SET @ware_resourcedesc28 = @ware_resourcedesc
                                                                                    SET @ware_shortname28 = @ware_shortname
                                                                                  END
                                                                                ELSE 
                                                                                  IF (@ware_roleline = 29)
                                                                                    BEGIN
                                                                                      SET @ware_displayname29 = @ware_displayname
                                                                                      SET @ware_firstname29 = @ware_firstname
                                                                                      SET @ware_lastname29 = @ware_lastname
                                                                                      SET @ware_middlename29 = @ware_middlename
                                                                                      SET @ware_resourcedesc29 = @ware_resourcedesc
                                                                                      SET @ware_shortname29 = @ware_shortname
                                                                                    END
                                                                                  ELSE 
                                                                                    IF (@ware_roleline = 30)
                                                                                      BEGIN
                                                                                        SET @ware_displayname30 = @ware_displayname
                                                                                        SET @ware_firstname30 = @ware_firstname
                                                                                        SET @ware_lastname30 = @ware_lastname
                                                                                        SET @ware_middlename30 = @ware_middlename
                                                                                        SET @ware_resourcedesc30 = @ware_resourcedesc
                                                                                        SET @ware_shortname30 = @ware_shortname
                                                                                      END
                                                                                    ELSE 
                                                                                      IF (@ware_roleline = 31)
                                                                                        BEGIN
                                                                                          SET @ware_displayname31 = @ware_displayname
                                                                                          SET @ware_firstname31 = @ware_firstname
                                                                                          SET @ware_lastname31 = @ware_lastname
                                                                                          SET @ware_middlename31 = @ware_middlename
                                                                                          SET @ware_resourcedesc31 = @ware_resourcedesc
                                                                                          SET @ware_shortname31 = @ware_shortname
                                                                                        END
                                                                                      ELSE 
                                                                                        IF (@ware_roleline = 32)
                                                                                          BEGIN
                                                                                            SET @ware_displayname32 = @ware_displayname
                                                                                            SET @ware_firstname32 = @ware_firstname
                                                                                            SET @ware_lastname32 = @ware_lastname
                                                                                            SET @ware_middlename32 = @ware_middlename
                                                                                            SET @ware_resourcedesc32 = @ware_resourcedesc
                                                                                            SET @ware_shortname32 = @ware_shortname
                                                                                          END
                                                                                        ELSE 
                                                                                          IF (@ware_roleline = 33)
                                                                                            BEGIN
                                                                                              SET @ware_displayname33 = @ware_displayname
                                                                                              SET @ware_firstname33 = @ware_firstname
                                                                                              SET @ware_lastname33 = @ware_lastname
                                                                                              SET @ware_middlename33 = @ware_middlename
                                                                                              SET @ware_resourcedesc33 = @ware_resourcedesc
                                                                                              SET @ware_shortname33 = @ware_shortname
                                                                                            END
                                                                                          ELSE 
                                                                                            IF (@ware_roleline = 34)
                                                                                              BEGIN
                                                                                                SET @ware_displayname34 = @ware_displayname
                                                                                                SET @ware_firstname34 = @ware_firstname
                                                                                                SET @ware_lastname34 = @ware_lastname
                                                                                                SET @ware_middlename34 = @ware_middlename
                                                                                                SET @ware_resourcedesc34 = @ware_resourcedesc
                                                                                                SET @ware_shortname34 = @ware_shortname
                                                                                              END
                                                                                            ELSE 
                                                                                              IF (@ware_roleline = 35)
                                                                                                BEGIN
                                                                                                  SET @ware_displayname35 = @ware_displayname
                                                                                                  SET @ware_firstname35 = @ware_firstname
                                                                                                  SET @ware_lastname35 = @ware_lastname
                                                                                                  SET @ware_middlename35 = @ware_middlename
                                                                                                  SET @ware_resourcedesc35 = @ware_resourcedesc
                                                                                                  SET @ware_shortname35 = @ware_shortname
                                                                                                END
                                                                                              ELSE 
                                                                                                IF (@ware_roleline = 36)
                                                                                                  BEGIN
                                                                                                    SET @ware_displayname36 = @ware_displayname
                                                                                                    SET @ware_firstname36 = @ware_firstname
                                                                                                    SET @ware_lastname36 = @ware_lastname
                                                                                                    SET @ware_middlename36 = @ware_middlename
                                                                                                    SET @ware_resourcedesc36 = @ware_resourcedesc
                                                                                                    SET @ware_shortname36 = @ware_shortname
                                                                                                  END
                                                                                                ELSE 
                                                                                                  IF (@ware_roleline = 37)
                                                                                                    BEGIN
                                                                                                      SET @ware_displayname37 = @ware_displayname
                                                                                                      SET @ware_firstname37 = @ware_firstname
                                                                                                      SET @ware_lastname37 = @ware_lastname
                                                                                                      SET @ware_middlename37 = @ware_middlename
                                                                                                      SET @ware_resourcedesc37 = @ware_resourcedesc
                                                                                                      SET @ware_shortname37 = @ware_shortname
                                                                                                    END
                                                                                                 ELSE 
                                                                                                    IF (@ware_roleline = 38)
                                                                                                     BEGIN
                                                                                                        SET @ware_displayname38 = @ware_displayname
                                                                                                        SET @ware_firstname38 = @ware_firstname
                                                                                                        SET @ware_lastname38 = @ware_lastname
                                                                                                        SET @ware_middlename38 = @ware_middlename
                                                                                                        SET @ware_resourcedesc38 = @ware_resourcedesc
                                                                                                        SET @ware_shortname38 = @ware_shortname
                                                                                                      END
                                                                                                    ELSE 
                                                                                                      IF (@ware_roleline = 39)
                                                                                                       BEGIN
                                                                                                          SET @ware_displayname39 = @ware_displayname
                                                                                                          SET @ware_firstname39 = @ware_firstname
                                                                                                          SET @ware_lastname39 = @ware_lastname
                                                                                                          SET @ware_middlename39 = @ware_middlename
                                                                                                          SET @ware_resourcedesc39 = @ware_resourcedesc
                                                                                                          SET @ware_shortname39 = @ware_shortname
                                                                                                        END
                                                                                                     ELSE 
                                                                                                        IF (@ware_roleline = 40)
                                                                                                          BEGIN
                                                                                                            SET @ware_displayname40 = @ware_displayname
                                                                                                            SET @ware_firstname40 = @ware_firstname
                                                                                                            SET @ware_lastname40 = @ware_lastname
                                                                                                            SET @ware_middlename40 = @ware_middlename
                                                                                                             SET @ware_resourcedesc40 = @ware_resourcedesc
                                                                                                           SET @ware_shortname40 = @ware_shortname
                                                                                                          END
                        END
                    END

                  FETCH NEXT FROM warehouserole
                    INTO 
                      @cursor_row$ROLETYPECODE$2, 
                      @cursor_row$DEPTTYPECODE$2, 
                      @cursor_row$RESOURCEDESC$2, 
                      @cursor_row$DISPLAYNAME$2, 
                      @cursor_row$FIRSTNAME$2, 
                      @cursor_row$LASTNAME$2, 
                      @cursor_row$MIDDLENAME$2, 
                      @cursor_row$SHORTNAME$2

                END

              CLOSE warehouserole

              DEALLOCATE warehouserole

            END

            INSERT INTO dbo.WHTITLEPERSONNEL
              (
                dbo.WHTITLEPERSONNEL.BOOKKEY, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME1, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME1, 
                dbo.WHTITLEPERSONNEL.LASTNAME1, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME2, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME2, 
                dbo.WHTITLEPERSONNEL.LASTNAME2, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME3, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME3, 
                dbo.WHTITLEPERSONNEL.LASTNAME3, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME4, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME4, 
                dbo.WHTITLEPERSONNEL.LASTNAME4, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME5, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME5, 
                dbo.WHTITLEPERSONNEL.LASTNAME5, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME6, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME6, 
                dbo.WHTITLEPERSONNEL.LASTNAME6, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME7, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME7, 
                dbo.WHTITLEPERSONNEL.LASTNAME7, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME8, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME8, 
                dbo.WHTITLEPERSONNEL.LASTNAME8, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME9, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME9, 
                dbo.WHTITLEPERSONNEL.LASTNAME9, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME10, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME10, 
                dbo.WHTITLEPERSONNEL.LASTNAME10, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME11, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME11, 
                dbo.WHTITLEPERSONNEL.LASTNAME11, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME12, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME12, 
                dbo.WHTITLEPERSONNEL.LASTNAME12, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME13, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME13, 
                dbo.WHTITLEPERSONNEL.LASTNAME13, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME14, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME14, 
                dbo.WHTITLEPERSONNEL.LASTNAME14, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME15, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME15, 
                dbo.WHTITLEPERSONNEL.LASTNAME15, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC1, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME1, 
                dbo.WHTITLEPERSONNEL.SHORTNAME1, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC2, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME2, 
                dbo.WHTITLEPERSONNEL.SHORTNAME2, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC3, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME3, 
                dbo.WHTITLEPERSONNEL.SHORTNAME3, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC4, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME4, 
                dbo.WHTITLEPERSONNEL.SHORTNAME4, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC5, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME5, 
                dbo.WHTITLEPERSONNEL.SHORTNAME5, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC6, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME6, 
                dbo.WHTITLEPERSONNEL.SHORTNAME6, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC7, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME7, 
                dbo.WHTITLEPERSONNEL.SHORTNAME7, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC8, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME8, 
                dbo.WHTITLEPERSONNEL.SHORTNAME8, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC9, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME9, 
                dbo.WHTITLEPERSONNEL.SHORTNAME9, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC10, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME10, 
                dbo.WHTITLEPERSONNEL.SHORTNAME10, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC11, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME11, 
                dbo.WHTITLEPERSONNEL.SHORTNAME11, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC12, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME12, 
                dbo.WHTITLEPERSONNEL.SHORTNAME12, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC13, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME13, 
                dbo.WHTITLEPERSONNEL.SHORTNAME13, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC14, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME14, 
                dbo.WHTITLEPERSONNEL.SHORTNAME14, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC15, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME15, 
                dbo.WHTITLEPERSONNEL.SHORTNAME15, 
                dbo.WHTITLEPERSONNEL.LASTUSERID, 
                dbo.WHTITLEPERSONNEL.LASTMAINTDATE, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME16, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME16, 
                dbo.WHTITLEPERSONNEL.LASTNAME16, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC16, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME16, 
                dbo.WHTITLEPERSONNEL.SHORTNAME16, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME17, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME17, 
                dbo.WHTITLEPERSONNEL.LASTNAME17, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC17, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME17, 
                dbo.WHTITLEPERSONNEL.SHORTNAME17, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME18, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME18, 
                dbo.WHTITLEPERSONNEL.LASTNAME18, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC18, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME18, 
                dbo.WHTITLEPERSONNEL.SHORTNAME18, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME19, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME19, 
                dbo.WHTITLEPERSONNEL.LASTNAME19, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC19, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME19, 
                dbo.WHTITLEPERSONNEL.SHORTNAME19, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME20, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME20, 
                dbo.WHTITLEPERSONNEL.LASTNAME20, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC20, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME20, 
                dbo.WHTITLEPERSONNEL.SHORTNAME20, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME21, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME21, 
                dbo.WHTITLEPERSONNEL.LASTNAME21, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC21, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME21, 
                dbo.WHTITLEPERSONNEL.SHORTNAME21, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME22, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME22, 
                dbo.WHTITLEPERSONNEL.LASTNAME22, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC22, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME22, 
                dbo.WHTITLEPERSONNEL.SHORTNAME22, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME23, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME23, 
                dbo.WHTITLEPERSONNEL.LASTNAME23, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC23, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME23, 
                dbo.WHTITLEPERSONNEL.SHORTNAME23, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME24, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME24, 
                dbo.WHTITLEPERSONNEL.LASTNAME24, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC24, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME24, 
                dbo.WHTITLEPERSONNEL.SHORTNAME24, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME25, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME25, 
                dbo.WHTITLEPERSONNEL.LASTNAME25, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC25, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME25, 
                dbo.WHTITLEPERSONNEL.SHORTNAME25, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME26, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME26, 
                dbo.WHTITLEPERSONNEL.LASTNAME26, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC26, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME26, 
                dbo.WHTITLEPERSONNEL.SHORTNAME26, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME27, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME27, 
                dbo.WHTITLEPERSONNEL.LASTNAME27, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC27, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME27, 
                dbo.WHTITLEPERSONNEL.SHORTNAME27, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME28, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME28, 
                dbo.WHTITLEPERSONNEL.LASTNAME28, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC28, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME28, 
                dbo.WHTITLEPERSONNEL.SHORTNAME28, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME29, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME29, 
                dbo.WHTITLEPERSONNEL.LASTNAME29, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC29, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME29, 
                dbo.WHTITLEPERSONNEL.SHORTNAME29, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME30, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME30, 
                dbo.WHTITLEPERSONNEL.LASTNAME30, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC30, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME30, 
                dbo.WHTITLEPERSONNEL.SHORTNAME30, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME31, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME31, 
                dbo.WHTITLEPERSONNEL.LASTNAME31, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC31, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME31, 
                dbo.WHTITLEPERSONNEL.SHORTNAME31, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME32, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME32, 
                dbo.WHTITLEPERSONNEL.LASTNAME32, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC32, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME32, 
                dbo.WHTITLEPERSONNEL.SHORTNAME32, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME33, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME33, 
                dbo.WHTITLEPERSONNEL.LASTNAME33, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC33, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME33, 
                dbo.WHTITLEPERSONNEL.SHORTNAME33, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME34, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME34, 
                dbo.WHTITLEPERSONNEL.LASTNAME34, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC34, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME34, 
                dbo.WHTITLEPERSONNEL.SHORTNAME34, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME35, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME35, 
                dbo.WHTITLEPERSONNEL.LASTNAME35, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC35, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME35, 
                dbo.WHTITLEPERSONNEL.SHORTNAME35, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME36, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME36, 
                dbo.WHTITLEPERSONNEL.LASTNAME36, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC36, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME36, 
                dbo.WHTITLEPERSONNEL.SHORTNAME36, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME37, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME37, 
                dbo.WHTITLEPERSONNEL.LASTNAME37, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC37, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME37, 
                dbo.WHTITLEPERSONNEL.SHORTNAME37, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME38, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME38, 
                dbo.WHTITLEPERSONNEL.LASTNAME38, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC38, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME38, 
                dbo.WHTITLEPERSONNEL.SHORTNAME38, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME39, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME39, 
                dbo.WHTITLEPERSONNEL.LASTNAME39, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC39, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME39, 
                dbo.WHTITLEPERSONNEL.SHORTNAME39, 
                dbo.WHTITLEPERSONNEL.DISPLAYNAME40, 
                dbo.WHTITLEPERSONNEL.FIRSTNAME40, 
                dbo.WHTITLEPERSONNEL.LASTNAME40, 
                dbo.WHTITLEPERSONNEL.RESOURCEDESC40, 
                dbo.WHTITLEPERSONNEL.MIDDLENAME40, 
                dbo.WHTITLEPERSONNEL.SHORTNAME40
              )
              VALUES 
                (
                  @ware_bookkey, 
                  @ware_displayname1, 
                  @ware_firstname1, 
                  @ware_lastname1, 
                  @ware_displayname2, 
                  @ware_firstname2, 
                  @ware_lastname2, 
                  @ware_displayname3, 
                  @ware_firstname3, 
                  @ware_lastname3, 
                  @ware_displayname4, 
                  @ware_firstname4, 
                  @ware_lastname4, 
                  @ware_displayname5, 
                  @ware_firstname5, 
                  @ware_lastname5, 
                  @ware_displayname6, 
                  @ware_firstname6, 
                  @ware_lastname6, 
                  @ware_displayname7, 
                  @ware_firstname7, 
                  @ware_lastname7, 
                  @ware_displayname8, 
                  @ware_firstname8, 
                  @ware_lastname8, 
                  @ware_displayname9, 
                  @ware_firstname9, 
                  @ware_lastname9, 
                  @ware_displayname10, 
                  @ware_firstname10, 
                  @ware_lastname10, 
                  @ware_displayname11, 
                  @ware_firstname11, 
                  @ware_lastname11, 
                  @ware_displayname12, 
                  @ware_firstname12, 
                  @ware_lastname12, 
                  @ware_displayname13, 
                  @ware_firstname13, 
                  @ware_lastname13, 
                  @ware_displayname14, 
                  @ware_firstname14, 
                  @ware_lastname14, 
                  @ware_displayname15, 
                  @ware_firstname15, 
                  @ware_lastname15, 
                  @ware_resourcedesc1, 
                  @ware_middlename1, 
                  @ware_shortname1, 
                  @ware_resourcedesc2, 
                  @ware_middlename2, 
                  @ware_shortname2, 
                  @ware_resourcedesc3, 
                  @ware_middlename3, 
                  @ware_shortname3, 
                  @ware_resourcedesc4, 
                  @ware_middlename4, 
                  @ware_shortname4, 
                  @ware_resourcedesc5, 
                  @ware_middlename5, 
                  @ware_shortname5, 
                  @ware_resourcedesc6, 
                  @ware_middlename6, 
                  @ware_shortname6, 
                  @ware_resourcedesc7, 
                  @ware_middlename7, 
                  @ware_shortname7, 
                  @ware_resourcedesc8, 
                  @ware_middlename8, 
                  @ware_shortname8, 
                  @ware_resourcedesc9, 
                  @ware_middlename9, 
                  @ware_shortname9, 
                  @ware_resourcedesc10, 
                  @ware_middlename10, 
                  @ware_shortname10, 
                  @ware_resourcedesc11, 
                  @ware_middlename11, 
                  @ware_shortname11, 
                  @ware_resourcedesc12, 
                  @ware_middlename12, 
                  @ware_shortname12, 
                  @ware_resourcedesc13, 
                  @ware_middlename13, 
                  @ware_shortname13, 
                  @ware_resourcedesc14, 
                  @ware_middlename14, 
                  @ware_shortname14, 
                  @ware_resourcedesc15, 
                  @ware_middlename15, 
                  @ware_shortname15, 
                  'WARE_STORED_PROC', 
                  @ware_system_date, 
                  @ware_displayname16, 
                  @ware_firstname16, 
                  @ware_lastname16, 
                  @ware_resourcedesc16, 
                  @ware_middlename16, 
                  @ware_shortname16, 
                  @ware_displayname17, 
                  @ware_firstname17, 
                  @ware_lastname17, 
                  @ware_resourcedesc17, 
                  @ware_middlename17, 
                  @ware_shortname17, 
                  @ware_displayname18, 
                  @ware_firstname18, 
                  @ware_lastname18, 
                  @ware_resourcedesc18, 
                  @ware_middlename18, 
                  @ware_shortname18, 
                  @ware_displayname19, 
                  @ware_firstname19, 
                  @ware_lastname19, 
                  @ware_resourcedesc19, 
                  @ware_middlename19, 
                  @ware_shortname19, 
                  @ware_displayname20, 
                  @ware_firstname20, 
                  @ware_lastname20, 
                  @ware_resourcedesc20, 
                  @ware_middlename20, 
                  @ware_shortname20, 
                  @ware_displayname21, 
                  @ware_firstname21, 
                  @ware_lastname21, 
                  @ware_resourcedesc21, 
                  @ware_middlename21, 
                  @ware_shortname21, 
                  @ware_displayname22, 
                  @ware_firstname22, 
                  @ware_lastname22, 
                  @ware_resourcedesc22, 
                  @ware_middlename22, 
                  @ware_shortname22, 
                  @ware_displayname23, 
                  @ware_firstname23, 
                  @ware_lastname23, 
                  @ware_resourcedesc23, 
                  @ware_middlename23, 
                  @ware_shortname23, 
                  @ware_displayname24, 
                  @ware_firstname24, 
                  @ware_lastname24, 
                  @ware_resourcedesc24, 
                  @ware_middlename24, 
                  @ware_shortname24, 
                  @ware_displayname25, 
                  @ware_firstname25, 
                  @ware_lastname25, 
                  @ware_resourcedesc25, 
                  @ware_middlename25, 
                  @ware_shortname25, 
                  @ware_displayname26, 
                  @ware_firstname26, 
                  @ware_lastname26, 
                  @ware_resourcedesc26, 
                  @ware_middlename26, 
                  @ware_shortname26, 
                  @ware_displayname27, 
                  @ware_firstname27, 
                  @ware_lastname27, 
                  @ware_resourcedesc27, 
                  @ware_middlename27, 
                  @ware_shortname27, 
                  @ware_displayname28, 
                  @ware_firstname28, 
                  @ware_lastname28, 
                  @ware_resourcedesc28, 
                  @ware_middlename28, 
                  @ware_shortname28, 
                  @ware_displayname29, 
                  @ware_firstname29, 
                  @ware_lastname29, 
                  @ware_resourcedesc29, 
                  @ware_middlename29, 
                  @ware_shortname29, 
                  @ware_displayname30, 
                  @ware_firstname30, 
                  @ware_lastname30, 
                  @ware_resourcedesc30, 
                  @ware_middlename30, 
                  @ware_shortname30, 
                  @ware_displayname31, 
                  @ware_firstname31, 
                  @ware_lastname31, 
                  @ware_resourcedesc31, 
                  @ware_middlename31, 
                  @ware_shortname31, 
                  @ware_displayname32, 
                  @ware_firstname32, 
                  @ware_lastname32, 
                  @ware_resourcedesc32, 
                  @ware_middlename32, 
                  @ware_shortname32, 
                  @ware_displayname33, 
                  @ware_firstname33, 
                  @ware_lastname33, 
                  @ware_resourcedesc33, 
                  @ware_middlename33, 
                  @ware_shortname33, 
                  @ware_displayname34, 
                  @ware_firstname34, 
                  @ware_lastname34, 
                  @ware_resourcedesc34, 
                  @ware_middlename34, 
                  @ware_shortname34, 
                  @ware_displayname35, 
                  @ware_firstname35, 
                  @ware_lastname35, 
                  @ware_resourcedesc35, 
                  @ware_middlename35, 
                  @ware_shortname35, 
                  @ware_displayname36, 
                  @ware_firstname36, 
                  @ware_lastname36, 
                  @ware_resourcedesc36, 
                  @ware_middlename36, 
                  @ware_shortname36, 
                  @ware_displayname37, 
                  @ware_firstname37, 
                  @ware_lastname37, 
                  @ware_resourcedesc37, 
                  @ware_middlename37, 
                  @ware_shortname37, 
                  @ware_displayname38, 
                  @ware_firstname38, 
                  @ware_lastname38, 
                  @ware_resourcedesc38, 
                  @ware_middlename38, 
                  @ware_shortname38, 
                  @ware_displayname39, 
                  @ware_firstname39, 
                  @ware_lastname39, 
                  @ware_resourcedesc39, 
                  @ware_middlename39, 
                  @ware_shortname39, 
                  @ware_displayname40, 
                  @ware_firstname40, 
                  @ware_lastname40, 
                  @ware_resourcedesc40, 
                  @ware_middlename40, 
                  @ware_shortname40
                )

            IF @@ROWCOUNT = 0
              BEGIN
                INSERT INTO dbo.WHERRORLOG
                  (
                    dbo.WHERRORLOG.LOGKEY, 
                    dbo.WHERRORLOG.WAREHOUSEKEY, 
                    dbo.WHERRORLOG.ERRORDESC, 
                    dbo.WHERRORLOG.ERRORSEVERITY, 
                    dbo.WHERRORLOG.ERRORFUNCTION, 
                    dbo.WHERRORLOG.LASTUSERID, 
                    dbo.WHERRORLOG.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      CAST( @ware_logkey AS varchar(8000)), 
                      CAST( @ware_warehousekey AS varchar(8000)), 
                      'Unable to insert whtitlepersonnel table - for book contributor', 
                      ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(8000)), '')), 
                      'Stored procedure datawarehouse_role', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
                IF (@@TRANCOUNT > 0)
                    COMMIT WORK
              END

            IF (cursor_status(N'local', N'warehouserole') = 1)
              BEGIN
                CLOSE warehouserole
                DEALLOCATE warehouserole
              END

          END
      END
go
grant execute on datawarehouse_bookrole  to public
go
