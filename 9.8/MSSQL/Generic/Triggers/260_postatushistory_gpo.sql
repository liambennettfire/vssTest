IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.postatushistory_gpo') AND type = 'TR')
	DROP TRIGGER dbo.postatushistory_gpo
GO

CREATE TRIGGER postatushistory_gpo ON gpo
FOR UPDATE AS
IF UPDATE (gpostatus) 

BEGIN
	DECLARE 
      @v_postatushistorykey	INT,
      @v_gpokey 					INT,
		@v_potypekey				INT,
		@v_pocurrentstatus		VARCHAR(1), 
		@v_poprevstatus   		VARCHAR(1), 
		@v_postatuschangeddate	DATETIME,
		@v_lastmaintdate			DATETIME,
		@v_lastmaintuserid		VARCHAR(30),
      @v_gpochangenum         INT,
      @v_compkey              INT,
      @v_sectiontype          INT,
      @v_maxkey                INT
		

	SELECT @v_gpokey = i.gpokey, @v_potypekey = i.potypekey,
          @v_pocurrentstatus = i.gpostatus, @v_poprevstatus = d.gpostatus,
          @v_postatuschangeddate = i.lastmaintdate,@v_lastmaintuserid = i.lastuserid,
          @v_gpochangenum = i.gpochangenum
     FROM inserted i, deleted d 
	 WHERE i.gpokey = d.gpokey

   SELECT @v_compkey = key3, @v_sectiontype = sectiontype
     FROM gposection
    WHERE gpokey = @v_gpokey

	SELECT  @v_postatushistorykey = MAX(postatushistorykey) from postatushistory

	IF  @v_postatushistorykey IS NULL SET  @v_postatushistorykey = 0
	
    /** Do not process if Misc. Pos - sectiontype = 3 and key3 = 1 on gposection ****/
     IF (@v_sectiontype = 3 AND @v_compkey <> 1) OR @v_sectiontype <> 3  
     BEGIN
         --EXEC get_next_key 'QSIDBA', @v_postatushistorykey OUTPUT
         
			SELECT @v_postatushistorykey = @v_postatushistorykey  + 1 
                      
			INSERT INTO postatushistory 
                     (postatushistorykey, pokey, potypekey, pocurrentstatus,poprevstatus, postatuschangeddate,lastmaintuser, lastmaintdate)
					VALUES (@v_postatushistorykey,@v_gpokey,@v_potypekey,@v_pocurrentstatus,@v_poprevstatus,@v_postatuschangeddate,@v_lastmaintuserid,getdate())
           
	  END
END
GO




