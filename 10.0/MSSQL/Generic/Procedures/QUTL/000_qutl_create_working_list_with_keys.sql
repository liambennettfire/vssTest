IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_create_working_list_with_keys')
  BEGIN
    DROP PROCEDURE  qutl_create_working_list_with_keys
  END
GO

PRINT 'Creating Procedure qutl_create_working_list_with_keys'
GO

CREATE PROCEDURE qutl_create_working_list_with_keys
 (@i_itemkeys    varchar(max), --projectkey, bookkey, etc.
  @i_searchtypecode integer, --determines which item type is used as well as what type of key @i_itemkeys will contain
  @i_userkey		integer,
  @o_listkey		integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_create_working_list_with_keys
**  Desc: 
**
**  Auth: Dustin Miller
**  Date: 11 April 2016
**
*******************************************************************************
**    Change History
*******************************************************************************
**  Date:       Author:   Description:
**  --------    -------   -----------------------------------------------------
**  07/15/2016  Uday      Case 39178
**  07/02/2018  Colman    TM-555
**  07/06/2018  Alan	  TM-581
*******************************************************************************/
	DECLARE @v_curitemkey VARCHAR(50),
	        @v_itemkey			INT,
			@v_itemsubkey		INT,
			@v_nextpos			INT,
			@v_userid			VARCHAR(30),
			@v_itemtypecode		INT,
			@v_usageclasscode	INT,
			@v_order			INT

	SET @o_error_code = 0
	SET @o_error_desc = ''
	SET @v_usageclasscode = 0
	SET @o_listkey = -1
	SET @v_itemsubkey = 0
	
	-- Get SearchItemCode - hardcoding results table based on search type (as seen in qutl_update_recent_use_list)
	IF @i_searchtypecode = 1 OR @i_searchtypecode = 6 BEGIN
		-- Titles
		SET @v_itemtypecode = 1
		SET @v_itemsubkey = 1 --printing key
	END
	ELSE IF @i_searchtypecode = 7 OR @i_searchtypecode = 10 BEGIN
		-- Projects
		SET @v_itemtypecode = 3
	END
	ELSE IF @i_searchtypecode = 8 BEGIN
		-- Contacts
		SET @v_itemtypecode = 2   
	END
	ELSE IF @i_searchtypecode = 16 BEGIN
		-- Lists
		SET @v_itemtypecode = 4
	END
	ELSE IF @i_searchtypecode = 17 BEGIN
		-- P&L Templates
		SET @v_itemtypecode = 5
	END
	ELSE IF @i_searchtypecode = 18 BEGIN
		-- Journals
		SET @v_itemtypecode = 6
	END
	ELSE IF @i_searchtypecode = 19 OR @i_searchtypecode = 20 BEGIN
		-- Task Views/Groups
		SET @v_itemtypecode = 8
	END
	ELSE IF @i_searchtypecode = 22 BEGIN      
		-- works
		SET @v_itemtypecode = 9
	END
	ELSE IF @i_searchtypecode = 24 BEGIN
		-- Scales
		SET @v_itemtypecode = 11
	END
	ELSE IF @i_searchtypecode = 25 BEGIN
		-- Contracts
		SET @v_itemtypecode = 10
	END
	ELSE IF @i_searchtypecode = 28 BEGIN
		-- Printings
		SET @v_itemtypecode = 14
	END 
	ELSE IF @i_searchtypecode = 29 BEGIN
		-- Purchase Orders
		SET @v_itemtypecode = 15
	END  
	ELSE IF @i_searchtypecode = 30 BEGIN
		-- Admin Spec Templates
		SET @v_itemtypecode = 5
		SET @v_usageclasscode = 2
	END

	IF LEN(@i_itemkeys) > 0
	BEGIN
		SELECT TOP 1 @v_userid = userid
		FROM qsiusers
		WHERE userkey = @i_userkey

		SELECT @o_listkey = listkey 
		FROM qse_searchlist 
		WHERE userkey = @i_userkey AND 
			searchtypecode = @i_searchtypecode AND listtypecode = 1

		IF @o_listkey > 0 BEGIN
			PRINT 'Listkey found: ' + CAST(@o_listkey AS VARCHAR)

			DELETE FROM qse_searchresults
			WHERE listkey = @o_listkey
		END
		ELSE BEGIN
			EXEC next_generic_key @v_userid, @o_listkey output, @o_error_code output, @o_error_desc output
			
			INSERT INTO qse_searchlist
			(listkey, userkey, searchtypecode, listtypecode, listdesc, saveascriteriaind, defaultind, lastuserid, lastmaintdate,
			autofindind, hidecriteriaind, hideorgfilterind, searchitemcode, createddate, createdbyuserid, privateind, usageclasscode, includeorglevelsind,
			firebrandlockind, resultswithnoorgsind, resultsviewkey, defaultonpopupsind)
			VALUES
			(@o_listkey, @i_userkey, @i_searchtypecode, 1, 'Current Working List', 0, 1, @v_userid, GETDATE(),
			0, 0, 0, @v_itemtypecode, GETDATE(), @v_userid, 0, @v_usageclasscode, 0, 1, 0, null, 0)
		END

		SET @v_order = 0

		WHILE LEN(@i_itemkeys) > 0
		BEGIN
			SET @v_nextpos = CHARINDEX(',', @i_itemkeys)
			IF @v_nextpos = 0
			BEGIN
				SET @v_nextpos = LEN(@i_itemkeys) + 1
			END
			SET @v_curitemkey = LTRIM(RTRIM(LEFT(@i_itemkeys, @v_nextpos - 1)))
			
			PRINT 'ItemKey parsed as: ' + COALESCE(@v_curitemkey, '')

			SET @v_itemkey = 0
			SELECT @v_itemkey = CAST(@v_curitemkey AS INT)

			IF @v_itemkey > 0
			BEGIN
			
				IF @i_searchtypecode = 22 BEGIN      
					-- works
					SELECT @v_itemsubkey = ISNULL(workkey, 0) FROM taqproject WHERE taqprojectkey = @v_itemkey					
				END	
				ELSE IF @i_searchtypecode = 28 BEGIN
					-- Printings
					SELECT @v_itemsubkey = bookkey FROM taqprojectprinting_view WHERE taqprojectkey = @v_itemkey
				END
							
				SET @v_order = @v_order + 1

				INSERT INTO qse_searchresults
				(listkey, key1, key2, key3, selectedind, sortorder)
				VALUES
				(@o_listkey, @v_itemkey, @v_itemsubkey, 0, 0, @v_order)

				PRINT 'qse_searchresults record created for ItemKey: ' + COALESCE(@v_curitemkey, '') + ' ListKey: ' + CAST(@o_listkey AS VARCHAR)
			END

			SET @i_itemkeys = SUBSTRING(@i_itemkeys, @v_nextpos + 1, LEN(@i_itemkeys) - (@v_nextpos - 1))
		END
	END

GO

GRANT EXEC ON qutl_create_working_list_with_keys TO PUBLIC
GO
