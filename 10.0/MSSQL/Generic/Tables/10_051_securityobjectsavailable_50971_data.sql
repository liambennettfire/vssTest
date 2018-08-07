UPDATE securityobjectsavailable
SET availobjectcodetableid = 284
WHERE windowid = (
    SELECT windowid
    FROM qsiwindows
    WHERE windowname = 'printingsummary'
    )
  AND availobjectid = 'ProjectComments'
