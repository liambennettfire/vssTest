SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.taqprojecttask_update_bookmiscitems_HGP') AND type = 'TR')
	DROP TRIGGER dbo.taqprojecttask_update_bookmiscitems_HGP
GO

/************************************************************************************************************
**  Name: taqprojecttask_update_bookmiscitems_HGP
**  Desc: 
**  Auth: Uday A. Khisty
**  Date: 07/13/2016
*************************************************************************************************************
**  Change History
*************************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    --------------------------------------------------------------------------------
** 
*************************************************************************************************************/


CREATE TRIGGER [dbo].[taqprojecttask_update_bookmiscitems_HGP] ON [dbo].[taqprojecttask]
AFTER INSERT, UPDATE, DELETE
AS
    BEGIN  

      DECLARE @v_insert_row_count INT, 
		      @v_delete_row_count INT,
              @v_bookkey           INT,
              @v_printingkey       INT,
              @v_datetypecode      INT,
              @v_activedate        DATETIME,
              @v_lastmaindate      DATETIME,
              @v_lastuserid        VARCHAR(50),
              @v_action            VARCHAR(25),
              @v_taqtaskkey        INT,
              @v_count             INT,
              @v_misckey		   INT,
              @v_BestUKPubDate     VARCHAR(10)  
              
		SET @v_insert_row_count = 0
		SET @v_delete_row_count = 0
			  
		SELECT @v_insert_row_count=count(*) FROM inserted WHERE inserted.datetypecode = 498 AND inserted.bookkey > 0 AND printingkey = 1
		SELECT @v_delete_row_count=count(*) FROM deleted WHERE deleted.datetypecode = 498 AND deleted.bookkey > 0 AND printingkey = 1
		
		IF @v_insert_row_count + @v_delete_row_count = 0 
			RETURN 		  
			
        IF EXISTS(SELECT * FROM bookmiscitems WHERE  externalid  = 'HGUKPUBDATE') BEGIN
           SELECT TOP(1) @v_misckey = misckey FROM bookmiscitems WHERE  externalid  = 'HGUKPUBDATE'	
        END
		ELSE BEGIN
			RETURN
		END    		

		IF @v_insert_row_count > 0 AND UPDATE (activedate) BEGIN		
			SELECT @v_bookkey =    Inserted.bookkey,
			       @v_printingkey = coalesce(Inserted.printingkey, 0),
			       @v_datetypecode = Inserted.datetypecode,
			       @v_activedate = Inserted.activedate,
			       @v_taqtaskkey = Inserted.taqtaskkey,
			       @v_lastuserid = Inserted.lastuserid
			FROM Inserted
			WHERE datetypecode = 498 AND
				  bookkey > 0 AND 
				  printingkey = 1
			
           IF @v_activedate IS NULL BEGIN
			   DELETE FROM bookmisc WHERE misckey = @v_misckey AND bookkey = @v_bookkey
			   EXEC CoreTitleInfo_Load @v_bookkey, 0	 
           END 
           ELSE BEGIN
               SET @v_BestUKPubDate = CONVERT(VARCHAR,@v_activedate,103)
			   IF EXISTS(SELECT * FROM bookmisc WHERE misckey = @v_misckey AND bookkey = @v_bookkey) BEGIN
				   UPDATE bookmisc SET textvalue = @v_BestUKPubDate, lastmaintdate = GETDATE(), lastuserid = @v_lastuserid
				   WHERE misckey = @v_misckey AND bookkey = @v_bookkey
			   END 
			   ELSE BEGIN
				   INSERT INTO bookmisc (bookkey, misckey, textvalue, lastmaintdate, lastuserid) VALUES (@v_bookkey, @v_misckey, @v_BestUKPubDate, GETDATE(), @v_lastuserid)
				   EXEC CoreTitleInfo_Load @v_bookkey, 0
			   END
           END  			
		END
		ELSE IF @v_delete_row_count > 0 AND @v_insert_row_count = 0 BEGIN			
			SELECT @v_bookkey = deleted.bookkey,
			       @v_printingkey = coalesce(deleted.printingkey, 0),
			       @v_datetypecode = deleted.datetypecode,
			       @v_activedate = deleted.activedate,
			       @v_taqtaskkey = deleted.taqtaskkey,
			       @v_lastuserid = deleted.lastuserid
			FROM deleted	
			WHERE datetypecode = 498 AND
			      bookkey > 0 AND 
			      printingkey = 1
			
			IF @v_bookkey > 0 BEGIN
				DELETE FROM bookmisc WHERE misckey = @v_misckey AND bookkey = @v_bookkey
				EXEC CoreTitleInfo_Load @v_bookkey, 0	 
			END	
		END
		ELSE BEGIN
			RETURN
		END                 
END
GO