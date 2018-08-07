if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_genrel_table1') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_genrel_table1
GO

CREATE PROCEDURE qutl_get_genrel_table1 (
  @i_gentablesrelationshipkey INT,
  @i_tableid      INT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/*************************************************************************************************
**  Name: qutl_get_genrel_table1
**  Desc: This stored procedure returns Table1 data from gentables/gentablesrelationshipdetail.
**
**  Auth: Kate J. Wiewiora
**  Date: August 15 2007
*************************************************************************************************/

  DECLARE
		@v_datacode INT,
		@v_datasubcode	INT,
		@v_datasub2code	INT,
		@v_datadesc VARCHAR(40),
		@v_datasubdesc	VARCHAR(40),
		@v_datasub2desc	VARCHAR(40),
		@v_deletestatus VARCHAR(1),
		@v_table2exists	INT,
		@v_gentable1level INT,
    @v_error  INT,
    @v_rowcount   INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_datacode = 0
  SET @v_datasubcode = 0
  SET @v_datasub2code = 0
  
  DECLARE @results_table TABLE
	(
		tableid	INT,
		datacode	INT,
		datasubcode	INT,
		datasub2code	INT,
		datadesc	VARCHAR(122),
		deletestatus	VARCHAR(1),
		table2exists	INT,
		gentable1level	INT
	)
  
  DECLARE gentable_cursor CURSOR FAST_FORWARD FOR
  SELECT g.tableid, g.datacode, g.datadesc, g.deletestatus, dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, g.datacode) table2exists, r.gentable1level
  FROM gentables g, gentablesrelationships r
  WHERE g.tableid = @i_tableid
		AND r.gentablesrelationshipkey = @i_gentablesrelationshipkey
		AND r.Gentable1id = g.tableid
  UNION
  SELECT @i_tableid, -1, '&lt;INITIAL VALUE&gt;', 'N', dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, -1) table2exists, 1
  
  OPEN gentable_cursor 
	FETCH NEXT FROM gentable_cursor
	INTO @i_tableid, @v_datacode, @v_datadesc, @v_deletestatus, @v_table2exists, @v_gentable1level
	
	WHILE @@FETCH_STATUS = 0   
	BEGIN
		IF @v_gentable1level > 1
		BEGIN
			--loop through subgentables rows and get datasubcode and datasubdesc...
			DECLARE subgentable_cursor CURSOR FAST_FORWARD FOR
			SELECT datasubcode, datadesc
			FROM subgentables
			WHERE tableid = @i_tableid
				AND datacode = @v_datacode
			
			OPEN subgentable_cursor
			FETCH NEXT FROM subgentable_cursor
			INTO @v_datasubcode, @v_datasubdesc
			
			WHILE @@FETCH_STATUS = 0 
			BEGIN
				IF @v_gentable1level > 2
				BEGIN
					--loop through sub2gentables rows and get datasub2code and datasub2desc...
					DECLARE sub2gentable_cursor CURSOR FAST_FORWARD FOR
					SELECT datasub2code, datadesc
					FROM sub2gentables
					WHERE tableid = @i_tableid
						AND datacode = @v_datacode
						AND datasubcode = @v_datasubcode
						
					OPEN sub2gentable_cursor
					FETCH NEXT FROM sub2gentable_cursor
					INTO @v_datasub2code, @v_datasub2desc
					
					WHILE @@FETCH_STATUS = 0 
					BEGIN
						SELECT @v_table2exists = dbo.qutl_genrel_table1_multilevel_count(@i_gentablesrelationshipkey, @v_datacode, @v_datasubcode, @v_datasub2code)
						
						INSERT INTO @results_table
						(tableid, datacode, datasubcode, datasub2code, datadesc, deletestatus, table2exists, gentable1level)
						VALUES
						(@i_tableid, @v_datacode, @v_datasubcode, @v_datasub2code, (@v_datadesc + '/' + @v_datasubdesc + '/' + @v_datasub2desc), @v_deletestatus, @v_table2exists, @v_gentable1level)
						
						FETCH NEXT FROM sub2gentable_cursor
						INTO @v_datasub2code, @v_datasub2desc
					END
					
					CLOSE sub2gentable_cursor   
					DEALLOCATE sub2gentable_cursor
				END
				ELSE BEGIN
					SELECT @v_table2exists = dbo.qutl_genrel_table1_multilevel_count(@i_gentablesrelationshipkey, @v_datacode, @v_datasubcode, 0)
					
					INSERT INTO @results_table
					(tableid, datacode, datasubcode, datasub2code, datadesc, deletestatus, table2exists, gentable1level)
					VALUES
					(@i_tableid, @v_datacode, @v_datasubcode, NULL, (@v_datadesc + '/' + @v_datasubdesc), @v_deletestatus, @v_table2exists, @v_gentable1level)
				END
				
				FETCH NEXT FROM subgentable_cursor
				INTO @v_datasubcode, @v_datasubdesc
			END
			
			CLOSE subgentable_cursor   
			DEALLOCATE subgentable_cursor
		END
		ELSE BEGIN
			--add all value for the gentable level 1 entry to the table variable w/ @v_datadesc (level 1) as the desc and null for datasubcode and datasub2code
			INSERT INTO @results_table
			(tableid, datacode, datasubcode, datasub2code, datadesc, deletestatus, table2exists, gentable1level)
			VALUES
			(@i_tableid, @v_datacode, NULL, NULL, @v_datadesc, @v_deletestatus, @v_table2exists, @v_gentable1level)
		END
		
		FETCH NEXT FROM gentable_cursor
		INTO @i_tableid, @v_datacode, @v_datadesc, @v_deletestatus, @v_table2exists, @v_gentable1level
	END   

	CLOSE gentable_cursor   
	DEALLOCATE gentable_cursor
	
	SELECT *
	FROM @results_table

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing gentables (tableid=' + CONVERT(VARCHAR, @i_tableid) + ').'
  END 
GO

GRANT EXEC ON qutl_get_genrel_table1 TO PUBLIC
GO
