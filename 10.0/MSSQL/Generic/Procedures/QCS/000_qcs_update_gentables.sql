IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_gentables')
DROP PROCEDURE  qcs_update_gentables
GO

CREATE PROCEDURE qcs_update_gentables
(
  @i_gentableinfo_xml   NVARCHAR(max),
  @i_tableid            INT,
  @i_fullreplaceind     INT,
  @i_gentable_type      VARCHAR(255),
  @o_error_code         INT OUT,
  @o_error_desc         VARCHAR(2000) OUT 
)
AS
BEGIN
  DECLARE 
    @AccessInd INT,
    @DocNum	INT,
    @IsOpen BIT,
    @Quote VARCHAR(3),
    @ErrorVar	INT,
    @RowcountVar INT,
    @CountVar INT,
    @SequenceNum INT,
    @UserID	VARCHAR(30),
    @UserKey TINYINT,
    @XMLSearchString VARCHAR(120),
    @ActiveInd INT, 
    @InactiveString VARCHAR(5),
    @InternalString VARCHAR(5),
    @UpdatedBy VARCHAR(30),
    @dtUpdatedAt NVARCHAR(50),
    @UpdatedAt DATETIME,
    @Tag VARCHAR(25),
    @Name VARCHAR(50),
    @AlternateName VARCHAR(50),
    @GentableType VARCHAR(50),
    @NodePath varchar(50),
    @PublicInd TINYINT,
    @datacode INT,
    @LastMaintDate DATETIME,
    @newkey INT,
    @gen1ind INT,
    @datasubcode INT,
    @fetchStatus INT,
	@filterind	INT,
	@itemtypefilter	INT

  IF @i_gentable_type is null OR ltrim(rtrim(@i_gentable_type)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'gentable_type must be passed in'
    GOTO ExitHandler
  END
  
  -- TMM Cloud Sync Patch 8.1.4.1 - prevents deactivation of non CS records.
  IF @i_tableid IN (287, 520) BEGIN
	SET @i_fullreplaceind = 0
  END

  SET @filterind = 0
  SELECT @filterind = COALESCE(itemtypefilterind, 0)
  FROM gentablesdesc
  where tableid = @i_tableid

  SET @itemtypefilter = 0
  IF @filterind IN (2, 3, 4) BEGIN
	SELECT @itemtypefilter = COALESCE(datacode, 0)
	FROM gentables
	WHERE tableid = 550
		and qsicode = 1
  END

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @i_gentableinfo_xml,'<Test xmlns:x="http://cloud.firebrandtech.com/"/>'

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the xml record'
    GOTO ExitHandler
  END
  SET @IsOpen = 1
  
  -- Get the client's datetypecode for Creation Date (qsicode=10)
--  SELECT @TempCounter = COUNT(*)
--  FROM datetype WHERE qsicode = 10
--  
--  SET @CreationDateCode = 0
--  IF @TempCounter > 0
--    SELECT @CreationDateCode = datetypecode
--    FROM datetype WHERE qsicode = 10
      
  SET @NodePath = @i_gentable_type
  
  -- Loop to get all elements from the passed XML document
  DECLARE gentable_cursor CURSOR LOCAL FOR 
    SELECT InactiveString,UpdatedBy,UpdatedAt,Tag,Name,
           AlternateName,InternalString
    FROM OPENXML(@DocNum,  @NodePath)
    WITH (InactiveString VARCHAR(5) 'x:inactive', 
          UpdatedBy VARCHAR(30) 'x:updated-by',
          UpdatedAt nvarchar(50) 'x:updated-at',
          Tag VARCHAR(25) 'x:tag',
          Name VARCHAR(50) 'x:name',
          AlternateName VARCHAR(50) 'x:alternate-name',
          InternalString VARCHAR(5) 'x:internal')

  OPEN gentable_cursor

  FETCH NEXT FROM gentable_cursor
  INTO @InactiveString, @UpdatedBy, @dtUpdatedAt, @Tag, @Name, @AlternateName, @InternalString

  SET @fetchStatus=@@FETCH_STATUS
  
  IF @fetchStatus <> 0	BEGIN -- no updates for this gentable - return  
    SET @o_error_code = 1
    SET @o_error_desc = 'No updates for tableid ' + CAST(@i_tableid as varchar)
    GOTO ExitHandler
  END
  ELSE BEGIN
    -- at least 1 update for this gentable
    IF @i_fullreplaceind = 1 BEGIN
      -- make all current rows inactive - updates below will set rows to active
      -- do not set lastmaintdate here or the row will never become active
      -- because of the date check below - lastmaintdate is set at the end
      -- if the row is still inactive
      UPDATE gentables
         SET deletestatus = 'Y',
             lastuserid = 'Cloud'
       WHERE tableid = @i_tableid
       
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not update gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
        GOTO ExitHandler
      END      
    END
  END
  
  --FETCH NEXT FROM gentable_cursor
  --INTO @InactiveString, @UpdatedBy, @dtUpdatedAt, @Tag, @Name, @AlternateName, @InternalString
  
  WHILE @fetchStatus = 0 BEGIN
    --DEBUG
    PRINT '@Name: ' + @Name
    PRINT '@Tag: ' + @Tag
    PRINT '@UpdatedBy: ' + @UpdatedBy
    PRINT '@UpdatedAt: ' + @dtUpdatedAt
    PRINT '@InactiveString: ' + @InactiveString
    PRINT '@AlternateName: ' + @AlternateName
    PRINT '@InternalString: ' + @InternalString
    
    SET @ActiveInd = 1
    IF lower(@InactiveString) = 'true' BEGIN
      SET @ActiveInd = 0
    END

    SET @PublicInd = 1
    IF lower(@InternalString) = 'true' BEGIN
      SET @PublicInd = 0
    END

    SET @UpdatedAt = CONVERT(datetime, @dtUpdatedAt, 127)
    
    --DEBUG
    PRINT '@ActiveInd: ' + CONVERT(VARCHAR, @ActiveInd)
    PRINT '@PublicInd: ' + CONVERT(VARCHAR, @PublicInd)
    
    IF @Name is null OR ltrim(rtrim(@Name)) = '' BEGIN
      goto GetNextRow
    END

    IF @Tag is null OR ltrim(rtrim(@Tag)) = '' BEGIN
      goto GetNextRow
    END

    IF @UpdatedAt is null BEGIN
      goto GetNextRow
    END
    
    IF @ActiveInd = 1 and @PublicInd = 1 BEGIN
      -- try to match on eloquence tag
      SELECT @CountVar = count(*)
        FROM gentables
       WHERE tableid = @i_tableid
         AND upper(eloquencefieldtag) = upper(@Tag)
         --AND upper(COALESCE(deletestatus,'N')) = 'N'
         
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could access gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
        GOTO ExitHandler
      END       

      IF @CountVar > 0 BEGIN
        SELECT @LastMaintDate = lastmaintdate,
               @datacode = datacode
          FROM gentables
         WHERE tableid = @i_tableid
           AND upper(eloquencefieldtag) = upper(@Tag)
           --AND upper(COALESCE(deletestatus,'N')) = 'N'

        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could access gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
          GOTO ExitHandler
        END       

--print '@datacode: ' + cast(@datacode as varchar)
--print '@LastMaintDate: ' + cast(@LastMaintDate as varchar)
      
        IF @LastMaintDate is null OR @UpdatedAt > @LastMaintDate BEGIN
          UPDATE gentables
             SET datadesc = @Name,
                 datadescshort = substring(@Name,1,20),
                 lastuserid = 'Cloud',
                 lastmaintdate = getdate(),
                 deletestatus = 'N'
           WHERE tableid = @i_tableid
             AND datacode = @datacode
               
          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to update gentables tableid: ' + CONVERT(VARCHAR, @i_tableid) + '/datacode: ' + CONVERT(VARCHAR, @datacode)
            GOTO ExitHandler
          END
		  
          IF @itemtypefilter > 0 BEGIN
            -- add gentablesitemtype row if necessary
              
            SELECT @CountVar = count(*)
              FROM gentablesitemtype
             WHERE tableid = @i_tableid
               AND datacode = @datacode
               AND datasubcode = 0
               AND datasub2code = 0
               AND itemtypecode = @itemtypefilter
                   
            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Could access gentablesitemtype tableid: ' + CONVERT(VARCHAR, @i_tableid)
              GOTO ExitHandler
            END 
                
            IF @CountVar = 0 BEGIN
              -- doesn't exist - add it
              EXEC get_next_key 'Cloud', @newkey OUTPUT
                
              IF @newkey > 0 BEGIN
                INSERT INTO gentablesitemtype (gentablesitemtypekey,tableid,datacode,datasubcode,datasub2code,
                                               itemtypecode,itemtypesubcode,defaultind,lastuserid,lastmaintdate,
                                               sortorder)
                                       VALUES (@newkey,@i_tableid,@datacode,0,0,@itemtypefilter,0,0,'Cloud',getdate(),0)

                SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
                IF @ErrorVar <> 0 BEGIN
                  SET @o_error_code = -1
                  SET @o_error_desc = 'Could not insert into gentablesitemtype tableid: ' + CONVERT(VARCHAR, @i_tableid) + '/datacode: ' + CONVERT(VARCHAR, @datacode)
                  GOTO ExitHandler
                END                                           
              END
            END   
          END 
          
          goto GetNextRow         
        END
        
        ELSE
          BEGIN
          
            UPDATE gentables
               SET deletestatus = 'N'
             WHERE tableid = @i_tableid
               AND datacode = @datacode
                 
            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Unable to update gentables tableid: ' + CONVERT(VARCHAR, @i_tableid) + '/datacode: ' + CONVERT(VARCHAR, @datacode)
              GOTO ExitHandler
            END 
            
            goto GetNextRow  
          
          END
      END     
      ELSE BEGIN
        -- didn't match on eloquence tag - try to match on datadesc
        SELECT @CountVar = count(*)
          FROM gentables
         WHERE tableid = @i_tableid
           AND lower(datadesc) = lower(@Name)
           --AND upper(COALESCE(deletestatus,'N')) = 'N'
           
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could access gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
          GOTO ExitHandler
        END       
      
        IF @CountVar > 0 BEGIN
          IF @i_tableid = 287 BEGIN
            -- write to log
            print 'There is an existing value on the element table that matches the description of an asset type in the cloud - ' + @Name + 
                  '. Need to have unique name for asset - one that does not exist for other Elements.' 

            goto GetNextRow         
          END
          ELSE BEGIN          
            UPDATE gentables
               SET eloquencefieldtag = @Tag,
                   acceptedbyeloquenceind = 1,
                   lockbyeloquenceind = 1,
                   lockbyqsiind = 1,
                   lastuserid = 'Cloud',
                   lastmaintdate = getdate(),
                   deletestatus = 'N'
             WHERE tableid = @i_tableid
               AND lower(datadesc) = lower(@Name)
               AND upper(COALESCE(deletestatus,'N')) = 'N'
                 
            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Unable to update gentables tableid: ' + CONVERT(VARCHAR, @i_tableid) + '/datacode: ' + CONVERT(VARCHAR, @datacode)
              GOTO ExitHandler
            END       
            
            IF @itemtypefilter > 0 BEGIN
              -- add gentablesitemtype row if necessary
              SELECT @datacode = datacode
                FROM gentables
               WHERE tableid = @i_tableid
                 AND lower(datadesc) = lower(@Name)
                 --AND upper(COALESCE(deletestatus,'N')) = 'N'

              SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
              IF @ErrorVar <> 0 BEGIN
                SET @o_error_code = -1
                SET @o_error_desc = 'Could access gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
                GOTO ExitHandler
              END 
              
              IF @datacode > 0 BEGIN
                SELECT @CountVar = count(*)
                  FROM gentablesitemtype
                 WHERE tableid = @i_tableid
                   AND datacode = @datacode
                   AND datasubcode = 0
                   AND datasub2code = 0
                   AND itemtypecode = @itemtypefilter
                   
                SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
                IF @ErrorVar <> 0 BEGIN
                  SET @o_error_code = -1
                  SET @o_error_desc = 'Could access gentablesitemtype tableid: ' + CONVERT(VARCHAR, @i_tableid)
                  GOTO ExitHandler
                END 
                
                IF @CountVar = 0 BEGIN
                  -- doesn't exist - add it
                  EXEC get_next_key 'Cloud', @newkey OUTPUT
                  
                  IF @newkey > 0 BEGIN
                    INSERT INTO gentablesitemtype (gentablesitemtypekey,tableid,datacode,datasubcode,datasub2code,
                                                   itemtypecode,itemtypesubcode,defaultind,lastuserid,lastmaintdate,
                                                   sortorder)
                                           VALUES (@newkey,@i_tableid,@datacode,0,0,@itemtypefilter,0,0,'Cloud',getdate(),0)

                    SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
                    IF @ErrorVar <> 0 BEGIN
                      SET @o_error_code = -1
                      SET @o_error_desc = 'Could not insert into gentablesitemtype tableid: ' + CONVERT(VARCHAR, @i_tableid) + '/datacode: ' + CONVERT(VARCHAR, @datacode)
                      GOTO ExitHandler
                    END                                           
                  END
                END
              END      
            END      
            goto GetNextRow         
          END
        END
        ELSE BEGIN
          -- no match on datadesc - insert new row on gentables
          SELECT @datacode = COALESCE(max(datacode),0) + 1
            FROM gentables
           WHERE tableid = @i_tableid

          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could access gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
            GOTO ExitHandler
          END
          
          SET @gen1ind = null
          IF @i_tableid = 287 BEGIN
            -- asset/element type
            SET @gen1ind = 1
          END
          
          INSERT INTO gentables (tableid,datacode,datadesc,deletestatus,sortorder,tablemnemonic,datadescshort,lastuserid,lastmaintdate,
                                 acceptedbyeloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,gen1ind)
          SELECT @i_tableid,@datacode,@name,'N',0,tablemnemonic,substring(@name,1,20),'Cloud',getdate(),1,1,1,@tag,@gen1ind
            FROM gentablesdesc
           WHERE tableid = @i_tableid

          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could insert to gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
            GOTO ExitHandler
          END
 
          IF @itemtypefilter > 0 BEGIN
            -- add gentablesitemtype row
            EXEC get_next_key 'Cloud', @newkey OUTPUT
            
            IF @newkey > 0 BEGIN
              INSERT INTO gentablesitemtype (gentablesitemtypekey,tableid,datacode,datasubcode,datasub2code,
                                             itemtypecode,itemtypesubcode,defaultind,lastuserid,lastmaintdate,
                                             sortorder)
                                     VALUES (@newkey,@i_tableid,@datacode,0,0,@itemtypefilter,0,0,'Cloud',getdate(),0)

              SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
              IF @ErrorVar <> 0 BEGIN
                SET @o_error_code = -1
                SET @o_error_desc = 'Could not insert into gentablesitemtype tableid: ' + CONVERT(VARCHAR, @i_tableid) + '/datacode: ' + CONVERT(VARCHAR, @datacode)
                GOTO ExitHandler
              END                                           
            END
          END 
          
          IF @i_tableid = 287 BEGIN
            SELECT @datasubcode = COALESCE(max(datasubcode),0) + 1
              FROM subgentables
             WHERE tableid = 550
               AND datacode = 7

            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Could access subgentables tableid: 550/datacode: 7'
              GOTO ExitHandler
            END
              
            -- new asset/element type - need to create a usageclass (subgentable) under itemtype of element (datacode = 7)
            INSERT INTO subgentables (tableid,datacode,datasubcode,datadesc,deletestatus,tablemnemonic,datadescshort,
                                      lastuserid,lastmaintdate,lockbyqsiind)
            SELECT 550,7,@datasubcode,@name,'N',tablemnemonic,substring(@name,1,20),'Cloud',getdate(),1
              FROM gentablesdesc
             WHERE tableid = 550
             
            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Could not insert into subgentables tableid: 550/datcode: 7/datasubcode: ' + CONVERT(VARCHAR, @datasubcode)
              GOTO ExitHandler
            END                                           
          END       
        END   
      END     
    END
    ELSE BEGIN
      -- inactive or not public
      IF @i_fullreplaceind = 0 BEGIN
        SELECT @CountVar = count(*)
          FROM gentables
         WHERE tableid = @i_tableid
           AND upper(eloquencefieldtag) = upper(@Tag)
           --AND upper(COALESCE(deletestatus,'N')) = 'N'
           
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could access gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
          GOTO ExitHandler
        END       

        IF @CountVar > 0 BEGIN
          UPDATE gentables
             SET deletestatus = 'Y',
                 lastuserid = 'Cloud',
                 lastmaintdate = getdate()
           WHERE tableid = @i_tableid
             AND upper(eloquencefieldtag) = upper(@Tag)
           
          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could not update gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
            GOTO ExitHandler
          END      
        END
      END
    END
        
    GetNextRow:

    FETCH NEXT FROM gentable_cursor
    INTO @InactiveString, @UpdatedBy, @dtUpdatedAt, @Tag, @Name, @AlternateName, @InternalString
    SET @fetchStatus=@@FETCH_STATUS
  END

  CLOSE gentable_cursor
  DEALLOCATE gentable_cursor

  IF @i_fullreplaceind = 1 BEGIN
    -- set lastmaintdate for all rows still marked as inactive by cloud
    -- need to set lastmaintdate here because there is a check on lastmaintdate
    -- before the gentable entry is marked active
    UPDATE gentables
       SET lastmaintdate = getdate()
     WHERE tableid = @i_tableid
       AND deletestatus = 'Y'
       AND lastuserid = 'Cloud'
     
    SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
    IF @ErrorVar <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not update gentables tableid: ' + CONVERT(VARCHAR, @i_tableid)
      GOTO ExitHandler
    END      
  END
  
------------
ExitHandler:
------------

  -- Close criteria cursor if still valid
  IF CURSOR_STATUS('local', 'gentable_cursor') >= 0
  BEGIN
    CLOSE gentable_cursor
    DEALLOCATE gentable_cursor
  END

  IF @IsOpen = 1
    EXEC sp_xml_removedocument @DocNum

  IF @o_error_desc IS NOT NULL AND LTRIM(@o_error_desc) <> ''
    PRINT 'ERROR: ' + @o_error_desc  
END
GO

GRANT EXEC ON qcs_update_gentables TO PUBLIC
GO
