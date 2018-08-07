if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_genrel_table2') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_genrel_table2
GO

CREATE PROCEDURE qutl_get_genrel_table2 (
  @i_gentablesrelationshipkey  INT,
  @i_datacode                  INT,
  @i_datasubcode							 INT,
  @i_datasub2code							 INT,
  @o_error_code                INT OUTPUT,
  @o_error_desc                VARCHAR(2000) OUTPUT)
AS

/*************************************************************************************************
**  Name: qutl_get_genrel_table2
**  Desc: This stored procedure returns Table2 data from gentables/gentablesrelationshipdetail.
**
**  Auth: Kate J. Wiewiora
**  Date: August 15 2007
*************************************************************************************************/

  DECLARE
    @v_error					INT,
    @v_rowcount				INT,
    @v_tableid				INT,
    @v_gentable1level	INT,
    @v_gentable2level	INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_tableid = gentable2id From gentablesrelationships where gentablesrelationshipkey = @i_gentablesrelationshipkey

	IF @v_tableid = 323 --datetype

	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
		  CASE WHEN d1.datelabel IS NULL OR LTRIM(RTRIM(d1.datelabel)) = '' THEN d1.description ELSE d1.datelabel END datadesc, 
		  '' datasubdesc, '' datasub2desc, CASE d1.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d, datetype d1 
	  WHERE d1.tableid = @v_tableid AND
			d.code2 = d1.datetypecode AND
			d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
			d.code1 = @i_datacode
	  UNION
	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
	    CONVERT(VARCHAR, d.code2) datadesc, '' datasubdesc, '' datasub2desc, 'Y' deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d
	  WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND
			d.code1 = @i_datacode AND
			NOT EXISTS (SELECT * FROM datetype d1 WHERE d1.tableid = @v_tableid AND d.code2 = d1.datetypecode)

	IF @v_tableid = 329 --season

	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
		  s.seasondesc datadesc, '' datasubdesc, '' datasub2desc, CASE s.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d, season s 
	  WHERE s.tableid = @v_tableid AND
			d.code2 = s.seasonkey AND
			d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
			d.code1 = @i_datacode
	  UNION
	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
	    CONVERT(VARCHAR, d.code2) datadesc, '' datasubdesc, '' datasub2desc, 'Y' deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d
	  WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND
			d.code1 = @i_datacode AND
			NOT EXISTS (SELECT * FROM season s WHERE s.tableid = @v_tableid AND d.code2 = s.seasonkey)

	IF @v_tableid = 340 --personnel

	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
		  p.displayname datadesc, '' datasubdesc, '' datasub2desc, CASE p.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d, person p 
	  WHERE p.tableid = @v_tableid AND
			d.code2 = p.contributorkey AND
			d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
			d.code1 = @i_datacode
	  UNION
	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
	    CONVERT(VARCHAR, d.code2) datadesc, '' datasubdesc, '' datasub2desc, 'Y' deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d
	  WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND
			d.code1 = @i_datacode AND
			NOT EXISTS (SELECT * FROM person p WHERE p.tableid = @v_tableid AND d.code2 = p.contributorkey)

	IF @v_tableid = 356 --filelocationtable

	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
		  f.logicaldesc datadesc, '' datasubdesc, '' datasub2desc, CASE f.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d, filelocationtable f 
	  WHERE f.tableid = @v_tableid AND
			d.code2 = f.filelocationkey AND
			d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
			d.code1 = @i_datacode
	  UNION
	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
	    CONVERT(VARCHAR, d.code2) datadesc, '' datasubdesc, '' datasub2desc, 'Y' deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d
	  WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND
			d.code1 = @i_datacode AND
			NOT EXISTS (SELECT * FROM filelocationtable f WHERE f.tableid = @v_tableid AND d.code2 = f.filelocationkey)

	IF @v_tableid = 572 --cdlist

	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
		  c.externaldesc datadesc, '' datasubdesc, '' datasub2desc, CASE c.activeind WHEN 1 THEN 'N' ELSE 'Y' END deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d, cdlist c 
	  WHERE c.tableid = @v_tableid AND
			d.code2 = c.internalcode AND
			d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
			d.code1 = @i_datacode
	  UNION
	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
	    CONVERT(VARCHAR, d.code2) datadesc, '' datasubdesc, '' datasub2desc, 'Y' deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d
	  WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND
			d.code1 = @i_datacode AND
			NOT EXISTS (SELECT * FROM cdlist c WHERE c.tableid = @v_tableid AND d.code2 = c.internalcode)

	IF @v_tableid = 1014 --inks

	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
		  i.inkdesc datadesc, '' datasubdesc, '' datasub2desc, i.inactiveind deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d, ink i 
	  WHERE i.tableid = @v_tableid AND
			d.code2 = i.inkkey AND
			d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
			d.code1 = @i_datacode
	  UNION
	  SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, 
	    CONVERT(VARCHAR, d.code2) datadesc, '' datasubdesc, '' datasub2desc, 'Y' deletestatus, 0 newind
	  FROM gentablesrelationshipdetail d
	  WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND
			d.code1 = @i_datacode AND
			NOT EXISTS (SELECT * FROM ink i WHERE i.tableid = @v_tableid AND d.code2 = i.inkkey)

	ELSE BEGIN --gentable
		SELECT @v_gentable1level = gentable1level, @v_gentable2level = gentable2level
		FROM gentablesrelationships
		WHERE gentablesrelationshipkey = @i_gentablesrelationshipkey
		
		IF @v_gentable2level > 1
		BEGIN
			IF @v_gentable2level > 2
			BEGIN
				SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, g.datadesc, s.datadesc datasubdesc, s2.datadesc datasub2desc, g.deletestatus, 0 newind
				FROM gentablesrelationshipdetail d, gentables g, subgentables s, sub2gentables s2
				WHERE g.tableid = @v_tableid AND
					d.code2 = g.datacode AND
					s.tableid = @v_tableid AND
					d.code2 = s.datacode AND
					d.subcode2 = s.datasubcode AND
					s2.tableid = @v_tableid AND
					d.code2 = s2.datacode AND
					d.subcode2 = s2.datasubcode AND
					d.sub2code2 = s2.datasub2code AND
					d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
					d.code1 = @i_datacode AND
					(d.subcode1 = @i_datasubcode OR @v_gentable1level < 2) AND
					(d.sub2code1 = @i_datasub2code OR @v_gentable1level < 3)
				UNION
				SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, g.datadesc, s.datadesc datasubdesc, CONVERT(VARCHAR, d.sub2code2) datasub2desc, 'Y', 0 newind
				FROM gentablesrelationshipdetail d, gentables g, subgentables s
				WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
					d.code1 = @i_datacode AND
					(d.subcode1 = @i_datasubcode OR @v_gentable1level < 2) AND
					(d.sub2code1 = @i_datasub2code OR @v_gentable1level < 3) AND
					g.tableid = @v_tableid AND
					g.datacode = d.code2 AND
					s.tableid = @v_tableid AND
					s.datacode = d.code2 AND
					s.datasubcode = d.subcode2 AND
					NOT EXISTS (SELECT * FROM sub2gentables s2 WHERE s2.tableid = @v_tableid AND d.code2 = s2.datacode
											AND d.subcode2 = s2.datasubcode AND d.sub2code2 = s2.datasub2code)
			END
			ELSE BEGIN
				SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, g.datadesc, s.datadesc datasubdesc, '' datasub2desc, g.deletestatus, 0 newind
				FROM gentablesrelationshipdetail d, gentables g, subgentables s
				WHERE g.tableid = @v_tableid AND
					d.code2 = g.datacode AND
					s.tableid = @v_tableid AND
					d.code2 = s.datacode AND
					d.subcode2 = s.datasubcode AND
					d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
					d.code1 = @i_datacode AND
					(d.subcode1 = @i_datasubcode OR @v_gentable1level < 2) AND
					(d.sub2code1 = @i_datasub2code OR @v_gentable1level < 3)
				UNION
				SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, g.datadesc, CONVERT(VARCHAR, d.subcode2) datasubdesc, '' datasub2desc, 'Y', 0 newind
				FROM gentablesrelationshipdetail d, gentables g
				WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
					d.code1 = @i_datacode AND
					(d.subcode1 = @i_datasubcode OR @v_gentable1level < 2) AND
					(d.sub2code1 = @i_datasub2code OR @v_gentable1level < 3) AND
					g.tableid = @v_tableid AND
					g.datacode = d.code2 AND
					NOT EXISTS (SELECT * FROM subgentables s WHERE s.tableid = @v_tableid AND d.code2 = s.datacode
											AND d.subcode2 = s.datasubcode)
			END
		END
		ELSE BEGIN
			SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, g.datadesc, '' datasubdesc, '' datasub2desc, g.deletestatus, 0 newind
			FROM gentablesrelationshipdetail d, gentables g
			WHERE g.tableid = @v_tableid AND
				d.code2 = g.datacode AND
				d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND
				d.code1 = @i_datacode AND
				(d.subcode1 = @i_datasubcode OR @v_gentable1level < 2) AND
				(d.sub2code1 = @i_datasub2code OR @v_gentable1level < 3)
			UNION
			SELECT d.*, d.code2 origcode2, @v_tableid gentable2id, CONVERT(VARCHAR, d.code2) datadesc, '' datasubdesc, '' datasub2desc, 'Y', 0 newind
			FROM gentablesrelationshipdetail d
			WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey AND 
				d.code1 = @i_datacode AND
				(d.subcode1 = @i_datasubcode OR @v_gentable1level < 2) AND
				(d.sub2code1 = @i_datasub2code OR @v_gentable1level < 3) AND
				NOT EXISTS (SELECT * FROM gentables g WHERE g.tableid = @v_tableid AND d.code2 = g.datacode)
		END
	END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing gentablesrelationshipdetail (gentablesrelationshipkey=' + CONVERT(VARCHAR, @i_gentablesrelationshipkey) + ').'
  END 
GO

GRANT EXEC ON qutl_get_genrel_table2 TO PUBLIC
GO
