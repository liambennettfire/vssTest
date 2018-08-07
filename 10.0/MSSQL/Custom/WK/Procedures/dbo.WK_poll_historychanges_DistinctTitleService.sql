if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_poll_historychanges_DistinctTitleService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_poll_historychanges_DistinctTitleService
GO

CREATE PROCEDURE [dbo].[WK_poll_historychanges_DistinctTitleService]
@Test_WebServiceName varchar(50) = NULL
AS
BEGIN
	Declare @bookkey int,
			@PartOfWebService varchar(50),
			@TitleOrDateHistoryField char(1),
			@i_titlefetchstatus int
--			,@i_sortorder smallint

	CREATE TABLE #tmp(
		[isbn] [varchar](13) NOT NULL,
		[bookkey] [int] NOT NULL,
		[lastmaintdate] [datetime] NOT NULL,
		[columnkey] [int] NOT NULL,
		[PartofWebService] [varchar](80) NOT NULL,
		[TitleOrdateHistory] [char](1) NOT NULL,
		[key] [int] NOT NULL,
		[ModificationType] [varchar] (20) NOT NULL
--		,		[WebserviceSortOrder] smallint 
	)

   --  DROP TABLE #Updates
	
	CREATE TABLE #Updates (
		[bookkey] [int] NOT NULL,
		[PartofWebService] [varchar](80) NOT NULL,
		[TitleOrdateHistory] [char](1) NOT NULL
--		,[Sortorder] smallint NOT NULL
	)

		/* Insert TitleHistory Updates First, two cases for titlehistory records
		First one is where we have a match on columnkey, easy ones.
		Second one will be for fields like bookcomments, subject categories, misc items where
		we derive the field based on stringvalue, currentstringvalue, fielddesc fields from titlehistory
		
		*/
		INSERT INTO #Updates
		Select Distinct bookkey, PartOfWebService, 'T'
		from titlehistory th
		JOIN WK_CSIWebServiceColumns wsc
		ON th.columnkey = wsc.columnkey
		WHERE th.id_num > (Select lastIdProcessed FROM [WK_titlehistory_lastprocessed])
		and wsc.TitleOrDateHistoryField = 'T'
		and wsc.IsActive = 1
		and th.columnkey not in (
		220, --subject1
		221, --subject2
		222, --subject3
		225, --misc item
		226, --misc item
		227,  --misc item
		247,  --misc item checkbox
		248, --misc item
		23, --Org Level 4, publisher
		67, 68, 69, 201)  --Citations
		and not (th.columnkey = 261 and --changed from 70 to 261, 70 for Desktop
		(th.fielddesc = '(E) New Features' OR th.fielddesc = '(E) Features' OR th.fielddesc = '(E) Foreword'
		OR th.fielddesc = '(E) Contributors' OR th.fielddesc = '(E) Preface' OR th.fielddesc = '(E) Table of Contents'
		OR th.fielddesc = '(E) Sales Strategy' OR th.fielddesc = '(E) Full Description-Public' 
		OR th.fielddesc = '(E) Note to Booksellers' 
		--OR th.fielddesc = '(E) Volume Set Type' 
		OR th.fielddesc = '(E) System Requirements' --OR th.fielddesc like 'Citation%' Citation is 70 on desktop
		)) --process bookcomment fields  in the next select
		and not (th.columnkey = 65 AND (th.currentstringvalue not like '%DELETED%') AND EXISTS(Select * FROM globalcontact gc JOIN globalcontactrole gcr ON gc.globalcontactkey = gcr.globalcontactkey where gc.displayname = th.currentstringvalue and gcr.rolecode in (18,43,44))) --Acq. Editor's are personnel with rolecode = 18, took out "and gc.personnelind = 1", marketer and sales rep are 43 and 44
		and not (th.columnkey = 65 AND (th.currentstringvalue like '%DELETED%') AND EXISTS(Select * FROM globalcontact gc JOIN globalcontactrole gcr ON gc.globalcontactkey = gcr.globalcontactkey where gc.displayname = REPLACE(th.fielddesc, 'Personnel - ','') and gcr.rolecode in (18,43,44))) --if deleted, then the name is in fielddesc - Acq. Editor's are personnel with rolecode = 18, took out "and gc.personnelind = 1", marketer and sales rep are 43 and 44
		and not (th.columnkey in (6,40,60)) -- and wsc.PartofWebService ='publishproductproduct') --primary author, plus any author related type because of actors object in product class - 
		and 

		ORDER BY th.bookkey
