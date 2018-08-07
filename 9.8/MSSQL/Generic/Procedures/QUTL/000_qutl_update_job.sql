if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_update_job') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_update_job
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_update_job
 (@i_qsibatchkey            integer output,
  @i_qsijobkey              integer output,
  @i_jobtypecode            integer,
  @i_jobtypesubcode         integer,
  @i_jobdesc                varchar(2000),
  @i_jobdescshort           varchar(255),
  @i_userid                 varchar(30),
  @i_referencekey1          integer,
  @i_referencekey2          integer,
  @i_referencekey3          integer,
  @i_messagetypecode        integer,
  @i_messagelongdesc        varchar(4000),
  @i_messageshortdesc       varchar(255),
  @i_messagecode            integer,
  @i_messagetypeqsicode     integer,
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS
/******************************************************************************
**  File: 
**  Name: qutl_update_job
**  Desc: This stored procedure will maintain qsijob/qsijobmessages 
**        information (this is a copy of write_qsijobmessage with modifications)
**
**    Auth: Kusum Basra
**    Date: 28 March 2013
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/
 DECLARE 
   @error_var               int,
   @rowcount_var            int,
   @current_datetime_var    datetime,
   @messagetypecode_var     smallint,
   @messagecode_var         int,
   @statuscode_var          smallint,
   @newkey                  int,
   @v_full_desc             varchar(100)

   SET @o_error_code = 1
   SET @o_error_desc = ''
   SET @statuscode_var = 0
   SET @messagetypecode_var = @i_messagetypeqsicode
   SET @messagecode_var = @i_messagecode
   IF (@messagecode_var < 0)
   BEGIN
		SELECT @messagecode_var = NULL
   END

   SELECT @current_datetime_var = getdate()


   --@i_messagetypeqsicode: 1 = Started 7 = Pending
   IF @i_qsijobkey IS NULL OR @i_qsijobkey = 0 OR @i_messagetypeqsicode = 1 OR @i_messagetypeqsicode = 7 BEGIN
     

     IF @i_qsijobkey IS NULL OR @i_qsijobkey = 0 BEGIN
       IF @i_qsibatchkey IS NULL OR @i_qsibatchkey = 0 BEGIN
        -- new batch - need to generate a new batchkey
         EXECUTE get_next_key @i_userid,@i_qsibatchkey OUTPUT
       END

       -- new job - need to generate a new jobkey and insert a qsijob record
       EXECUTE get_next_key @i_userid,@i_qsijobkey OUTPUT
  
       IF @i_messagetypeqsicode = 1 BEGIN
         SELECT @statuscode_var = datacode FROM gentables WHERE tableid = 544 AND qsicode = 1  -- Start
       END 
       IF @i_messagetypeqsicode = 7 BEGIN
        SELECT @statuscode_var = datacode FROM gentables WHERE tableid = 544 AND qsicode = 4  -- Pending
       END 
   
       SELECT @messagetypecode_var = datacode FROM gentables WHERE tableid = 539 and qsicode = @i_messagetypeqsicode

       -- get full description of process
       SELECT @v_full_desc = datadesc FROM subgentables WHERE tableid  = 543 AND datacode = @i_jobtypecode AND datasubcode = @i_jobtypesubcode
      
       IF @i_jobdesc IS NOT NULL BEGIN
         SET @v_full_desc = @i_jobdesc + COALESCE(' - '  + @v_full_desc, '')
       END

       INSERT INTO qsijob (qsibatchkey,qsijobkey,jobtypecode,jobtypesubcode,jobdesc,jobdescshort,startdatetime,
                          runuserid,lastuserid,lastmaintdate,statuscode)
        VALUES (@i_qsibatchkey,@i_qsijobkey,@i_jobtypecode,@i_jobtypesubcode,@v_full_desc,@i_jobdescshort,@current_datetime_var,
                @i_userid,@i_userid,@current_datetime_var,@statuscode_var)

       SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
       IF @error_var <> 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to insert into qsijob table.'
         RETURN
        END
     END -- @i_qsijobkey IS NULL OR @i_qsijobkey = 0 
     ELSE BEGIN  -- this processing will occur for start job type when Job Key already exists
       IF @messagetypecode_var = 1 BEGIN
          SELECT @statuscode_var = datacode FROM gentables WHERE tableid = 544 AND qsicode = 1  -- Start
       END 
     
       UPDATE qsijob
          SET startdatetime = @current_datetime_var,
              statuscode = @statuscode_var,
              lastmaintdate = @current_datetime_var,
              lastuserid = @i_userid
        WHERE qsijobkey = @i_qsijobkey

       SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
       IF @error_var <> 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update qsijob table.'
         RETURN
        END
     END
  END
 
  IF @i_qsijobkey > 0 BEGIN
    execute get_next_key @i_userid,@newkey OUTPUT

    INSERT INTO qsijobmessages (qsijobmessagekey,qsijobkey,referencekey1,referencekey2,referencekey3,
                                messagetypecode,messagelongdesc,messageshortdesc,lastuserid,lastmaintdate,messagecode)
    VALUES (@newkey,@i_qsijobkey,@i_referencekey1,@i_referencekey2,@i_referencekey3,
            @messagetypecode_var,@i_messagelongdesc,@i_messageshortdesc,@i_userid,@current_datetime_var,@messagecode_var);

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to insert into qsijobmessages table.'
      RETURN
    END 

    -- Certain Message Types Signal the End of the Job
    IF @messagetypecode_var = 5 BEGIN
      -- 'Aborted'
      SET @statuscode_var = 2
    END
    ELSE BEGIN
      IF @messagetypecode_var = 6 BEGIN
        -- 'Completed'
        SET @statuscode_var = 3
      END 
    END

    IF @statuscode_var = 2 OR @statuscode_var = 3 BEGIN
       -- Job has ended - messagetype is 'Aborted' OR 'Completed' - Update status on qsijob
       UPDATE qsijob
          SET stopdatetime = @current_datetime_var,
              statuscode = @statuscode_var,
              lastmaintdate = @current_datetime_var,
              lastuserid = @i_userid
        WHERE qsijobkey = @i_qsijobkey

       SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
       IF @error_var <> 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update qsijob table.'
         RETURN
       END 
    END
  END
GO

GRANT EXEC ON qutl_update_job TO PUBLIC
GO


