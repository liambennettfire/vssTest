if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_copy_territoryright_to_bookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_copy_territoryright_to_bookkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_copy_territoryright_to_bookkey
 (@i_projectkey						integer,
  @i_rightskey						integer,
  @i_bookkey							integer,
  @i_userid								varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_copy_territoryright_to_bookkey
**  Desc: This procedure copies the corresponding rows from territoryrights and territoryrightcountries with the corresponding projectkey and rightskey
**		to the corresponding bookkey
**
**	Auth: Dustin Miller
**	Date: May 10 2012
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''	
	
	DECLARE @v_error			INT,
          @v_rowcount		INT,
					@v_count INT,
					@v_territoryrightskey	INT,
					@v_itemtype	INT,
					@v_currentterritorycode	INT,
					@v_contractterritorycode	INT,
					@v_description	VARCHAR(2000),
					@v_autoterritorydescind	TINYINT,
					@v_exclusivecode	INT,
					@v_singlecountrycode	INT,
					@v_singlecountrygroupcode	INT,
					@v_updatewithsubrightsind	TINYINT,
					@v_note	VARCHAR(200),
					@v_forsalehistory	VARCHAR(2000),
					@v_notforsalehistory VARCHAR(2000),
					@v_countrycode	INT,
					@v_forsaleind	TINYINT,
					@v_contractexclusiveind	TINYINT,
					@v_nonexclusivesubrightsoldind	TINYINT,
					@v_currentexclusiveind	TINYINT,
					@v_exclusivesubrightsoldind	TINYINT

	SELECT @v_count = count(*)
	FROM territoryrights
	WHERE taqprojectkey = @i_projectkey
		AND rightskey = @i_rightskey

	IF @v_count > 0
	BEGIN
		DELETE
		FROM territoryrights
		WHERE bookkey = @i_bookkey
		
		--Copy territoryrights
		SELECT @v_itemtype=itemtype, @v_currentterritorycode=currentterritorycode, @v_contractterritorycode=contractterritorycode,
			@v_description=description, @v_autoterritorydescind=autoterritorydescind, @v_exclusivecode=exclusivecode, @v_singlecountrycode=singlecountrycode,
			@v_singlecountrygroupcode=singlecountrygroupcode, @v_updatewithsubrightsind=updatewithsubrightsind, @v_note=note, @v_forsalehistory=forsalehistory, @v_notforsalehistory=notforsalehistory
		FROM territoryrights
		WHERE taqprojectkey = @i_projectkey
		AND rightskey = @i_rightskey
		
		EXEC get_next_key @i_userid, @v_territoryrightskey OUTPUT
		
		INSERT INTO territoryrights
		(territoryrightskey, itemtype, bookkey, currentterritorycode, contractterritorycode, description, autoterritorydescind, exclusivecode, singlecountrycode,
		singlecountrygroupcode, updatewithsubrightsind, note, forsalehistory, notforsalehistory, lastuserid, lastmaintdate)
		VALUES
		(@v_territoryrightskey, @v_itemtype, @i_bookkey, @v_currentterritorycode, @v_contractterritorycode, @v_description, @v_autoterritorydescind, @v_exclusivecode, @v_singlecountrycode,
		@v_singlecountrygroupcode, @v_updatewithsubrightsind, @v_note, @v_forsalehistory, @v_notforsalehistory, @i_userid, GETDATE())
		
		DELETE
		FROM territoryrightcountries
		WHERE bookkey = @i_bookkey
		
		DECLARE terr_cursor CURSOR FOR
		SELECT countrycode, itemtype, forsaleind, contractexclusiveind, nonexclusivesubrightsoldind, currentexclusiveind, exclusivesubrightsoldind
		FROM territoryrightcountries
		WHERE taqprojectkey = @i_projectkey
		AND rightskey = @i_rightskey
		
		OPEN terr_cursor
		
		FETCH terr_cursor
		INTO @v_countrycode, @v_itemtype, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind, @v_currentexclusiveind, @v_exclusivesubrightsoldind
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			INSERT INTO territoryrightcountries
				(territoryrightskey, countrycode, itemtype, bookkey, forsaleind, contractexclusiveind, nonexclusivesubrightsoldind,
				 currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate)
			VALUES
				(@v_territoryrightskey, @v_countrycode, @v_itemtype, @i_bookkey, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind,
				 @v_currentexclusiveind, @v_exclusivesubrightsoldind, @i_userid, getdate())
				
			FETCH terr_cursor
			INTO @v_countrycode, @v_itemtype, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind, @v_currentexclusiveind, @v_exclusivesubrightsoldind
		END
		
		CLOSE terr_cursor
		DEALLOCATE terr_cursor
	END
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error copying territoryrights/territoryrightcountries rows (bookkey=' + cast(@i_bookkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_copy_territoryright_to_bookkey TO PUBLIC
GO