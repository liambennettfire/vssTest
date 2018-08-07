PRINT 'TRIGGER : dbo.AFTER_HISTORY_CHANGEDFROM' 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.AFTER_HISTORY_CHANGEDFROM') and (type = 'P' or type = 'TR'))
begin
 drop trigger dbo.AFTER_HISTORY_CHANGEDFROM
end

GO

create trigger AFTER_HISTORY_CHANGEDFROM
ON TITLEHISTORY
FOR INSERT, UPDATE 
AS


DECLARE	@v_bookkey		int
DECLARE 	@v_printingkey	int
DECLARE	@v_columnkey	int
DECLARE	@v_fromvalue	varchar(255) 
DECLARE	@v_tovalue		varchar(255) 
DECLARE	@v_fielddesc	varchar(50) 
DECLARE	@v_lastmaintdate	datetime

DECLARE	@v_test		varchar(100) 
DECLARE	@historystatus 	int

select 
	@v_bookkey = ins.bookkey,
	@v_printingkey = ins.printingkey,
	@v_columnkey = ins.columnkey ,
	@v_fielddesc = ins.fielddesc,
	@v_tovalue = ins.currentstringvalue,
	@v_lastmaintdate = ins.lastmaintdate
			from inserted ins

	/* PV - For some reason condition fielddesc = @v_fielddesc was */
	/* commented out. Not having this condition is causing problems */
	/* where incorrect stringvalue is being saved (See SIR # 2690) */
	DECLARE cur_oldtitlehistory  CURSOR
	FOR
		SELECT currentstringvalue
		FROM titlehistory
		WHERE bookkey = @v_bookkey AND
			printingkey =  @v_printingkey AND
			columnkey = @v_columnkey AND
			fielddesc = @v_fielddesc
		  order by bookkey,printingkey,columnkey,lastmaintdate desc

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

		UPDATE titlehistory
			SET stringvalue = @v_fromvalue
				WHERE bookkey = @v_bookkey AND
					printingkey = @v_printingkey AND
					columnkey = @v_columnkey AND
					fielddesc = @v_fielddesc AND
					currentstringvalue = @v_tovalue AND
					lastmaintdate = @v_lastmaintdate 	
	
GO