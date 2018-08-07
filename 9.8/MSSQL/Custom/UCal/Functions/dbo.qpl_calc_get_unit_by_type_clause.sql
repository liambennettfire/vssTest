if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_get_unit_by_type_clause') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.qpl_calc_get_unit_by_type_clause
GO


CREATE FUNCTION dbo.qpl_calc_get_unit_by_type_clause
    ( @i_formattype as varchar(50)
    ) 
    
RETURNS varchar(4000)

/******************************************************************************************
**  Name: qpl_calc_get_unit_by_type_clause
**  Desc: This function will return the where clause for media/format datacodes based on the format parameter passed in. 
**		  The return value will be used in p&l generic routines. e.g. unit by type, unit by sales channel, unit by sales channel and format, etc. 
**
**  Auth: TT
**  Date: June 01 2012

Select * FROM taqplsales_actual


*******************************************************************************************/

BEGIN 
DECLARE @RETURN varchar(4000)

SET @RETURN = ''

DECLARE @v_datacode_list	varchar(100),
  @v_datasubcode_list varchar(2000),
  @v_datacode INT,
  @v_datasubcode INT,
  @v_built_clause	varchar(4000),
  @v_formattype varchar(50),
  @v_count INT,
  @v_alternatedesc1	varchar(100),
  @SQLString_var NVARCHAR(4000),
  @v_whereclause NVARCHAR(4000),
  @SQLparams_var NVARCHAR(4000)
  

	SET @v_datacode_list = ''
	SET @v_datasubcode_list = ''
	SET @v_built_clause = ''
	SET @v_count = 0

	SELECT @v_formattype = @i_formattype

	SELECT @v_count = count(*)
	FROM subgentables_ext se 
	join subgentables s
	on se.tableid = s.tableid and se.datacode = s.datacode and se.datasubcode = s.datasubcode 
	WHERE se.tableid = 312 and s.deletestatus = 'N'
	AND se.gentext1 = @v_formattype

	IF @v_count = 0 
	BEGIN
		SELECT @v_count = count(*)
		  FROM gentables_ext ge
		  JOIN gentables g
		  on ge.tableid = g.tableid and ge.datacode = g.datacode 
		 WHERE ge.tableid = 312 and g.deletestatus = 'N'
		   AND ge.gentext1 = @v_formattype
	END

	IF @v_count = 0 
	BEGIN
		SET @v_formattype = 'OTHER'
	END

--	print '@v_formattype'
--	print @v_formattype

	IF @v_formattype = 'OTHER' 
		BEGIN
				SELECT @v_built_clause = ''

				DECLARE gentables_cursor CURSOR FOR
					SELECT g.datacode 
					FROM gentables_ext ge
					JOIN gentables g
					on ge.tableid = g.tableid and ge.datacode = g.datacode 
					WHERE ge.tableid = 312 and g.deletestatus = 'N'
					AND (ge.gentext1 = @i_formattype OR ge.gentext1 IS NULL)	

				OPEN gentables_cursor

				FETCH NEXT FROM gentables_cursor INTO @v_datacode

				WHILE (@@FETCH_STATUS <> -1)
				BEGIN
						
					SELECT @v_datasubcode_list = ''

					DECLARE subgentables_cursor CURSOR FOR
						SELECT se.datasubcode 
						FROM subgentables_ext se 
						join subgentables s
						on se.tableid = s.tableid and se.datacode = s.datacode and se.datasubcode = s.datasubcode 
						WHERE se.tableid = 312 and s.deletestatus = 'N'
						AND se.datacode = @v_datacode
						AND (se.gentext1 = @i_formattype
						OR se.gentext1 IS NULL)

					 OPEN subgentables_cursor

					 FETCH NEXT FROM subgentables_cursor INTO @v_datasubcode

					 WHILE (@@FETCH_STATUS <> -1)
					 BEGIN
