UPDATE securityobjectsavailable
SET defaultaccesscode = 2, availobjectcodetableid = 616, availobjectwholerowind = 1, allowadmintochoosevalueind = 1
WHERE windowid = (
    SELECT windowid
    FROM qsiwindows
    WHERE windowname = 'specificationtemplatesummary'
    )
  AND availobjectid = 'shProdSpecs'
  AND availobjectname IS NULL
