if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_gentables_desc') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_gentables_desc
GO

CREATE FUNCTION get_gentables_desc
    ( @i_tableid as integer,@i_datacode as integer,@i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: get_gentables_desc
**  Desc: This function returns the datadesc or datadescshort depending on
**        i_desctype. 
**
**        i_desctype = 'long' or empty --> return datadesc
**        i_desctype = 'short' --> return datadescshort
**
**    Auth: Alan Katzen
**    Date: 25 August 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_desc       VARCHAR(255)
  DECLARE	@v_location		VARCHAR(25)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort - get datadesc if short is not filled in
    SELECT @i_desc = coalesce(datadescshort,datadesc)
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode
  END
  ELSE BEGIN
  
		SELECT @v_location = location
		FROM gentablesdesc
		WHERE tableid = @i_tableid
				
		IF @v_location IS NOT NULL AND lower(@v_location) <> 'gentables'
		BEGIN
			--get datadesc from fake gentables
			IF @i_tableid = 323 -- datetype
			SELECT @i_desc =
				CASE
					WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
					ELSE d.datelabel
				END
			FROM gentablesdesc gd, datetype d 
				LEFT OUTER JOIN gentablesorglevel o ON d.tableid = o.tableid AND d.datetypecode = o.datacode
			WHERE d.tableid = gd.tableid
				AND d.datetypecode = @i_datacode
	    
			ELSE IF @i_tableid = 329  --season
				SELECT @i_desc = s.seasondesc
				FROM gentablesdesc gd, season s 
					LEFT OUTER JOIN gentablesorglevel o ON s.tableid = o.tableid AND s.seasonkey = o.datacode
				WHERE s.tableid = gd.tableid
					AND s.seasonkey = @i_datacode
		    
			ELSE IF @i_tableid = 340 --personnel
				SELECT @i_desc = p.displayname
				FROM gentablesdesc gd, person p 
					LEFT OUTER JOIN gentablesorglevel o ON p.tableid = o.tableid AND p.contributorkey = o.datacode
				WHERE p.tableid = gd.tableid
					AND p.contributorkey = @i_datacode

			ELSE IF @i_tableid = 356 --filelocationtable
				SELECT @i_desc = fl.logicaldesc
				FROM gentablesdesc gd, filelocationtable fl 
					LEFT OUTER JOIN gentablesorglevel o ON fl.tableid = o.tableid AND fl.filelocationkey = o.datacode
				WHERE fl.tableid = gd.tableid
					AND gd.tableid = @i_tableid
					AND fl.filelocationkey = @i_datacode

			ELSE IF @i_tableid = 572 --cdlist
				SELECT @i_desc = c.externaldesc
				FROM gentablesdesc gd, cdlist c 
					LEFT OUTER JOIN gentablesorglevel o ON c.tableid = o.tableid AND c.internalcode = o.datacode
				WHERE c.tableid = gd.tableid
					AND c.internalcode = @i_datacode
		    
			ELSE IF @i_tableid = 1014 --inks
				SELECT @i_desc = i.inkdesc
				FROM gentablesdesc gd, ink i
					LEFT OUTER JOIN gentablesorglevel o ON i.tableid = o.tableid AND i.inkkey = o.datacode
				WHERE i.tableid = gd.tableid
					AND i.inkkey = @i_datacode
			
		END
		ELSE BEGIN
			-- get datadesc
			SELECT @i_desc = datadesc
				FROM gentables
			 WHERE tableid = @i_tableid and
						 datacode = @i_datacode
    END
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

  RETURN @i_desc
END
GO

GRANT EXEC ON dbo.get_gentables_desc TO public
GO
