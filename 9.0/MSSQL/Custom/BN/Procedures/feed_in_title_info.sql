IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[feed_in_title_info]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_in_title_info]
GO

SET  QUOTED_IDENTIFIER OFF 
GO
SET  ANSI_NULLS ON 
GO

create proc dbo.feed_in_title_info 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/
DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @bookwasupdatedind int
DECLARE @i_sendtoeloquence INT
DECLARE @update_tmm_fields INT

DECLARE @feedin_bookkey  int
DECLARE @feedin_authorkey  int

DECLARE @feedin_isbn  varchar(10)
DECLARE @feedin_bisacstatuscode varchar(10)
DECLARE @feedin_retailprice  varchar(20)
DECLARE @feedin_canadianprice varchar(20)
DECLARE @feedin_categorycode   varchar(20)
DECLARE @feedin_cartonqty  varchar(20)
DECLARE @feedin_canadianrestriction  varchar(20)
DECLARE @feedin_projectisbn  varchar (20)
DECLARE @feedin_qtyavailable  varchar(20)

DECLARE @feedin_canadianrestrictcode  int
DECLARE @feedin_canrestrictcode_old  int
DECLARE @feed_isbn  varchar (13)
DECLARE @feed_prepackind char(1) 
DECLARE @feedin_temp_isbn varchar(8)
DECLARE @feedin_isbn_prefix int
DECLARE @feedin_price_temp  numeric(9,2)
DECLARE @feedin_retailp numeric(9,2) 
DECLARE @feedin_canadianp numeric(9,2)
DECLARE @feedin_retailprice_old numeric(9,2) 
DECLARE @feedin_canadianprice_old numeric(9,2)
DECLARE @feedin_cartonqty1 int 
DECLARE @feedin_cartonqty_old int
DECLARE @feedin_pubtowebind   tinyint
DECLARE @titlehistory_newvalue varchar (100)
DECLARE @feedin_NCRcode  int
DECLARE @feedin_i_qtyavailable int
DECLARE @feedin_i_receivedwarehouseind int
DECLARE @feedin_opexhaustedind int

DECLARE @feedin_bisacstatus int
DECLARE @feedin_titlestatuscode_old int
DECLARE @feedin_bisacstatus_olddesc varchar(10)
DECLARE @feedin_pubstring  varchar(11)
DECLARE @feedin_bisacstatus_old int 
DECLARE @feedin_count int
DECLARE @feedin_count2 int
DECLARE @i_isbn int
DECLARE @feedin_tableid int
DECLARE @nextkey  int
DECLARE @eloquenceind tinyint
DECLARE @c_message  varchar(255)
DECLARE @edistatuscode int
DECLARE @v_customcode03 INT
DECLARE @i_neverpublishtoweb INT

SELECT @statusmessage = 'BEGIN VISTA FEED IN AT ' + convert (char,getdate())
print @statusmessage


SELECT @titlecount=0
SELECT @titlecountremainder=0
SELECT @feedin_NCRcode=0

SELECT @feed_system_date = getdate()


/* run titles feed from here */
insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Inserts',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values('3',@feed_system_date,'Feed Summary: Updates',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Rejected',0)

SELECT  @feedin_NCRcode = datacode
 FROM gentables
 WHERE tableid= 428 AND externalcode = 'NCR'

IF @feedin_NCRcode = 0 or @feedin_NCRcode IS NULL
BEGIN
	INSERT INTO feederror (isbn,batchnumber,processdate,errordesc)
		VALUES (@feedin_isbn,'3',@feed_system_date,'No Canadian Restriction with External code = NCR')
END


DECLARE feed_titles INSENSITIVE CURSOR FOR
	SELECT rtrim(ltrim (t.isbn)),rtrim(ltrim (bisacstatuscode)),rtrim(ltrim (retailprice)),rtrim(ltrim (canadianprice)),rtrim(ltrim (categorycode)),
			 rtrim(ltrim (cartonqty)),rtrim(ltrim (canadianrestriction)),rtrim(ltrim (projectisbn)),rtrim(ltrim (qtyavailable)),opexhaustedind
	  FROM feedin_titles t, isbn i
	 WHERE i.isbn10 = t.isbn AND t.isbn NOT IN(SELECT isbn FROM feedin_vista_exclude)
			 ORDER BY t.isbn FOR READ ONLY
		
