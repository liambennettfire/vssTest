if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_price_validate_activeindanddates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_price_validate_activeindanddates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_price_validate_activeindanddates
 (@i_bookkey     integer,
  @i_messagetype integer,
  @i_validatetype integer,
  @o_error_code               integer       output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_price_validate_activeindanddates
**  Desc: This validates the prices
**	NOTE! THERE IS A SECOND VERSION OF THIS PROCEDURE IN THE C# CODE (PricesEdit.ascx.cs).
**		Important changes should be made in both places!
**           
**
**    Auth: Kusum Basra
**    Date: 4 August 2011
*******************************************************************************/

	 SET @o_error_code = 0
	 SET @o_error_desc = ''

	 DECLARE @v_error_code INT
	 DECLARE @v_error_desc varchar(2000)
	 DECLARE @v_error_msg varchar(200)
	 DECLARE @error_var    INT
	 DECLARE @rowcount_var INT
	 DECLARE @v_count	INT
	 DECLARE @v_count2	INT
	 DECLARE @v_count3	INT
	 DECLARE @v_count_rows INT
	 DECLARE @v_pricekey	INT
	 DECLARE @v_saved_pricekey	INT
	 DECLARE @v_pricetypecode	INT
	 DECLARE @v_currencytypecode	INT
	 DECLARE @v_pricetypedesc varchar(40)
	 DECLARE @v_currencytypedesc  varchar(40)
	 DECLARE @v_gen2ind 	INT
	 DECLARE @v_optionvalue	INT
	 DECLARE @v_activeind	INT
	 DECLARE @v_effectivedate	datetime
	 DECLARE @v_expirationdate	datetime
	 DECLARE @v_saved_effectivedate datetime
	 DECLARE @v_saved_expirationdate datetime	
	 DECLARE @v_productnumber varchar(30)
	 DECLARE @v_title varchar(255)
	 DECLARE @v_historyorder INT
	 DECLARE @v_saved_historyorder	INT
	 DECLARE @v_saved_pricetypecode INT
     DECLARE @v_saved_currencytypecode	INT
	 DECLARE @v_row_count INT
	 DECLARE @v_more_than_one_active_price	INT

	SELECT @v_count = count(*)
	  FROM clientoptions
	 WHERE optionid = 99

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to determine value of clientoption 99 (Auto Set Price Active Ind)' 
      return
    END 

    IF @v_count = 0 BEGIN
	  SET @o_error_code = -1
      SET @o_error_desc = 'Unable to determine value of clientoption 99 (Auto Set Price Active Ind)' 
      return
    END 
    ELSE BEGIN
		  SELECT @v_optionvalue = optionvalue
		    FROM clientoptions
	     WHERE optionid = 99

			--only run procedure if optionvalue = 1
		  IF @v_optionvalue = 0 BEGIN
		   SET @o_error_code = 1
		    SET @o_error_desc = 'Value of clientoption 99 (Auto Set Price Active Ind)is set to 0' 
		    return
		  END
      IF @v_optionvalue = 2 BEGIN
		    SET @o_error_code = 1
		    SET @o_error_desc = 'Value of clientoption 99 (Auto Set Price Active Ind)is set to 2' 
		    return
		  END
    END

	  IF @i_bookkey > 0 BEGIN
       ---- IF @i_validate_type = 1 BEGIN
			SET @v_count = 0

			SELECT @v_count = count(*)
			  FROM bookprice
			 WHERE bookkey = @i_bookkey

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Unable to retrieve bookprice rows for: bookkey = ' + cast(@i_bookkey AS VARCHAR)
			  return
			END 

			IF @v_count > 0 BEGIN
				DECLARE cur_related_bookprice_rows CURSOR FOR
					SELECT p.pricekey,p.pricetypecode, p.currencytypecode,p.activeind,p.expirationdate,p.effectivedate,p.history_order
					  FROM bookprice p
					  LEFT OUTER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306
					 WHERE bookkey = @i_bookkey
					   AND activeind = 1
					ORDER BY p.pricetypecode,p.currencytypecode,p.pricekey
					
				OPEN cur_related_bookprice_rows
					
				FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricekey,@v_pricetypecode,@v_currencytypecode,@v_activeind,@v_expirationdate,@v_effectivedate,@v_historyorder

				SET @v_count2 = 0
				SET @v_more_than_one_active_price = 0
				SET @v_saved_effectivedate = NULL
				SET @v_saved_expirationdate = NULL
				SET @v_saved_pricetypecode = @v_pricetypecode
				SET @v_saved_currencytypecode = @v_currencytypecode

				WHILE (@@FETCH_STATUS <> -1)
				BEGIN
--print '@v_pricetypecode'
--print @v_pricetypecode
--print '@v_currencytypecode'
--print @v_currencytypecode
					SELECT @v_count2 = count(*)
					  FROM bookprice
					 WHERE bookkey = @i_bookkey
					   AND pricetypecode = @v_pricetypecode
					   AND currencytypecode = @v_currencytypecode
             AND activeind = 1
--print '@v_count2'
--print @v_count2
					IF @v_count2 = 2
					BEGIN
--print '@v_count2'
--print @v_count2
						SET @v_saved_effectivedate = @v_effectivedate
						SET @v_saved_expirationdate = @v_expirationdate
						SET @v_saved_pricekey = @v_pricekey
						SET @v_saved_historyorder = @v_historyorder	
--print '@v_saved_effectivedate'
--print @v_saved_effectivedate
--print '@v_saved_expirationdate'
--print @v_saved_expirationdate
--print '@v_saved_pricekey'
--print @v_saved_pricekey
---print @v_saved_historyorder

						FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricekey,@v_pricetypecode,@v_currencytypecode,@v_activeind,@v_expirationdate,@v_effectivedate,@v_historyorder
--print '@v_effectivedate'
--print @v_effectivedate
--print '@v_expirationdate'
--print @v_expirationdate
--print '@v_pricekey'
--print @v_pricekey
---print @v_historyorder
						IF (((@v_saved_effectivedate IS NOT NULL AND @v_expirationdate IS NOT NULL AND @v_saved_effectivedate = @v_expirationdate) OR (@v_saved_effectivedate IS NOT NULL AND @v_expirationdate IS NULL))
								OR ((@v_saved_expirationdate IS NOT NULL AND @v_effectivedate IS NOT NULL AND @v_saved_expirationdate = @v_effectivedate)) OR (@v_saved_expirationdate IS NOT NULL AND  @v_effectivedate IS NULL ))
						BEGIN
                            SET @v_more_than_one_active_price = 0
							IF (@v_expirationdate IS NULL AND @v_saved_expirationdate IS NOT NULL) OR @v_expirationdate < @v_saved_expirationdate BEGIN
--print 'update 1'							     
								UPDATE bookprice
									SET activeind = 0,lastuserid='Verify Active Procedure',lastmaintdate = getdate()
								  WHERE bookkey = @i_bookkey
								    AND pricekey = @v_pricekey
									AND pricetypecode = @v_pricetypecode
									AND currencytypecode = @v_currencytypecode
									AND expirationdate = @v_expirationdate
								
								SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
 								SELECT @v_pricetypedesc = @v_pricetypedesc + ' Active Ind'
								
								EXEC dbo.qtitle_update_titlehistory 'bookprice', 'activeind', @i_bookkey, 1, 0, 'N',
								'update', 'Verify Active Procedure', @v_historyorder,@v_pricetypedesc, @o_error_code output, @o_error_desc output
	
							END
							IF (@v_expirationdate IS NULL AND @v_saved_expirationdate IS NOT NULL) OR @v_saved_expirationdate < @v_expirationdate BEGIN
--print 'update 2'
								UPDATE bookprice
									SET activeind = 0,lastuserid='Verify Active Procedure',lastmaintdate=getdate()
								  WHERE bookkey = @i_bookkey
								    AND pricekey = @v_saved_pricekey
									AND pricetypecode = @v_pricetypecode
									AND currencytypecode = @v_currencytypecode
									AND expirationdate = @v_saved_expirationdate
									
								SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
								SELECT @v_pricetypedesc = @v_pricetypedesc + ' Active Ind'
								
								EXEC dbo.qtitle_update_titlehistory 'bookprice', 'activeind', @i_bookkey, 1, 0, 'N',
								'update', 'Verify Active Procedure', @v_saved_historyorder, @v_pricetypedesc, @o_error_code output, @o_error_desc output
	
							END
						END
						ELSE BEGIN
							SET @v_more_than_one_active_price = 1
						END
					END
--print '@v_more_than_one_active_price'
--print @v_more_than_one_active_price
					IF (@v_count2 > 2) OR (@v_more_than_one_active_price = 1)
					BEGIN
						SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
           				SELECT @v_currencytypedesc = dbo.get_gentables_desc(122,@v_currencytypecode,'long')
						SET @o_error_code = -1
						
						SELECT @v_productnumber = productnumber, @v_title = title
						  FROM coretitleinfo
						 WHERE bookkey = @i_bookkey
						   AND printingkey = 1
						
						IF @i_messagetype = 1 BEGIN
							IF @o_error_desc = ' ' BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = @v_title + ', ' + @v_productnumber + ', has more than one active price for ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
--print @o_error_code
--print @o_error_desc

						END
						ELSE BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = @o_error_desc + ' and more than one active price for ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
--print @o_error_desc
--print @o_error_code

						END
					END
					ELSE BEGIN
						IF @o_error_desc = ' ' BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = 'More than one active price exists for ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
--print @o_error_desc
--print @o_error_code

						END
					    ELSE BEGIN
						    SET @o_error_code = -1
							SET @o_error_desc = @o_error_desc + ' and more than one active price exists for ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
--print @o_error_desc
--print @o_error_code

						END
					END
					IF @v_count2 > 0 BEGIN
					  SET @v_row_count = 0
					  WHILE @v_row_count <= (@v_count2 - 1)
					  BEGIN
	--print '@v_row_count'
	--print @v_row_count
					  	  FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricekey,@v_pricetypecode,@v_currencytypecode,@v_activeind,@v_expirationdate,@v_effectivedate,@v_historyorder
						  SET @v_row_count = @v_row_count + 1
	--print '@v_pricetypecode'
	--print @v_pricetypecode
	--print '@v_currencytypecode'
	--print @v_currencytypecode
						END
					END
				END
					--IF @v_count2 = 1 BEGIN
--print '@v_count2'
--print '@v_count'
				FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricekey,@v_pricetypecode,@v_currencytypecode,@v_activeind,@v_expirationdate,@v_effectivedate,@v_historyorder
--print '@v_pricetypecode'
--print @v_pricetypecode
--print '@v_currencytypecode'
--print @v_currencytypecode
	---				END

			END -- end of while fetch_status <> - 1
			CLOSE cur_related_bookprice_rows 
      		DEALLOCATE cur_related_bookprice_rows
			IF @o_error_code = -1 BEGIN
				SET @o_error_desc = @o_error_desc + '.'
--print '@o_error_desc before close'
--print @o_error_desc
				IF @i_validatetype = 1 BEGIN
      				RETURN
				 END
			END
		END -- bookprice rows greater > 0 
		---END -- validate type = 1
		IF @i_validatetype = 2 BEGIN
			SET @v_count = 0
--			SET @o_error_code = 0
--			SET @o_error_desc = ''

			SELECT @v_count = count(*)
			  FROM bookprice
			 WHERE bookkey = @i_bookkey

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Unable to retrieve bookprice rows for: bookkey = ' + cast(@i_bookkey AS VARCHAR)
			  return
			END 

			IF @v_count > 0 BEGIN
				DECLARE cur_related_bookprice_rows CURSOR FOR
					SELECT p.pricekey, p.pricetypecode, p.currencytypecode,p.activeind,p.expirationdate,p.effectivedate
					  FROM bookprice p
					  LEFT OUTER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306
					 WHERE bookkey = @i_bookkey
					ORDER BY p.pricetypecode, p.currencytypecode, p.pricekey
					
				OPEN cur_related_bookprice_rows
					
				FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricekey,@v_pricetypecode,@v_currencytypecode,@v_activeind,@v_expirationdate,@v_effectivedate

				SET @v_count2 = 0
				SET @v_saved_effectivedate = NULL
				SET @v_saved_expirationdate = NULL
				SET @v_saved_pricetypecode = @v_pricetypecode
				SET @v_saved_currencytypecode = @v_currencytypecode
--print '@v_count2 for type 2'
--print @v_count2
--print '@v_pricetypecode'
--print @v_pricetypecode
--print '@v_currencytypecode'
--print @v_currencytypecode
				WHILE (@@FETCH_STATUS <> -1)
				BEGIN
					SELECT @v_count2 = count(*)
					  FROM bookprice
					 WHERE bookkey = @i_bookkey
					   AND pricetypecode = @v_pricetypecode
					   AND currencytypecode = @v_currencytypecode
--print '@v_count2'
--print @v_count2
					IF @v_count2 > 1
					BEGIN
						SET @v_saved_effectivedate = @v_effectivedate
						SET @v_saved_expirationdate = @v_expirationdate	
--print 'pricekey'						SET @v_saved_pricekey = @v_pricekey
--print @v_pricekey
--print @v_effectivedate
--print @v_expirationdate					
						SET @v_row_count = 0
						WHILE @v_row_count <= (@v_count2 - 1)
						BEGIN
						  SET @v_count3 = 0
						  
						  SELECT @v_count3 = count(*)
						    FROM bookprice
						   WHERE pricekey > @v_pricekey
                             AND bookkey = @i_bookkey
						     AND pricetypecode = @v_pricetypecode
						     AND currencytypecode = @v_currencytypecode
						     AND ((@v_effectivedate >= effectivedate AND @v_effectivedate <= expirationdate)
						          OR (@v_expirationdate >= effectivedate AND @v_expirationdate <= expirationdate))

--print '@v_count3'						     
--print @v_count3				  
						  IF @v_count3 > 0 BEGIN
							
							SELECT @v_pricetypedesc = dbo.get_gentables_desc(306,@v_pricetypecode,'short')
							SELECT @v_currencytypedesc = dbo.get_gentables_desc(122,@v_currencytypecode,'long')
							---EXEC gentables_longdesc 122,@v_currencytypecode,@v_currencytypedesc OUTPUT
							SET @o_error_code = -1
							
							SELECT @v_productnumber = productnumber, @v_title = title
							  FROM coretitleinfo
							 WHERE bookkey = @i_bookkey
							   AND printingkey = 1
							
							IF @i_messagetype = 1 BEGIN
								IF @o_error_desc = ' ' BEGIN
									SET @o_error_code = -1
									SET @o_error_desc = @v_title + ', ' + @v_productnumber + ', has effective and expiration dates that overlap for ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
--print @o_error_desc
--print @o_error_code
								END
								ELSE BEGIN
									SET @o_error_code = -1
									SET @o_error_desc = @o_error_desc + ' and has effective and expiration dates that overlap for ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
	--print @o_error_desc
	--print @o_error_code
								END
							END
							ELSE BEGIN
								IF @o_error_desc = ' ' BEGIN
									SET @o_error_code = -1
									SET @o_error_desc = 'Effective and expiration dates exist that overlap for  ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
--print @o_error_desc
--print @o_error_code
								END
								ELSE BEGIN
									SET @o_error_code = -1
									SET @o_error_desc = @o_error_desc + '  and effective and expiration dates that overlap for ' + @v_pricetypedesc + '/' + @v_currencytypedesc 
--print @o_error_desc
--print @o_error_code
								END
							END
						  END
						  FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricekey,@v_pricetypecode,@v_currencytypecode,@v_activeind,@v_expirationdate,@v_effectivedate
--print '@v_pricetypecode - x'
--print @v_pricetypecode
--print '@v_currencytypecode'
--print @v_currencytypecode
						  SET @v_row_count = @v_row_count + 1
						END
					END --@v_count2 > 1
					ELSE BEGIN
						FETCH NEXT FROM cur_related_bookprice_rows INTO @v_pricekey,@v_pricetypecode,@v_currencytypecode,@v_activeind,@v_expirationdate,@v_effectivedate
--print '@v_pricetypecode - y'
--print @v_pricetypecode
--print '@v_currencytypecode'
--print @v_currencytypecode
					END
				END -- end of while fetch_status <> - 1
				CLOSE cur_related_bookprice_rows 
      			DEALLOCATE cur_related_bookprice_rows
--print '@o_error_code - final'
--print @o_error_code
				IF @o_error_code = -1 BEGIN
					SET @o_error_desc = @o_error_desc + '.'
--print @o_error_desc
				END
      			RETURN
     END -- bookprice rows greater > 0 
	END  -- validate type = 2
END  --bookkey > 0
GO

  

GRANT EXEC ON dbo.qtitle_price_validate_activeindanddates TO PUBLIC
GO