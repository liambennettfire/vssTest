/********************************************************************
             Stat_ECF4.0_Release_upgrade.sql
    Mediachase ECF 4.1 Release 4.1.0 to Release 4.1.2 Statistics Upgrade Script
*********************************************************************/

SET NUMERIC_ROUNDABORT OFF
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE


BEGIN TRANSACTION
PRINT N'Adding indexes to [dbo].[Stat_Global]'
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_Global]') AND name = N'IX_Stat_Global')
CREATE NONCLUSTERED INDEX [IX_Stat_Global] ON [dbo].[Stat_Global] 
(
	[StatObjectId] ASC
) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_Global]') AND name = N'IX_Stat_Global_1')
CREATE NONCLUSTERED INDEX [IX_Stat_Global_1] ON [dbo].[Stat_Global] 
(
	[StatObjectTypeId] ASC
) ON [PRIMARY]
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
COMMIT

BEGIN TRANSACTION
PRINT N'Adding indexes to [dbo].[Stat_RequestInfo]'

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_RequestInfo]') AND name = N'IX_Stat_RequestInfo')
CREATE NONCLUSTERED INDEX [IX_Stat_RequestInfo] ON [dbo].[Stat_RequestInfo] 
(
	[VisitorId] ASC
) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_RequestInfo]') AND name = N'IX_Stat_RequestInfo_1')
CREATE NONCLUSTERED INDEX [IX_Stat_RequestInfo_1] ON [dbo].[Stat_RequestInfo] 
(
	[DeltaSecond] ASC
) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_RequestInfo]') AND name = N'IX_Stat_RequestInfo_2')
CREATE NONCLUSTERED INDEX [IX_Stat_RequestInfo_2] ON [dbo].[Stat_RequestInfo] 
(
	[DateTime] ASC
) ON [PRIMARY]

IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
COMMIT

PRINT N'Altering [dbo].[Stat_RequestInfo]'
BEGIN TRANSACTION

CREATE TABLE dbo.Tmp_Stat_Visitors
	(
	VisitorId int NOT NULL IDENTITY (1, 1),
	Host varchar(255) NULL,
	MachineCookie varchar(50) NULL,
	UserName nvarchar(100) NULL,
	CountryId char(2) NULL,
	UserAgent varchar(512) NULL
	)  ON [PRIMARY]

SET IDENTITY_INSERT dbo.Tmp_Stat_Visitors ON

IF EXISTS(SELECT * FROM dbo.Stat_Visitors)
	 EXEC('INSERT INTO dbo.Tmp_Stat_Visitors (VisitorId, Host, MachineCookie, UserName, CountryId, UserAgent)
		SELECT VisitorId, Host, MachineCookie, UserName, CountryId, CONVERT(varchar(512), UserAgent) FROM dbo.Stat_Visitors TABLOCKX')

SET IDENTITY_INSERT dbo.Tmp_Stat_Visitors OFF

ALTER TABLE dbo.Stat_RequestInfo
	DROP CONSTRAINT FK_Stat_RequestInfo_Stat_Visitors

DROP TABLE dbo.Stat_Visitors

EXECUTE sp_rename N'dbo.Tmp_Stat_Visitors', N'Stat_Visitors', 'OBJECT'

ALTER TABLE dbo.Stat_Visitors ADD CONSTRAINT
	PK_Visitors PRIMARY KEY CLUSTERED (VisitorId) ON [PRIMARY]
	
ALTER TABLE dbo.Stat_RequestInfo WITH NOCHECK ADD CONSTRAINT
	FK_Stat_RequestInfo_Stat_Visitors FOREIGN KEY
	(VisitorId) REFERENCES dbo.Stat_Visitors
	(VisitorId) NOT FOR REPLICATION

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_Visitors]') AND name = N'IX_Stat_Visitors')
CREATE NONCLUSTERED INDEX [IX_Stat_Visitors] ON [dbo].[Stat_Visitors] 
(
	[MachineCookie] ASC
) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_Visitors]') AND name = N'IX_Stat_Visitors_1')
CREATE NONCLUSTERED INDEX [IX_Stat_Visitors_1] ON [dbo].[Stat_Visitors] 
(
	[Host] ASC
) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_Visitors]') AND name = N'IX_Stat_Visitors_2')
CREATE NONCLUSTERED INDEX [IX_Stat_Visitors_2] ON [dbo].[Stat_Visitors] 
(
	[UserAgent] ASC
) ON [PRIMARY]
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Stat_Visitors]') AND name = N'IX_Stat_Visitors_3')
CREATE NONCLUSTERED INDEX [IX_Stat_Visitors_3] ON [dbo].[Stat_Visitors] 
(
	[UserName] ASC
) ON [PRIMARY]

IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
COMMIT


PRINT N'Altering [dbo].[Stat_FillRequestInfo]'

EXEC dbo.sp_executesql @statement = N'ALTER PROCEDURE [dbo].[Stat_FillRequestInfo]
	@MaxCount int = 100,
	@deltaTimeMin int = 20
AS
DECLARE @RequestId int, @RequestCount int, @DateTime datetime
DECLARE @Scheme nvarchar(50), @MachineGUID varchar(50), @SiteName varchar(50)
DECLARE @IP varchar(2048), @Host varchar(2048)
DECLARE @Url nvarchar(1024), @Object nvarchar(1024), @UserName varchar(512), @UrlReferer nvarchar(1024), @UserAgent nvarchar(1024), @OnlyDefinedSites nvarchar(50)

SET @OnlyDefinedSites = ''False''
SELECT @OnlyDefinedSites = ParamValue FROM Stat_Settings WHERE ParamName =  ''OnlyDefinedSites''

SET @RequestCount = 0
DECLARE newRequestCursor CURSOR FOR
   SELECT R.RequestId, R.[c-ip],  R.[c_machine_cookie], R.[datetime], R.[s-scheme], R.[s-sitename], R.[cs-uri-stem], R.[cs-uri-query] , R.[c-username], R.[csReferer], R.[csUser-Agent], R.[cs-host] FROM Stat_Request AS R ORDER BY [datetime]

