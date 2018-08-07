if exists (select * from dbo.sysobjects where id = object_id(N'dbo.dwo_send_to_whse_dwodetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.dwo_send_to_whse_dwodetail
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dwo_send_to_whse_dwodetail
 (@i_taqprojectkey			 integer,
  @i_dwokey                 integer,
  @i_userid                 varchar(30),
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: dwo_send_to_whse_dwodetail
**  Desc: This stored procedure will write a row to the dwodetail table 
**        for each taqprojecttitle record for this project
**        
**             
**
**    Auth: Kusum Basra
**    Date: 3 February 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_dwokey IS NULL OR @i_dwokey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to send to warehouse : dwokey is empty.'
    RETURN
  END 

/**** dwodetail table ********/

DECLARE 	
	@v_bookkey						INT,
    @v_printingkey					INT,
    @v_prodnum_title_column		VARCHAR(50),
	@v_prodnum_title_table 		VARCHAR(50),
    @v_prodnum_value				VARCHAR(50),
    @v_value						   VARCHAR(50),
    @v_title        				VARCHAR(255),
	@v_author						VARCHAR(150),
	@v_quantity						INT,
	@v_mediacode					INT,
    @v_formatdesc					VARCHAR(120),
	@v_formatcode					INT,
	@v_bisacstatusdesc			VARCHAR(120),
	@v_bisacstatuscode			INT,
	@v_shorttitle					VARCHAR(50),
    @v_count							INT,
 	@v_sqlstring					NVARCHAR(4000),
 	@v_isbn                     VARCHAR(13)
	

/*** Get source table and column for the the primary productnumber value for DWO ***/
SELECT @v_prodnum_title_table = LOWER(tablename), @v_prodnum_title_column = LOWER(columnname)
  FROM productnumlocation
 WHERE productnumlockey = 5


/** Declare a cursor for each taqprojecttitle record for the passed taqprojectkey **/
  DECLARE taqprojecttitle_cur CURSOR FOR
    SELECT bookkey, printingkey, quantity1
	   FROM taqprojecttitle
	  WHERE taqprojectkey = @i_taqprojectkey
		 AND bookkey is not null 
       AND printingkey = 1
	  
        
  OPEN taqprojecttitle_cur

  FETCH NEXT FROM taqprojecttitle_cur INTO @v_bookkey, @v_printingkey, @v_quantity
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
		SET @v_title = ''					
		SET @v_author = ''				
		--SET @v_quantity = 0				
		SET @v_mediacode = 0					
		SET @v_formatdesc = ''						
		SET @v_bisacstatusdesc = ''						
		SET @v_bisacstatuscode = 0			
		SET @v_shorttitle = ''						
		SET @v_count = 0	

		IF @v_bookkey > 0 
      BEGIN
      
         SELECT @v_isbn = ( select isbn10 from isbn where bookkey = @v_bookkey )
         
         SELECT @v_count = count(*)
          FROM coretitleinfo
         WHERE bookkey = @v_bookkey
           AND printingkey = @v_printingkey
				
			IF @v_count = 1 
         BEGIN		
				IF @v_prodnum_title_column = 'ean' 
				BEGIN
					SELECT @v_title = title, @v_author = authorname, @v_mediacode = mediatypecode, @v_formatdesc = formatname, 
					  @v_formatcode = mediatypesubcode,@v_bisacstatuscode = bisacstatuscode, @v_shorttitle = shorttitle,
                 @v_bisacstatusdesc = bisacstatusdesc,@v_value = ean
					 FROM coretitleinfo
					WHERE bookkey = @v_bookkey
					  AND printingkey = @v_printingkey
				END
				IF @v_prodnum_title_column = 'itemnumber' 
				BEGIN
					SELECT @v_title = title, @v_author = authorname, @v_mediacode = mediatypecode, @v_formatdesc = formatname, 
					  @v_formatcode = mediatypesubcode,@v_bisacstatuscode = bisacstatuscode, @v_shorttitle = shorttitle,
                 @v_bisacstatusdesc = bisacstatusdesc,@v_value = itemnumber
					 FROM coretitleinfo
					WHERE bookkey = @v_bookkey
					  AND printingkey = @v_printingkey
				END
				IF @v_prodnum_title_column = 'isbn' 
				BEGIN
					SELECT @v_title = title, @v_author = authorname, @v_mediacode = mediatypecode, @v_formatdesc = formatname, 
					  @v_formatcode = mediatypesubcode,@v_bisacstatuscode = bisacstatuscode, @v_shorttitle = shorttitle,
                 @v_bisacstatusdesc = bisacstatusdesc,@v_value = isbn
					 FROM coretitleinfo
					WHERE bookkey = @v_bookkey
					  AND printingkey = @v_printingkey
				END
			END   

			IF @v_quantity IS NULL
         BEGIN
         	SET @v_quantity = 1
         END 
				
			INSERT INTO dwodetail (dwokey,bookkey,productnumber,title,author,quantity,lastmaintdate,lastuserid,mediacode,
             formatdesc,formatcode,bisacstatusdesc,bisacstatuscode,shorttitle,isbn)
           VALUES (@i_dwokey,@v_bookkey,@v_value,@v_title,@v_author,@v_quantity,getdate(),@i_userid,@v_mediacode,
             @v_formatdesc,@v_formatcode,@v_bisacstatusdesc,@v_bisacstatuscode,@v_shorttitle,@v_isbn)
      END --IF @v_bookkey > 0 			

		FETCH NEXT FROM taqprojecttitle_cur INTO @v_bookkey,@v_printingkey, @v_quantity
  END /* @@FETCH_STATUS=0 - taqprojecttitle_cur cursor */
    
  CLOSE taqprojecttitle_cur 
  DEALLOCATE taqprojecttitle_cur

GO
GRANT EXEC ON dwo_send_to_whse_dwodetail TO PUBLIC
GO



