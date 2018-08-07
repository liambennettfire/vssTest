DECLARE
  @v_count INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_relcurproj INT,
  @v_relrelproj INT,
  @v_reltabcode INT

BEGIN

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 25	--Contracts tab
  
  IF @v_count > 0
  BEGIN
    SELECT @v_reltabcode = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 25

    UPDATE taqrelationshiptabconfig
    SET relatecurrentprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 16), --Work (for Contract)
      relaterelatedprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 17) --Contract (for Work)
    WHERE relationshiptabcode = @v_reltabcode
  END

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 23	--Works tab
  
  IF @v_count > 0
  BEGIN
    SELECT @v_reltabcode = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 23
      
    UPDATE taqrelationshiptabconfig
    SET relatecurrentprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 17), --Contract (for Work)
      relaterelatedprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 16) --Work (for Contract)
    WHERE relationshiptabcode = @v_reltabcode
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 33	--Printings (on Purchase Orders)
  
  IF @v_count > 0
  BEGIN
    SELECT @v_reltabcode = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 33
      
    UPDATE taqrelationshiptabconfig
    SET relatecurrentprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 26), --Purchase Orders (for Printings)
      relaterelatedprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 25) --Printing (for Purchase Orders)
    WHERE relationshiptabcode = @v_reltabcode
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 29	--Additional P&L tab
  
  IF @v_count > 0
  BEGIN
    SELECT @v_reltabcode = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 29
    
    UPDATE taqrelationshiptabconfig
    SET relatecurrentprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 22), --Acquisition Project (for Addtl P&L)
      relaterelatedprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 24) --Additional P&L
    WHERE relationshiptabcode = @v_reltabcode 
		AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 3) --Projects
		AND usageclass = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1) --Acquisition
		
    UPDATE taqrelationshiptabconfig
    SET relatecurrentprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 23), --Work (for Addtl P&L)
      relaterelatedprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 24) --Additional P&L
    WHERE relationshiptabcode = @v_reltabcode 
		AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) --Works
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 30	--Primary P&L
  
  IF @v_count > 0
  BEGIN
    SELECT @v_reltabcode = datacode
    FROM gentables
    WHERE tableid = 583 AND qsicode = 30
      
    UPDATE taqrelationshiptabconfig
    SET relatecurrentprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 29), --Additional P&L
      relaterelatedprojrelcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 30) --Primary P&L
    WHERE relationshiptabcode = @v_reltabcode
  END
  
  -- Also do the setup for Contractual Sale tab (if exists)
  SELECT @v_count = COUNT(*)
  FROM subgentables 
  WHERE tableid = 550 AND datadesc = 'Contractual Sale'

  SET @v_datacode = 0
  SET @v_datasubcode = 0
  
  IF @v_count = 1
    SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
    WHERE tableid = 550 AND datadesc = 'Contractual Sale'
    
  IF @v_datacode > 0 AND @v_datasubcode > 0
  BEGIN
	SELECT @v_count = COUNT(*)
	FROM taqrelationshiptabconfig
	WHERE relateitemtypecode = @v_datacode AND relateclasscode = @v_datasubcode
	
	IF @v_count > 0	--tab configuration exists for relating Contractual Sale
	BEGIN
	  SELECT TOP 1 @v_relcurproj = datacode
	  FROM gentables 
	  WHERE tableid = 582 AND datadesc = 'Work (for Contractual Sale)'
	  
	  SELECT TOP 1 @v_relrelproj = datacode
	  FROM gentables 
	  WHERE tableid = 582 AND datadesc = 'Contractual Sale (for Work)'  
	  
      UPDATE taqrelationshiptabconfig
      SET relatecurrentprojrelcode = @v_relcurproj, relaterelatedprojrelcode = @v_relrelproj
      WHERE relateitemtypecode = @v_datacode AND relateclasscode = @v_datasubcode
	END
  END

END
go
