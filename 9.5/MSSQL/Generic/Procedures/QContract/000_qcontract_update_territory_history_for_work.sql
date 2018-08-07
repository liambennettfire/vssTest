if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_update_territory_history_for_work') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_update_territory_history_for_work
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_update_territory_history_for_work
 (@i_contractprojectkey	integer,
  @i_tablename					varchar(50),
  @i_actiontype					varchar(20),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/************************************************************************************
**  Name: qcontract_update_territory_history_for_work
**  Desc: 
**
**  Auth: Dustin Miller
**  Date: 8/13/12
*************************************************************************************/

BEGIN

  DECLARE
		@v_bookkey									INT,
		@v_bookkey_count						INT,
		@v_printingkey							INT,
		@v_gentablesrelationshipkey INT,
		@v_relationshipTabCode			INT,
		@v_qsicode									INT,
    @v_error										INT,
    @v_rowcount									INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	DECLARE @booktable TABLE
	(
		bookkey	int,
		printingkey int
	)
	
	SET @v_qsicode = 15
	
	SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
	FROM gentablesrelationships
	WHERE gentable1id = 605
		AND gentable2id = 583

	SELECT @v_relationshipTabCode = datacode FROM gentables where tableid = 583 and qsicode = 15
	
	INSERT INTO @booktable
	SELECT r.bookkey, r.printingkey
	FROM taqprojecttitle r
	JOIN bookdetail d ON (d.bookkey = r.bookkey)
	LEFT OUTER JOIN coretitleinfo c ON r.bookkey = c.bookkey AND COALESCE(r.printingkey,1) = c.printingkey  
	WHERE r.taqprojectkey = @i_contractprojectkey
		AND d.territoryderivedfromcontractind = 1
		AND titlerolecode in (SELECT datacode from gentables
													WHERE tableid = 605
														AND ((datacode in (SELECT distinct code1 FROM gentablesrelationshipdetail
																								WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey
																									AND code2 = @v_relationshipTabCode)) OR
																	-- Case #18293 - Only show title roles not configured for any tab if we are on the 
																	-- generic titles tab on projects (qsicode = 15)
																 (@v_qsicode = 15 and datacode not in (SELECT distinct code1 FROM gentablesrelationshipdetail
																										WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey))))
  
  SELECT @v_bookkey_count = COUNT(bookkey)
  FROM @booktable
  
  IF @v_bookkey_count IS NOT NULL AND @v_bookkey_count > 0
  BEGIN
		DECLARE book_cursor CURSOR FAST_FORWARD FOR
		SELECT bookkey, printingkey
		FROM @booktable
		
		OPEN book_cursor
		
		FETCH book_cursor
		INTO @v_bookkey, @v_printingkey
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC qtitle_update_titlehistory @i_tablename, '(multiple)', @v_bookkey, @v_printingkey, 0,
				NULL, @i_actiontype, 'qsidba', 0, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT
			
			FETCH book_cursor
			INTO @v_bookkey, @v_printingkey
		END
		
		CLOSE book_cursor
		DEALLOCATE book_cursor
	 
	END
  
END
GO

GRANT EXEC ON qcontract_update_territory_history_for_work TO PUBLIC
GO
