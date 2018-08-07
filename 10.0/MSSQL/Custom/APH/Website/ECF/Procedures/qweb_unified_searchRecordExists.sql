if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qweb_unified_searchRecordExists') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qweb_unified_searchRecordExists
GO

CREATE PROCEDURE dbo.qweb_unified_searchRecordExists
@agency varchar(8000),
@catalog_number varchar(8000)

as
BEGIN

SELECT     COUNT(search_object_id) AS [count]
FROM         qweb_unified_search_objects
WHERE     (agency = @agency) AND (catalog_number = @catalog_number)

END
 