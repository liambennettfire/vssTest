-- Add an Author role entry to globalcontactrole for any Authors in bookauthor that do not have one
DECLARE
  @v_authortype INT,
  @v_authorrole INT,
  @v_authorkey INT

SELECT @v_authortype = datacode FROM gentables WHERE tableid = 134 AND qsicode = 2

SELECT @v_authorrole = code2
FROM gentablesrelationshipdetail 
WHERE gentablesrelationshipkey = 1      -- TMM Author Type to Contact Role Mapping
  AND code1 = @v_authortype

SELECT DISTINCT authorkey
INTO #tempauthor
FROM bookauthor
WHERE authortypecode = @v_authortype 
  AND authorkey NOT IN (
    SELECT a.authorkey 
    FROM author a
      INNER JOIN globalcontactrole r ON r.globalcontactkey = a.authorkey AND r.rolecode = @v_authorrole
  )
  AND NOT EXISTS (
    SELECT 1 FROM globalcontactrole
    WHERE globalcontactkey = authorkey
      AND rolecode = @v_authorrole
  )

INSERT INTO globalcontactrole
  (globalcontactkey, rolecode, keyind, lastuserid, lastmaintdate, sortorder, ratetypecode, workrate)
  SELECT authorkey, @v_authorrole, 1, 'qsiadmin', getdate(), NULL, 0, 0
  FROM #tempauthor

DROP TABLE #tempauthor
