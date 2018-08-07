UPDATE gentablesrelationships 
SET indicator1label = 'Default first to primary' 
WHERE gentablesrelationshipkey = 2 -- TAQ Role to AuthorType

-- Activate this behavior for existing author types
UPDATE gentablesrelationshipdetail 
SET indicator1 = 1
WHERE gentablesrelationshipkey = 2 
  AND code2 IN (
    SELECT datacode FROM gentables WHERE tableid = 134 AND bisacdatacode = 'A'
  )