OPEN newRequestCursor
FETCH NEXT FROM newRequestCursor INTO @RequestId, @IP, @MachineGUID, @DateTime, @Scheme, @SiteName, @Url, @Object, @UserName, @UrlReferer, @UserAgent, @Host
-- Main Loop
WHILE(@@FETCH_STATUS = 0)
BEGIN
	-- Break?
	SET @RequestCount = @RequestCount + 1
	IF @RequestCount > @MaxCount  BREAK
	
	--- Site
	DECLARE @SiteId INT
	SET @SiteId = NULL

	SELECT @SiteId = SiteId FROM Stat_Sites S WHERE S.Name LIKE @SiteName AND S.Host LIKE @Host

	IF @OnlyDefinedSites = ''False''
	BEGIN
		IF @SiteId IS NULL
		BEGIN
			INSERT INTO Stat_Sites ([Name], Host) VALUES (@SiteName, @Host)
			SET @SiteId = @@IDENTITY
		END
	END
	ELSE
	BEGIN
		IF @SiteId IS NULL
		BEGIN
			DELETE Stat_Request WHERE RequestId = @RequestId

			FETCH NEXT FROM newRequestCursor INTO @RequestId, @IP, @MachineGUID, @DateTime, @Scheme, @SiteName, @Url, @Object, @UserName, @UrlReferer, @UserAgent, @Host
			CONTINUE
		END
	END

	-- Visitor
	DECLARE @SearcherBot INT, @VisitorId INT,  @VisitorHostId INT,  @LastSession datetime,  @CountryId CHAR(2),  @NewVisitorSession bit
	
	SET @SearcherBot = NULL		
	SELECT @SearcherBot = SearcherId FROM Stat_Searchers WHERE (UserAgent IS NOT NULL) AND (@UserAgent LIKE ''%''+RTRIM(UserAgent)+''%'')

	IF @SearcherBot IS NOT NULL
	BEGIN
		EXEC Stat_GlobalIncrement ''SearcherBot'', @SearcherBot, @DateTime
		
		DELETE Stat_Request WHERE RequestId = @RequestId

		FETCH NEXT FROM newRequestCursor INTO @RequestId, @IP, @MachineGUID, @DateTime, @Scheme, @SiteName, @Url, @Object, @UserName, @UrlReferer, @UserAgent, @Host
		CONTINUE
	END

	BEGIN TRAN			

	SET @VisitorId = NULL
	SET @VisitorHostId = NULL
	SET @CountryId = NULL
	SET @LastSession = NULL
	SET @NewVisitorSession = 0

	IF(@MachineGUID IS NULL)
	BEGIN
		SELECT @VisitorId  = VisitorId FROM Stat_Visitors WHERE Host = @IP AND MachineCookie IS NULL
		IF @VisitorId IS NULL
		BEGIN 
			SELECT @CountryId = CountryId FROM Stat_Visitors WHERE Host = @IP

			IF(@CountryId IS NULL)
				SELECT @CountryId = [id] FROM Stat_GetCountryByIP(@IP)

			INSERT INTO Stat_Visitors (Host, MachineCookie, UserName, CountryId, UserAgent) VALUES (@IP, @MachineGUID, @UserName,@CountryId, @UserAgent)
			SET @VisitorId = @@IDENTITY
			
		END
	END
	ELSE
	BEGIN
		
		SELECT @VisitorId  = VisitorId, @CountryId = CountryId FROM Stat_Visitors WHERE MachineCookie = @MachineGUID
		IF @CountryId IS NULL
		BEGIN
			SELECT @CountryId = [id] FROM Stat_GetCountryByIP(@IP)
			IF @VisitorId IS NOT NULL
			BEGIN
				UPDATE    Stat_Visitors
				SET              CountryId = @CountryId
				WHERE     (VisitorId = @VisitorId)
			END
		END
		IF(@VisitorId IS NULL)
		BEGIN
			INSERT INTO Stat_Visitors (Host, MachineCookie, UserName, CountryId, UserAgent) VALUES (@IP, @MachineGUID, @UserName, @CountryId,@UserAgent)
			SET @VisitorId = @@IDENTITY
		
			SET @NewVisitorSession = 1

			SELECT @VisitorHostId = VisitorId FROM Stat_Visitors WHERE Host = @IP AND MachineCookie IS NULL
			IF(@VisitorHostId IS NOT NULL)
			BEGIN
				SELECT TOP 1  @LastSession = [DateTime] FROM Stat_RequestInfo WHERE VisitorId = @VisitorHostId AND DeltaSecond > (@deltaTimeMin * 60) ORDER BY [DateTime] DESC
				UPDATE Stat_RequestInfo SET VisitorId = @VisitorId, DeltaSecond = 0 WHERE VisitorId = @VisitorHostId AND (@LastSession = NULL OR [DateTime] > @LastSession)
				--IF(@LastSession IS NULL)
				IF(NOT EXISTS(SELECT * FROM Stat_RequestInfo WHERE VisitorId = @VisitorHostId))
					DELETE Stat_Visitors WHERE VisitorId = @VisitorHostId
			END
		END
	END

	DECLARE @AuthUser bit
	SET @AuthUser = 0
	
	IF(@UserName IS NOT NULL)
		IF(EXISTS(SELECT * FROM Stat_Visitors WHERE VisitorId = @VisitorId AND (UserName IS NULL OR UserName  NOT LIKE @UserName)))
		BEGIN
			UPDATE Stat_Visitors SET UserName = @UserName, CountryId = @CountryId WHERE VisitorId = @VisitorId
			SET @AuthUser = 1
		END
	
	IF(EXISTS(SELECT * FROM Stat_Visitors WHERE VisitorId = @VisitorId AND (UserAgent IS NULL OR UserAgent  NOT LIKE @UserAgent)))
		UPDATE Stat_Visitors SET UserAgent = @UserAgent WHERE VisitorId = @VisitorId

	--- Protocol
	DECLARE @ProtocolId INT
	SELECT @ProtocolId = ProtocolId FROM Stat_Protocols WHERE [Name] = @Scheme 
	IF @ProtocolId IS NULL
	BEGIN
		INSERT INTO Stat_Protocols (Name) VALUES (@Scheme)
		SET @ProtocolId = @@IDENTITY
	END
	-- Page
	DECLARE @PageId INT
	DECLARE @N int
	DECLARE @Folder nvarchar(255)
	DECLARE @Page nvarchar(255)
	SET @PageId = NULL
	SET @N = 0
	WHILE  (CHARINDEX(''/'', @Url, @N + 1) > 0)
		SET @N = CHARINDEX(''/'', @Url, @N + 1)
	SET @Page =  SUBSTRING(@Url, @N+1, LEN(@Url)-@N)
	SET @Folder =  SUBSTRING(@Url, 1, @N)
	
	SET @PageId  = (SELECT TOP 1 PageId FROM Stat_Pages U WHERE U.FolderName = @Folder AND U.PageName = @Page)
	IF @PageId IS NULL
	BEGIN
		INSERT INTO Stat_Pages (FolderName, PageName) VALUES (@Folder, @Page)
		SET @PageId = @@IDENTITY
	END
	
	-- PageObjects
	DECLARE @PageKeyId INT
	SET @PageKeyId = NULL
	DECLARE @PageObjectId INT
	SET @PageObjectId = NULL
	DECLARE @value nvarchar(255)
	
	SELECT TOP 1 @value = P.Value, @PageKeyId = PageKeyId FROM Stat_PageKeys K
		INNER JOIN Stat_ParseQueryString(@Object) P ON (K.Name LIKE P.Param AND K.PageId = @PageId)

	IF @PageKeyId IS NOT NULL
	BEGIN
		SET @PageObjectId  = (SELECT TOP 1 PageObjectId FROM Stat_PageObjects WHERE PageKeyId = @PageKeyId AND Value = @value)
		IF @PageObjectId IS NULL
		BEGIN
			INSERT INTO Stat_PageObjects (PageKeyId, Value) VALUES (@PageKeyId, @value)
			SET @PageObjectId = @@IDENTITY
		END
	END

	-- Referers
	DECLARE @RefSiteId INT
	SET @RefSiteId = NULL
	
	DECLARE @SearcherId int
	SET @SearcherId = NULL
	DECLARE @PhraseId int
	SET @PhraseId = NULL
	
	DECLARE @RefPageId INT
	SET @RefPageId = NULL
	DECLARE @RefPageObjectId INT
	SET @RefPageObjectId = NULL
	
	DECLARE @N1 int
	DECLARE @RefHost nvarchar(255)
	DECLARE @RefPageQuery nvarchar(2048)
	IF @UrlReferer IS NOT NULL
	BEGIN
		SELECT @RefHost = Domain, @Folder = Folder, @Page = Page, @RefPageQuery = Query FROM Stat_ParseUrl(@UrlReferer)
		-- internal url
		IF @Host LIKE @RefHost
		BEGIN
			SET @RefPageId  = (SELECT TOP 1 PageId FROM Stat_Pages U WHERE U.FolderName = @Folder AND U.PageName = @Page)
			IF @RefPageId IS NULL
			BEGIN
				INSERT INTO Stat_Pages (FolderName, PageName) VALUES (@Folder, @Page)
				SET @RefPageId = @@IDENTITY
			END
			
			-- get oject id
			SELECT TOP 1 @value = P.Value, @PageKeyId = PageKeyId FROM Stat_PageKeys K
				INNER JOIN Stat_ParseQueryString(@RefPageQuery) P ON (K.Name LIKE P.Param AND K.PageId = @RefPageId)
			IF @PageKeyId IS NOT NULL
			BEGIN
				SET @RefPageObjectId  = (SELECT TOP 1 PageObjectId FROM Stat_PageObjects WHERE PageKeyId = @PageKeyId AND Value = @value)
				IF @RefPageObjectId IS NULL
				BEGIN
					INSERT INTO Stat_PageObjects (PageKeyId, Value) VALUES (@PageKeyId, @value)
					SET @PageObjectId = @@IDENTITY
				END
				--BREAK
			END
		END
		ELSE
		BEGIN
			SELECT @RefSiteId = RefSiteId FROM Stat_RefSites WHERE SiteName = @RefHost
			IF @RefSiteId IS NULL
			BEGIN
				INSERT INTO Stat_RefSites (SiteName) VALUES (@RefHost)
				SET @RefSiteId = @@IDENTITY
			END

			
			DECLARE @SearcherParams varchar(100)
			DECLARE @SearchKeyId int
			
			SELECT @SearcherId = SearcherId, @SearchKeyId = KeyId, @SearcherParams = [Key] FROM Stat_SearcherKeys SK WHERE @RefHost LIKE ''%_'' + SK.Domain
			
			IF @SearcherId IS NOT NULL
			BEGIN
				DECLARE @SearchPrase nvarchar(1024)

				SELECT @SearchPrase = Q.Value FROM Stat_ParseQueryString(@RefPageQuery) Q
					INNER JOIN Stat_SplitString(@SearcherParams, '','') K ON Q.Param LIKE K.Value	
				
				IF @SearchPrase IS NOT NULL
				BEGIN
					--SELECT @PhraseId = PhraseId FROM Stat_SearchPhrases WHERE @SearchPrase = Value
					SELECT @PhraseId = PhraseId FROM Stat_SearchPhrases WHERE @SearchPrase = Value AND SearchKeyId = @SearchKeyId AND RefSiteId = @RefSiteId
					IF @PhraseId IS NULL
					BEGIN
						INSERT INTO Stat_SearchPhrases (SearcherId,  SearchKeyId, RefSiteId, Value) VALUES (@SearcherId, @SearchKeyId, @RefSiteId, @SearchPrase)
						SET @PhraseId = @@IDENTITY
					END
				END	

			END

			SET @RefPageQuery = @UrlReferer
		END
	END
	
	-- Delta
	DECLARE @Delta INT
	SET @Delta = -1

	IF @VisitorId IS NOT NULL
	BEGIN
		DECLARE @DT DateTime
		DECLARE @RequestInfoId int
		SELECT TOP 1 @DT = [DateTime], @RequestInfoId = RequestInfoId FROM Stat_RequestInfo WHERE VisitorId = @VisitorId AND DeltaSecond = -1 AND [DateTime] <= @DateTime  ORDER BY [DateTime] DESC
		IF (DATEDIFF(day, @Dt, @DateTime) > 0)
			SET @Delta = 10000
		ELSE
			SET @Delta = DATEDIFF(second, @Dt, @DateTime)

		UPDATE Stat_RequestInfo SET DeltaSecond = @Delta WHERE RequestInfoId = @RequestInfoId
	END

	-- Add a record to Stat_RequestInfo Table
	INSERT INTO Stat_RequestInfo (DateTime, ProtocolId, SiteId,	PageId, PageObjectId, PageQuery, VisitorId, Auth, DeltaSecond, RefSiteId, RefPageId, RefPageObjectId, RefPageQuery)
			VALUES (@DateTime, @ProtocolId,	 @SiteId, @PageId, @PageObjectId, @Object, @VisitorId, @AuthUser, -1, @RefSiteId, @RefPageId, @RefPageObjectId, @RefPageQuery)
	DELETE Stat_Request  WHERE RequestId = @RequestId

	/* Global increments */
	EXEC Stat_GlobalIncrement ''SiteLoad'', @SiteId, @DateTime  

	IF @Delta > 60
		EXEC Stat_GlobalIncrement ''SiteHit'', @SiteId, @DateTime 

	IF (@Delta > 1200) OR (@NewVisitorSession = 1)
		EXEC Stat_GlobalIncrement ''SiteSession'', @SiteId, @DateTime  
		
	EXEC Stat_GlobalIncrement ''PageLoad'', @PageId, @DateTime 
	
	IF @VisitorId IS NOT NULL
	BEGIN
		EXEC Stat_GlobalIncrement ''VisitorLoad'', @VisitorId, @DateTime 
	
		IF @Delta > 60
			EXEC Stat_GlobalIncrement ''VisitorHit'', @VisitorId, @DateTime	

		IF (@Delta > 1200) OR (@NewVisitorSession = 1)
			EXEC Stat_GlobalIncrement ''VisitorSession'', @VisitorId, @DateTime	
	END

	IF @PageObjectId IS NOT NULL
		EXEC Stat_GlobalIncrement ''PageObjectLoad'', @PageObjectId, @DateTime 
	
	IF @RefSiteId IS NOT NULL
		EXEC Stat_GlobalIncrement ''RefSiteLoad'', @RefSiteId, @DateTime 
	
	IF @RefPageObjectId IS NOT NULL
		EXEC Stat_GlobalIncrement ''RefPageObjectLoad'', @RefPageObjectId, @DateTime
	
	IF @PhraseId IS NOT NULL
		EXEC Stat_GlobalIncrement ''SearchPhrase'', @PhraseId, @DateTime

	IF @SearcherId IS NOT NULL
		EXEC Stat_GlobalIncrement ''Searcher'', @SearcherId, @DateTime

	COMMIT TRAN
	-- Next
	FETCH NEXT FROM newRequestCursor INTO @RequestId, @IP, @MachineGUID, @DateTime, @Scheme, @SiteName, @Url, @Object, @UserName, @UrlReferer, @UserAgent, @Host
END
CLOSE newRequestCursor

DEALLOCATE newRequestCursor

--Clearing of counters on days and hours by ObjectType settings
exec Stat_GlobalDelete

--Clearing of the detailed information on requests
SET @DateTime = DATEADD(day, -90, getdate())
DELETE Stat_RequestInfo WHERE [DateTime] < @DateTime
' 