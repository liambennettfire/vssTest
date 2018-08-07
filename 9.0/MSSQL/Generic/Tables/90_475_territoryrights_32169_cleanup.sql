DECLARE
	@v_bookkey INT, 
	@v_isbn	   VARCHAR(13), 
	@v_description VARCHAR(2000),
	@v_territoryrightskey_latest INT,
	@v_count INT,
	@v_territoryrightskey INT

CREATE TABLE #territoryrights_duplicates (
  territoryrightskey int  null,
  bookkey			   int  null,
  isbn			   varchar (13) null,
  description		   varchar(2000) null,
  currentterritorycode int null, 
  contractterritorycode int null, 
  exclusivecode			int null,
  singlecountrycode		int null,
  singlecountrygroupcode int null,
  lastmaintdate	   datetime null)

CREATE TABLE #territoryrights_temp_1 (
  territoryrightskey int  null,
  bookkey			   int  null,
  isbn			   varchar (13) null,
  description		   varchar(2000) null,
  row_count			   int null,
  lastmaintdate	   datetime null)
  
CREATE TABLE #territoryrights_temp_2 (
  territoryrightskey int  null,
  row_count			   int null,
  lastmaintdate	   datetime null)  
  
CREATE TABLE #territoryrightscountries_temp(
  countrycode int  null,
  forsaleind  tinyint null)    

DELETE FROM #territoryrights_duplicates
DELETE FROM #territoryrights_temp_1
DELETE FROM #territoryrights_temp_2
DELETE FROM #territoryrightscountries_temp

INSERT INTO #territoryrights_duplicates (territoryrightskey, bookkey, description, currentterritorycode, contractterritorycode, 
exclusivecode, singlecountrycode, singlecountrygroupcode, lastmaintdate)
select tr.territoryrightskey, tr.bookkey, tr.description, tr.currentterritorycode, tr.contractterritorycode,
tr.exclusivecode, tr.singlecountrycode, tr.singlecountrygroupcode, lastmaintdate
 from territoryrights tr
  where territoryrightskey in (select t.territoryrightskey from territoryrights t
join bookdetail bd on bd.bookkey=t.bookkey
where t.contractterritorycode is NULL and t.updatewithsubrightsind is NULL 
and t.bookkey in (select bookkey from territoryrights group by bookkey having COUNT(*) > 1))
order by tr.bookkey ,tr.description


-- 1. Any delete SQL must delete from territoryrightcountries before deleting from territoryrights. Some territoryrights entries may not have a corresponding territoryrightcountries entry
-- 2. Any duplicate entry by bookkey that has NULL or NONE in the description can be deleted from territoryrights table. 

DELETE
from territoryrightcountries WHERE territoryrightskey IN
(
select territoryrightskey
from #territoryrights_duplicates 
where description IS NULL OR LOWER(LTRIM(RTRIM(description))) = 'none'
and bookkey > 0
)

DELETE t
FROM territoryrights t
INNER JOIN #territoryrights_duplicates td
ON t.bookkey = td.bookkey  AND t.territoryrightskey = td.territoryrightskey
WHERE td.description IS NULL OR LOWER(LTRIM(RTRIM(td.description))) = 'none'

-- 3. When duplicate entries by bookkey have the same exact description and rights detail data (as determine by data on territoryrights table) then delete the oldest row
   
INSERT INTO #territoryrights_temp_1 (territoryrightskey, bookkey, isbn, description, lastmaintdate)
select DISTINCT t1.territoryrightskey, t1.bookkey, ct.isbn, t1.description, t1.lastmaintdate
from #territoryrights_duplicates t1 INNER JOIN #territoryrights_duplicates t2
ON t1.bookkey = t2.bookkey AND 
   t1.territoryrightskey <> t2.territoryrightskey AND
   COALESCE(t1.currentterritorycode, -99999) = COALESCE(t2.currentterritorycode, -99999) AND
   COALESCE(t1.contractterritorycode, -99999) = COALESCE(t2.contractterritorycode, -99999) AND
   t1.description = t2.description AND    
   COALESCE(t1.exclusivecode, -99999) = COALESCE(t2.exclusivecode, -99999) AND
   COALESCE(t1.singlecountrycode, -99999) = COALESCE(t2.singlecountrycode, -99999) AND
   COALESCE(t1.singlecountrygroupcode, -99999) = COALESCE(t2.singlecountrygroupcode, -99999) 
