if exists (select * from dbo.sysobjects where id = object_id(N'dbo.next_id_number') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.next_id_number
GO

CREATE PROCEDURE next_id_number
  @i_projectkey         INT,
  @i_elementkey         INT,
  @i_related_journalkey	INT,
  @i_productidcode      INT,
  @o_result             VARCHAR(50) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT 
AS

/******************************************************************************************
**  Name: calc_cost_actual
**  Desc: Generic Get Next ID procedure for Project/Element ID gentable 594.
**
**  Auth: Kate
**  Date: March 19 2009
*******************************************************************************************/

DECLARE
  @v_next_id  int,
  @v_lock tinyint,
  @v_loop tinyint,
  @v_loop_inner tinyint,
  @v_count int  
  
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_loop = 0
  SET @v_loop_inner = 0  
  SET @o_result = 0
  
  BEGIN TRANSACTION next_id

  WHILE @v_loop = 0 
  BEGIN
    SELECT @v_next_id = numericdesc1, @v_lock = lockbyeloquenceind
    FROM gentables
    WHERE tableid = 594 AND datacode = @i_productidcode
    
    IF @v_lock = 1
      CONTINUE
          
    UPDATE gentables
    SET lockbyeloquenceind= 1
    WHERE tableid = 594 AND datacode = @i_productidcode

    IF @v_next_id IS NULL
      SET @v_next_id = 0
      
    WHILE @v_loop_inner = 0
    BEGIN	
		SELECT @v_count = COUNT(*) 
		FROM taqproductnumbers
		WHERE LTRIM(RTRIM(LOWER(productnumber))) = LTRIM(RTRIM(LOWER(CAST(@v_next_id AS VARCHAR))))
		AND productidcode = @i_productidcode
		
		IF @v_count = 0 BEGIN
			SET @v_loop_inner = 1
		END
		ELSE BEGIN
			SET @v_next_id = @v_next_id + 1
		END
    END       

    SET @o_result = @v_next_id

    SET @v_next_id = @v_next_id + 1
    
    UPDATE gentables
    SET numericdesc1 = @v_next_id, lockbyeloquenceind = 0
    WHERE tableid = 594 AND datacode = @i_productidcode
    
    SET @v_loop = 1
  END

  COMMIT TRANSACTION next_id

END
go

GRANT EXEC ON next_id_number TO PUBLIC
GO
