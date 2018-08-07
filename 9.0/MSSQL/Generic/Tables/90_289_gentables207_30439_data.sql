UPDATE gentables SET qsicode = 1 WHERE tableid = 207 AND LTRIM(RTRIM(LOWER(datadesc))) = 'company mailing'
UPDATE gentables SET qsicode = 2 WHERE tableid = 207 AND LTRIM(RTRIM(LOWER(datadesc))) = 'company street'

GO