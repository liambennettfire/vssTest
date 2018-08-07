DECLARE 
	@v_taskviewkey INT
	
	EXEC dbo.get_next_key 'QSIDBA', @v_taskviewkey OUT	


INSERT INTO taskview (taskviewkey, taskviewdesc, detaildescription, itemtypecode, usageclasscode, userkey, templateind, alldatetypesind, keydatecheckedind, hideactualsind, taskgroupind, minimizeselectionsectionind, elementtypecode, elementsubtypecode, printingnumber, rolecode, lastuserid, lastmaintdate)  
VALUES (@v_taskviewkey, 'All Tasks - Completed Tasks Hidden', 'All Tasks with contacts, titles and project description', 0, 0, -1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 21, 1, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 22, 2, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 24, 3, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 2, 4, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 31, 5, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 28, 6, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 19, 7, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 6, 8, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 5, 9, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 7, 10, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 15, 11, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 14, 12, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 16, 13, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 18, 14, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 8, 15, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 10, 16, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 4, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 30, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 9, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 1, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 11, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 25, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 13, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 26, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 12, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 27, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 17, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 20, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 29, 0, 'QSIDBA', getdate()) 

INSERT INTO taskviewfields (taskviewkey, taskfieldkey, columnorder, lastuserid, lastmaintdate)  VALUES (@v_taskviewkey, 23, 0, 'QSIDBA', getdate()) 

UPDATE taskviewfields SET sortorder=NULL, lastuserid='QSIDBA', lastmaintdate=getdate() WHERE taskviewkey=@v_taskviewkey

UPDATE taskviewfields SET sortorder=1, lastuserid='QSIDBA', lastmaintdate=getdate() WHERE taskviewkey=@v_taskviewkey AND taskfieldkey=6

UPDATE taskviewfields SET sortorder=2, lastuserid='QSIDBA', lastmaintdate=getdate() WHERE taskviewkey=@v_taskviewkey AND taskfieldkey=21

UPDATE taskviewfields SET sortorder=3, lastuserid='QSIDBA', lastmaintdate=getdate() WHERE taskviewkey=@v_taskviewkey AND taskfieldkey=22