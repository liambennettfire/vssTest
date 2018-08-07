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
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/10/2016   AK		     Case 36267 - Added FlightDeck columns from customer table
**  03/02/2016   Colman      Added customer.servicelevelcode
**  03/08/2016   UK	         Case 36678
*******************************************************************************/


  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_lastsentdate datetime,
          @v_cover_image_path varchar(8000),
          @v_use_web_file_locations INT,
          @v_metadata_uploaded_to_CS datetime,
          @v_uploaded_datetype int,
          @v_metadata_assettype int,
          @v_cloudproductid varchar(50),
          @v_work_projectkey int,
          @v_title_title_role int,
          @v_work_project_role int,
          @v_work_project_title varchar(255)

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

  -- only return image path if web file locations is used
  SELECT @v_use_web_file_locations = optionvalue
    FROM clientoptions
   WHERE optionid = 77

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @v_use_web_file_locations = 0
  END 
   
  SET @v_cover_image_path = ''
  IF @v_use_web_file_locations = 1 BEGIN
    -- get cover image path if it exists (if more than 1 exists, use first one)
    SELECT TOP 1 @v_cover_image_path = CASE WHEN fl.filelocationkey > 0 THEN
        '~\' + dbo.qutl_get_filelocation_rootpath(fl.filelocationkey,'logical') + '\' + pathname
        ELSE pathname END  
     FROM filelocation fl, gentables g
    WHERE bookkey = @i_bookkey AND
      printingkey = @i_printingkey AND
      fl.filetypecode = g.datacode AND
      g.tableid = 354 AND
      g.gen1ind = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error returning cover image path (bookkey=' + cast(@i_bookkey as varchar) + ', printingkey=' + cast(@i_printingkey as varchar) + ')'
      RETURN  
    END 
  END
  
  SELECT @v_uploaded_datetype = datetypecode
    FROM datetype
   WHERE qsicode = 12

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error retrieving Upload Asset datetypecode from datetype: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
    return
  END 
   
  SELECT @v_metadata_assettype = datacode
    FROM gentables
   WHERE tableid = 287
     AND qsicode = 3

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error retrieving element type for Metadata asset: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
    return
  END 
  
  SET @v_metadata_uploaded_to_CS = null
  IF @v_uploaded_datetype > 0 and @v_metadata_assettype > 0 BEGIN
    SELECT @v_metadata_uploaded_to_CS = activedate
      FROM taqprojecttask
     WHERE bookkey = @i_bookkey
       AND printingkey = @i_printingkey
       AND datetypecode = @v_uploaded_datetype
       AND taqelementkey = (SELECT taqelementkey FROM taqprojectelement e 
                             WHERE e.taqelementkey = taqelementkey
                               AND e.taqelementtypecode = @v_metadata_assettype 
                               AND e.bookkey = @i_bookkey
                               AND e.printingkey = @i_printingkey)

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error retrieving metadata uploaded to CS datetype: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
      return
    END 
  END

  SELECT @v_cloudproductid = cloudproductid  
    FROM isbn
   WHERE bookkey = @i_bookkey
     
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error retrieving cloudproductid from isbn: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
    return
  END 
      
  SELECT @v_work_project_role = datacode
    FROM gentables
   WHERE tableid = 604
     and qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'UError getting work project role: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR) 
    RETURN
  END 
     
  SELECT @v_title_title_role = datacode
    FROM gentables
   WHERE tableid = 605
     and qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting title title role: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR) 
    RETURN
  END 
      
  SELECT @v_work_projectkey = tpt.taqprojectkey,
         @v_work_project_title = c.projecttitle
    FROM taqprojecttitle tpt, coreprojectinfo c
   WHERE tpt.taqprojectkey = c.projectkey
     AND tpt.bookkey = @i_bookkey
     AND COALESCE(tpt.printingkey,1) = @i_printingkey
     AND tpt.titlerolecode = @v_title_title_role
     AND tpt.projectrolecode = @v_work_project_role

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting work projectkey: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR) 
    RETURN
  END 
  
  IF @v_work_projectkey is null BEGIN
    SET @v_work_projectkey = 0
  END  
    
  SELECT printing.trimsizelength,printing.esttrimsizelength,printing.tmmactualtrimlength,

