if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_specific_project_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_specific_project_format
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_specific_project_format
 (@i_projectkey        integer,
  @i_projectformatkey  integer,
  @o_error_code        integer output,
  @o_error_desc        varchar(2000) output)
AS

/********************************************************************************
**  Name: qproject_get_specific_project_format
**  Desc: This stored procedure get a specific project format
**
**    Auth: Alan Katzen
**    Date: 04 April 2011
*********************************************************************************/

  DECLARE @ErrorValue    INT
  DECLARE @RowcountValue INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @ErrorValue = 0
  SET @RowcountValue = 0
  
  SELECT tpt.*,
         case 
	         when tpt.bookkey > 0 then 
	           (select isbn from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.isbn
         end isbnvalue, 
         case 
	         when tpt.bookkey > 0 then 
	           (select isbn10 from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.isbn10
         end isbn10value, 
         case 
	         when tpt.bookkey > 0 then 
	           (select ean from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.ean
         end eanvalue, 
         case 
	         when tpt.bookkey > 0 then 
	           (select ean13 from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.ean13
         end ean13value, 
         case 
	         when tpt.bookkey > 0 then 
	           (select gtin from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.gtin
         end gtinvalue, 
         case 
	         when tpt.bookkey > 0 then 
	           (select gtin14 from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.gtin14
         end gtin14value, 
         case 
	         when tpt.bookkey > 0 then 
	           (select lccn from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.lccn
         end lccnvalue, 
         case 
	         when tpt.bookkey > 0 then 
	           (select dsmarc from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.dsmarc
         end dsmarcvalue, 
         case 
	         when tpt.bookkey > 0 then 
	           (select itemnumber from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.itemnumber
         end itemnumbervalue, 
         case 
	         when tpt.bookkey > 0 then 
	           (select upc from isbn where isbn.bookkey = tpt.bookkey)  
	         else tpt.upc
         end upcvalue,
         tp.taqprojecttitle
    FROM taqprojecttitle tpt, taqproject tp
   WHERE tpt.taqprojectkey = tp.taqprojectkey
     AND tpt.taqprojectkey = @i_projectkey
     AND tpt.taqprojectformatkey = @i_projectformatkey
  
  SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT  
  IF @ErrorValue <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access table taqprojecttitle'
    RETURN
  END
  
GO

GRANT EXEC ON qproject_get_specific_project_format TO PUBLIC
GO


