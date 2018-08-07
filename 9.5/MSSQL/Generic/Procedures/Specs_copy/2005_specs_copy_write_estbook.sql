IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_estbook') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_estbook
END
GO

CREATE PROCEDURE Specs_Copy_write_estbook	(
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

DECLARE

	@v_estkey    	INT,
	@v_orgentrykey INT,
	@v_orglevelkey INT

	DECLARE estbookorgentry_cur CURSOR FOR
		 SELECT orgentrykey, orglevelkey FROM bookorgentry
		  WHERE (bookkey=@i_to_bookkey) 
BEGIN
	UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

	SELECT @v_estkey = generickey from keys

	INSERT INTO estbook (estkey, bookkey,printingkey,lastuserid,lastmaintdate)
    VALUES (@v_estkey,@i_to_bookkey,@i_to_printingkey,@i_userid,getdate())


	OPEN estbookorgentry_cur

	FETCH NEXT FROM estbookorgentry_cur INTO @v_orgentrykey, @v_orglevelkey

	WHILE (@@FETCH_STATUS = 0 )
  	BEGIN

		INSERT INTO estbookorgentry  (estkey,orgentrykey,orglevelkey,lastuserid,lastmaintdate )  
		 VALUES (@v_estkey,@v_orgentrykey,@v_orglevelkey,@i_userid,getdate())   
			
		FETCH NEXT FROM estbookorgentry_cur INTO @v_orgentrykey, @v_orglevelkey
			 
	END --estbookorgentry_cur LOOP
			
	CLOSE estbookorgentry_cur
	DEALLOCATE estbookorgentry_cur

END
go