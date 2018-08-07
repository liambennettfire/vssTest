if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_formats') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_project_formats
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_formats
 (@i_projectkey   integer,
  @i_dropdownuse  bit,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/********************************************************************************
**  Name: qproject_get_project_formats
**  Desc: This stored procedure get a list of the project formats. 
**
**    Auth: James Weber
**    Date: 17 May 2004
*********************************************************************************
**  4/21/05 - KW - Added sort - Primary format first.
**  8/3/05 - KW - Changed second argument (primary only) to (dropdown use).
**  dropdownuse=1 will be used for drop-down retrievals where we only need 
**  key and description (this limits viewstate).
**  11/29/11 - JH - 14197 - Added filtering to prevent Competitive 
**                          or Comparative rows from being returned.
**  07/24/18 - Colman - TM-584
*********************************************************************************/
  DECLARE @ErrorValue    INT
  DECLARE @RowcountValue INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @ErrorValue = 0
  SET @RowcountValue = 0  
  
  
  IF @i_dropdownuse = 1
    BEGIN
      SELECT taqprojectformatkey, COALESCE(relateditem2name,taqprojectformatdesc) relateditem2name FROM taqprojecttitle 
      WHERE taqprojectkey = @i_projectkey 
        AND titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)	--Format
      ORDER BY primaryformatind DESC, mediatypecode, taqprojectformatdesc
    END
  ELSE
    BEGIN
      SELECT ISNULL(v.description, g.datadesc + '/' + s.datadesc) description, tpt.*,
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
		         end upcvalue
        FROM taqprojecttitle tpt
          JOIN gentables g ON g.tableid = 312 AND g.datacode = tpt.mediatypecode
          JOIN subgentables s ON s.tableid = 312 AND s.datacode = tpt.mediatypecode AND s.datasubcode = tpt.mediatypesubcode
          LEFT JOIN taqversionformat v ON v.taqprojectformatkey = tpt.selectedversionformatkey
       WHERE tpt.taqprojectkey = @i_projectkey and titlerolecode = 2
      ORDER BY tpt.primaryformatind DESC, tpt.mediatypecode, tpt.taqprojectformatdesc
    END
  
  SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT  
  IF @ErrorValue <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access table taqproject format'
    RETURN
  END
  
GO

GRANT EXEC ON qproject_get_project_formats TO PUBLIC
GO
