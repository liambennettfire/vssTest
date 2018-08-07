SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.fulldisplayname_refresh') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.fulldisplayname_refresh
  END

GO

/*************************************************************************/
/*                                                			 */
/*  Anes Hrenovica                                    			 */
/*  07-09-2004                                    			 */
/*                                              			 */
/*                   MSSQL VERSION                			 */
/*                                                			 */
/*  This stored proc will call fulldisplayname for all bookkeys		 */
/*  fullauthordisplayname in bookdetail.          			 */
/*     									 */
/**************************************************************************/


CREATE PROCEDURE dbo.fulldisplayname_refresh
AS

DECLARE @v_bookkey         INT

DECLARE c_bookkey CURSOR FOR
   SELECT bookauthor.bookkey
    FROM bookauthor,   
         author  
   WHERE  bookauthor.authorkey = author.authorkey  

BEGIN

--clean orphans from bookauthor
delete bookauthor
where bookkey not in(select bookkey from book)

   OPEN c_bookkey

   FETCH NEXT FROM c_bookkey
      INTO @v_bookkey

   WHILE (@@FETCH_STATUS= 0) 
      BEGIN

	EXECUTE fulldisplayname @v_bookkey

         FETCH NEXT FROM c_bookkey
           INTO  @v_bookkey

      END
CLOSE c_bookkey
   DEALLOCATE c_bookkey

END
GO
--execute prox
--exec fulldisplayname_refresh
--GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

