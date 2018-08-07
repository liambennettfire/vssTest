/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_misccompspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_misccompspecs
END
GO

CREATE PROCEDURE specs_copy_write_misccompspecs 
	(@i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

DECLARE
	@v_compkey INT,
   @v_misctype INT,
   @v_miscsubtype INT,
   @v_misctableid INT,
   @v_quantity INT
 
DECLARE misccompspecs_cur CURSOR FOR
	SELECT compkey, misctype, miscsubtype, misctableid, quantity 
	FROM misccompspecs
	WHERE (bookkey = @i_from_bookkey) AND
			(printingkey = @i_from_printingkey) 

BEGIN

 OPEN misccompspecs_cur

  FETCH NEXT FROM misccompspecs_cur INTO @v_compkey,@v_misctype,@v_miscsubtype,@v_misctableid,@v_quantity

  WHILE (@@FETCH_STATUS = 0 )
  BEGIN

		INSERT INTO misccompspecs(bookkey,printingkey,compkey,misctype,miscsubtype,misctableid,quantity,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_compkey,@v_misctype,@v_miscsubtype,@v_misctableid,@v_quantity,@i_userid,getdate())
		
      FETCH NEXT FROM misccompspecs_cur INTO @v_compkey,@v_misctype,@v_miscsubtype,@v_misctableid,@v_quantity

       
   END --misccompspecs_cur LOOP
      
   CLOSE misccompspecs_cur
   DEALLOCATE misccompspecs_cur
END