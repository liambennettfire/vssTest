/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_notes') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_notes
END
GO

CREATE PROCEDURE Specs_Copy_write_notes (
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_from_compkey     INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

DECLARE
	@v_notekey INT,
   @v_newnotekey INT,
   @v_text varchar(5500),
   @v_showonpoind varchar(1),
   @v_copynextprtgind varchar(1),
   @v_detaillinenbr  INT


DECLARE notes_cursor INSENSITIVE CURSOR FOR
	SELECT distinct notekey
     FROM note
    WHERE (bookkey=@i_from_bookkey) AND
		    (printingkey=@i_from_printingkey) AND
          (compkey = @i_from_compkey) 

BEGIN

 OPEN notes_cursor

  FETCH NEXT FROM notes_cursor INTO @v_notekey

  WHILE (@@FETCH_STATUS = 0 )
  BEGIN

		SELECT @v_text = text,@v_showonpoind = showonpoind,@v_copynextprtgind = copynextprtgind,@v_detaillinenbr = detaillinenbr
		  FROM note  
		 WHERE notekey= @v_notekey

      UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

		SELECT @v_newnotekey = generickey from keys
	
		INSERT INTO note (notekey,text,bookkey,printingkey,compkey,showonpoind,copynextprtgind,detaillinenbr,lastuserid,lastmaintdate )
			VALUES (@v_newnotekey,@v_text,@i_to_bookkey,@i_to_printingkey,@i_from_compkey,@v_showonpoind,@v_copynextprtgind,@v_detaillinenbr,@i_userid,getdate())

      FETCH NEXT FROM notes_cursor INTO @v_notekey
       
   END --notes_cursor LOOP
      
   CLOSE notes_cursor
   DEALLOCATE notes_cursor
END