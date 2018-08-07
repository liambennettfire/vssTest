DECLARE   @v_count              int
DECLARE   @v_datacode           int
DECLARE   @v_datasubcode        int
DECLARE   @v_tableid            int
DECLARE   @v_datadesc           varchar(120)
DECLARE   @v_datadescshort      varchar(20)
DECLARE   @v_tablemnemonic      varchar(40)
DECLARE   @v_alternatedesc1     varchar(255)
DECLARE   @v_alternatedesc2     varchar(255)
DECLARE   @v_newkey             int
DECLARE   @v_itemtypecode       int
DECLARE   @v_itemtypesubcode    int
DECLARE   @v_qsicode            int

BEGIN
  SET @v_tableid = 669
  SET @v_tablemnemonic = 'TMWPROC'

  SELECT @v_count = count(*)
    FROM gentablesdesc
   WHERE tableid = @v_tableid

  IF @v_count = 0 BEGIN
    INSERT INTO gentablesdesc
	  (tableid, tabledesc, tabledesclong, tablemnemonic, userupdatableind, userupdate, filterorglevelkey,usedivisionind,
	  sourcetablecode, location, lockind, gentablesdesclong, 
      subjectcategoryind, subgenallowed, sub2genallowed, requiredlevels,
	  updatedescallowed, activeind, itemtypefilterind, fakeentryind,
	  hideonixfields,elofieldidlevel,elofieldid,productdetailind,
	  gen1indlabel,gentext1label,gentext2label,
	  subgen1indlabel,subgentext1label)
    VALUES
	    (669, 'TMWPROC', 'TM Web Process', 'TMWPROC', 0, 'N', NULL,0,
       0, 'gentables',   1, 'This table will hold values for processes that can be invoked from TM Web.  These processes might be called from a Summary window, Search window or a menu item.  They may involve uploading a file but they can also just be a stored procedure that runs.  Message including errors from this job will be written to the qsijobs/qsijobmessages tables.  The subgentables value will hold the column names for the file upload table (if that exists for this process).  Not every process will have  a file upload.',
       0, 1, 0, 1, 
       0, 1, 2, 1,
       1,0,NULL,0,
       'Background Job?','File Upload Table Name','Process Procedure',
       'Required?','Predefined Variable')
   END
END
go