set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'contractdates_maintbestdate')
	BEGIN
		DROP  Trigger contractdates_maintbestdate
	END
GO

CREATE TRIGGER contractdates_maintbestdate ON contractdates 
FOR INSERT, UPDATE AS
IF UPDATE(activedate) OR UPDATE(estdate) 

DECLARE
  @v_contractkey INT,
  @v_datetypecode INT,
  @v_estdate DATETIME,
  @v_activedate DATETIME,	
  @v_actualind  TINYINT,
  @v_bestdate DATETIME,
  @err_msg VARCHAR(100)
 
SELECT @v_activedate = i.activedate,
  @v_estdate = i.estdate,
  @v_bestdate = COALESCE(i.activedate, i.estdate),
  @v_contractkey = i.contractkey,
  @v_datetypecode = i.datetypecode
FROM inserted i

IF @v_contractkey is null
   RETURN

IF @@error != 0
BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = 'Could not select from contractdates table (trigger).'
	print @err_msg
END
ELSE
BEGIN
      UPDATE contractdates 
      SET bestdate = @v_bestdate
      WHERE contractkey = @v_contractkey AND
              datetypecode = @v_datetypecode 

      IF @@error != 0
			BEGIN
			  ROLLBACK TRANSACTION
			  select @err_msg = 'Could not update contractdates table (trigger).'
			  print @err_msg
			END
END




