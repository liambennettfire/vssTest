IF EXISTS (
    SELECT *
    FROM sysobjects
    WHERE type = 'P'
      AND name = 'qutl_update_title_territories_in_list'
    )
BEGIN
  PRINT 'Dropping Procedure qutl_update_title_territories_in_list'

  DROP PROCEDURE qutl_update_title_territories_in_list
END
GO

PRINT 'Creating Procedure qutl_update_title_territories_in_list'
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE qutl_update_title_territories_in_list (
  @i_xmlParameters VARCHAR(max),
  @i_KeyNamePairs VARCHAR(max),
  @o_newKeys VARCHAR(max) OUTPUT,
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/******************************************************************************
**  Name: qutl_update_title_territories_in_list
**  Desc: This stored procedure loops through all titles within the passed list
**        and executes the passes dbchangerequest xml against each bookkey by replacing
**        the variable '??bookkey??'
**
**  Auth: Colman
**  Case: 42604
**  Date: 06/12/2018
*******************************************************************************/
DECLARE 
  @v_error_code INT,
  @v_error_desc VARCHAR(2000),
  @v_bookkey INT,
  @v_printingkey INT,
  @v_territoryrightskey INT,
  @v_overridepropagationind INT,
  @v_title VARCHAR(max),
  @v_derivedFromContract INT,
  @v_searchitemcode INT,
  @v_accesscode INT,
  @v_docnum INT,
  @v_failedind BIT,
  @v_doc_is_open BIT,
  @v_listkey INT,
  @v_errorcode INT,
  @v_errordesc VARCHAR(2000),
  @v_tempidx INT,
  @v_tempstr VARCHAR(100),
  @v_userid VARCHAR(30),
  @v_userkey INT,
  @v_filterorglevelkey INT,
  @v_orgentrykey INT,
  @v_org_accesscode INT,
  @v_sql NVARCHAR(max),
  @v_dbchangerequest VARCHAR(max),
  @v_xml VARCHAR(max),
  @v_xml_temp VARCHAR(max),
  @v_warnings VARCHAR(4000),
  @v_trancount INT

SET NOCOUNT ON

SET @v_doc_is_open = 0
SET @v_failedind = 0
SET @o_error_code = 0
SET @o_error_desc = ''
SET @v_trancount = @@TRANCOUNT

BEGIN TRY

  -- exec qutl_trace 'qutl_update_title_territories_in_list', 
    -- '@i_xmlParameters', NULL, @i_xmlParameters

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @v_docnum OUTPUT,
    @i_xmlParameters

  SET @v_doc_is_open = 1

  -- Extract parameters to the calling function from passed XML
  SELECT @v_userkey = UserKey,
    @v_listkey = ListKey,
    @v_dbchangerequest = DBChangeRequest
  FROM OPENXML(@v_docnum, '//Parameters') WITH (
      UserKey INT 'UserKey',
      ListKey INT 'ListKey',
      DBChangeRequest VARCHAR(MAX) 'DBChangeRequest'
      )

  -- Embedded XML is base64 encoded to avoid parsing weirdness
  SELECT @v_xml = CAST(CAST(N'' AS XML).value('xs:base64Binary(sql:column("bin"))', 'VARBINARY(MAX)') AS VARCHAR(MAX))
  FROM (
    SELECT CAST(@v_dbchangerequest AS VARCHAR(MAX)) AS bin
    ) AS bin_sql_server_temp;

  -- exec qutl_trace 'qutl_update_title_territories_in_list', 
    -- '@v_listkey', @v_listkey, NULL,
    -- '@v_xml', NULL, @v_xml,
    -- '@v_userkey', @v_userkey

  SELECT @v_userid = userid
  FROM qsiusers
  WHERE userkey = @v_userkey

  -- Make sure qsiusers record exists for this userkey
  IF @v_userid IS NULL
  BEGIN
    SET @o_error_code = - 1
    SET @o_error_desc = 'Error getting UserID from qsiusers table (userkey=' + CONVERT(VARCHAR, @v_userkey) + ').'

    GOTO ExitHandler
  END

  SELECT @v_filterorglevelkey = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = 7 -- User Org Access Level    

  IF @v_filterorglevelkey IS NULL
  BEGIN
    SET @o_error_code = - 1
    SET @o_error_desc = 'No user Org Access level configured.'

    GOTO ExitHandler
  END

  SELECT @v_searchitemcode = searchitemcode
  FROM qse_searchlist
  WHERE listkey = @v_listkey

  -- Delete any existing update feedback rows for this user/searchitemcode
  DELETE
  FROM qse_updatefeedback
  WHERE userkey = @v_userkey
    AND searchitemcode = @v_searchitemcode

  SELECT c.bookkey,
    c.printingkey,
    tr.territoryrightskey,
    isnull(tr.overridepropagationind, 0) overridepropagationind,
    c.title,
    d.territoryderivedfromcontractind
  INTO #temp_titles
  FROM qse_searchresults sr
  INNER JOIN coretitleinfo c
    ON c.bookkey = sr.key1
      AND c.printingkey = sr.key2
  INNER JOIN bookdetail d
    ON d.bookkey = sr.key1
  LEFT JOIN territoryrights tr
    ON tr.bookkey = sr.key1
  WHERE sr.listkey = @v_listkey

  -- ****** Loop through all items in the list *****
  DECLARE updatetitle_cur CURSOR LOCAL
  FOR
  SELECT bookkey,
    printingkey,
    territoryrightskey,
    overridepropagationind,
    title,
    territoryderivedfromcontractind
  FROM #temp_titles

  OPEN updatetitle_cur

  FETCH NEXT FROM updatetitle_cur
  INTO @v_bookkey,
    @v_printingkey,
    @v_territoryrightskey,
    @v_overridepropagationind,
    @v_title,
    @v_derivedFromContract

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- exec qutl_trace 'qutl_update_title_territories_in_list',
      -- '@v_bookkey', @v_bookkey, NULL,
      -- '@v_printingkey', @v_printingkey, NULL,
      -- '@v_territoryrightskey', @v_territoryrightskey, NULL,
      -- '@v_overridepropagationind', @v_overridepropagationind, NULL,
      -- '@v_title', NULL, @v_title,
      -- '@v_derivedFromContract', @v_derivedFromContract, NULL

    IF @v_derivedFromContract = 1
    BEGIN
      SET @v_failedind = 1
      SET @v_error_desc = 'Could not update title. Territory Rights are derived from a contract.'

      INSERT INTO qse_updatefeedback (
        userkey,
        searchitemcode,
        key1,
        key2,
        itemdesc,
        message,
        runtime
        )
      VALUES (
        @v_userkey,
        @v_searchitemcode,
        @v_bookkey,
        @v_printingkey,
        @v_title,
        @v_error_desc,
        getdate()
        )

      GOTO FetchNext
    END

    -- ****** BEGIN TRANSACTION for this title ******
    BEGIN TRANSACTION

    -- Lock title
    -- Returned ACCESS CODE:
    --  0 (Locked By Another User)
    --  1 (Not Locked or Locked By This User already)
    -- -1 (Error)
    EXEC qutl_add_object_lock @v_userid,
      'booklock',
      'bookkey',
      'printingkey',
      @v_bookkey,
      0,
      'title',
      'TMMW',
      @v_accesscode OUTPUT,
      @v_error_code OUTPUT,
      @v_error_desc OUTPUT

    SET @v_orgentrykey = NULL
    SET @v_org_accesscode = 2

    SELECT @v_orgentrykey = b.orgentrykey
    FROM orglevel o
    INNER JOIN bookorgentry b
      ON o.orglevelkey = b.orglevelkey
        AND b.bookkey = @v_bookkey
        AND b.orglevelkey = @v_filterorglevelkey

    IF @v_accesscode = 1
      AND @v_orgentrykey IS NOT NULL
    BEGIN
      EXEC qutl_check_user_orgsecurity @v_userkey,
        @v_orgentrykey,
        @v_org_accesscode OUTPUT,
        @v_error_code OUTPUT,
        @v_error_desc OUTPUT

      IF @v_org_accesscode <> 2
      BEGIN
        SET @v_error_desc = @v_userid + ' does not have rights to change this title: Org Level security set to Read Only / No Access.'
        SET @v_failedind = 1

        INSERT INTO qse_updatefeedback (
          userkey,
          searchitemcode,
          key1,
          key2,
          itemdesc,
          message,
          runtime
          )
        VALUES (
          @v_userkey,
          @v_searchitemcode,
          @v_bookkey,
          @v_printingkey,
          @v_title,
          @v_error_desc,
          getdate()
          )

        EXEC qutl_remove_object_lock @v_userid,
          'booklock',
          'bookkey',
          'printingkey',
          @v_bookkey,
          0,
          'title',
          'TMMW',
          @v_error_code OUTPUT,
          @v_error_desc OUTPUT

        GOTO FetchNext
      END
    END

    IF @v_accesscode = 1
      AND @v_org_accesscode = 2
    BEGIN
      EXEC qtitle_delete_territoryrights @v_bookkey,
        @v_error_code OUTPUT,
        @v_error_desc OUTPUT

      -- In all other cases, use our generic stored procedure parameters
      SET @v_sql = N'exec qutl_dbchange_request @v_xml, @o_newKeys output, @v_warnings output, @v_errorcode output, @v_errordesc output'
      SET @v_xml_temp = REPLACE(@v_xml, '??bookkey??', @v_bookkey)

      --exec qutl_trace 'qutl_update_title_territories_in_list', 
      --  '@v_xml_temp', NULL, @v_xml_temp

      EXECUTE sp_executesql @v_sql,
        N'@v_xml varchar(max), 
          @o_newKeys varchar(4000) output, @v_warnings varchar(4000) output,
          @v_errorcode int output, @v_errordesc varchar(2000) output',
        @v_xml = @v_xml_temp,
        @o_newKeys = @o_newKeys OUTPUT,
        @v_warnings = @v_warnings OUTPUT,
        @v_errorcode = @v_errorcode OUTPUT,
        @v_errordesc = @v_errordesc OUTPUT

      IF @v_errorcode <> 0
      BEGIN
        SET @v_error_desc = 'Error updating territory rights: ' + @v_error_desc
        SET @v_failedind = 1

        INSERT INTO qse_updatefeedback (
          userkey,
          searchitemcode,
          key1,
          key2,
          itemdesc,
          message,
          runtime
          )
        VALUES (
          @v_userkey,
          @v_searchitemcode,
          @v_bookkey,
          @v_printingkey,
          @v_title,
          @v_error_desc,
          getdate()
          )

        GOTO FetchNext
      END

      -- ********* Remove lock for this title ********  
      EXEC qutl_remove_object_lock @v_userid,
        'booklock',
        'bookkey',
        'printingkey',
        @v_bookkey,
        0,
        'title',
        'TMMW',
        @v_error_code OUTPUT,
        @v_error_desc OUTPUT
    END
    ELSE
    BEGIN -- @v_accesscode=0 (locked by other user) OR @v_accesscode=-1 (error), @v_org_accesscode = 0 or 1 (Read Only / No Access Org Level Security set)
      PRINT '  @v_accesscode=' + CONVERT(VARCHAR, @v_accesscode)
      PRINT '  @v_org_accesscode=' + CONVERT(VARCHAR, @v_org_accesscode)

      -- Could not lock and update title - write to qse_updatefeedback table
      SET @v_failedind = 1
      SET @v_tempidx = CHARINDEX('.', @v_error_desc, 0)
      SET @v_error_desc = SUBSTRING(@v_error_desc, 0, @v_tempidx + 1)

      INSERT INTO qse_updatefeedback (
        userkey,
        searchitemcode,
        key1,
        key2,
        itemdesc,
        message,
        runtime
        )
      VALUES (
        @v_userkey,
        @v_searchitemcode,
        @v_bookkey,
        @v_printingkey,
        @v_title,
        @v_error_desc,
        getdate()
        )

    END

    COMMIT TRANSACTION

    FetchNext:

    FETCH NEXT FROM updatetitle_cur
    INTO @v_bookkey,
      @v_printingkey,
      @v_territoryrightskey,
      @v_overridepropagationind,
      @v_title,
      @v_derivedFromContract
  END

  CLOSE updatetitle_cur

  DEALLOCATE updatetitle_cur

  GOTO ExitHandler

;END TRY
BEGIN CATCH
  SET @o_error_code = -1
  SET @o_error_desc = 'Error in procedure ''' + ERROR_PROCEDURE() + ''': ' + ERROR_MESSAGE()

  IF @@TRANCOUNT > @v_trancount
    ROLLBACK TRANSACTION
END CATCH;

ExitHandler:

IF EXISTS (
    SELECT *
    FROM tempdb..sysobjects
    WHERE id = object_id('tempdb.dbo.#temp_titles')
    )
  DROP TABLE #temp_titles

IF CURSOR_STATUS('local', 'updatetitle_cur') = 1
BEGIN
  CLOSE updatetitle_cur
  DEALLOCATE updatetitle_cur
END

IF @v_doc_is_open = 1
BEGIN
  EXEC sp_xml_removedocument @v_docnum
END

IF @o_error_desc IS NOT NULL AND LTRIM(RTRIM(@o_error_desc)) <> ''
  PRINT @o_error_desc

-- Flag this update to indicate to the calling function that some titles 
-- within the passed list could not be updated (qse_updatefeedback records exist)
IF @v_failedind = 1
  SET @o_error_code = - 2

GO

GRANT EXEC
  ON qutl_update_title_territories_in_list
  TO PUBLIC
GO


