DECLARE
  @v_count  INT,
  @v_maxkey INT,
  @v_tabcode  INT,
  @v_datetypecode  INT,
  @v_usageclass INT,
  @v_datetype_pubdate INT,
  @v_label_pubdate VARCHAR(40),
  @v_datetype_releasedate INT,
  @v_label_releasedate VARCHAR(40),
  @v_datetype_bbdate INT,
  @v_label_bbdate VARCHAR(40),
  @v_projectrole_code INT,
  @v_titlerole_code INT,
  @v_roletypecode_code INT,
  @v_roletype_label VARCHAR(40)
  
BEGIN
  SELECT @v_maxkey = MAX(taqrelationshiptabconfigkey)
  FROM taqrelationshiptabconfig
  
  IF @v_maxkey IS NULL
    SET @v_maxkey = 0
    
  SELECT @v_tabcode = datacode 
  FROM gentables 
  WHERE tableid = 583 AND qsicode = 31  --Printings (on Titles)
  
  SELECT @v_usageclass = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND datacode = 14  --Printing
  
  IF @v_tabcode > 0 AND @v_usageclass > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM datetype
    WHERE description = 'Publication Date'

    SET @v_datetype_pubdate = NULL
    SET @v_label_pubdate = NULL
    IF @v_count > 0
      SELECT @v_datetype_pubdate = datetypecode, @v_label_pubdate = datelabel
      FROM datetype
      WHERE description = 'Publication Date'

    SELECT @v_count = COUNT(*)
    FROM datetype
    WHERE description = 'Release Date'

    SET @v_datetype_releasedate = NULL
    SET @v_label_releasedate = NULL
    IF @v_count > 0
      SELECT @v_datetype_releasedate = datetypecode, @v_label_releasedate = datelabel
      FROM datetype
      WHERE description = 'Release Date'

    SELECT @v_count = COUNT(*)
    FROM datetype
    WHERE description = 'Bound Book Date'

    SET @v_datetype_bbdate = NULL
    SET @v_label_bbdate = NULL
    IF @v_count > 0
      SELECT @v_datetype_bbdate = datetypecode, @v_label_bbdate = datelabel
      FROM datetype
      WHERE description = 'Bound Book Date'

    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 604
      AND qsicode = 3

    SET @v_projectrole_code = NULL
    IF @v_count > 0
      SELECT @v_projectrole_code = datacode
        FROM gentables
        WHERE tableid = 604
          AND qsicode = 3

    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 605
      AND qsicode = 7

    SET @v_titlerole_code = NULL
    IF @v_count > 0
      SELECT @v_titlerole_code = datacode
        FROM gentables
        WHERE tableid = 605
          AND qsicode = 7

    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 285
      AND datadesc = 'Production Manager'

    SET @v_roletypecode_code = NULL
    SET @v_roletype_label = NULL
    IF @v_count > 0
      SELECT @v_roletypecode_code = datacode, @v_roletype_label = datadesc
        FROM gentables
        WHERE tableid = 285
          AND datadesc = 'Production Manager'

    SELECT @v_count = COUNT(*)
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @v_tabcode AND
      itemtypecode = 14 AND
      usageclass = @v_usageclass
    
    IF @v_count = 0
    BEGIN
      SET @v_maxkey = @v_maxkey + 1
      
      INSERT INTO taqrelationshiptabconfig
        (taqrelationshiptabconfigkey, relationshiptabcode, itemtypecode, usageclass, datetypecode1,date1label,
         datetypecode2, date2label, datetypecode3, date3label,createitemtypecode,createclasscode,
         createprojrolecode,createtitlerolecode,roletypecode1,roletype1label,lastuserid,lastmaintdate, 
         hidethisrelind, hideotherrelind, hidefiltersind, hideclassind, hidetypeind, hidenotesind, hideownerind, addrelateditemind, 
         relateitemtypecode, relateclasscode, relate2itemtypecode, relate2classcode, relate3itemtypecode, relate3classcode)
      VALUES
        (@v_maxkey, @v_tabcode, NULL, NULL, @v_datetype_pubdate,@v_label_pubdate,
         @v_datetype_releasedate,@v_label_releasedate,@v_datetype_bbdate,@v_label_bbdate,14,@v_usageclass,
         @v_projectrole_code,@v_titlerole_code,@v_roletypecode_code,@v_roletype_label,'QIADMIN',getdate(), 
         1, 1, 1, 1, 1, 1, 1, 0, 
         NULL, NULL, NULL, NULL, NULL, NULL)
    END
  END
END
go
