if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_titlerights_country_misc_fields') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_create_titlerights_country_misc_fields
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_create_titlerights_country_misc_fields
 (@i_bookkey				integer,
	@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_create_titlerights_country_misc_fields
**  Desc: This stored procedure creates the title rights country misc fields
**
**  Auth: Dustin Miller
**  Date: 7/26/12
**  Modified: Kusum Basra
**  Date: 12/19/2013 
**    - retrieve eloquencefieldtag from gentables 114 instead of bisacdatacode
**    - only retrieve country codes where deletestatus = ‘N’ and exporteloquenceind = 1
*************************************************************************************/

BEGIN

  DECLARE
		@v_misckey	INT,
		@v_defaultsendtoeloqvalue	TINYINT,
		@v_miscitemval	VARCHAR(4000),
		@v_datadesc	VARCHAR(40),
		@v_countrycode	INT,
		@v_existcount	INT,
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  BEGIN TRAN
  --For Sale Exclusive Country Codes
  SET @v_misckey = NULL
  
  SELECT @v_misckey = misckey,
		@v_defaultsendtoeloqvalue = defaultsendtoeloqvalue
  FROM bookmiscitems
  WHERE qsicode = 7
  
  IF @v_misckey IS NOT NULL
  BEGIN
		DECLARE exclusive_cursor CURSOR FAST_FORWARD FOR
		SELECT t.countrycode
		FROM qtitle_get_territorycountry_by_title(@i_bookkey)t, gentables g
		WHERE forsaleind = 1
			AND currentexclusiveind = 1
      AND t.countrycode = g.datacode
      AND g.deletestatus = 'N' 
      AND g.exporteloquenceind = 1
      AND g.tableid = 114
		
		OPEN exclusive_cursor
		
		FETCH exclusive_cursor
		INTO @v_countrycode
		
		SET @v_miscitemval = ''
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SELECT @v_datadesc = eloquencefieldtag
			FROM gentables
			WHERE tableid = 114
				AND datacode = @v_countrycode
			
			IF @v_datadesc IS NOT NULL
			BEGIN
				IF LEN(@v_miscitemval) > 0
				BEGIN
					SET @v_miscitemval = @v_miscitemval + ' '
				END
				SET @v_miscitemval = @v_miscitemval + @v_datadesc
			END
			
			FETCH exclusive_cursor
			INTO @v_countrycode
		END
	  
		CLOSE exclusive_cursor
		DEALLOCATE exclusive_cursor
	  
	  SELECT @v_existcount = count(*) FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @v_misckey
	  IF @v_existcount > 0
		BEGIN
			UPDATE bookmisc
			SET textvalue = @v_miscitemval, sendtoeloquenceind = @v_defaultsendtoeloqvalue, lastuserid = 'QSIDBA', lastmaintdate = GETDATE()
			WHERE bookkey = @i_bookkey
				AND misckey = @v_misckey
		END
		ELSE BEGIN
			INSERT INTO bookmisc
			(bookkey, misckey, textvalue, sendtoeloquenceind, lastuserid, lastmaintdate)
			VALUES
			(@i_bookkey, @v_misckey, @v_miscitemval, @v_defaultsendtoeloqvalue, 'QSIDBA', GETDATE())
		END
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not create title rights country misc fields (bookkey=' + cast(@i_bookkey as varchar) + ').'
    ROLLBACK TRAN
    RETURN
  END
  
  --For Sale Non-Exc Country Codes
  SET @v_misckey = NULL
  
  SELECT @v_misckey = misckey,
		@v_defaultsendtoeloqvalue = defaultsendtoeloqvalue
  FROM bookmiscitems
  WHERE qsicode = 8
  
  IF @v_misckey IS NOT NULL
  BEGIN
		DECLARE nonexclusive_cursor CURSOR FAST_FORWARD FOR
		SELECT t.countrycode
		FROM qtitle_get_territorycountry_by_title(@i_bookkey)t, gentables g
		WHERE forsaleind = 1
			AND (currentexclusiveind IS NULL OR currentexclusiveind = 0)
      AND t.countrycode = g.datacode
      AND g.deletestatus = 'N' 
      AND g.exporteloquenceind = 1
      AND g.tableid = 114
		
		OPEN nonexclusive_cursor
		
		FETCH nonexclusive_cursor
		INTO @v_countrycode
		
		SET @v_miscitemval = ''
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SELECT @v_datadesc = eloquencefieldtag
			FROM gentables
			WHERE tableid = 114
				AND datacode = @v_countrycode
			
			IF @v_datadesc IS NOT NULL
			BEGIN
				IF LEN(@v_miscitemval) > 0
				BEGIN
					SET @v_miscitemval = @v_miscitemval + ' '
				END
				SET @v_miscitemval = @v_miscitemval + @v_datadesc
			END
			
			FETCH nonexclusive_cursor
			INTO @v_countrycode
		END
	  
		CLOSE nonexclusive_cursor
		DEALLOCATE nonexclusive_cursor
	  
	  SELECT @v_existcount = count(*) FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @v_misckey
	  IF @v_existcount > 0
		BEGIN
			UPDATE bookmisc
			SET textvalue = @v_miscitemval, sendtoeloquenceind = @v_defaultsendtoeloqvalue, lastuserid = 'QSIDBA', lastmaintdate = GETDATE()
			WHERE bookkey = @i_bookkey
				AND misckey = @v_misckey
		END
		ELSE BEGIN
			INSERT INTO bookmisc
			(bookkey, misckey, textvalue, sendtoeloquenceind, lastuserid, lastmaintdate)
			VALUES
			(@i_bookkey, @v_misckey, @v_miscitemval, @v_defaultsendtoeloqvalue, 'QSIDBA', GETDATE())
		END
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not create title rights country misc fields (bookkey=' + cast(@i_bookkey as varchar) + ').'
    ROLLBACK TRAN
    RETURN
  END
  
  --Not For Sale Country Codes
  SET @v_misckey = NULL
  
  SELECT @v_misckey = misckey,
		@v_defaultsendtoeloqvalue = defaultsendtoeloqvalue
  FROM bookmiscitems
  WHERE qsicode = 9
  
  IF @v_misckey IS NOT NULL
  BEGIN
		DECLARE notforsale_cursor CURSOR FAST_FORWARD FOR
		SELECT t.countrycode
		FROM qtitle_get_territorycountry_by_title(@i_bookkey) t, gentables g
		WHERE forsaleind = 0
      AND t.countrycode = g.datacode
      AND g.deletestatus = 'N' 
      AND g.exporteloquenceind = 1
      AND g.tableid = 114
		
		OPEN notforsale_cursor
		
		FETCH notforsale_cursor
		INTO @v_countrycode
		
		SET @v_miscitemval = ''
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SELECT @v_datadesc = eloquencefieldtag
			FROM gentables
			WHERE tableid = 114
				AND datacode = @v_countrycode
			
			IF @v_datadesc IS NOT NULL
			BEGIN
				IF LEN(@v_miscitemval) > 0
				BEGIN
					SET @v_miscitemval = @v_miscitemval + ' '
				END
				SET @v_miscitemval = @v_miscitemval + @v_datadesc
			END
			
			FETCH notforsale_cursor
			INTO @v_countrycode
		END
	  
		CLOSE notforsale_cursor
		DEALLOCATE notforsale_cursor
	  
	  SELECT @v_existcount = count(*) FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @v_misckey
	  IF @v_existcount > 0
		BEGIN
			UPDATE bookmisc
			SET textvalue = @v_miscitemval, sendtoeloquenceind = @v_defaultsendtoeloqvalue, lastuserid = 'QSIDBA', lastmaintdate = GETDATE()
			WHERE bookkey = @i_bookkey
				AND misckey = @v_misckey
		END
		ELSE BEGIN
			INSERT INTO bookmisc
			(bookkey, misckey, textvalue, sendtoeloquenceind, lastuserid, lastmaintdate)
			VALUES
			(@i_bookkey, @v_misckey, @v_miscitemval, @v_defaultsendtoeloqvalue, 'QSIDBA', GETDATE())
		END
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not create title rights country misc fields (bookkey=' + cast(@i_bookkey as varchar) + ').'
    ROLLBACK TRAN
    RETURN
  END
  
  COMMIT TRAN
  
END
GO

GRANT EXEC ON qtitle_create_titlerights_country_misc_fields TO PUBLIC
GO
