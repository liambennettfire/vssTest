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
*************************************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  03/18/2016   UK          Case 37113
*******************************************************************************/

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
    @v_rowcount   INT,
    @v_tableid INT

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
	
  SELECT @v_tableid = Gentable1id From gentablesrelationships where gentablesrelationshipkey = @i_gentablesrelationshipkey	
  
  IF @v_tableid = 323 BEGIN --datetype							
	  INSERT  INTO @results_table (tableid, datacode, datadesc, deletestatus, table2exists, gentable1level)
	  (SELECT d1.tableid, d1.datetypecode datacode, CASE WHEN d1.datelabel IS NULL OR LTRIM(RTRIM(d1.datelabel)) = '' THEN d1.description ELSE d1.datelabel END datadesc, 
	  CASE d1.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, d1.datetypecode) table2exists, r.gentable1level
	  FROM datetype d1, gentablesrelationships r
	  WHERE d1.tableid = @i_tableid
			AND r.gentablesrelationshipkey = @i_gentablesrelationshipkey
			AND r.Gentable1id = d1.tableid
	  UNION
	  SELECT @i_tableid, -1, '&lt;INITIAL VALUE&gt;', 'N', dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, -1) table2exists, 1)						
  END	   
  ELSE 	IF @v_tableid = 329 BEGIN --season	
	  INSERT  INTO @results_table (tableid, datacode, datadesc, deletestatus, table2exists, gentable1level)
	  (SELECT s.tableid, s.seasontypecode datacode, s.seasondesc datadesc, 
	  CASE s.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, s.seasontypecode) table2exists, r.gentable1level
	  FROM season s, gentablesrelationships r
	  WHERE s.tableid = @i_tableid
			AND r.gentablesrelationshipkey = @i_gentablesrelationshipkey
			AND r.Gentable1id = s.tableid
	  UNION
	  SELECT @i_tableid, -1, '&lt;INITIAL VALUE&gt;', 'N', dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, -1) table2exists, 1)	  
  END
  ELSE 	IF @v_tableid = 340 BEGIN --personnel
	  INSERT  INTO @results_table (tableid, datacode, datadesc, deletestatus, table2exists, gentable1level)
	  (SELECT p.tableid, p.persontypecode datacode, p.displayname datadesc, 
	  CASE p.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, p.persontypecode) table2exists, r.gentable1level
	  FROM person p, gentablesrelationships r
	  WHERE p.tableid = @i_tableid
			AND r.gentablesrelationshipkey = @i_gentablesrelationshipkey
			AND r.Gentable1id = p.tableid
	  UNION
	  SELECT @i_tableid, -1, '&lt;INITIAL VALUE&gt;', 'N', dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, -1) table2exists, 1)  
  END  
  ELSE 	IF @v_tableid = 356 BEGIN --filelocationtable
	  INSERT  INTO @results_table (tableid, datacode, datadesc, deletestatus, table2exists, gentable1level)
	  (SELECT f.tableid, f.filelocationkey datacode, f.logicaldesc datadesc, 
	  CASE f.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, f.filelocationkey) table2exists, r.gentable1level
	  FROM filelocationtable f, gentablesrelationships r
	  WHERE f.tableid = @i_tableid
			AND r.gentablesrelationshipkey = @i_gentablesrelationshipkey
			AND r.Gentable1id = f.tableid
	  UNION
	  SELECT @i_tableid, -1, '&lt;INITIAL VALUE&gt;', 'N', dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, -1) table2exists, 1)    
  END   
  ELSE 	IF @v_tableid = 572 BEGIN --cdlist
	  INSERT  INTO @results_table (tableid, datacode, datadesc, deletestatus, table2exists, gentable1level)
	  (SELECT c.tableid, c.internalcode datacode, c.externaldesc datadesc, 
	  CASE c.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, c.internalcode) table2exists, r.gentable1level
	  FROM cdlist c, gentablesrelationships r
	  WHERE c.tableid = @i_tableid
			AND r.gentablesrelationshipkey = @i_gentablesrelationshipkey
			AND r.Gentable1id = c.tableid
	  UNION
	  SELECT @i_tableid, -1, '&lt;INITIAL VALUE&gt;', 'N', dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, -1) table2exists, 1)   
  END  
  ELSE 	IF @v_tableid = 1014 BEGIN --inks
	  INSERT  INTO @results_table (tableid, datacode, datadesc, deletestatus, table2exists, gentable1level)
	  (SELECT i.tableid, i.inkkey datacode, i.inkdesc datadesc, 
	   i.inactiveind deletestatus, dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, i.inkkey) table2exists, r.gentable1level
	  FROM ink i, gentablesrelationships r
	  WHERE i.tableid = @i_tableid
			AND r.gentablesrelationshipkey = @i_gentablesrelationshipkey
			AND r.Gentable1id = i.tableid
	  UNION
	  SELECT @i_tableid, -1, '&lt;INITIAL VALUE&gt;', 'N', dbo.qutl_genrel_table1_count(@i_gentablesrelationshipkey, -1) table2exists, 1)      
  END     
  ELSE BEGIN			    
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
	END
	
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
