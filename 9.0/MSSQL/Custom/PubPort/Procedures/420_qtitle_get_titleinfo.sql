if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_titleinfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_titleinfo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_titleinfo
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_titleinfo
**  Desc: This stored procedure returns all title information
**        from the coretitle table and some from the printing 
**        table. It is designed to be used in conjunction with
**        a title information control.
**
**    Auth: Alan Katzen
**    Date: 25 March 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_lastsentdate datetime

  -- get date of last send to eloquence 
  SELECT @v_lastsentdate = max(lastmaintdate)  
    FROM fileprocesscatalog  
   WHERE fileprocesscatalog.bookkey = @i_bookkey    

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error retrieving last sent to eloquence date: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
    return
  END 

  SELECT printing.trimsizelength,printing.esttrimsizelength,printing.tmmactualtrimlength,
        COALESCE(printing.tmmactualtrimlength,printing.trimsizelength,printing.esttrimsizelength) besttrimsizelength,
        printing.trimsizewidth,printing.esttrimsizewidth,printing.tmmactualtrimwidth,
        COALESCE(printing.tmmactualtrimwidth,printing.trimsizewidth,printing.esttrimsizewidth) besttrimsizewidth,
        dbo.qutl_get_clientoptions_flag('tmm actual trimsize') usetmmactualtrimsize,
        printing.actualinsertillus,printing.estimatedinsertillus,
        COALESCE(printing.actualinsertillus,printing.estimatedinsertillus) bestinsertillus,
        printing.announcedfirstprint,printing.estannouncedfirstprint,
        COALESCE(printing.announcedfirstprint,printing.estannouncedfirstprint) bestannouncedfirstprint,
        printing.firstprintingqty,printing.tentativeqty,
        COALESCE(printing.firstprintingqty,printing.tentativeqty) bestreleaseqty,
        printing.pagecount,printing.tentativepagecount,printing.tmmpagecount,
        COALESCE(printing.tmmpagecount,printing.pagecount,printing.tentativepagecount) bestpagecount,
        dbo.qutl_get_clientoptions_flag('tmm page count') usetmmpagecount,
        printing.pubmonthcode,book.subtitle,bookdetail.volumenumber, bookdetail.canadianrestrictioncode, 
        bookedistatus.edistatuscode, bookedipartner.sendtoeloquenceind, c.*, printing.spinesize, bindingspecs.cartonqty1,
        printing.barcodeid1,printing.barcodeposition1,printing.barcodeid2,printing.barcodeposition2,
        COALESCE(booksimon.bookweight,0) bookweight,printing.printingnum,
        dbo.qutl_get_productnumber(3,@i_bookkey) secondarytitleprodnum, @v_lastsentdate lastsenttoelodate,
        bookdetail.editionNumber, bookdetail.editiondescription, bookdetail.additionaleditinfo,
        audiocassettespecs.numcassettes, audiocassettespecs.totalruntime, 
        book.elocustomerkey, customer.customershortname
    FROM coretitleinfo c
        JOIN printing on c.bookkey = printing.bookkey and c.printingkey = printing.printingkey
        JOIN book on c.bookkey = book.bookkey 
        JOIN bookdetail on c.bookkey = bookdetail.bookkey
        LEFT OUTER JOIN bookedistatus ON c.bookkey = bookedistatus.bookkey AND c.printingkey = bookedistatus.printingkey AND bookedistatus.edipartnerkey = 1
        LEFT OUTER JOIN bindingspecs ON c.bookkey = bindingspecs.bookkey AND c.printingkey = bindingspecs.printingkey 	  
        LEFT OUTER JOIN bookedipartner ON c.bookkey = bookedipartner.bookkey AND c.printingkey = bookedipartner.printingkey AND bookedipartner.edipartnerkey = 1
        LEFT OUTER JOIN booksimon ON c.bookkey = booksimon.bookkey 
        LEFT OUTER JOIN audiocassettespecs on c.bookkey = audiocassettespecs.bookkey AND c.printingkey = audiocassettespecs.printingkey
        LEFT OUTER JOIN customer on book.elocustomerkey = customer.customerkey
           
   WHERE c.bookkey = @i_bookkey and
         c.printingkey = @i_printingkey 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_titleinfo TO PUBLIC
GO



