if exists (select * from dbo.sysobjects where id = object_id(N'dbo.write_qsijobmessage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.write_qsijobmessage
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE write_qsijobmessage
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
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS
/******************************************************************************
**  File: 
**  Name: write_qsijobmessage
**  Desc: This stored procedure will maintain qsijob/qsijobmessages 
**        information
**
**    Auth: Alan Katzen
**    Date: 06 July 2005
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
   @statuscode_var          smallint,
   @newkey                  int,
   @v_full_desc             varchar(100)

   SET @o_error_code = 1
   SET @o_error_desc = ''
   SET @statuscode_var = 0
   SET @messagetypecode_var = @i_messagetypecode

   SELECT @current_datetime_var = getdate()

   --DBMS_OUTPUT.PUT_LINE('Jobkey: ' || i_qsijobkey);

   IF @i_qsijobkey IS NULL OR @i_qsijobkey = 0 OR @i_messagetypecode = 1 BEGIN
     IF @i_qsibatchkey IS NULL OR @i_qsibatchkey = 0 BEGIN
       -- new batch - need to generate a new batchkey
       EXECUTE get_next_key @i_userid,@i_qsibatchkey OUTPUT
     END

     -- new job - need to generate a new jobkey and insert a qsijob record
     EXECUTE get_next_key @i_userid,@i_qsijobkey OUTPUT

     -- set status to 'Started'
     SET @statuscode_var = 1

     -- set messagetype to 'Started'
     SET @messagetypecode_var = 1

     -- get full description of process
     SELECT @v_full_desc = datadesc
       FROM subgentables 
      WHERE tableid  = 543
        AND datacode = @i_jobtypecode 
        AND datasubcode = @i_jobtypesubcode
    
     IF @i_jobdesc IS NOT NULL BEGIN
       SET @v_full_desc = @i_jobdesc + ' - '  + @v_full_desc
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
   END

   IF @i_qsibatchkey IS NULL OR @i_qsibatchkey = 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Batchkey is required.'
     RETURN
   END

   IF @i_qsijobkey > 0 BEGIN
     execute get_next_key @i_userid,@newkey OUTPUT

     INSERT INTO qsijobmessages (qsijobmessagekey,qsijobkey,referencekey1,referencekey2,referencekey3,
                                 messagetypecode,messagelongdesc,messageshortdesc,lastuserid,lastmaintdate)
     VALUES (@newkey,@i_qsijobkey,@i_referencekey1,@i_referencekey2,@i_referencekey3,
             @messagetypecode_var,@i_messagelongdesc,@i_messageshortdesc,@i_userid,@current_datetime_var);

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

GRANT EXEC ON write_qsijobmessage TO PUBLIC
GO