-- JH ( 12146 ) As of 8/2/2010 there is an issue on Powerbuilder where if the estimated values are input only, 
-- the tmmactualtrimwidth and tmmactualtrimlength write different values ( width='' and length=NULL ) 
--  which was causing issue in the code below which was modified accordingly but Powerbuilder should change for consistency sake.

        CASE
          WHEN dbo.qutl_get_clientoptions_flag('tmm actual trimsize') = 1 THEN
            CASE 
              WHEN( printing.tmmactualtrimlength is null or printing.tmmactualtrimlength = '' )
					THEN COALESCE(printing.esttrimsizelength, '')
					ELSE COALESCE(printing.tmmactualtrimlength, '')
           
             END
          WHEN dbo.qutl_get_clientoptions_flag('tmm actual trimsize') = 0 THEN
             CASE
				WHEN ( printing.trimsizelength is null or printing.trimsizelength = '' )
					THEN COALESCE(printing.esttrimsizelength, '') 
					ELSE COALESCE(printing.trimsizelength, '') 
             END
        END AS besttrimsizelength,

        printing.trimsizewidth,printing.esttrimsizewidth,printing.tmmactualtrimwidth,

        CASE
         WHEN dbo.qutl_get_clientoptions_flag('tmm actual trimsize') = 1 THEN
          CASE
            WHEN ( printing.tmmactualtrimwidth is null or printing.tmmactualtrimwidth = '' )
				THEN COALESCE(printing.esttrimsizewidth, '')
				ELSE COALESCE(printing.tmmactualtrimwidth, '')
          END
          WHEN dbo.qutl_get_clientoptions_flag('tmm actual trimsize') = 0 THEN
           CASE
            WHEN ( printing.trimsizewidth is null or printing.trimsizewidth = '' )
				  THEN COALESCE(printing.esttrimsizewidth, '')  
				  ELSE COALESCE(printing.trimsizewidth, '')
            END
        END AS besttrimsizewidth,

        dbo.qutl_get_clientoptions_flag('tmm actual trimsize') usetmmactualtrimsize,
        printing.actualinsertillus,printing.estimatedinsertillus,
        COALESCE(printing.actualinsertillus,printing.estimatedinsertillus) bestinsertillus,
        printing.announcedfirstprint,printing.estannouncedfirstprint,
        COALESCE(printing.announcedfirstprint,printing.estannouncedfirstprint) bestannouncedfirstprint,
        printing.firstprintingqty,printing.tentativeqty,
        COALESCE(printing.firstprintingqty,printing.tentativeqty) bestreleaseqty,
        printing.pagecount,printing.tentativepagecount,printing.tmmpagecount,        
 ---       COALESCE(printing.tmmpagecount,printing.pagecount,printing.tentativepagecount) bestpagecount,
        
       CASE 
          WHEN (printing.tmmpagecount is null) and (printing.pagecount is null) and (tentativepagecount is null)
            THEN COALESCE(printing.tmmpagecount,printing.pagecount,printing.tentativepagecount) 
            ELSE
			 CASE 
			  WHEN dbo.qutl_get_clientoptions_flag('tmm page count') = 1 THEN 
					 CASE 
					   WHEN (printing.tmmpagecount is null or printing.tmmpagecount = '' or printing.tmmpagecount = 0) THEN COALESCE(printing.tentativepagecount,'') 
         			   ELSE COALESCE(printing.tmmpagecount, '') 
					  END 
			  ELSE 
					 CASE
						WHEN (printing.pagecount is null or printing.pagecount = '' or printing.pagecount = 0) THEN COALESCE(printing.tentativepagecount,'') 
               			ELSE COALESCE(printing.pagecount,'') 
					 END  
			  END 
        END  AS bestpagecount,

        dbo.qutl_get_clientoptions_flag('tmm page count') usetmmpagecount,
        printing.pubmonthcode,book.subtitle,bookdetail.volumenumber, bookdetail.canadianrestrictioncode, 
        bookedistatus.edistatuscode, bookedipartner.sendtoeloquenceind, UPPER(c.title) titleupper, c.*, printing.spinesize, bindingspecs.cartonqty1,
        printing.barcodeid1,printing.barcodeposition1,printing.barcodeid2,printing.barcodeposition2,
        COALESCE(printing.bookweight,0) bookweight,printing.printingnum,
        dbo.qutl_get_productnumber(3,@i_bookkey) secondarytitleprodnum, @v_lastsentdate lastsenttoelodate,
        bookdetail.editionNumber, bookdetail.editiondescription, bookdetail.additionaleditinfo,
        bookdetail.csapprovalcode, dbo.qutl_get_gentables_ext_gentext1(620, bookdetail.csapprovalcode) iconfilename, bookdetail.csmetadatastatuscode, bookdetail.csassetstatuscode, bookdetail.csmetadatalastupdate,
        audiocassettespecs.numcassettes, audiocassettespecs.totalruntime, 
        book.elocustomerkey, customer.customershortname, customer.servicelevelcode, svclevels.datadesc as serviceleveldesc,
        printing.trimsizeunitofmeasure, printing.bookweightunitofmeasure, printing.spinesizeunitofmeasure,
        @v_cover_image_path coverimagepath, @v_metadata_uploaded_to_CS metadata_uploaded_to_CS,
        @v_cloudproductid cloudproductid, @v_work_projectkey workprojectkey, @v_work_project_title workprojecttitle, customer.eloqcustomerid, dbo.qcs_get_istitleinoutbox(@i_bookkey) istitleinoutbox, customer.cloudaccesskey, bookedistatus.previousedistatuscode,
        textspecs.vendorkey AS textvendorkey, jacketspecs.vendorkey AS jacketvendorkey,flightdeckkey,flightdecksecret,flightdeckurl
    FROM coretitleinfo c
        JOIN printing on c.bookkey = printing.bookkey and c.printingkey = printing.printingkey
        JOIN book on c.bookkey = book.bookkey 
        JOIN bookdetail on c.bookkey = bookdetail.bookkey
        LEFT OUTER JOIN bookedistatus ON c.bookkey = bookedistatus.bookkey AND c.printingkey = bookedistatus.printingkey AND bookedistatus.edipartnerkey = 1
        LEFT OUTER JOIN bindingspecs ON c.bookkey = bindingspecs.bookkey AND c.printingkey = bindingspecs.printingkey
        LEFT OUTER JOIN textspecs ON c.bookkey = textspecs.bookkey AND c.printingkey = textspecs.printingkey
        LEFT OUTER JOIN jacketspecs ON c.bookkey = jacketspecs.bookkey AND c.printingkey = jacketspecs.printingkey                 	  
        LEFT OUTER JOIN bookedipartner ON c.bookkey = bookedipartner.bookkey AND c.printingkey = bookedipartner.printingkey AND bookedipartner.edipartnerkey = 1
        LEFT OUTER JOIN booksimon ON c.bookkey = booksimon.bookkey 
        LEFT OUTER JOIN audiocassettespecs on c.bookkey = audiocassettespecs.bookkey AND c.printingkey = audiocassettespecs.printingkey
        LEFT OUTER JOIN customer on book.elocustomerkey = customer.customerkey
        LEFT OUTER JOIN gentables svclevels on COALESCE(customer.servicelevelcode,99) = svclevels.datacode AND svclevels.tableid = 677
           
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