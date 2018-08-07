IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcs_update_status_datetypes')
DROP PROCEDURE  qcs_update_status_datetypes
GO

CREATE PROCEDURE qcs_update_status_datetypes
(
  @i_gentableinfo_xml   NVARCHAR(max),
  @i_transaction_type   INT,
  @i_status_tableid     INT,
  @i_taskview_qsicode   INT,
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
    @CancellationString VARCHAR(5),
    @UpdatedAt DATETIME,
    @Tag VARCHAR(25),
    @Name VARCHAR(50),
    @AlternateName VARCHAR(50),
    @GentableType VARCHAR(50),
    @NodePath varchar(50),
    @PublicInd TINYINT,
    @CancellationInd TINYINT,
    @datacode INT,
    @LastMaintDate DATETIME,
    @newkey INT,
    @gen1ind INT,
    @datasubcode INT,
    @status_datacode INT,
    @datetypecode INT,
    @taskviewkey INT,
    @x XML,
    @sqlstmt nvarchar(2000)

  IF @i_gentable_type is null OR ltrim(rtrim(@i_gentable_type)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'gentable_type must be passed in'
    GOTO ExitHandler
  END
  
  SET ARITHABORT ON 
  SET QUOTED_IDENTIFIER ON
  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @x = @i_gentableinfo_xml

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @i_gentableinfo_xml,'<Test xmlns:x="http://cloud.firebrandtech.com/"/>'

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the xml record'
    GOTO ExitHandler
  END
  SET @IsOpen = 1
        
  SET @NodePath = @i_gentable_type
  
  -- Loop to get all elements from the passed XML document
--  DECLARE gentable_cursor CURSOR LOCAL FOR 
--  
--  WITH XMLNAMESPACES ( default 'http://cloud.firebrandtech.com/' ) 
--  SELECT t.c.query('inactive').value('.','varchar(5)') as InactiveString,
--          t.c.query('tag').value('.','varchar(25)') as Tag,
--          t.c.query('name').value('.','varchar(255)') as Name,        
--          --CONVERT(datetime, t.c.value('(updated-at)[1]','nvarchar(50)'), 127) AS lastmaintdate,
--          t.c.query('alternate-name').value('.','varchar(50)') as AlternateName,
--          t.c.query('internal').value('.','varchar(255)') as InternalString,
--          t.c.query('cancellation').value('.','varchar(255)') as CancellationString
--  FROM	 @x.nodes('asset-statuses/asset-status') t(c)

  DECLARE gentable_cursor CURSOR LOCAL FOR 
    SELECT InactiveString,Tag,Name,
           AlternateName,InternalString,CancellationString
    FROM OPENXML(@DocNum,  @NodePath)
    WITH (InactiveString VARCHAR(5) 'x:inactive', 
          Tag VARCHAR(25) 'x:tag',
          Name VARCHAR(50) 'x:name',
          AlternateName VARCHAR(50) 'x:alternate-name',
          InternalString VARCHAR(5) 'x:internal',
          CancellationString VARCHAR(5) 'x:cancellation')
  
  OPEN gentable_cursor

  FETCH NEXT FROM gentable_cursor
  INTO @InactiveString, @Tag, @Name, @AlternateName, @InternalString, @CancellationString

  IF @@FETCH_STATUS <> 0	BEGIN -- no updates for this gentable - return  
    SET @o_error_code = 1
    SET @o_error_desc = 'No status updates for tableid ' + CAST(@i_status_tableid as varchar)
    GOTO ExitHandler
  END
  
  WHILE @@FETCH_STATUS = 0 BEGIN
    --DEBUG
    PRINT '@Name: ' + @Name
    PRINT '@Tag: ' + @Tag
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

    SET @CancellationInd = 0
    IF lower(@CancellationString) = 'true' BEGIN
      SET @CancellationInd = 1
    END

    --DEBUG
    PRINT '@ActiveInd: ' + CONVERT(VARCHAR, @ActiveInd)
    PRINT '@PublicInd: ' + CONVERT(VARCHAR, @PublicInd)
    PRINT '@CancellationInd: ' + CONVERT(VARCHAR, @CancellationInd)
    
    IF @Name is null OR ltrim(rtrim(@Name)) = '' BEGIN
      goto GetNextRow
    END

    IF @Tag is null OR ltrim(rtrim(@Tag)) = '' BEGIN
      goto GetNextRow
    END

--    IF @UpdatedAt is null BEGIN
--      goto GetNextRow
--    END
             
    -- for cancelled distribution statuses, set gen1ind = 1 otherwise set to 0
    IF @i_status_tableid = 576 BEGIN
      print '@CancellationInd: ' + cast(@CancellationInd as varchar)   
    
      UPDATE gentables
         SET gen1ind = COALESCE(@CancellationInd,0)
       WHERE tableid = @i_status_tableid
         AND upper(eloquencefieldtag) = upper(@Tag)

      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not update gentables to set gen1ind for distribution status tableid: ' + CONVERT(VARCHAR, @i_status_tableid) + '/Tag: ' + @Tag
        GOTO ExitHandler
      END       
    END
              
    IF @ActiveInd = 1 and @PublicInd = 1 BEGIN
      -- Get status datacode
      SELECT @status_datacode = datacode
        FROM gentables
       WHERE tableid = @i_status_tableid
         AND upper(eloquencefieldtag) = upper(@Tag)
    
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not access gentables to get status datacode from gentables tableid: ' + CONVERT(VARCHAR, @i_status_tableid)
        GOTO ExitHandler
      END       

      IF @RowcountVar = 0 OR @status_datacode is null OR @status_datacode <= 0 BEGIN
        -- status datacode not found
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not get status datacode from gentables tableid: ' + CONVERT(VARCHAR, @i_status_tableid)
        GOTO ExitHandler
      END       
    
     UPDATE datetype SET cstransactioncode = @i_transaction_type, csstatuscode = @status_datacode, usedexclusivelybycsind = 1, eloquencefieldtag = @Tag
     WHERE upper([description]) = upper(@AlternateName) AND activeind = 1
     
     UPDATE datetype SET qsicode = 16
     WHERE upper([description]) = upper('Approve Asset') AND activeind = 1
      
      SELECT @CountVar = count(*)
        FROM datetype
       WHERE cstransactioncode = @i_transaction_type
         AND csstatuscode = @status_datacode
      
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not access datetype table'
        GOTO ExitHandler
      END       
    
      IF @CountVar = 0 BEGIN
        SELECT @CountVar = count(*)
          FROM datetype
         WHERE upper([description]) = upper(@AlternateName)
           AND activeind = 1
        
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not access datetype table'
          GOTO ExitHandler
        END       
        
        IF @CountVar > 0 BEGIN
          -- error - write to log
          GOTO GetNextRow
        END
        ELSE BEGIN
          -- insert to datetype
	        SELECT @newkey = COALESCE(MAX(datetypecode),0) + 1
	          FROM datetype
           WHERE datetypecode < 20000

          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could not access datetype table'
            GOTO ExitHandler
          END       

          INSERT INTO datetype
              (datetypecode, [description], printkeydependent, changetitlestatusind, datelabel, datelabelshort, tableid, lastuserid, lastmaintdate,
              acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, activeind, qsicode, contractind, advanceind, showintaqind,
              csstatuscode,cstransactioncode,usedexclusivelybycsind, eloquencefieldtag)
	        VALUES
              (@newkey, @AlternateName, 0, 0, @AlternateName, substring(@AlternateName,1,10), 323, 'Cloud-WindowsService', getdate(),
              0, 0, 1, 1, 1, 0, 0, 0, 1, @status_datacode, @i_transaction_type, 1 ,@Tag)

          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could not insert into datetype table'
            GOTO ExitHandler
          END       
          
          IF @i_taskview_qsicode > 0 BEGIN
            SELECT @taskviewkey = taskviewkey
              FROM taskview
             WHERE qsicode = @i_taskview_qsicode

            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Could not access taskview table for qsicode: ' + CONVERT(VARCHAR, @i_taskview_qsicode)
              GOTO ExitHandler
            END       
                     
            IF @taskviewkey > 0 BEGIN
              INSERT INTO taskviewdatetype (taskviewkey, datetypecode, sortorder, lastuserid, lastmaintdate)
              VALUES (@taskviewkey, @newkey, 0, 'Cloud-WindowsService', getdate())
               
              SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
              IF @ErrorVar <> 0 BEGIN
                SET @o_error_code = -1
                SET @o_error_desc = 'Could not insert into datetype table'
                GOTO ExitHandler
              END       
            END
          END
        END
      END 
    END
    ELSE BEGIN
      -- inactive or not public
      -- Get status datacode
      SELECT @status_datacode = datacode
        FROM gentables
       WHERE tableid = @i_status_tableid
         AND upper(eloquencefieldtag) = upper(@Tag)
    
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not access gentables to get status datacode from gentables tableid: ' + CONVERT(VARCHAR, @i_status_tableid)
        GOTO ExitHandler
      END       

      IF @RowcountVar = 0 OR @status_datacode is null OR @status_datacode <= 0 BEGIN
        -- status datacode not found - no gentable row for the status (status has never been public) 
        -- no datetype to inactivate
        GOTO GetNextRow
      END       
    
      SELECT @CountVar = count(*)
        FROM datetype
       WHERE cstransactioncode = @i_transaction_type
         AND csstatuscode = @status_datacode
      
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not access datetype table'
        GOTO ExitHandler
      END       
      
      IF @CountVar > 0 BEGIN
        SELECT @datetypecode = count(*)
          FROM datetype
         WHERE cstransactioncode = @i_transaction_type
           AND csstatuscode = @status_datacode
        
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not access datetype table'
          GOTO ExitHandler
        END       

        -- mark datetype as inactive
        UPDATE datetype
           SET activeind = 0,
               lastuserid = 'Cloud',
               lastmaintdate = getdate()
         WHERE datetypecode = @datetypecode

        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not update datetype table (inactivate) datetypecode: ' + CONVERT(VARCHAR, @datetypecode)
          GOTO ExitHandler
        END       
      END      
    END
    
    GetNextRow:

    FETCH NEXT FROM gentable_cursor
    INTO @InactiveString, @Tag, @Name, @AlternateName, @InternalString, @CancellationString
  END

  CLOSE gentable_cursor
  DEALLOCATE gentable_cursor

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

GRANT EXEC ON qcs_update_status_datetypes TO PUBLIC
GO