--		and dbo.WK_get_itemnumber(th.bookkey) <> ''	 --Has to have an itemnumber
--		and dbo.WK_IsPrepub(th.bookkey) = 'N' -- No prepubs here

		--Select * FROM #Updates

		/* NOW THE SECOND TITLEHISTORY RUN FOR BOOKCOMMENT, SUBJECT CATEGORY, MISC ITEM, ETC. FIELDS
		ONLY INSERT IF bookkey and PartofWebSErvice does not already exist
		We are doing a left outer join on #Updates where bookkey is null 
		This should return titlehistory records that don't already exist in #updates
		*/

		INSERT INTO #Updates
		Select DISTINCT th.bookkey, wsc.PartOfWebService, 'T'
		from titlehistory th
		LEFT OUTER JOIN WK_CSIWebServiceColumns wsc
		ON th.columnkey = wsc.columnkey and 
		[dbo].[WK_rpt_get_CategoryDesc_from_TitleHistory](th.bookkey, currentstringvalue, th.fielddesc, th.columnkey) = wsc.description
		LEFT OUTER JOIN #Updates u
		ON u.bookkey = th.bookkey AND u.PartOfWebService = wsc.PartOfWebService
		WHERE u.bookkey IS NULL --only get nonmatching records !! 
		and th.id_num > (Select lastIdProcessed FROM [WK_titlehistory_lastprocessed])
		and wsc.TitleOrDateHistoryField = 'T'
		and wsc.IsActive = 1
		and (
		th.columnkey in (220, --subject1
		221, --subject2
		222, --subject3
		225, --misc item
		226, --misc item
		227,  --misc item
		247,  --misc item checkbox
		248, --misc item
		23, --Org Level 4, publisher
		67, 68, 69, 201)  --Citations
		OR (th.columnkey = 261 and (th.fielddesc = '(E) New Features' OR th.fielddesc = '(E) Features' OR th.fielddesc = '(E) Foreword'
		OR th.fielddesc = '(E) Contributors' OR th.fielddesc = '(E) Preface' OR th.fielddesc = '(E) Table of Contents'
		OR th.fielddesc = '(E) Sales Strategy' OR th.fielddesc = '(E) Full Description-Public' 
		OR th.fielddesc = '(E) Note to Booksellers' 
		--OR th.fielddesc = '(E) Volume Set Type' 
		OR th.fielddesc = '(E) System Requirements' --OR th.fielddesc like 'Citation%'
		))
		OR (th.columnkey = 65 AND (th.currentstringvalue not like '%DELETED%') AND EXISTS(Select * FROM globalcontact gc JOIN globalcontactrole gcr ON gc.globalcontactkey = gcr.globalcontactkey where gc.displayname = th.currentstringvalue and gcr.rolecode in (18,43,44))) --Acq. Editor's are personnel with rolecode = 18, took out "and gc.personnelind = 1", marketer and sales rep are 43 and 44
		OR (th.columnkey = 65 AND (th.currentstringvalue like '%DELETED%') AND EXISTS(Select * FROM globalcontact gc JOIN globalcontactrole gcr ON gc.globalcontactkey = gcr.globalcontactkey where gc.displayname = REPLACE(th.fielddesc, 'Personnel - ','') and gcr.rolecode in (18,43,44))) --if deleted, then the name is in fielddesc - Acq. Editor's are personnel with rolecode = 18, took out "and gc.personnelind = 1", marketer and sales rep are 43 and 44
		OR (th.columnkey in (6,40,60)) -- and th.fielddesc like 'Author 1%' and wsc.PartofWebService ='publishproductproduct') --Primary author
		)
		ORDER BY th.bookkey



		--Check if any datehistory records exists where the bookkey is NOT already added!
		--No need to check on webservice name because we are only tracking one date field (pub date) from datehistory
		--which instantiates a publishproduct call

		IF EXISTS(Select * from datehistory dh JOIN WK_CSIWebServiceColumns wsc ON dh.datetypecode = wsc.columnkey WHERE dh.lastmaintdate > (Select lastmaintdate_processed FROM [WK_datehistory_lastprocessed]) and wsc.TitleOrDateHistoryField= 'D' and wsc.IsActive = 1 and dh.bookkey not in (Select Distinct bookkey from #Updates where [PartofWebService] = 'publishproductproduct'))
			BEGIN
					--ONLY ADD DATE HISTORY BOOKKEYS THAT DON'T ALREADY EXIST IN OUR TABLE!
					INSERT INTO #Updates
					Select DISTINCT dh.bookkey, wsc.PartOfWebService, 'D'
					FROM datehistory dh
					JOIN WK_CSIWebServiceColumns wsc 
					ON dh.datetypecode = wsc.columnkey 
					WHERE dh.lastmaintdate > (Select lastmaintdate_processed FROM [WK_datehistory_lastprocessed]) 
					and wsc.TitleOrDateHistoryField= 'D' 
					and wsc.IsActive = 1
					and dh.bookkey NOT IN (Select Distinct bookkey from #Updates where [PartofWebService] = 'publishproductproduct')
					ORDER BY dh.bookkey
			END
		ELSE
			BEGIN
				/*WE COULD DO NOTHING 
				OR FOR BETTER PERFORMANCE, UPDATE [WK_datehistory_lastprocessed] TABLE HERE WITH THE MOST RECENT
				ENTRY FROM DATEHISTORY TABLE REGARDLESS OF THE DATETYPECODE SO WE HAVE
				LESS RECORDS TO GO OVER THE NEXT TIME THIS PROC RUNS 
				*/
				
							DECLARE @i_bookkey int,
							@datetypecode int,
							@datekey int,
							@lastmaintdate_processed datetime

							Select TOP 1 @i_bookkey = dh.bookkey,
							@datetypecode = dh.datetypecode,
							@datekey = dh.datekey,
							@lastmaintdate_processed = dh.lastmaintdate
							from datehistory dh 
--							JOIN WK_CSIWebServiceColumns wsc 
--							ON dh.datetypecode = wsc.columnkey 
--							WHERE dh.lastmaintdate > (Select lastmaintdate_processed FROM [WK_datehistory_lastprocessed]) 
--							and wsc.TitleOrDateHistoryField= 'D' and wsc.IsActive = 1
							ORDER BY dh.lastmaintdate DESC
						
							execute dbo.WK_Update_LastDateHistory_Processed @i_bookkey, @datetypecode, @datekey, @lastmaintdate_processed


			END


		
		/*NOW PROCESS GLOBAL CONTACT UPDATES
		
		We are only tracking 3 fields; First, Last and Middle Name
SElect * FROM globalcontacthistory

Select * FROM WK_CSIWebServiceColumns
WHERE TItleOrDateHistoryField = 'C'


		*/

		IF EXISTS (Select * FROM globalcontacthistory gch JOIN WK_CSIWebServiceColumns wsc 
				ON gch.columnkey = wsc.columnkey JOIN bookauthor ba ON gch.globalcontactkey = ba.authorkey
				WHERE gch.globalcontacthistorykey > (Select LastIdProcessed FROM [WK_globalcontacthistory_lastprocessed])
				and wsc.TitleOrDateHistoryField= 'C' and wsc.IsActive = 1
				and ba.bookkey NOT IN (Select Distinct bookkey from #Updates where [PartofWebService] = 'publishproductproduct')		
				)
			BEGIN
				--ONly get bookkeys that don't exist in #updates already
				INSERT INTO #Updates
				Select Distinct ba.bookkey, PartOfWebService, 'C'
				FROM globalcontacthistory gch 
				JOIN WK_CSIWebServiceColumns wsc 
				ON gch.columnkey = wsc.columnkey 
				JOIN bookauthor ba 
				ON gch.globalcontactkey = ba.authorkey
				WHERE gch.globalcontacthistorykey > (Select LastIdProcessed FROM [WK_globalcontacthistory_lastprocessed])
				and wsc.TitleOrDateHistoryField= 'C' and wsc.IsActive = 1
				and ba.bookkey NOT IN (Select Distinct bookkey from #Updates where [PartofWebService] = 'publishproductproduct')		
				ORDER BY ba.bookkey

			END
		ELSE
			BEGIN
				/*WE COULD DO NOTHING 
				OR FOR BETTER PERFORMANCE, UPDATE [WK_globalcontacthistory_lastprocessed] TABLE HERE WITH THE MOST RECENT
				ENTRY FROM globalcontacthistory TABLE SO WE HAVE
				LESS RECORDS TO GO OVER THE NEXT TIME THIS PROC RUNS 
				*/

							UPDATE WK_globalcontacthistory_lastprocessed
							SET LastIdProcessed = (Select Max(globalcontacthistorykey) from globalcontacthistory) 
							,changeddate = getdate()
			END


/*
DELETE IF ITEMNUMBER DOES NOT EXIST
OR IF IT IS A PREPUBLICATION
PREPUBS ARE PROCESSED NIGHTLY

INSTEAD OF RUNNING itemnumber and prepub logic in all inserts above
We are running it once, should be better performance 


1- REAL-TIME UPDATE - Outbound 
CASE: (publication date - current date) > 14 months

If the product has already been sent to Advantage do not send to PPT anymore. 
CHECK IF "CSI Request ID (Adv/SLX)" is populated. Pub date could have been moved to a future date. 
BY THE USER

•	We should not update Advantage and SLX. 
•	Only consume "publishprepubproduct" web service to update PPT 
•	There will be two CSI Request ID fields in TM. 
I will change the labels to:
CSI Request ID (Adv/SLX)
CSI Request ID (PPT) 
•	publishPrepubProduct will update "CSI Request ID (PPT)"  
•	publishProduct will update "CSI Request ID (Adv/SLX)"
 
2 - REAL-TIME UPDATE - OUTBOUND

CASE: 0 < (publication date - current date) <= 14 months

IMPORTANT NOTE: If pub date is in the past and the title status is still "Not Yet Published", 
the updates on this title will NOT flow to
back-end systems until the publication date is updated to a future date in TM. 
 
LOGIC TO IMPLEMENT:
 
IF "CSI Request ID (Adv/SLX)" is EMPTY 
 It means this title has not been sent to ADV & SLX via the nightly feed yet. 
 ONLY consume publishPrePubProduct (Updates PPT)
ELSE
 This title has already been sent to ADV & SLX, DO NOT UPDATE PPT ANYMORE
 Always Consume publishProduct for this title going forward. 









*/

DELETE FROM #Updates
WHERE dbo.WK_get_itemnumber(bookkey) = ''	 --Has to have an itemnumber
OR dbo.WK_IsPrepub(bookkey) = 'Y' -- No prepubs here




--Select * FROM #Updates
--ORDER BY bookkey

	DECLARE c_historyUpdates INSENSITIVE CURSOR
		FOR
		SELECT  bookkey, PartOfWebService, TitleOrdateHistory
		FROM #Updates

		FOR READ ONLY
				
		OPEN c_historyUpdates 

		FETCH NEXT FROM c_historyUpdates 
			INTO @bookkey ,@PartOfWebService ,@TitleOrDateHistoryField --, @i_sortorder


		select  @i_titlefetchstatus  = @@FETCH_STATUS

		 while (@i_titlefetchstatus >-1 )
			begin
				IF (@i_titlefetchstatus <>-2) 
				begin
				IF @TitleOrdateHistoryField = 'T'
					BEGIN
						/* ISSUE:
						Scenario: Btw polling changes a user updates a price first
						That should initiate a publishprice and publishproduct webservice call
						(We always want to make sure we consume publishproduct first especially when inserting a new product
						Not sure how CSI updates back-end systems but the assumption is publishproduct would insert
						the new product first and publishprice would then update the prices for that title)
						let's say the id_num for price update is 1000 in titlehistory
						next the user updates another field that would initiate a publishproduct call, say TOC
						TMM would then write another titlehistory record which will be greater than 1000, say 1005
						NOW, We need to make sure publishproduct is called first and 
						also create MSMQ messages by FIFO - first in first out - so the updates flow to CSI in the same sequence they are added to TM
						To accomplish this we need to sort on id_num which will force publishprice to appear first in our temp table:

						Bookkey  Columnkey         webservice        id_num   sortorder
						XXXX	   111	           publishprice       1000      2
						XXXX       222             publishproduct     1005      1

						However, we want to call publishproduct first
						Since we are only sending 1 row per bookkey/web service
						it is safe to assign max(id_num) for all webservice calls if we are initiating more than one webservice
						The columnkeys will not be correct but that should not affect anything
						
						This is how I will be sending updates instead:
					
						Bookkey  Columnkey         webservice        id_num    sortorder
						XXXX       222             publishproduct     1005        1
						XXXX	   222	           publishprice       1005        2


						*/

						INSERT INTO #tmp
						Select TOP 1
						dbo.WK_get_itemnumber(@bookkey) as isbn,
						@bookkey, lastmaintdate, 
						th.columnkey as [columnkey], 
						@PartOfWebService, @TitleOrDateHistoryField as [TitleOrDateHistory], 
						th.id_num as [key],	 
						(CASE WHEN th.bookkey > (Select last_bookkey_processed from [dbo].[WK_lastTitle_processed]) THEN 'INSERT'
							  ELSE 'UPDATE' END) as ModificationType
--						,@i_sortorder as [WebserviceSortOrder]
						from titlehistory th
						JOIN WK_CSIWebServiceColumns wsc
						ON th.columnkey = wsc.columnkey
						WHERE th.id_num > (Select lastIdProcessed FROM [WK_titlehistory_lastprocessed])
						and wsc.TitleOrDateHistoryField = 'T'
						and wsc.IsActive = 1
						and th.bookkey = @bookkey
						and wsc.PartOfWebService = @PartOfWebService
						ORDER BY id_num DESC -- Select the most recent change on the bookkey


						/*
						INSERT INTO #tmp
						Select TOP 1
						dbo.WK_get_itemnumber(@bookkey) as isbn,
						@bookkey, lastmaintdate, 
						th.columnkey as [columnkey], 
						wsc.PartOfWebService, wsc.TitleOrDateHistoryField as [TitleOrDateHistory], 
						th.id_num as [key],	 
						(CASE WHEN th.bookkey > (Select last_bookkey_processed from [dbo].[WK_lastTitle_processed]) THEN 'INSERT'
							  ELSE 'UPDATE' END) as ModificationType,
						@i_sortorder as [WebserviceSortOrder]
						from titlehistory th
						JOIN WK_CSIWebServiceColumns wsc
						ON th.columnkey = wsc.columnkey
						WHERE th.id_num > (Select lastIdProcessed FROM [WK_titlehistory_lastprocessed])
						and wsc.TitleOrDateHistoryField = 'T'
						and wsc.IsActive = 1
						and th.bookkey = @bookkey
						and wsc.PartOfWebService = @PartOfWebService
						ORDER BY id_num DESC -- Select the most recent change on the bookkey

						*/

					END
				IF @TitleOrdateHistoryField = 'D'
					BEGIN
						INSERT INTO #tmp
						select TOP 1
						dbo.WK_get_itemnumber(@bookkey) as isbn, 
						@bookkey, lastmaintdate, 
						dh.datetypecode as [columnkey], 
						wsc.PartOfWebService, wsc.TitleOrDateHistoryField as [TitleOrDateHistory],
						dh.datekey as [key],--this column will hold id_num for titlehistory and datekey for datehistory
						(CASE WHEN dh.bookkey > (Select last_bookkey_processed from [dbo].[WK_lastTitle_processed]) THEN 'INSERT'
							  ELSE 'UPDATE' END) as ModificationType
--						,@i_sortorder as [WebserviceSortOrder]
						from datehistory dh
						JOIN WK_CSIWebServiceColumns wsc
						ON dh.datetypecode = wsc.columnkey
						WHERE dh.lastmaintdate > (Select lastmaintdate_processed FROM [WK_datehistory_lastprocessed])
						and wsc.TitleOrDateHistoryField= 'D'
						and wsc.IsActive = 1
						and dh.bookkey = @bookkey
						and wsc.PartOfWebService = @PartOfWebService
						ORDER BY dh.lastmaintdate DESC --get the most recent change, should we use datekey instead???



					END

				IF @TitleOrdateHistoryField = 'C'
					BEGIN
						INSERT INTO #tmp
						select TOP 1
						dbo.WK_get_itemnumber(@bookkey) as isbn, 
						ba.bookkey, gch.lastmaintdate, 
						gch.columnkey as [columnkey], 
						wsc.PartOfWebService, wsc.TitleOrDateHistoryField as [TitleOrDateHistory],
						gch.globalcontacthistorykey as [key],--this column will hold id_num for titlehistory and datekey for datehistory
						(CASE WHEN ba.bookkey > (Select last_bookkey_processed from [dbo].[WK_lastTitle_processed]) THEN 'INSERT'
							  ELSE 'UPDATE' END) as ModificationType
--						,@i_sortorder as [WebserviceSortOrder]
						FROM globalcontacthistory gch
						JOIN WK_CSIWebServiceColumns wsc
						ON gch.columnkey = wsc.columnkey
						JOIN bookauthor ba
						ON gch.globalcontactkey = ba.authorkey
						WHERE gch.globalcontacthistorykey > (Select LastIdProcessed FROM [WK_globalcontacthistory_lastprocessed])
						and wsc.TitleOrDateHistoryField= 'C'
						and wsc.IsActive = 1
						and ba.bookkey = @bookkey
						and wsc.PartOfWebService = @PartOfWebService
						ORDER BY globalcontacthistorykey DESC --get the most change - most recent globalcontacthistorykey



					END
					
				

				end
				FETCH NEXT FROM c_historyUpdates
					INTO @bookkey ,@PartOfWebService ,@TitleOrDateHistoryField --, @i_sortorder
						select  @i_titlefetchstatus  = @@FETCH_STATUS
			end
				

	close c_historyUpdates
	deallocate c_historyUpdates

	IF @Test_WebServiceName IS NOT NULL
		BEGIN --Means we are only testing this particular web service, get the most recent update
			Select TOP 1 isbn, bookkey,lastmaintdate, columnkey,PartofWebService,TitleOrdateHistory, [key], ModificationType FROM #tmp where PartOfWebService = @Test_WebServiceName ORDER BY [key] DESC
		END
	ELSE
		BEGIN
			Select isbn, bookkey,lastmaintdate, columnkey,PartofWebService,TitleOrdateHistory, [key], ModificationType FROM #tmp 
			ORDER BY TitleOrDateHistory DESC, [Key]  --Title Updates first, if multiple web service sort by webservicesortorder so publishproduct is called first
		END


	
	DROP TABLE #tmp
	DROP TABLE #Updates
END
