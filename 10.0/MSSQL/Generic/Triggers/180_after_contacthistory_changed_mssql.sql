PRINT 'TRIGGER : dbo.AFTER_GLOBALCONTACTHISTORY_CHANGEDFROM' 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.AFTER_GLOBALCONTACTHISTORY_CHANGEDFROM') and (type = 'P' or type = 'TR'))
begin
 drop trigger dbo.AFTER_GLOBALCONTACTHISTORY_CHANGEDFROM
end

GO

create trigger AFTER_GLOBALCONTACTHISTORY_CHANGEDFROM
ON GLOBALCONTACTHISTORY
FOR INSERT, UPDATE 
AS


DECLARE	@v_globalcontacthistorykey		int
DECLARE 	@v_globalcontactkey	int
DECLARE	@v_columnkey	int
DECLARE	@v_fromvalue	varchar(255) 
DECLARE	@v_tovalue		varchar(255) 
DECLARE	@v_fielddesc	varchar(50) 
DECLARE	@v_lastmaintdate	datetime

DECLARE	@v_test		varchar(100) 
DECLARE	@historystatus 	int

select 
	@v_globalcontacthistorykey = ins.globalcontacthistorykey,
	@v_globalcontactkey = ins.globalcontactkey,
	@v_columnkey = ins.columnkey ,
	@v_fielddesc = ins.fielddesc,
	@v_tovalue = ins.currentstringvalue,
	@v_lastmaintdate = ins.lastmaintdate
			from inserted ins

	DECLARE cur_oldtitlehistory  CURSOR
	FOR
		SELECT currentstringvalue
		FROM globalcontacthistory
		WHERE globalcontactkey =  @v_globalcontactkey AND
			columnkey = @v_columnkey AND
			fielddesc = @v_fielddesc
		  order by globalcontactkey,columnkey,lastmaintdate desc

	FOR READ ONLY

	OPEN cur_oldtitlehistory

	FETCH NEXT FROM cur_oldtitlehistory INTO @v_fromvalue
	FETCH NEXT FROM cur_oldtitlehistory INTO @v_fromvalue
		
	select @historystatus  = @@FETCH_STATUS

	IF (@historystatus<>0)
		begin
			select @v_fromvalue = '(Not Present)' 	/* no old value found - stringvalue should stand at (Not Present) */
		end

		close cur_oldtitlehistory
		deallocate cur_oldtitlehistory

		UPDATE globalcontacthistory
			SET stringvalue = @v_fromvalue
				WHERE globalcontacthistorykey = @v_globalcontacthistorykey AND
					globalcontactkey = @v_globalcontactkey AND
					columnkey = @v_columnkey AND
					fielddesc = @v_fielddesc AND
					currentstringvalue = @v_tovalue AND
					lastmaintdate = @v_lastmaintdate 	
	
GO