--						print '@v_datasubcode'
--						print @v_datasubcode
						IF @v_datasubcode_list = ''
							BEGIN
								SELECT @v_datasubcode_list = convert(varchar,@v_datasubcode)
							END
						ELSE
							BEGIN
								SELECT @v_datasubcode_list = @v_datasubcode_list + ',' + convert(varchar,@v_datasubcode)
							END
						FETCH NEXT FROM subgentables_cursor INTO @v_datasubcode		
					 END
					CLOSE subgentables_cursor 
					DEALLOCATE subgentables_cursor
					
					--if there is no match at the format level (exact match or NULL) then don't even include the media type level match
					--e.g. Book has two formats: Hardover and Paperback. So gentext1 is set to NULL for media type book
					--When we run this for "OTHER" we don't want to include media type book. None of the formats are eligible to be included in OTHER. 
					IF @v_datasubcode_list <> '' 
						BEGIN
							IF @v_built_clause = '' 
								BEGIN
									SELECT @v_built_clause = '(f.mediatypecode = ' + convert(varchar,@v_datacode) + ' AND f.mediatypesubcode IN (' + @v_datasubcode_list + '))'
								END
							ELSE
								BEGIN
									SELECT @v_built_clause = @v_built_clause + ' OR (f.mediatypecode = ' + convert(varchar,@v_datacode) + ' AND f.mediatypesubcode IN (' + @v_datasubcode_list + '))'					
								END
						END
					

					FETCH NEXT FROM gentables_cursor INTO @v_datacode
				END
				CLOSE gentables_cursor 
				DEALLOCATE gentables_cursor
		END --formattype <> 'OTHER'
		ELSE 
			BEGIN
				SELECT @v_built_clause = ''

				DECLARE gentables_cursor CURSOR FOR
				   SELECT ge.datacode, ge.gentext1
					 FROM gentables_ext ge
					 JOIN gentables g
					on ge.tableid = g.tableid and ge.datacode = g.datacode   
					WHERE ge.tableid = 312 and g.deletestatus = 'N'
					  AND (ge.gentext1 = @v_formattype
						OR ge.gentext1 IS NULL)

				OPEN gentables_cursor

				FETCH NEXT FROM gentables_cursor INTO @v_datacode,@v_alternatedesc1

				WHILE (@@FETCH_STATUS <> -1)
				BEGIN
					-- It is possible that the media type is blank but there is a match on one of the formats:
					--e.g. Media Book, genttext1 is NULL but gentext1 for Hardcover and Paperback formats are populated 
					IF @v_alternatedesc1 IS NULL
					BEGIN
						SELECT @v_count = 0
						
						SELECT @v_count = count(*)
						FROM subgentables_ext se 
						join subgentables s
						on se.tableid = s.tableid and se.datacode = s.datacode and se.datasubcode = s.datasubcode 
						WHERE se.tableid = 312 and s.deletestatus = 'N'
						AND se.datacode = @v_datacode
						AND se.gentext1 = @v_formattype
					END

					IF @v_count > 0 OR @v_alternatedesc1 IS NOT NULL 
					BEGIN
						SELECT @v_datasubcode_list = ''

						DECLARE subgentables_cursor CURSOR FOR
						SELECT datasubcode 
						  FROM subgentables_ext 
						 WHERE tableid = 312
						   AND datacode = @v_datacode
						   AND gentext1 = @v_formattype
						
						 OPEN subgentables_cursor

						 FETCH NEXT FROM subgentables_cursor INTO @v_datasubcode

						 WHILE (@@FETCH_STATUS <> -1)
						 BEGIN
--							print '@v_datasubcode'
--							print @v_datasubcode
							IF @v_datasubcode_list = ''
								BEGIN
									SELECT @v_datasubcode_list = convert(varchar,@v_datasubcode)
								END
							ELSE
								BEGIN
									SELECT @v_datasubcode_list = @v_datasubcode_list + ',' + convert(varchar,@v_datasubcode)
								END
							FETCH NEXT FROM subgentables_cursor INTO @v_datasubcode		
						 END
						CLOSE subgentables_cursor 
						DEALLOCATE subgentables_cursor

						IF @v_built_clause = '' 
							BEGIN
								IF @v_datasubcode_list = ''
									BEGIN
										SELECT @v_built_clause = '(f.mediatypecode = ' + convert(varchar,@v_datacode) + ')'
									END
								ELSE
									BEGIN
										SELECT @v_built_clause = '(f.mediatypecode = ' + convert(varchar,@v_datacode) + ' AND f.mediatypesubcode IN (' + @v_datasubcode_list + '))'
									END
							END
						ELSE
							BEGIN
								IF @v_datasubcode_list = ''
									BEGIN
										SELECT @v_built_clause = @v_built_clause + ' OR (f.mediatypecode = ' + convert(varchar,@v_datacode) + ')'
									END
								ELSE
									BEGIN
										SELECT @v_built_clause = @v_built_clause + ' OR (f.mediatypecode = ' + convert(varchar,@v_datacode) + ' AND f.mediatypesubcode IN (' + @v_datasubcode_list + '))'
									END
							END

						FETCH NEXT FROM gentables_cursor INTO @v_datacode,@v_alternatedesc1
					END
				END
				CLOSE gentables_cursor 
				DEALLOCATE gentables_cursor
		END --formattype <> 'OTHER'
   
RETURN @v_built_clause

END
GO
GRANT EXEC ON dbo.qpl_calc_get_unit_by_type_clause TO PUBLIC
GO


