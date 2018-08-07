IF EXISTS (SELECT *
             FROM sys.objects
             WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_formats]')
               AND type IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qproject_copy_project_formats]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_formats]    Script Date: 07/16/2008 10:31:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_formats]
(
  @i_copy_projectkey INTEGER,
  @i_copy2_projectkey INTEGER,
  @i_new_projectkey INTEGER,
  @i_userid VARCHAR(30),
  @i_cleardatagroups_list VARCHAR(MAX),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /**************************************************************************************************************************
**  Name: [qproject_copy_project_formats]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/10/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
*****************************************************************************************************************************/

DECLARE 
  @error_var                    INT,
  @rowcount_var                 INT,
  @newkey                       INT,
  @v_cursor_taqprojectformatkey INT,
  @v_maxsort					INT,
  @v_sortorder					INT,
  @v_seasoncode					INT, 
  @v_seasonfirmind				TINYINT,
  @v_mediatypecode				INT,
  @v_mediatypesubcode			INT,
  @v_discountcode				SMALLINT,
  @v_price						NUMERIC(9, 2),
  @v_initialrun					INT,
  @v_projectdollars				NUMERIC(15, 2),
  @v_marketingplancode			INT,
  @v_primaryformatind			TINYINT,
  @v_taqprojectformatdesc		VARCHAR(120),
  @v_projectrolecode			INT,
  @v_titlerolecode				INT,
  @v_keyind						TINYINT,
  @v_indicator1					TINYINT,
  @v_indicator2					TINYINT,
  @v_quantity1					INT,
  @v_quantity2					INT,	
  @v_relateditem2name			VARCHAR(100),
  @v_relateditem2status			VARCHAR(100),	
  @v_relateditem2participants	VARCHAR(100),
  @v_decimal1					DECIMAL(14, 4),
  @v_decimal2					DECIMAL(14, 4),	
  @v_currencytypecode			SMALLINT,
  @v_newprojectitemtype			INT,
  @v_newprojectusageclass		INT  
        
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'copy project key not passed to copy formats (' + cast(
      @error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS
      VARCHAR)
      RETURN
    END

  IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'new project key not passed to copy formats (' + cast(@error_var
      AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)
      RETURN
    END
    
-- only want to copy items types that are defined for the new project
  IF (@i_new_projectkey > 0)
  BEGIN
    SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
    FROM taqproject
    WHERE taqprojectkey = @i_new_projectkey

    IF @v_newprojectitemtype is null or @v_newprojectusageclass = 0
    BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Unable to copy elements because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	  RETURN
    END
  
    IF @v_newprojectusageclass is null 
      SET @v_newprojectusageclass = 0
  END     

  DECLARE taqProjectTitleCursor CURSOR FOR
  SELECT taqprojectformatkey, MAX(sortorder), seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
			discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
			taqprojectformatdesc, projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
			quantity1, quantity2, relateditem2name, relateditem2status,	 relateditem2participants,
			decimal1, decimal2, currencytypecode 
  FROM taqprojecttitle
  WHERE taqprojectkey = @i_copy_projectkey AND titlerolecode = 2
  GROUP BY taqprojectformatkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
			discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
			taqprojectformatdesc, projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
			quantity1, quantity2, relateditem2name, relateditem2status,	 relateditem2participants,
			decimal1, decimal2, currencytypecode 
  ORDER BY taqprojectformatkey ASC

  OPEN taqProjectTitleCursor

  FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey, @v_maxsort, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
		@v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
		@v_taqprojectformatdesc, @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2,
		@v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status,	 @v_relateditem2participants,
		@v_decimal1, @v_decimal2, @v_currencytypecode 

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
  
    IF (@v_seasoncode IS NOT NULL AND @v_seasoncode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(329, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_seasoncode = NULL	
    END
    
    IF (@v_mediatypecode IS NOT NULL AND @v_mediatypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_mediatypecode = NULL	
	   SET @v_mediatypesubcode = NULL
    END
    ELSE IF (@v_mediatypesubcode IS NOT NULL AND @v_mediatypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_mediatypecode)) BEGIN	
	   SET @v_mediatypesubcode = NULL
    END     
    
    IF (@v_discountcode IS NOT NULL AND @v_discountcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(459, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_discountcode = NULL	
    END    
    
    IF (@v_marketingplancode IS NOT NULL AND @v_marketingplancode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(524, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_marketingplancode = NULL	
    END    
    
    IF (@v_projectrolecode IS NOT NULL AND @v_projectrolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(604, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_projectrolecode = NULL	
    END     
    
    IF (@v_titlerolecode IS NOT NULL AND @v_titlerolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(605, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_titlerolecode = NULL	
    END    
    
    IF (@v_currencytypecode IS NOT NULL AND @v_currencytypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(122, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	   SET @v_currencytypecode = NULL	
    END      

    EXEC get_next_key @i_userid, @newkey OUTPUT

    INSERT INTO taqprojecttitle
      (taqprojectformatkey, taqprojectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
      discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind, taqprojectformatdesc, 
      projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2, quantity1, quantity2, 
      relateditem2name, relateditem2status, relateditem2participants, lastuserid, lastmaintdate, decimal1, decimal2, currencytypecode)
   VALUES(@newkey, @i_new_projectkey, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
      @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind, @v_taqprojectformatdesc, 
      @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2, @v_quantity1, @v_quantity2, 
      @v_relateditem2name, @v_relateditem2status, @v_relateditem2participants, @i_userid, getdate(), @v_decimal1, @v_decimal2, @v_currencytypecode)

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'copy/insert into taqprojecttitle failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)
      CLOSE taqProjectTitleCursor
      DEALLOCATE taqProjectTitleCursor
      RETURN
    END
    
    FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey, @v_maxsort, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
		@v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
		@v_taqprojectformatdesc, @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2,
		@v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status,	 @v_relateditem2participants,
		@v_decimal1, @v_decimal2, @v_currencytypecode 
  END

  CLOSE taqProjectTitleCursor
  DEALLOCATE taqProjectTitleCursor

  /* 4/30/12 - KW - From case 17842:
  Project Format (4): copy from i_copy_projectkey; add non-existing project formats from i_copy2_projectkey */
  IF @i_copy2_projectkey > 0
  BEGIN
    DECLARE taqProjectTitleCursor CURSOR FOR
      SELECT t1.taqprojectformatkey, t1.seasoncode, t1.seasonfirmind, t1.mediatypecode, t1.mediatypesubcode,
			 t1.discountcode, t1.price, t1.initialrun, t1.projectdollars, t1.marketingplancode, t1.primaryformatind,
			 t1.taqprojectformatdesc, t1.projectrolecode, t1.titlerolecode, t1.keyind, t1.indicator1, t1.indicator2,
			 t1.quantity1, t1.quantity2, t1.relateditem2name, t1.relateditem2status, t1.relateditem2participants,
			 t1.decimal1, t1.decimal2, t1.currencytypecode 
      FROM taqprojecttitle t1
      WHERE t1.taqprojectkey = @i_copy2_projectkey AND t1.titlerolecode = 2 AND
         NOT EXISTS (SELECT * FROM taqprojecttitle t2 
                     WHERE t1.mediatypecode = t2.mediatypecode AND t1.mediatypesubcode = t2.mediatypesubcode AND t2.taqprojectkey = @i_copy_projectkey)
      ORDER BY taqprojectformatkey ASC     

    OPEN taqProjectTitleCursor

    SET @v_sortorder = @v_maxsort + 1

    FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
		@v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
		@v_taqprojectformatdesc, @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_indicator1, @v_indicator2,
		@v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status,	 @v_relateditem2participants,
		@v_decimal1, @v_decimal2, @v_currencytypecode 

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
    
	  IF (@v_seasoncode IS NOT NULL AND @v_seasoncode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(329, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
		 SET @v_seasoncode = NULL	
	  END
	    
      IF (@v_mediatypecode IS NOT NULL AND @v_mediatypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
		 SET @v_mediatypecode = NULL	
		 SET @v_mediatypesubcode = NULL
	  END
	  ELSE IF (@v_mediatypesubcode IS NOT NULL AND @v_mediatypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_mediatypecode)) BEGIN	
		 SET @v_mediatypesubcode = NULL
	  END     
	    
	  IF (@v_discountcode IS NOT NULL AND @v_discountcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(459, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
		 SET @v_discountcode = NULL	
	  END    
	    
	  IF (@v_marketingplancode IS NOT NULL AND @v_marketingplancode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(524, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
		 SET @v_marketingplancode = NULL	
	  END    
	    
	  IF (@v_projectrolecode IS NOT NULL AND @v_projectrolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(604, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
		 SET @v_projectrolecode = NULL	
	  END     
	    
	  IF (@v_titlerolecode IS NOT NULL AND @v_titlerolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(605, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
		 SET @v_titlerolecode = NULL	
	  END    
	    
	  IF (@v_currencytypecode IS NOT NULL AND @v_currencytypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(122, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	     SET @v_currencytypecode = NULL	
	  END     

      EXEC get_next_key @i_userid, @newkey OUTPUT

      INSERT INTO taqprojecttitle
        (taqprojectformatkey, taqprojectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
        discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind, taqprojectformatdesc, 
        projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2, quantity1, quantity2, 
        relateditem2name, relateditem2status, relateditem2participants, lastuserid, lastmaintdate, decimal1, decimal2,currencytypecode)
      VALUES(@newkey, @i_new_projectkey, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
        @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind, @v_taqprojectformatdesc, 
        @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2, @v_indicator1, @v_indicator2,
        @v_relateditem2name, @v_relateditem2status,	 @v_relateditem2participants, @i_userid, getdate(), @v_decimal1, @v_decimal2, @v_currencytypecode)

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'copy/insert into taqprojecttitle failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)
        CLOSE taqProjectTitleCursor
        DEALLOCATE taqProjectTitleCursor
        RETURN
      END
      
      SET @v_sortorder = @v_sortorder + 1
      
      FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
		@v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
		@v_taqprojectformatdesc, @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_indicator1, @v_indicator2,
		@v_indicator1, @v_indicator2, @v_relateditem2name, @v_relateditem2status,	 @v_relateditem2participants,
		@v_decimal1, @v_decimal2, @v_currencytypecode 
    END

    CLOSE taqProjectTitleCursor
    DEALLOCATE taqProjectTitleCursor
  END

END
go
