if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_apply_pubmonth_defaults') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_apply_pubmonth_defaults
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_apply_pubmonth_defaults
 (@i_bookkey  integer,
  @i_printingkey  integer,
  @i_pubmonth integer,
  @i_pubyear  integer,
  @i_userid   varchar(30),
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************************
**  Name: qtitle_apply_pubmonth_defaults
**  Desc: This stored procedure handles pubmonth defaults.
**        For any dates entered for a given set of Orgentries, Pub Year and Pub Month,
**        if a date exists on the title, it will be updated to the default value.
**
**  Auth: Kate
**  Date: 3 August 2010
*******************************************************************************************
**    Change History
*******************************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value     
******************************************************************************************/
 
  
DECLARE
  @v_actualind  TINYINT,
  @v_count  INT,
  @v_datetypecode INT,
  @v_defaultdate  DATETIME,
  @v_keydateind TINYINT,
  @v_orgentrykey  INT,
  @v_taqtaskkey INT,
  @v_webscheduling_clientvalue TINYINT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Check if client uses web scheduling
  SELECT @v_webscheduling_clientvalue = optionvalue
  FROM clientoptions
  WHERE optionid = 72
  
  -- Loop through title's orgentries from the lowest orgentry up
  DECLARE bookorgentry_cur CURSOR FOR
    SELECT orgentrykey
    FROM bookorgentry 
    WHERE bookkey = @i_bookkey
    ORDER BY orglevelkey DESC
        
  OPEN bookorgentry_cur

  FETCH NEXT FROM bookorgentry_cur INTO @v_orgentrykey
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
  
    -- If pubmonthdefaults exist for this orgentry and Pub Year, we will use them
    SELECT @v_count = COUNT(*)
    FROM pubmonthdefaults
    WHERE orgentrykey = @v_orgentrykey AND pubyear = @i_pubyear

    IF @v_count > 0
    BEGIN
      -- Loop through all pub month defaults for this orgentry and pub year, and update title's estimated date
      -- with the default date value
      DECLARE defaults_cur CURSOR FOR    
        SELECT datetypecode, keydateind, 
          CASE @i_pubmonth
            WHEN 1 THEN january
            WHEN 2 THEN february
            WHEN 3 THEN march
            WHEN 4 THEN april
            WHEN 5 THEN may
            WHEN 6 THEN june
            WHEN 7 THEN july
            WHEN 8 THEN august
            WHEN 9 THEN september
            WHEN 10 THEN october
            WHEN 11 THEN november
            WHEN 12 THEN december
          END defaultdate
        FROM pubmonthdefaults 
        WHERE orgentrykey = @v_orgentrykey AND pubyear = @i_pubyear
        
      OPEN defaults_cur

      FETCH NEXT FROM defaults_cur INTO @v_datetypecode, @v_keydateind, @v_defaultdate
      
      WHILE (@@FETCH_STATUS = 0) 
      BEGIN
      
        IF @v_webscheduling_clientvalue = 1 --client uses web scheduling - update taqprojecttask table
          BEGIN
            SELECT @v_count = COUNT(*)
            FROM taqprojecttask
            WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @v_datetypecode
            
            IF @v_count > 0
            BEGIN
              SELECT @v_actualind = COALESCE(actualind,0)
              FROM taqprojecttask
              WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @v_datetypecode
              
              IF @v_actualind = 0
              BEGIN
                UPDATE taqprojecttask
                SET activedate = @v_defaultdate, keyind = @v_keydateind, lastuserid = @i_userid, lastmaintdate = getdate()
                WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @v_datetypecode
              END
            END
            ELSE
            BEGIN
              EXEC get_next_key 'taqprojecttask', @v_taqtaskkey OUTPUT
              
              INSERT INTO taqprojecttask
                (taqtaskkey, bookkey, printingkey, datetypecode, activedate, actualind, keyind, originaldate, lastuserid, lastmaintdate)
              VALUES
                (@v_taqtaskkey, @i_bookkey, @i_printingkey, @v_datetypecode, @v_defaultdate, 0, @v_keydateind, @v_defaultdate, @i_userid, getdate())
            END
          END
        ELSE  --client uses TMM scheduling - update task table, and bookdates table if key date
          BEGIN
            UPDATE task
            SET estimateddate = @v_defaultdate
            WHERE datetypecode = @v_datetypecode AND
              elementkey IN (SELECT elementkey FROM bookelement WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey)        
            
            IF @v_keydateind = 1
            BEGIN
              SELECT @v_count = COUNT(*)
              FROM bookdates
              WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @v_datetypecode
              
              IF @v_count > 0           
                UPDATE bookdates
                SET estdate = @v_defaultdate
                WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @v_datetypecode
              ELSE
                INSERT INTO bookdates
                  (bookkey, printingkey, datetypecode, estdate, lastuserid, lastmaintdate)
                VALUES
                  (@i_bookkey, @i_printingkey, @v_datetypecode, @v_defaultdate, @i_userid, getdate())
            END
          END
        
        FETCH NEXT FROM defaults_cur INTO @v_datetypecode, @v_keydateind, @v_defaultdate
        
      END	/* defaults cursor */
    	
      CLOSE defaults_cur 
      DEALLOCATE defaults_cur
      
      GOTO FINISHED
        
    END
    
    FETCH NEXT FROM bookorgentry_cur INTO @v_orgentrykey

  END	/* bookorgentry cursor */
	
	FINISHED:
  CLOSE bookorgentry_cur 
  DEALLOCATE bookorgentry_cur
  
END
GO

GRANT EXEC ON qtitle_apply_pubmonth_defaults TO PUBLIC
GO