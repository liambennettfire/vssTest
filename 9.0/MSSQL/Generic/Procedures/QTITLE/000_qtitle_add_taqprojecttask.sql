if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_add_taqprojecttask') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_add_taqprojecttask
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO            
              
CREATE PROCEDURE qtitle_add_taqprojecttask
  (@i_taqelementkey  integer,
  @i_bookcontactkey integer,
  @i_datetypecode integer,
  @i_keyind integer,
  @i_userid varchar(30),
  @i_taskviewkey integer,
  @i_bookkey integer,
  @i_printingkey integer,
  @i_rolecode integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_add_taqprojecttask
**  Desc: This stored procedure adds a new row to taqprojecttask table
**        for a Title/book.
**
**    Auth: Lisa
**    Date: 10/1/08
**
*******************************************************************************/

  DECLARE
    @v_count  INT,
    @v_creationdatecode  INT,
    @v_keyind TINYINT,
    @v_taqtaskkey INT,
    @v_error  INT,
    @v_rowcount INT ,
    @v_rolecode INT,
    @v_globalcontactkey INT 
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  /* Get the client datetypecode for Creation Date (qsicode=10) */  
  SELECT @v_count = COUNT(*)
  FROM datetype WHERE qsicode = 10
  
  SET @v_creationdatecode = 0
  IF @v_count > 0
    SELECT @v_creationdatecode = datetypecode
    FROM datetype WHERE qsicode = 10
  
  /* Generate new taqtaskkey for taqprojecttask table */
  EXEC get_next_key @i_userid, @v_taqtaskkey OUTPUT
  
  IF @v_taqtaskkey IS NOT NULL BEGIN  
    SET @v_rolecode = 0
    SET @v_globalcontactkey = 0
    
  IF ( @i_bookcontactkey > 0 and @i_bookkey > 0 and @i_printingkey > 0 )
    BEGIN
      SELECT @v_globalcontactkey = COALESCE(globalcontactkey,0)
        FROM bookcontact bc 
       WHERE bc.bookcontactkey = @i_bookcontactkey
         AND bc.bookkey = @i_bookkey
    END
    
    /***** ADD new row to TAQPROJECTTASK table ****/
    IF @i_taskviewkey > 0 AND @i_datetypecode > 0 BEGIN
      INSERT INTO taqprojecttask (taqtaskkey,taqprojectkey,taqelementkey,bookkey,printingkey,
             globalcontactkey,rolecode,rolecode2,scheduleind,stagecode,duration,
             datetypecode,activedate,actualind,keyind,originaldate,taqtasknote,
             decisioncode,paymentamt,taqtaskqty,sortorder,lastuserid,lastmaintdate, lag)
      SELECT @v_taqtaskkey,null,@i_taqelementkey,@i_bookkey,@i_printingkey,@v_globalcontactkey,
             @i_rolecode,tvd.rolecode2,tvd.scheduleind,tvd.stagecode,
			 CASE
				WHEN COALESCE(tvd.duration, 0) = 0 THEN 
				     d.defaultduration
				ELSE tvd.duration
			 END duration,                          
             @i_datetypecode,tvd.defaultdate,0,@i_keyind,tvd.defaultdate,tvd.defaultnote,tvd.decisioncode,
             tvd.paymentamt,tvd.defaultqty,tvd.sortorder,@i_userid,getdate(), tvd.lag
        FROM taskviewdatetype tvd ,datetype d
       WHERE tvd.taskviewkey = @i_taskviewkey
         AND tvd.datetypecode = @i_datetypecode
         AND tvd.datetypecode = d.datetypecode          
    END
    ELSE BEGIN
      INSERT INTO taqprojecttask
        (taqtaskkey,
        bookkey,
        taqelementkey,
        globalcontactkey,
        rolecode,
        datetypecode,
        keyind,
        printingkey,
        lastuserid,
        lastmaintdate)
      VALUES
        (@v_taqtaskkey,
        @i_bookkey,
        @i_taqelementkey,
        @v_globalcontactkey,
        @v_rolecode,
        @i_datetypecode,
        @i_keyind,
        @i_printingkey,
        @i_userid,
        getdate())
    END
      
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Error inserting to taqprojecttask table (bookkey=' + CAST(@i_bookkey AS VARCHAR) + ', datetypecode=' + CAST(@i_datetypecode AS VARCHAR) + ', bookcontactkey=' + CAST(@i_bookcontactkey AS VARCHAR)
    END
    
    -- For Creation Date, also set activedate and keyind
    IF @v_creationdatecode > 0 AND @i_datetypecode = @v_creationdatecode
    BEGIN  
      UPDATE taqprojecttask
      SET activedate = lastmaintdate, actualind = 1
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND
        datetypecode = @i_datetypecode AND taqtaskkey = @v_taqtaskkey
    END
   END
   
  ELSE  --@v_taqtaskkey not generated (NULL)
   BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Could not generate new taqtaskkey (taqprojecttask table)'
   END
  
GO

GRANT EXEC ON qtitle_add_taqprojecttask TO PUBLIC
GO
