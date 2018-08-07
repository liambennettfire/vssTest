DECLARE @v_windowid INT, @v_nextkey INT

SELECT @v_windowid = windowid
FROM qsiwindows
WHERE windowname = 'TaskTracking'

DELETE FROM securityobjectsavailable WHERE windowid = @v_windowid

EXEC get_next_key 'qsidba', @v_nextkey OUTPUT

INSERT INTO securityobjectsavailable (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder, menuitemid, menuitemname, menuitemdesc, lastuserid, lastmaintdate, availobjectcode, availobjectwholerowind, availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode)
VALUES (@v_nextkey, @v_windowid, 'TasksByStatus', NULL, 'Tasks - by Status', 1, NULL, NULL, NULL, 'QSIDBA', getdate(), NULL, 1, 323, 1, 2)