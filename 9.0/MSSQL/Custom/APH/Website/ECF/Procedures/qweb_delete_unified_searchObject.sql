if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qweb_delete_unified_searchObject') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qweb_delete_unified_searchObject
  print 'dropped dbo.qweb_delete_unified_searchObject'
  print 'created dbo.qweb_delete_unified_searchObject'

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].qweb_delete_unified_searchObject
@agency varchar(8000),
@catalog_number varchar(8000)

AS

BEGIN

	if @agency is not null AND @catalog_number is not null 
	BEGIN

DELETE 
FROM  qweb_unified_search_objects
WHERE agency = @agency
AND catalog_number = @catalog_number

END

  
END