INNER JOIN coretitleinfo ct ON ct.bookkey = t1.bookkey AND ct.printingkey = 1     
where t1.description IS NOT NULL OR LOWER(LTRIM(RTRIM(t1.description))) <> 'none'
and t1.bookkey > 0
order by t1.lastmaintdate asc,  t1.bookkey asc, t1.description asc, ct.isbn asc, t1.territoryrightskey asc

UPDATE t1
SET t1.row_count = (SELECT COUNT(*) FROM territoryrightcountries tc WHERE tc.bookkey = t1.bookkey AND tc.territoryrightskey = t1.territoryrightskey)
FROM #territoryrights_temp_1 t1

DECLARE crTerritoryRights CURSOR FOR
  SELECT DISTINCT bookkey, isbn, description
  FROM #territoryrights_temp_1
		  
  OPEN crTerritoryRights 

  FETCH NEXT FROM crTerritoryRights INTO @v_bookkey, @v_isbn, @v_description   -- We are processing the records by bookkey as description is same and isbn

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
	DELETE FROM #territoryrights_temp_2
	
	INSERT INTO #territoryrights_temp_2
	SELECT territoryrightskey, row_count, lastmaintdate
	FROM #territoryrights_temp_1 WHERE bookkey = @v_bookkey
	ORDER BY lastmaintdate ASC
	
	SET @v_territoryrightskey_latest = NULL
	
	SELECT TOP(1) @v_territoryrightskey_latest = territoryrightskey
	FROM #territoryrights_temp_2
	ORDER BY lastmaintdate ASC
			
	IF NOT EXISTS (SELECT * FROM #territoryrights_temp_2 WHERE row_count > 0) BEGIN	-- There are no TerritoryRightCountries rows corresponding to the territoryrights for the bookkey, so we Just delete all the oldest records	
		DELETE FROM territoryrights 
		WHERE bookkey = @v_bookkey AND territoryrightskey IN (SELECT territoryrightskey FROM #territoryrights_temp_2 WHERE territoryrightskey <> @v_territoryrightskey_latest)
		
		FETCH NEXT FROM crTerritoryRights INTO @v_bookkey, @v_isbn, @v_description
		CONTINUE
	END
	
	SET @v_count = 0
	
	SELECT @v_count = COUNT(DISTINCT row_count) FROM #territoryrights_temp_2 
	
	IF @v_count > 1 BEGIN  -- Differing nunmber of rows among territoryrightscountries table, delete from TerritoryRightsCountries &  TerritoryRights Table
		IF NOT EXISTS(SELECT * FROM territoryrightscleanup WHERE isbn = @v_isbn AND  bookkey = @v_bookkey AND description = @v_description) BEGIN
			INSERT INTO territoryrightscleanup (isbn, bookkey, description, lastuserid, lastmaintdate) 
			VALUES(@v_isbn, @v_bookkey, @v_description, 'QSIDBA', GETDATE())
		END
				
		DELETE FROM territoryrightcountries WHERE territoryrightskey IN (SELECT territoryrightskey FROM #territoryrights_temp_2 WHERE territoryrightskey <> @v_territoryrightskey_latest) AND bookkey = @v_bookkey
		DELETE FROM territoryrights WHERE territoryrightskey IN (SELECT territoryrightskey FROM #territoryrights_temp_2 WHERE territoryrightskey <> @v_territoryrightskey_latest) AND bookkey = @v_bookkey
	END
	ELSE IF @v_count = 1 BEGIN  -- Row Counts same for rows among the territoryrightscountries table
		DELETE FROM #territoryrightscountries_temp
		-- Check if we have any duplicates among each of the territoryrightscountries table based on each of the territoryrightskey for the book
		INSERT INTO #territoryrightscountries_temp (countrycode, forsaleind)
		SELECT countrycode, forsaleind 
		FROM territoryrightcountries
		WHERE bookkey = @v_bookkey AND territoryrightskey = @v_territoryrightskey_latest 	
		
		DECLARE crTerritoryRightsCountries CURSOR FOR
	   	  SELECT territoryrightskey 
		  FROM #territoryrights_temp_2
		  WHERE territoryrightskey <> @v_territoryrightskey_latest
				  
		OPEN crTerritoryRightsCountries 

		FETCH NEXT FROM crTerritoryRightsCountries INTO @v_territoryrightskey

		 WHILE (@@FETCH_STATUS <> -1)
		 BEGIN
			IF EXISTS(
				SELECT tc.*, tr.territoryrightskey 
				FROM #territoryrightscountries_temp tc 
				LEFT OUTER JOIN territoryrightcountries tr ON tr.territoryrightskey = @v_territoryrightskey     
				AND tc.countrycode = tr.countrycode AND COALESCE(tc.forsaleind, 0) = COALESCE(tr.forsaleind, 0)
				WHERE territoryrightskey IS NULL
			   ) 
			BEGIN -- Not all are duplicate entries as values do not match up to be part of latest territoryrightcountries entry's for @v_territoryrightskey_latest, write to territoryrightscleanup table
				IF NOT EXISTS(SELECT * FROM territoryrightscleanup WHERE isbn = @v_isbn AND  bookkey = @v_bookkey AND description = @v_description) BEGIN
					INSERT INTO territoryrightscleanup (isbn, bookkey, description, lastuserid, lastmaintdate) 
					VALUES(@v_isbn, @v_bookkey, @v_description, 'QSIDBA', GETDATE())               																									
				END	
			END	
			
		   DELETE FROM territoryrightcountries WHERE territoryrightskey = @v_territoryrightskey AND bookkey = @v_bookkey
		   DELETE FROM territoryrights WHERE territoryrightskey = @v_territoryrightskey AND bookkey = @v_bookkey
		   				 
		 FETCH NEXT FROM crTerritoryRightsCountries INTO @v_territoryrightskey
		END /* WHILE FECTHING */
		
		CLOSE crTerritoryRightsCountries 
		DEALLOCATE crTerritoryRightsCountries   							
	END
 
    FETCH NEXT FROM crTerritoryRights INTO @v_bookkey, @v_isbn, @v_description
 END /* WHILE FECTHING */

CLOSE crTerritoryRights 
DEALLOCATE crTerritoryRights   

DELETE FROM #territoryrights_temp_1

--  4. When duplicate entries by bookkey have different descriptions and/or rights detail data then write information to clean-up table and delete all but the newest row.

INSERT INTO #territoryrights_temp_1 (territoryrightskey, bookkey, isbn, description, lastmaintdate)
select DISTINCT t1.territoryrightskey, t1.bookkey, ct.isbn, t1.description, t1.lastmaintdate
from #territoryrights_duplicates t1 INNER JOIN #territoryrights_duplicates t2
ON t1.bookkey = t2.bookkey AND 
   t1.territoryrightskey <> t2.territoryrightskey AND
   ((t1.description <> t2.description) OR
   (COALESCE(t1.currentterritorycode, -99999) <> COALESCE(t2.currentterritorycode, -99999) OR
   COALESCE(t1.contractterritorycode, -99999) <> COALESCE(t2.contractterritorycode, -99999) OR
   COALESCE(t1.exclusivecode, -99999) <> COALESCE(t2.exclusivecode, -99999) OR
   COALESCE(t1.singlecountrycode, -99999) <> COALESCE(t2.singlecountrycode, -99999) OR
   COALESCE(t1.singlecountrygroupcode, -99999) <> COALESCE(t2.singlecountrygroupcode, -99999))) 
INNER JOIN coretitleinfo ct ON ct.bookkey = t1.bookkey AND ct.printingkey = 1     
where t1.description IS NOT NULL OR LOWER(LTRIM(RTRIM(t1.description))) <> 'none'
and t1.bookkey > 0
order by t1.lastmaintdate asc,  t1.bookkey asc, t1.description asc, ct.isbn asc, t1.territoryrightskey asc

UPDATE t1
SET t1.row_count = (SELECT COUNT(*) FROM territoryrightcountries tc WHERE tc.bookkey = t1.bookkey AND tc.territoryrightskey = t1.territoryrightskey)
FROM #territoryrights_temp_1 t1

DECLARE crTerritoryRights_different_description_or_rightsdetail CURSOR FOR
  SELECT DISTINCT bookkey, isbn, description, territoryrightskey
  FROM #territoryrights_temp_1
		  
  OPEN crTerritoryRights_different_description_or_rightsdetail 

  FETCH NEXT FROM crTerritoryRights_different_description_or_rightsdetail INTO @v_bookkey, @v_isbn, @v_description, @v_territoryrightskey -- We are processing the records by territoryrightskey as description / rights detail info is different

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
	DELETE FROM #territoryrights_temp_2
	
	INSERT INTO #territoryrights_temp_2
	SELECT territoryrightskey, row_count, lastmaintdate
	FROM #territoryrights_temp_1 WHERE bookkey = @v_bookkey
	ORDER BY lastmaintdate ASC
	
	SET @v_territoryrightskey_latest = NULL
	
	SELECT TOP(1) @v_territoryrightskey_latest = territoryrightskey
	FROM #territoryrights_temp_2
	ORDER BY lastmaintdate ASC
			
	IF @v_territoryrightskey = @v_territoryrightskey_latest BEGIN -- Skipping the latest entry
		FETCH NEXT FROM crTerritoryRights_different_description_or_rightsdetail INTO @v_bookkey, @v_isbn, @v_description, @v_territoryrightskey
		CONTINUE		
	END
		--- Write to territoryrightscleanup table for older entries if they dont exist
	IF NOT EXISTS(SELECT * FROM territoryrightscleanup WHERE isbn = @v_isbn AND bookkey = @v_bookkey AND description = @v_description)
	 BEGIN
		INSERT INTO territoryrightscleanup (isbn, bookkey, description, lastuserid, lastmaintdate) 
		VALUES(@v_isbn, @v_bookkey, @v_description, 'QSIDBA', GETDATE())
	END 			
	
	-- Delete from territoryrights and territoryrightcountries table for older entries
	IF NOT EXISTS (SELECT * FROM #territoryrights_temp_2 WHERE row_count > 0) BEGIN				
		DELETE FROM territoryrights 
		WHERE bookkey = @v_bookkey AND territoryrightskey IN (SELECT territoryrightskey FROM #territoryrights_temp_2 WHERE territoryrightskey <> @v_territoryrightskey_latest)
		
		FETCH NEXT FROM crTerritoryRights_different_description_or_rightsdetail INTO @v_bookkey, @v_isbn, @v_description, @v_territoryrightskey
		CONTINUE
	END
	ELSE BEGIN		
		DELETE FROM territoryrightcountries WHERE territoryrightskey IN (SELECT territoryrightskey FROM #territoryrights_temp_2 WHERE territoryrightskey <> @v_territoryrightskey_latest) AND bookkey = @v_bookkey
		DELETE FROM territoryrights WHERE territoryrightskey IN (SELECT territoryrightskey FROM #territoryrights_temp_2 WHERE territoryrightskey <> @v_territoryrightskey_latest) AND bookkey = @v_bookkey		
	END
 
    FETCH NEXT FROM crTerritoryRights_different_description_or_rightsdetail INTO @v_bookkey, @v_isbn, @v_description, @v_territoryrightskey
 END /* WHILE FECTHING */

CLOSE crTerritoryRights_different_description_or_rightsdetail 
DEALLOCATE crTerritoryRights_different_description_or_rightsdetail  

 DROP TABLE #territoryrights_duplicates
 DROP TABLE #territoryrights_temp_1
 DROP TABLE #territoryrights_temp_2  
 DROP TABLE #territoryrightscountries_temp
 
 GO