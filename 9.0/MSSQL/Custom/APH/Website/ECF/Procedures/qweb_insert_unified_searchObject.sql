if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qweb_insert_unified_searchObject') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qweb_insert_unified_searchObject
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].qweb_insert_unified_searchObject
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
INSERT INTO dbo.qweb_unified_search_objects
  ( 
    agency, 
    isbn,   
    catalog_number, 
    title, 
    subtitle, 
    author_displayname, 
    format, 
    series, 
    edition, 
    state_edition, 
    original_publisher,
    copyright_year, 
    subjects, 
    brief_description, 
    url, 
    grade, 
    createdate, 
    lastuserid,                                 
    lastmaintdate
  ) 
VALUES 
  ( 
    @agency,
    @isbn ,
    @catalog_number,
    @title,  
    @subtitle,
    @author_displayname,
    @format,
    @series,
    @edition,
    @state_edition,
    @original_publisher,
    @copyright_year,
    @subjects,
    @brief_description,
    @url,
    @grade,
    @createdate,
    @lastuserid,
    @lastmaintdate               
  ) 
END

