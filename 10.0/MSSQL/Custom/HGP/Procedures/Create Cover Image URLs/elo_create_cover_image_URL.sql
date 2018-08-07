if exists (select * from dbo.sysobjects where id = object_id(N'dbo.elo_create_cover_image_URL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure  dbo.[elo_create_cover_image_URL]
GO

/****** Object:  StoredProcedure [dbo].[elo_create_cover_image_URL]    Script Date: 04/01/2015 12:05:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[elo_create_cover_image_URL]
AS
/******************************************************************************
**  Name: elo_create_cover_image_URL
**  Desc: This stored procedure is run as a job that will create/update 
**        miscellaneous items for cover image URL links. The start and completion of the job
**        is logged using write_qsijobmessages. For any failures during the
**        stored procedure, we execute write_qsijobmessages to log an and error and an aborted
**        status.
*******************************************************************************/
DECLARE @count INT
DECLARE @i_ean13 BIGINT
DECLARE @i_bookkey INT
DECLARE @URLmisckey INT
DECLARE @i_rownumber INT
DECLARE @miscgentablesdatacode INT
DECLARE @i_URLcursorstatus INT
DECLARE @jobStopDateTime DATE
DECLARE @coverURL VARCHAR(4000)
DECLARE @v_qsibatchkey INT
DECLARE @v_qsijobkey INT
DECLARE @v_datacode INT
DECLARE @o_error_code INT
DECLARE @error_var INT
DECLARE @rowcount_var INT
DECLARE @o_error_desc VARCHAR(4000)

SELECT @v_qsibatchkey = null
SELECT @v_qsijobkey = null
SELECT @o_error_code = 0
SELECT @o_error_desc = ''
SELECT @URLmisckey = 0
SELECT @miscgentablesdatacode = 0
SELECT @jobStopDateTime = null


		
SELECT @v_datacode = datacode
FROM gentables 
WHERE tableid = 543 and eloquencefieldtag = 'COVERURL'

	IF @v_datacode is NULL
		BEGIN
			select @v_datacode = MAX(datacode) + 1 from gentables where tableid = 543
			INSERT INTO gentables (tableid,datacode,datadesc,deletestatus,tablemnemonic,datadescshort,lastuserid,lastmaintdate,gen1ind,gen2ind,
									acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag)
			VALUES (543,@v_datacode,'Create Cover Image URL','N','QSIJOBTYPE','Create URL','qsidba',getdate(),1,1,0,0,0,0,'COVERURL')
			
			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 OR @rowcount_var <= 0
				BEGIN
					EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Insert to gentables 543 failed','Insert to gentables 543 failed',@o_error_code output, @o_error_desc output
					EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
					
					RETURN -1
				END
		END

SELECT @jobStopDateTime = MAX(stopdatetime)
FROM qsijob
WHERE jobtypecode = @v_datacode and statuscode = 3

	IF @jobStopDateTime is NULL
		BEGIN
			SELECT @jobStopDateTime = '01/01/1990'
		END
		PRINT @jobStopDateTime



--Exec write_qsijobmessage to log start of procedure.
EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output
	IF (@o_error_code <> 1)
		BEGIN
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Unable to execute write_qsijobmessage procedure','Unable to execute write_qsijobmessage procedure',@o_error_code output, @o_error_desc output
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
			--We pass in a 5 for the abort status based on gentables 539. In write_qsijobmessage, it takes the message code of 5 and applies a statuscode of 2 (in qsijob table) which correlates to "Aborted" in gentables 544.
			--In qsijobmessages you shoud see a row with messagetypecode of 5.
			UPDATE qsijob
			SET jobdesc = 'Create Cover Image URL ' + CONVERT(VARCHAR,GETDATE(),109)
			WHERE qsijobkey=@v_qsijobkey and qsibatchkey=@v_qsibatchkey
			
			RETURN -1
		END
	IF (@o_error_code = 1)--If the execution of write_qsijobmessage was sucessful, then update the qsijob table to fill in the jobdesc because this is not handled in write_qsijobmessage.
		BEGIN
			UPDATE qsijob
			SET jobdesc = 'Create Cover Image URL ' + CONVERT(VARCHAR,GETDATE(),109)
			WHERE qsijobkey=@v_qsijobkey and qsibatchkey=@v_qsibatchkey
			
			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 OR @rowcount_var <= 0
				BEGIN
					EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Update to qsijob failed','Update to qsijob failed',@o_error_code output, @o_error_desc output
					EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
					
					RETURN -1
				END
		END
		


SELECT @URLmisckey = misckey, @miscgentablesdatacode = g.datacode
FROM bookmiscitems bm
JOIN gentables g on g.tableid = 560 and g.datacode=bm.eloquencefieldidcode and g.eloquencefieldtag='DPIDXBIZCOVERURL'

	IF @URLmisckey = 0 or @URLmisckey is NULL 
		BEGIN
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Cannot find misc item DPIDXBIZCOVERURL','Cannot find misc item DPIDXBIZCOVERURL',@o_error_code output, @o_error_desc output			
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
			UPDATE qsijob
			SET jobdesc = 'Create Cover Image URL ' + CONVERT(VARCHAR,GETDATE(),109)
			WHERE qsijobkey=@v_qsijobkey and qsibatchkey=@v_qsibatchkey
			
			RETURN -1
		END
	IF @miscgentablesdatacode = 0 OR @miscgentablesdatacode is NULL
		BEGIN
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Cannot find misc item DPIDXBIZCOVERURL','Cannot find misc item DPIDXBIZCOVERURL',@o_error_code output, @o_error_desc output
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
			UPDATE qsijob
			SET jobdesc = 'Create Cover Image URL ' + CONVERT(VARCHAR,GETDATE(),109)
			WHERE qsijobkey=@v_qsijobkey and qsibatchkey=@v_qsibatchkey
			
			RETURN -1
		END



DECLARE cursor_bookkeys CURSOR FAST_FORWARD
FOR
	SELECT distinct i.ean13, i.bookkey  From taqprojectelement tpe
	JOIN gentables g on tpe.taqelementtypecode=g.datacode 
	JOIN gentables g2 on g2.tableid = 593 and g2.datacode=tpe.elementstatus and g2.qsicode in (2,3)--uploaded or approved status
	JOIN isbn i on i.bookkey=tpe.bookkey
	WHERE tpe.lastmaintdate >= @jobStopDateTime and g.tableid = 287 and g.eloquencefieldtag = 'CLD_AT_CoverArtHigh'--Only cover art elements
FOR READ ONLY

OPEN cursor_bookkeys

FETCH NEXT FROM cursor_bookkeys
INTO @i_ean13, @i_bookkey

SELECT @i_URLcursorstatus = @@FETCH_STATUS
SELECT @i_rownumber=0

WHILE (@i_URLcursorstatus <> -1)
BEGIN
	SELECT @i_rownumber = @i_rownumber + 1
	IF (@i_URLcursorstatus<>-2)
	BEGIN
		SELECT @coverURL = 'http://www.hardiegrant.com.au/books/books/book-cover?isbn=' + CONVERT(varchar,@i_ean13)

		SELECT @count = COUNT(*) from bookmisc where bookkey=@i_bookkey and misckey=@URLmisckey
		IF (@count = 1)
			BEGIN
				UPDATE bookmisc
				SET textvalue = @coverURL, lastmaintdate = GETDATE()
				WHERE bookkey=@i_bookkey and misckey=@URLmisckey

				SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
				IF @error_var <> 0 OR @rowcount_var <= 0
					BEGIN
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Update to bookmisc failed','Update to bookmisc failed',@o_error_code output, @o_error_desc output
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
						
						RETURN -1
					END
				
				EXEC qtitle_update_titlehistory 'bookmisc','textvalue',@i_bookkey,0,0,@coverURL,'update','FBT-CreateURL',1,'Cover Image URL',@o_error_code output,@o_error_desc output
				IF (@o_error_code = -1)
					BEGIN
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Update to titlehistory failed','Update to titlehistory failed',@o_error_code output, @o_error_desc output
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
						UPDATE qsijob
						SET jobdesc = 'Create Cover Image URL ' + CONVERT(VARCHAR,GETDATE(),109)
						WHERE qsijobkey=@v_qsijobkey and qsibatchkey=@v_qsibatchkey
			
						RETURN -1
					END
			END
		IF (@count < 1)
			BEGIN
				INSERT INTO bookmisc (bookkey,misckey,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
				VALUES (@i_bookkey,@URLmisckey,@coverURL,'FBT-CreateURL',GETDATE(),'1')
				
				SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
				IF @error_var <> 0 OR @rowcount_var <= 0
					BEGIN
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Insert to bookmisc failed','Insert to bookmisc failed',@o_error_code output, @o_error_desc output
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
						
						RETURN -1
					END
				
				EXEC qtitle_update_titlehistory 'bookmisc','textvalue',@i_bookkey,0,0,@coverURL,'insert','FBT-CreateURL',1,'Cover Image URL',@o_error_code output,@o_error_desc output
				IF (@o_error_code = -1)
					BEGIN
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Insert to titlehistory failed','Insert to titlehistory failed',@o_error_code output, @o_error_desc output
						EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
						UPDATE qsijob
						SET jobdesc = 'Create Cover Image URL ' + CONVERT(VARCHAR,GETDATE(),109)
						WHERE qsijobkey=@v_qsijobkey and qsibatchkey=@v_qsibatchkey
			
						RETURN -1
					END
			END
	END
	
	FETCH NEXT FROM cursor_bookkeys
	INTO @i_ean13, @i_bookkey
	SELECT @i_URLcursorstatus = @@FETCH_STATUS
	
END

CLOSE cursor_bookkeys
DEALLOCATE cursor_bookkeys


EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,6,'job complete','complete',@o_error_code output, @o_error_desc output
	IF (@o_error_code = -1)
		BEGIN
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,2,'Job was unable to complete','Job was unable to complete',@o_error_code output, @o_error_desc output
			EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, @v_datacode,0,'Create Cover Image URL','Create Image URL','FBT-CreateURL',0,0,0,5,'job aborted','aborted',@o_error_code output, @o_error_desc output
			UPDATE qsijob
			SET jobdesc = 'Create Cover Image URL ' + CONVERT(VARCHAR,GETDATE(),109)
			WHERE qsijobkey=@v_qsijobkey and qsibatchkey=@v_qsibatchkey
			
			RETURN -1
		END
		
		
GRANT ALL ON [dbo].[elo_create_cover_image_URL] TO PUBLIC
