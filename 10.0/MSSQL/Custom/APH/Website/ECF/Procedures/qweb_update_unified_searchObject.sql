if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qweb_update_unified_searchObject') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qweb_update_unified_searchObject
  print 'dropped dbo.qweb_update_unified_searchObject'
  print 'created dbo.qweb_update_unified_searchObject'

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].qweb_update_unified_searchObject
@agency varchar(8000),
@isbn varchar(8000),
@catalog_number varchar(8000),
@title varchar(8000),
@subtitle varchar(8000),
@author_displayname varchar(8000),
@format varchar(8000),
@series varchar(8000),
@edition varchar(8000),
@state_edition varchar(8000),
@original_publisher varchar(8000),
@copyright_year varchar(8000),
@subjects varchar(8000),
@brief_description varchar(8000),
@url varchar(8000),
@grade varchar(8000),
@createdate datetime,
@lastuserid varchar(512),
@lastmaintdate datetime

AS

BEGIN

	if @agency is not null AND @catalog_number is not null 
	BEGIN
		
		IF @isbn is not NULL AND len(@isbn) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET isbn = @isbn,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @title is not NULL AND len(@title) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET title = @title,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END

		IF @subtitle is not NULL AND len(@subtitle) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET subtitle = @subtitle,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @author_displayname is not NULL AND len(@author_displayname) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET author_displayname = @author_displayname,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @format is not NULL AND len(@format) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET format = @format,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @series is not NULL AND len(@series) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET series = @series,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @edition is not NULL AND len(@edition) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET edition = @edition,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @state_edition is not NULL AND len(@state_edition) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET state_edition = @state_edition,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @original_publisher is not NULL AND len(@original_publisher) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET original_publisher = @original_publisher,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @copyright_year is not NULL AND len(@copyright_year) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET copyright_year = @copyright_year,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @subjects is not NULL AND len(@subjects) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET subjects = @subjects,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END

		IF @brief_description is not NULL AND len(@brief_description) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET brief_description = @brief_description,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		IF @url is not NULL AND len(@url) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET url = @url,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END

		IF @grade is not NULL AND len(@grade) > 0
		BEGIN
			UPDATE dbo.qweb_unified_search_objects
			SET grade = @grade,
				lastmaintdate = @lastmaintdate, 
				lastuserid = @lastuserid
			WHERE agency = @agency AND catalog_number = @catalog_number
		END
		
		
	END

  
END

