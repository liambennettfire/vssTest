if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_upcoming_titles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_get_upcoming_titles]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qweb_get_upcoming_titles
 (@i_websitekey      integer,
  @i_startdate       datetime, 
  @i_num_of_days     integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/**********************************************************************/
/*                                                                    */        
/*      Author   : FPT                                                */
/*      Creation Date   :   2/21/2007                                 */
/*      Comments : creates announcements for upcoming titles.         */
/**********************************************************************/     

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_enddate datetime

  IF @i_num_of_days > 0 BEGIN
    SET @v_enddate = @i_startdate + @i_num_of_days
  END
  ELSE BEGIN
    SET @v_enddate = @i_startdate
  END

   SELECT td.bookkey, 1 "printingkey",td.bestdate "pubdate", ti.audience, ti.fulltitle "title", ti.subtitle, 
          ti.fullauthordisplayname "authorname", ti.grouplevel3 imprint,
          ti.usretailprice, ti.isbn10, ti.isbn13, ti.ean, ti.format, ti.pagecount,
          dbo.qweb_wh_get_short_briefdesc(td.websitekey,td.bookkey,3,0) "bookdesc" 
     FROM qweb_wh_titleinfo ti, qweb_wh_titledates td
    WHERE td.websitekey = ti.websitekey
      and td.bookkey = ti.bookkey 
      and td.websitekey = @i_websitekey
      and lower(td.datedesc) = 'publication date'
      and (td.bestdate between @i_startdate and @v_enddate)
      and ti.usretailprice <> ''
      and dbo.qweb_wh_get_short_briefdesc(td.websitekey,td.bookkey,3,0)<>''
 ORDER BY ti.audience, ti.fulltitle
   
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'no titles found with pubdate between ' + cast(@i_startdate AS VARCHAR) + ' and ' + cast(@v_enddate AS VARCHAR)
  END 

GO
GRANT EXEC ON qweb_get_upcoming_titles TO PUBLIC
GO