OPEN feed_titles 

FETCH NEXT FROM feed_titles INTO @feedin_isbn,@feedin_bisacstatuscode,@feedin_retailprice,@feedin_canadianprice,@feedin_categorycode,
	@feedin_cartonqty,@feedin_canadianrestriction,@feedin_projectisbn,@feedin_qtyavailable,@feedin_opexhaustedind

SELECT @i_isbn  = @@FETCH_STATUS

IF @i_isbn <> 0 /*no isbn*/
BEGIN	
	INSERT INTO feederror (isbn,batchnumber,processdate,errordesc)
		VALUES (@feedin_isbn,'3',@feed_system_date,'NO ROWS to PROCESS')
END

WHILE (@i_isbn<>-1 )  /* status 1*/
BEGIN
	IF (@i_isbn<>-2) /* status 2*/
	BEGIN

		BEGIN tran 
		/** Increment Title Count, Print Status every 500 rows **/
		SELECT @titlecount=@titlecount + 1
		SELECT @titlecountremainder=0
		SELECT @titlecountremainder = @titlecount % 500

		IF(@titlecountremainder = 0)
		BEGIN
			SELECT @titlestatusmessage =  CONVERT(varchar (50),getdate()) + '   ' + CONVERT (varchar (10),@titlecount) + '   Rows Processed'
			PRINT @titlestatusmessage
			INSERT INTO feederror (isbn,batchnumber,processdate,errordesc)
				VALUES (@feedin_isbn,'3',@feed_system_date,@titlestatusmessage)
		END 
	
		SELECT @bookwasupdatedind = 0
		SELECT @feedin_bisacstatus = 0
		SELECT @feedin_count = 0
		SELECT @feedin_count2 = 0
		SELECT @feedin_isbn_prefix = 0
		SELECT @feedin_price_temp = 0
		SELECT @feedin_bookkey = 0
		SELECT @feedin_authorkey = 0
		SELECT @feedin_pubstring  =''
		SELECT @feed_isbn  = ''
		SELECT @feedin_temp_isbn = ''
		SELECT @feedin_price_temp = 0
		SELECT @feedin_canadianrestrictcode = 0
		SELECT @feedin_canrestrictcode_old = 0
		SELECT @feedin_bisacstatus_old = 0
		SELECT @feedin_retailp  = 0
		SELECT @feedin_canadianp  = 0
		SELECT @feedin_retailprice_old  = 0
		SELECT @feedin_canadianprice_old  = 0
		SELECT @feedin_cartonqty1  = 0
		SELECT @feedin_cartonqty_old  = 0
		SELECT @feedin_i_qtyavailable  = 0
		SELECT @feedin_i_receivedwarehouseind=0
	   SELECT @edistatuscode = 0
      SELECT @i_sendtoeloquence = 0
      SELECT @update_tmm_fields = 0
      SELECT @feedin_bisacstatus_olddesc = ''
      SELECT @v_customcode03 = 0
      SELECT @i_neverpublishtoweb = 0
	
		SELECT @feed_isbn = @feedin_isbn

		IF len(@feed_isbn) = 0 
	   BEGIN
			SELECT @feed_isbn = 'NO ISBN'
	
			INSERT INTO feederror (isbn,batchnumber,processdate,errordesc)
				VALUES  (RTRIM(@feedin_isbn),'3',@feed_system_date,('NO ISBN ENTERED ' + @feedin_isbn))
				
			UPDATE feederror 
				SET  detailtype = (detailtype + 1)
			 WHERE batchnumber='3'
				AND processdate > = @feed_system_date
				AND errordesc LIKE 'Feed Summary: Rejected%'
		 END	
	
		SELECT @feedin_bookkey = bookkey , @feed_isbn = isbn 
		 FROM isbn 
		WHERE isbn10= @feedin_isbn
	
		IF @feedin_bookkey = 0  
		BEGIN
			SELECT @feedin_bookkey = 0	/*new title title*/
			IF @feed_isbn <> 'NO ISBN' 
			BEGIN
				/* get isbn prefix code by stripping off values to the second '-'*/
				SELECT @feedin_count = 0
				SELECT @feedin_count = charindex('-', @feed_isbn)
				SELECT @feedin_count = @feedin_count - 1
				SELECT @feedin_temp_isbn = substring(@feed_isbn,1,@feedin_count)
		
				SELECT @feedin_isbn_prefix= datacode  
				  FROM gentables
				 WHERE datadesc = @feedin_temp_isbn AND tableid=138
			END
		END

		
		IF len(@feed_isbn) = 13 
		BEGIN
			/*------------- intialize data for new or old ---------*/
			/*bisacstatus*/
		
			SELECT @feedin_count = 0
	   
         IF @feedin_bisacstatuscode = 'OOS' 
         BEGIN
				SELECT @feedin_count = count(*)
				  FROM gentables
				 WHERE externalcode='ACT' AND tableid=314 
         END
         ELSE
         BEGIN
            SELECT @feedin_count = count(*)
				  FROM gentables
				 WHERE externalcode=@feedin_bisacstatuscode AND tableid=314 
         END
		
			IF @feedin_count > 0 
			BEGIN
            IF @feedin_bisacstatuscode = 'OOS' 
         	BEGIN
					SELECT @feedin_bisacstatus  = datacode
					  FROM gentables
					 WHERE externalcode='ACT' AND tableid=314 
            END
            ELSE
            BEGIN
					SELECT @feedin_bisacstatus  = datacode
					  FROM gentables
					 WHERE externalcode=@feedin_bisacstatuscode 	AND tableid=314 
            END
        	END
         ELSE
			BEGIN
				INSERT INTO feederror (isbn,batchnumber,processdate,errordesc)
				 VALUES  (@feedin_isbn, '3',@feed_system_date,('BISAC STATUS NOT ON GENTABLES; BISAC STATUS NOT UPDATED ' + @feedin_bisacstatuscode))
			END 
						
			/* prices*/
			IF len(@feedin_retailprice) > 0 
			BEGIN
				SELECT @feedin_price_temp = convert(float,@feedin_retailprice)

				IF @feedin_price_temp >0 
				BEGIN
					SELECT @feedin_retailp  = @feedin_price_temp
				END
				ELSE 	
				BEGIN 
				  SELECT @feedin_retailp = 0
				END 
			END 
		
			SELECT @feedin_price_temp = 0
		
			IF len(@feedin_canadianprice) > 0 
			BEGIN
				SELECT @feedin_price_temp = convert(float,@feedin_canadianprice)

				IF @feedin_price_temp >0 
				BEGIN
					SELECT @feedin_canadianp   = @feedin_price_temp
				END 
				ELSE 
				BEGIN
				  SELECT @feedin_canadianp = 0
				END 
			END
		
			/* canadian restrictionrictions*/
			SELECT @feedin_count = 0
				
			IF len(@feedin_canadianrestriction) > 0 
			BEGIN
				SELECT @feedin_count = count(*)
				  FROM gentables
				 WHERE tableid = 428 AND externalcode = convert(char,@feedin_canadianrestriction)	
		
				IF @feedin_count > 0 
				BEGIN
					SELECT  @feedin_canadianrestrictcode = datacode
					  FROM gentables
					 WHERE tableid= 428 AND  externalcode = convert(char,@feedin_canadianrestriction)
				END
				ELSE  
				BEGIN	
					SELECT @feedin_tableid = 428
					SELECT @feedin_canadianrestriction = @feedin_canadianrestriction
					EXEC feed_insert_gentables @feedin_tableid,@feedin_canadianrestriction, @feedin_canadianrestrictcode  OUTPUT
				END 
			END

         /* Check whether title should feed to Eloquence  */
         /* The Vista Feed should never override or change a field that will cause it to feed to Eloquence once the Never Send to Eloquence */
         /* checkbox is checked */
			SELECT 	@feedin_count = 0 
		
			SELECT @feedin_count = count(*) FROM bookedipartner
				WHERE bookkey =@feedin_bookkey
		
			IF @feedin_count > 0 
			BEGIN
				SELECT @edistatuscode = edistatuscode
				  FROM bookedistatus
				 WHERE bookkey =@feedin_bookkey
				
				/** Do not SEND to eloquence IF edistatuscode = 7 (Do Not Send) or 8 (Never Send)  **/
            /** 1 Not sent 6 - Delete **/
				IF (@edistatuscode in (0,1,6,7,8))   
				BEGIN
					SELECT @i_sendtoeloquence = 0
            END
				ELSE
            BEGIN
             	SELECT @i_sendtoeloquence = 1 
            END
         END
         ELSE
         BEGIN
         	SELECT @i_sendtoeloquence = 0
         END
          
         SELECT @update_tmm_fields = 0	
			
			/* --------------start updating existing title  record ------------*/					
			IF @feedin_bookkey > 0 
			BEGIN
				/* ------------------start updating tables------------------*/
				IF @feedin_bisacstatus > 0 
				BEGIN
					SELECT @feedin_bisacstatus_old = bisacstatuscode 
					FROM bookdetail b
					WHERE b.bookkey=@feedin_bookkey
					
					IF @feedin_bisacstatus_old is null
					BEGIN
						SELECT @feedin_bisacstatus_old = 0
					END

               IF  @feedin_bisacstatus_old > 0
               BEGIN
						SELECT @feedin_count = count(*)
						  FROM gentables
						 WHERE datacode=@feedin_bisacstatus_old AND tableid=314 
					
						IF @feedin_count > 0 
						BEGIN
							SELECT @feedin_bisacstatus_olddesc  = datadesc
							  FROM gentables
							 WHERE datacode=@feedin_bisacstatus_old 	AND tableid=314 
						END
					END

					/** UPDATE Bisac Status only IF value is different **/

					/**********************UPDATE titles that are ACTIVE ***************/
					/** Certain fields are updated only IF they are ACTIVE  **/
					
					/** Modified 2/42004 by DSL - Out of Print when exhausted is now treated as a ****/
					/** distinct Bisac Status in addition to the OP Exhausted Ind on custom fields ***/
					/** OPE is essentially an ACTIVE Title, therefore we want to continue to maintain */
					/** Prices, etc. Added OPE condition to IF statement immediately following     ***/
					IF (@feedin_bisacstatus <> @feedin_bisacstatus_old) OR (@feedin_bisacstatus = 1 AND @feedin_bisacstatus_old = 1)
					BEGIN
                  /****** Check whether update to TMM fields should happen  *****/
                  /*** Only following fields will be update by the feed:
                       US Price, Canadian Price, Bisac status, Carton Qty, Vista Quantity Available ****/ 
                  /*** Pub Date Release Date and Canadian restriction should not be updated by feed*****/
                  /**** 8/27/08 KB  ***/
                  /** The feed will only update titles that have a Vista Anscode of OOS or OPE ***/
                  /** When a title changes from active (OOS or OPE) to OP or OSI for the first time - ***/
                  /**  - in TMM the bisacstatuscode would be ACT per Rob -  the title should feed to TMM  ***/
                  /** Titles with a Vista Anscode of NYC, PC or PO do not feed to TMM **/
                  /**IF @feedin_bisacstatuscode IN ('OOS','OPE','ACT') 
                     OR (@feedin_bisacstatuscode IN ('OP','OSI') AND @feedin_bisacstatus_olddesc = 'ACT')
                  BEGIN
                  	SELECT @update_tmm_fields = 1
                  END
                  ELSE
                  BEGIN
							IF (@feedin_bisacstatuscode IN ('NYP' , 'PC' , 'OP'))  
                    		SELECT @update_tmm_fields = 0
                  END **/
						/** 2/6/2009 KB Modified to reflect procedure at client site for change made by Rob Stevens - per request by Adria ****/
						IF @feedin_bisacstatuscode IN ('OOS','OPE','ACT') 
                     OR (@feedin_bisacstatuscode IN ('OP','OSI') AND @feedin_bisacstatus_olddesc = 'ACT')
                     OR (@feedin_bisacstatuscode = 'NL' AND @feedin_bisacstatus_olddesc <>'NL')
                  BEGIN
                     SELECT @update_tmm_fields = 1
                  END
                  ELSE
                  BEGIN
                     SELECT @update_tmm_fields = 0
						END
                
                  IF @update_tmm_fields = 1
                  BEGIN
							SELECT @bookwasupdatedind = 1
							
							/** If Vista code =  'OOS' then opexhaustedind = 0 hence TMM bisacstatus = 'ACT'   **/
                     /** If Vista code =  'OPE' then opexhaustedind = 1 hence TMM bisacstatus = 'OPE'   **/
                     /** If Vista code =  'OP' (opexhaustedind = 0)  TMM bisacstatus = 'OP'   **/
                     /** If Vista code =  'OSI' ( opexhaustedind = 0)  TMM bisacstatus = 'OSI'   **/
                     IF (@feedin_bisacstatus <> @feedin_bisacstatus_old) 
							BEGIN
															
								SELECT @titlehistory_newvalue=NULL
								SELECT @titlehistory_newvalue = convert (char (100),@feedin_bisacstatus)

								EXEC dbo.titlehistory_insert 4,@feedin_bookkey,0,'',@titlehistory_newvalue

								UPDATE bookdetail
									SET bisacstatuscode = @feedin_bisacstatus,lastuserid='VISTAFEED',lastmaintdate=@feed_system_date
								 WHERE bookkey = @feedin_bookkey
                     END
                   END /** update tmm fields  **/
    				END /** if bisacstatuscode has changed ***/
				  END /** Bisacstatus > 0 **/
						
				  /*Quantity Available AND ReceivedWarehouse*/
				  IF len(@feedin_qtyavailable) > 0 
				  BEGIN
					SELECT @feedin_i_qtyavailable = convert(int,@feedin_qtyavailable)
				  END
				  ELSE
				  BEGIN
					SELECT @feedin_i_qtyavailable = 0
				  END
		
              IF @update_tmm_fields = 1
              BEGIN
					  IF  @feedin_i_qtyavailable  > 0 
					  BEGIN
						SELECT @feedin_i_receivedwarehouseind=1
						SELECT @feedin_count = 0
			
						SELECT @feedin_count = count (*) 
						  FROM bookcustom
						 WHERE bookkey = @feedin_bookkey
								
						IF @feedin_count>0 
						BEGIN
							/* Don't SET  Bookupdate flag - we don't want to resend every title */
							/* to eloquence due to a Qty Available change */
							UPDATE bookcustom
								SET customint01 = @feedin_i_qtyavailable,
									 customind08 = @feedin_i_receivedwarehouseind,
									 lastuserid = 'VISTAFEED',
									 lastmaintdate = @feed_system_date
							 WHERE bookkey = @feedin_bookkey
						END
						ELSE
						BEGIN
							/* Don't SET  Bookupdate flag - we don't want to resend every title */
							/* to eloquence due to a Qty Available change */
							INSERT INTO bookcustom (bookkey,customint01,customind08,lastuserid,lastmaintdate)
							 VALUES (@feedin_bookkey,@feedin_i_qtyavailable,@feedin_i_receivedwarehouseind,'VISTAFEED',@feed_system_date)
						 END
					  END /** IF feedin_qtyavailable>0 **/
              END
		
				  /** OP When Exhausted Indicator **/
              IF @update_tmm_fields = 1
              BEGIN
					  IF  @feedin_opexhaustedind IS NOT NULL
					  BEGIN
							SELECT @feedin_count = count (*) 
							  FROM bookcustom
							 WHERE bookkey = @feedin_bookkey
							
							IF @feedin_count>0 
							BEGIN
								UPDATE bookcustom
									SET  customind09 = @feedin_opexhaustedind,lastuserid = 'VISTAFEED',lastmaintdate = @feed_system_date
								 WHERE bookkey = @feedin_bookkey
							END
							ELSE
							BEGIN
								INSERT INTO bookcustom (bookkey,customind09,lastuserid,lastmaintdate)
								 VALUES (@feedin_bookkey,@feedin_opexhaustedind,'VISTAFEED',@feed_system_date)
							END
					  END /** IF feedin_opexhaustedind is not null **/
              END

	
				  /*cartonqty*/
              IF @update_tmm_fields = 1
              BEGIN 
					  IF len(@feedin_cartonqty) > 0 
					  BEGIN
						SELECT @feedin_cartonqty1 = convert(int,@feedin_cartonqty)
					  END
					  ELSE
					  BEGIN
						SELECT @feedin_cartonqty1 = 0
					  END
			
					  IF  @feedin_cartonqty1  > 0 
					  BEGIN
						SELECT @feedin_count = 0
			
						SELECT @feedin_count = count (*) 
						  FROM bindingspecs
						 WHERE bookkey = @feedin_bookkey AND printingkey=1
			
						IF @feedin_count>0 
						BEGIN
							SELECT @feedin_cartonqty_old = cartonqty1 
							  FROM bindingspecs
							 WHERE bookkey = @feedin_bookkey AND printingkey=1
							
							IF @feedin_cartonqty_old is null
							BEGIN
								SELECT @feedin_cartonqty_old = 0
							END
			
							/** IF Carton Qty is updated, then UPDATE bindingspecs **/
							/** Modified 6/12 by DSL Now updates ALL printings **/
							IF @feedin_cartonqty1 <> @feedin_cartonqty_old
							BEGIN
								EXEC dbo.titlehistory_insert 89,@feedin_bookkey,0,'',@feedin_cartonqty1
								
								SELECT @bookwasupdatedind = 1
								
								UPDATE bindingspecs
									SET  cartonqty1 = @feedin_cartonqty1,lastuserid='VISTAFEED',lastmaintdate = @feed_system_date
								 WHERE bookkey = @feedin_bookkey
							END
						END
						ELSE
						BEGIN
							EXEC dbo.titlehistory_insert 89,@feedin_bookkey,0,'',@feedin_cartonqty1
							
							SELECT @bookwasupdatedind=1
			
							INSERT INTO bindingspecs (bookkey,printingkey,vendorkey,cartonqty1)
							 VALUES (@feedin_bookkey,1,0,@feedin_cartonqty1)
						END
					 END /** IF feedin_cartonqty1>0 **/
            END  /* if update tmm fields  */
		
			
            IF @update_tmm_fields = 1
				BEGIN
					/*retail price*/
					IF @feedin_retailp > 0 
					BEGIN
						SELECT @feedin_count = 0   /* list price code is datacode 8, per doug*/
					
						SELECT @feedin_count = count(*)
						  FROM bookprice
						 WHERE bookkey=@feedin_bookkey AND currencytypecode=6 AND pricetypecode=8
		
						IF @feedin_count > 0 
						BEGIN
								
							SELECT @feedin_retailprice_old = finalprice
								FROM bookprice
								WHERE bookkey=@feedin_bookkey AND currencytypecode=6 AND pricetypecode=8
								
							IF @feedin_retailp <> @feedin_retailprice_old
							BEGIN
								EXEC dbo.titlehistory_insert 9,@feedin_bookkey,0,'6',@feedin_retailprice
								
								SELECT @bookwasupdatedind=1
															
								UPDATE bookprice
									SET finalprice = @feedin_retailp,  
										 lastuserid='VISTAFEED',
										 lastmaintdate = @feed_system_date
								 WHERE bookkey=@feedin_bookkey AND currencytypecode=6 AND pricetypecode=8
							END
					   END /** if feedin_count > 0 **/
               	ELSE /** No Retail price row on bookprice, so insert **/
						BEGIN
							EXEC dbo.titlehistory_insert 9,@feedin_bookkey,0,'6',@feedin_retailprice
							
							SELECT @bookwasupdatedind=1
				
							UPDATE keys 
								SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()
				
							SELECT @nextkey = generickey FROM Keys
												
							INSERT INTO bookprice  (pricekey,bookkey,pricetypecode,currencytypecode,activeind,finalprice,effectivedate,lastuserid,lastmaintdate)
							  VALUES (@nextkey,@feedin_bookkey,8,6,1,@feedin_retailp,@feed_system_date,'VISTAFEED',@feed_system_date)
						END
					END   /*retail price*/
	
					/*canada*/
               /*Do not update canadian price if canadianrestriction is "NCR' */
               /* Do not create canadian price row if TMM does not have row even if Vista has a canadian price*/
					IF (@feedin_canadianrestrictcode <> @feedin_NCRcode) AND (@feedin_canrestrictcode_old <> @feedin_NCRcode)
					BEGIN
						IF @feedin_canadianp > 0 
						BEGIN
							SELECT @feedin_count = 0
	
							SELECT @feedin_count = count(*)
							  FROM bookprice
							 WHERE bookkey=@feedin_bookkey AND currencytypecode=11 AND pricetypecode=8
								
							/** Check to see IF Canadian Price exists **/
							IF @feedin_count>0  
							BEGIN
								SELECT @feedin_canadianprice_old = finalprice
								  FROM bookprice
								 WHERE bookkey=@feedin_bookkey AND currencytypecode=11 AND pricetypecode=8

								/** Only UPDATE IF price is different **/
								IF @feedin_canadianp <> @feedin_canadianprice_old
								BEGIN

									EXEC dbo.titlehistory_insert 9,@feedin_bookkey,0,'11',@feedin_canadianprice

									SELECT @bookwasupdatedind=1
												
									UPDATE bookprice
										SET finalprice = @feedin_canadianp,lastuserid='VISTAFEED',lastmaintdate = @feed_system_date
									 WHERE bookkey= @feedin_bookkey AND currencytypecode=11 AND pricetypecode=8
								END
							END
						  END /* feed in canadian price > 0 */
					 END /* NOT NCR */
				 END /* update TMM Fields = 1*/

			END   /* END bookkey > 0*/
				
			/* new title ----------------------------------------------------------*/
			IF @feedin_bookkey = 0 
			BEGIN  
				UPDATE feederror 
					SET detailtype = (detailtype + 1)
				 WHERE batchnumber='3' AND processdate >= @feed_system_date AND errordesc LIKE 'Feed Summary: Rejected%'
			END /* bookkey =0 new title */

		END  /* ISBN Record*/
		
		IF @bookwasupdatedind=1 /** Output the Necessary UPDATE Flags**/
		BEGIN
			UPDATE feederror 
			   SET detailtype = detailtype + 1
			 WHERE batchnumber='3' AND processdate >= @feed_system_date AND errordesc LIKE 'Feed Summary: Updates%'
		
			/** Datawarehouse UPDATE **/
			/*** 08/26/08 - KB - The update to bookedipartner and insert to bookwhupdate is done by the called procedure dbo.titlehistory_insert
			SELECT  @feedin_count = count(*) 
			FROM bookwhUPDATE 
			WHERE bookkey = @feedin_bookkey
		
			IF @feedin_count = 0 
			BEGIN
				INSERT INTO bookwhUPDATE (bookkey,lastmaintdate,lastuserid)
				 VALUES (@feedin_bookkey,getdate(),'VISTAFEED')
			END
				
         IF @i_sendtoeloquence = 1 
         BEGIN
				UPDATE bookedipartner 
					SET sendtoeloquenceind=1,lastuserid='VISTAFEED',lastmaintdate = @feed_system_date
				 WHERE bookkey=@feedin_bookkey
			END  ***/
		END 
		commit tran
	END /*isbn status 2*/
	
	FETCH NEXT FROM feed_titles INTO @feedin_isbn,@feedin_bisacstatuscode,@feedin_retailprice,@feedin_canadianprice,@feedin_categorycode,
		@feedin_cartonqty,@feedin_canadianrestriction,@feedin_projectisbn,@feedin_qtyavailable,@feedin_opexhaustedind
	
	SELECT @i_isbn  = @@FETCH_STATUS
END /*isbn status 1*/

/*  delete when complete since looping through cursor undo comment once finish testing*/
/* DELETE FROM feedin_titles*/

INSERT INTO feederror (batchnumber,processdate,errordesc)
 	VALUES ('3',@feed_system_date,'Titles Completed')

CLOSE feed_titles
deallocate feed_titles

SELECT @statusmessage = 'END VISTA FEED IN AT ' + convert (char,getdate())
print @statusmessage

return 0

GO

SET  QUOTED_IDENTIFIER OFF 
GO
SET  ANSI_NULLS ON 
