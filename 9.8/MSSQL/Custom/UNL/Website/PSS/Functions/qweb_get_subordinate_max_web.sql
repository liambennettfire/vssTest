set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
drop function qweb_get_subordinate_max_web
go

CREATE FUNCTION [dbo].[qweb_get_subordinate_max_web] 
            	(@i_workkey 	INT)
		

 
/*     will return the max bookkey for a workkey that is marked published to web 

*/

RETURNS int

AS  

BEGIN 

DECLARE @i_maxsubordinate int
DECLARE @RETURN   	int

 

SELECT @i_maxsubordinate=max(bookkey) 
FROM bookdetail
WHERE bookkey in (select bookkey from book where workkey=@i_workkey)
	AND publishtowebind=1


 

	IF COALESCE (@i_maxsubordinate,0) > 0
		BEGIN
			SELECT @RETURN = @i_maxsubordinate
		END	
	
	ELSE -- IF NULL
		BEGIN
			SELECT @RETURN = NULL
		END	
		

RETURN @RETURN

END









