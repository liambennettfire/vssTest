IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id('[dbo].[qcs_update_distributions]') AND (type = 'P' OR type = 'RF'))
	DROP PROCEDURE [dbo].[qcs_update_distributions]
GO

CREATE PROCEDURE [dbo].[qcs_update_distributions](@xml xml, @updateExisting bit, @jobKey int)
AS
BEGIN
	BEGIN TRY
		DECLARE @idoc int
		DECLARE @roleCode int
		DECLARE @requestedDateType int
		DECLARE @completedDateType int
		DECLARE @requestedStatus int
		DECLARE @count int
		DECLARE @lastKey int
		DECLARE @baseKey int
	    
		DECLARE @DIST TABLE(
			Id INT PRIMARY KEY,
            Tag VARCHAR(25),
            AssetId UNIQUEIDENTIFIER,
            PartnerTag VARCHAR(25),
            [Status] VARCHAR(25),
            Notes VARCHAR(MAX),
            UpdatedBy VARCHAR(30),
            UpdatedAt DATETIME);

		DECLARE @EVENT TABLE(
			Id UNIQUEIDENTIFIER PRIMARY KEY,
			DistributionId INT,
            [Status] VARCHAR(25),
            Notes VARCHAR(2000),
            UpdatedBy VARCHAR(30),
            UpdatedAt DATETIME
		);

		DECLARE @TASK TABLE(
			[id] [int] PRIMARY KEY IDENTITY,
			[taqelementkey] [int],
			[bookkey] [int],
			[globalcontactkey] [int],
			[rolecode] [int],
			[datetypecode] [int] NOT NULL,
			[activedate] [datetime],
			[actualind] [tinyint],
			[originaldate] [datetime],
			[taqtasknote] [varchar](2000),
			[lastuserid] [varchar](30),
			[lastmaintdate] [datetime],
			[transactionkey] [int],
			[cseventid] [uniqueidentifier],
			[jobkey] [int]
		);

		SELECT @roleCode=datacode FROM gentables WHERE tableid=285 AND qsicode=12
		SELECT @requestedStatus=csstatuscode, @requestedDateType=datetypecode FROM csdistributionstatus WHERE cloudstatustag='CLD_DS_Requested'
		SELECT @completedDateType=datetypecode FROM csdistributionstatus WHERE cloudstatustag='CLD_DS_Completed'
	    
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		PRINT 'Load Xml...'

		INSERT INTO @DIST
		SELECT *
		FROM OPENXML(@idoc, '/Distributions/Dist', 1)
		WITH (Id int '@Id',
			  Tag varchar(25) '@Tag',
			  AssetId uniqueidentifier '@AssetId',
			  PartnerTag varchar(25) '@PartnerTag',
			  [Status] varchar(25) '@Status',
			  Notes varchar(max) 'Notes',
			  UpdatedBy varchar(30) '@UpdatedBy',
			  UpdatedAt datetime '@UpdatedAt')
			  

		INSERT INTO @EVENT
		SELECT *
		FROM OPENXML(@idoc, '/Distributions/Dist/Event', 1)
		WITH (Id uniqueidentifier '@Id',
			  DistributionId int '../@Id',
			  [Status] varchar(25) '@Status',
			  Notes varchar(2000) 'text()',
			  UpdatedBy varchar(30) '@UpdatedBy',
			  UpdatedAt datetime '@UpdatedAt')
			  
		IF @updateExisting=1
		BEGIN
			-- Update Existing Distributions
			PRINT 'Update Existing Distributions...'
			UPDATE D
			SET D.statuscode=S.datacode,
				D.notes=X.Notes,
				D.lastuserid=X.UpdatedBy,
				D.lastmaintdate=X.UpdatedAt
			FROM csdistribution D
			JOIN @DIST X ON X.Id=D.transactionkey
			JOIN gentables S ON S.tableid=576 AND S.eloquencefieldtag=X.[Status]
			WHERE
				D.statuscode!=S.datacode OR
				D.notes!=X.Notes OR
				D.lastuserid!=X.UpdatedBy
		END
		
		-- Insert New Distributions
		PRINT 'Insert New Distributions...'
		INSERT INTO csdistribution(
			[transactionkey],
			[bookkey],
			[assetkey],
			[partnercontactkey],
			[transactiontag],
			[statuscode],
			[notes],
			[lastuserid],
			[lastmaintdate],
			[qsijobkey])
		SELECT
			X.Id,
			A.bookkey,
			A.taqelementkey,
			P.globalcontactkey,
			X.Tag,
			S.datacode,
			X.Notes,
			X.UpdatedBy,
			X.UpdatedAt,
			@jobKey
		FROM @DIST X
		JOIN globalcontact P ON X.PartnerTag=P.partnerkey
		JOIN taqproductnumbers N ON X.AssetId=N.productnumber
		JOIN taqprojectelement A ON N.elementkey=A.taqelementkey
		JOIN gentables S ON S.tableid=576 AND S.eloquencefieldtag=X.[Status]
		WHERE 
			X.Id NOT IN (SELECT transactionkey FROM csdistribution)
	
		IF @updateExisting=1
		BEGIN
		PRINT 'Update Existing Tasks...'
			-- Update Existing Distribution Tasks
			UPDATE T
			SET T.cseventid=X.Id,
				T.activedate=X.UpdatedAt,
				T.originaldate=
					CASE WHEN S.datetypecode=@completedDateType
						THEN (SELECT TOP 1 O.UpdatedAt FROM @EVENT O WHERE O.DistributionId=X.DistributionId ORDER BY O.UpdatedAt)
						ELSE X.UpdatedAt
					END,
				T.actualind=1,
				T.datetypecode=S.datetypecode,
				T.taqtasknote=X.Notes,
				T.lastuserid=X.UpdatedBy,
				T.lastmaintdate=X.UpdatedAt
			FROM @EVENT X
			JOIN csdistribution D ON X.DistributionId=D.transactionkey
			JOIN csdistributionstatus S ON S.cloudstatustag=X.[Status]
			JOIN taqprojecttask T ON
				(
					T.cseventid=X.Id AND
					T.cseventid IS NOT NULL
				)OR
				(
					T.cseventid IS NULL AND
					T.transactionkey=D.transactionKey AND
					T.actualind=0 AND
					T.datetypecode=S.datetypecode
				)				
		END
		PRINT 'Load Distribute Tasks...'
		-- Insert Distribute Tasks that don't exist	
					
		INSERT INTO @TASK(
			taqelementkey, 
			bookkey, 
			globalcontactkey, 
			rolecode, 
			datetypecode, 
			activedate,
			actualind,
			originaldate,
			taqtasknote,
			lastuserid,
			lastmaintdate,
			transactionkey,
			jobkey
		)
		SELECT
			D.assetkey,
			D.bookkey,
			D.partnercontactkey,
			@roleCode,
			@completedDateType,
			D.lastmaintdate,
			0,
			D.lastmaintdate,
			D.notes,
			D.lastuserid,
			D.lastmaintdate,
			D.transactionkey,
			D.qsijobkey
		FROM csdistribution D
		LEFT JOIN taqprojecttask E ON
			E.cseventid IS NULL AND
			E.transactionkey=D.transactionKey AND
			E.actualind=0 AND
			E.datetypecode=@completedDateType
		WHERE
			E.taqtaskkey IS NULL AND
			D.statuscode=@requestedStatus
			
		SELECT @count=COUNT(*) FROM @TASK
		
		EXEC get_next_key_range 'Cloud', @count, @lastkey OUTPUT
		SET @baseKey=@lastKey-@count
		
		PRINT 'Insert Distribute Tasks...'
		INSERT INTO taqprojecttask(
			taqtaskkey,
			taqelementkey, 
			bookkey, 
			globalcontactkey, 
			rolecode, 
			datetypecode, 
			activedate,
			actualind,
			originaldate,
			taqtasknote,
			lastuserid,
			lastmaintdate,
			transactionkey,
			cseventid,
			printingkey,
			qsijobkey
		)
		SELECT
			@baseKey+id,
			taqelementkey, 
			bookkey, 
			globalcontactkey, 
			rolecode, 
			datetypecode, 
			activedate,
			actualind,
			originaldate,
			taqtasknote,
			lastuserid,
			lastmaintdate,
			transactionkey,
			cseventid,
			1,
			jobkey
		FROM @TASK
		
		PRINT 'Load New Tasks...'
		-- Insert Distribution Tasks that don't exist	
		DELETE FROM @TASK
					
		INSERT INTO @TASK(
			taqelementkey, 
			bookkey, 
			globalcontactkey, 
			rolecode, 
			datetypecode, 
			activedate,
			actualind,
			originaldate,
			taqtasknote,
			lastuserid,
			lastmaintdate,
			transactionkey,
			cseventid,
			jobkey
		)
		SELECT
			D.assetkey,
			D.bookkey,
			D.partnercontactkey,
			@roleCode,
			S.datetypecode,
			X.UpdatedAt,
			1,
			CASE WHEN S.datetypecode=@completedDateType
				THEN (SELECT TOP 1 O.UpdatedAt FROM @EVENT O WHERE O.DistributionId=X.DistributionId ORDER BY O.UpdatedAt)
				ELSE X.UpdatedAt
			END,
			X.Notes,
			X.UpdatedBy,
			X.UpdatedAt,
			D.transactionkey,
			X.Id,
			D.qsijobkey
		FROM @EVENT X
		JOIN csdistribution D ON X.DistributionId=D.transactionkey
		JOIN csdistributionstatus S ON X.[Status]=S.cloudstatustag
		LEFT JOIN taqprojecttask E ON
			(
				E.cseventid=X.Id AND
				E.cseventid IS NOT NULL
			)OR
			(
				E.cseventid IS NULL AND
				E.transactionkey=D.transactionKey AND
				E.actualind=0 AND
				E.datetypecode=S.datetypecode
			)	
		WHERE
			E.taqtaskkey IS NULL
			
		SELECT @count=COUNT(*) FROM @TASK
		
		EXEC get_next_key_range 'Cloud', @count, @lastkey OUTPUT
		SET @baseKey=@lastKey-@count
		
		PRINT 'Insert New Tasks...'
		INSERT INTO taqprojecttask(
			taqtaskkey,
			taqelementkey, 
			bookkey, 
			globalcontactkey, 
			rolecode, 
			datetypecode, 
			activedate,
			actualind,
			originaldate,
			taqtasknote,
			lastuserid,
			lastmaintdate,
			transactionkey,
			cseventid,
			printingkey,
			qsijobkey
		)
		SELECT
			@baseKey+id,
			taqelementkey, 
			bookkey, 
			globalcontactkey, 
			rolecode, 
			datetypecode, 
			activedate,
			actualind,
			originaldate,
			taqtasknote,
			lastuserid,
			lastmaintdate,
			transactionkey,
			cseventid,
			1,
			jobkey
		FROM @TASK
					
		IF @updateExisting=1
		BEGIN
			-- Delete Invalid Tasks
			PRINT 'Delete Invalid Tasks...'
			DELETE
			FROM taqprojecttask
			WHERE taqtaskkey IN (
				SELECT taqtaskkey
				FROM (				
					SELECT
						taqtaskkey,
						ROW_NUMBER() OVER(PARTITION BY transactionkey, datetypecode, actualind, cseventid ORDER BY activedate DESC) rownum,
						transactionkey,
						datetypecode,
						actualind,
						cseventid
					FROM taqprojecttask
				) T
				JOIN csdistributionstatus S ON T.datetypecode=S.datetypecode
				JOIN @DIST D ON T.transactionkey=D.Id				
				LEFT JOIN @EVENT X ON 
					T.cseventid=X.Id AND
					T.cseventid IS NOT NULL AND
					T.rownum = 1
				LEFT JOIN @DIST D2 ON
					T.cseventid IS NULL AND
					T.transactionkey=D2.Id AND
					T.actualind=0 AND
					T.datetypecode=@completedDateType AND
					T.rownum = 1
				WHERE
					X.Id IS NULL AND
					D2.Id IS NULL)
		END		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			
		EXEC rethrow_error
	END CATCH
END
