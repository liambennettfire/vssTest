SET ANSI_NULLS ON 
GO  
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_title_task') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_title_task
GO

CREATE FUNCTION dbo.rpt_get_title_task(@i_bookkey INT, @i_datetypecode int, @v_datetype varchar (3))
RETURNS datetime

 /** Returns the date for the passed bookkey and datetypecode, selecting the column specified in 3rd parameter @v_datetype. 
     This function is for Version 7 and retrieves date from new scheduling table taqprojecttask, rather than the
     original task table  **/

 -- v_datetype = 'O' = original
 -- v_datetype = 'A' = active
 -- v_datetype = 'B' = best
 -- v_datetype = 'R' = revised
 -- v_datetype = 'ACT' = actual
 AS

 BEGIN

   DECLARE @d_date as datetime
   DECLARE @RETURN as datetime

   SELECT @d_date =
     CASE
       WHEN @v_datetype = 'ACT' AND actualind = 1 THEN activedate
       WHEN @v_datetype = 'O' THEN originaldate
       WHEN @v_datetype = 'A' THEN activedate
       WHEN @v_datetype = 'R' THEN reviseddate
       WHEN @v_datetype = 'B' and originaldate IS NOT NULL AND activedate IS NOT NULL THEN activedate
       WHEN @v_datetype = 'B' and originaldate IS NULL AND activedate IS NOT NULL THEN activedate
       WHEN @v_datetype = 'B' and originaldate IS NOT NULL AND activedate IS NULL THEN originaldate
     END
    FROM taqprojecttask
   WHERE bookkey = @i_bookkey
     AND datetypecode = @i_datetypecode

   IF @v_datetype IS NULL BEGIN
    SELECT @RETURN = ''
   END
   ELSE BEGIN
    SELECT @RETURN = @d_date
   END

   RETURN @RETURN

END
GO

GRANT ALL ON rpt_get_title_task TO PUBLIC
Go
