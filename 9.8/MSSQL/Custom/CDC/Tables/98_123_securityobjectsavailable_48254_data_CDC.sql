UPDATE securityobjectsavailable SET defaultaccesscode = 2 
WHERE availablesecurityobjectskey IN (
  SELECT availablesecurityobjectskey 
  FROM securityobjectsavailable 
  WHERE availobjectdesc IN ('Prices - by Price Type', 'Prices - by Currency Type') 
    AND windowid = (SELECT windowid FROM qsiwindows WHERE windowname = 'titlesummary')
)
