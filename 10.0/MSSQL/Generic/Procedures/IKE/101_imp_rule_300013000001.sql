SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Name: imp_rule_ext_300013000001
**  Desc: IKE book price update
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_rule_ext_300013000001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_rule_ext_300013000001]
GO

CREATE PROCEDURE dbo.imp_rule_ext_300013000001 (
	@i_batch INT
	,@v_bookkey INT
	,@v_new_price FLOAT
	,@v_newtitleind INT
	,@v_pricetypecode INT
	,@v_currencytypecode INT
	,@v_destinationcolumn VARCHAR(100)
	,@v_effdate DATETIME
	,@i_userid VARCHAR(30)
	)
AS
DECLARE @v_cur_price FLOAT
	,@v_hit INT
	,@v_newkey INT
	,@v_sortorder INT
	,@v_price_maint VARCHAR(100)
	,@v_errcode INT
	,@o_writehistoryind INT
	,@i_currentstringvalue VARCHAR(255)
	,@o_history_order INT
	,@o_error_code INT
	,@o_error_desc VARCHAR(2000)
	,@Debug as int
	,@v_currencytypedatadesc varchar(255)	

BEGIN

	if @v_currencytypecode is null 
	BEGIN
		PRINT 'Null @v_currencytypecode no update'
		RETURN
	END
	if @v_pricetypecode is null 
	BEGIN
		PRINT 'Null @v_pricetypecode no update'
		RETURN
	END
	if @v_new_price is null  
	BEGIN
		PRINT 'Null @v_new_price no update'
		RETURN
	END
	if @v_new_price=0  
	BEGIN
		PRINT '@v_new_price=0 no update'
		RETURN
	END
 

	SET @Debug=0
	IF @Debug=1 PRINT 'IN .... PROCEDURE dbo.imp_rule_ext_300013000001'

	SET @v_hit = 0
	SET @v_newkey = 0
	SET @v_sortorder = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_price_maint = NULL

	IF COALESCE(@v_effdate, '') = ''
		SET @v_effdate = GETDATE()

	SELECT @v_hit = COUNT(*)
	FROM bookprice
	WHERE pricetypecode = @v_pricetypecode
		AND currencytypecode = @v_currencytypecode
		AND bookkey = @v_bookkey
		AND activeind = 1

	--mk20140219> Fixed this because it gave a warning "Warning: Null value is eliminated by an aggregate or other SET operation." when sort order is null
	--SELECT @v_sortorder = COALESCE(MAX(sortorder), 0) + 1
	SELECT @v_sortorder = MAX(COALESCE(sortorder,0)) + 1
	FROM bookprice
	WHERE bookkey = @v_bookkey

	/*get the datadesc for the @i_currencytypecode*/
	select	@v_currencytypedatadesc=datadescshort
	from	gentables 
	where	tableid=122
			and datacode=@v_currencytypecode

	/* Get bookorderhistory.historyorder using the sproc: 	qtitle_get_next_history_order */
	EXECUTE qtitle_get_next_history_order @v_bookkey
		,1
		,'bookprice'
		,@i_userid
		,@o_history_order OUTPUT
		,@o_error_code OUTPUT
		,@o_error_desc OUTPUT

	/* Get the Price Maintenance Default - the default instructs the procedure on how to handle Price Changes - either update existing prices with the new values or
   inactivate the existing price, and append a new price                            */
	SELECT @v_price_maint = upper(td.defaultvalue)
	FROM imp_template_detail td
		,imp_batch_master bm
	WHERE td.templatekey = bm.templatekey
		AND td.elementkey = 100013000
		AND bm.batchkey = @i_batch

	IF @v_price_maint IS NULL
	BEGIN
		SET @v_price_maint = 'UPDATE'
	END

	/*  IF Book is a new title, check to see if a template copied rows, if no price rows exist, insert the row, otherwise update the existing row  */
	IF @v_newtitleind = 1
	BEGIN
		IF @v_hit = 0
		BEGIN
			SELECT @v_newkey = generickey + 1
			FROM keys

			UPDATE keys
			SET generickey = @v_newkey

			IF @v_destinationcolumn = 'budgetprice'
			BEGIN
				IF @Debug=1 PRINT '2/IF @v_destinationcolumn = ''budgetprice'''

				INSERT INTO bookprice (
					pricekey
					,bookkey
					,pricetypecode
					,currencytypecode
					,budgetprice
					,effectivedate
					,activeind
					,lastuserid
					,lastmaintdate
					,sortorder
					,history_order
					)
				VALUES (
					@v_newkey
					,@v_bookkey
					,@v_pricetypecode
					,@v_currencytypecode
					,@v_new_price
					,@v_effdate
					,1
					,@i_userid
					,GETDATE()
					,@v_sortorder
					,@o_history_order
					)

				/*update history*/
				EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
					,@v_pricetypecode
					,@v_currencytypecode
					,@v_new_price
					,NULL
					,@v_effdate
					,1
					,@i_userid
					,@o_history_order
			END

			IF @v_destinationcolumn = 'finalprice'
			BEGIN
				IF @Debug=1 PRINT '3/IF @v_destinationcolumn = ''finalprice'''

				INSERT INTO bookprice (
					pricekey
					,bookkey
					,pricetypecode
					,currencytypecode
					,finalprice
					,effectivedate
					,activeind
					,lastuserid
					,lastmaintdate
					,sortorder
					,history_order
					)
				VALUES (
					@v_newkey
					,@v_bookkey
					,@v_pricetypecode
					,@v_currencytypecode
					,@v_new_price
					,@v_effdate
					,1
					,@i_userid
					,GETDATE()
					,@v_sortorder
					,@o_history_order
					)

				/*update history*/
				EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
					,@v_pricetypecode
					,@v_currencytypecode
					,NULL
					,@v_new_price
					,@v_effdate
					,1
					,@i_userid
					,@o_history_order
			END
		END
		ELSE
		BEGIN
			IF @v_destinationcolumn = 'budgetprice'
			BEGIN
				IF @Debug=1 PRINT '4/IF @v_destinationcolumn = ''budgetprice'''

				UPDATE bookprice
				SET budgetprice = @v_new_price
					,effectivedate = @v_effdate
					,lastuserid = @i_userid
					,lastmaintdate = GETDATE()
					,history_order = @o_history_order
				WHERE bookkey = @v_bookkey
					AND pricetypecode = @v_pricetypecode
					AND currencytypecode = @v_currencytypecode
					AND activeind = 1

				/*update history*/
				IF @Debug=1 PRINT '/*update history*/'

				SET @i_currentstringvalue = cast(@v_new_price AS VARCHAR(255)) + ' ' + @v_currencytypedatadesc

				EXECUTE qtitle_update_titlehistory 'bookprice'
					,'budgetprice'
					,@v_bookkey
					,1
					,0
					,@i_currentstringvalue
					,'insert'
					,@i_userid
					,@o_history_order
					,'budgetprice'
					,@o_error_code OUTPUT
					,@o_error_desc OUTPUT

				SET @i_currentstringvalue = cast(@v_effdate AS VARCHAR(255))

				EXECUTE qtitle_update_titlehistory 'bookprice'
					,'effectivedate'
					,@v_bookkey
					,1
					,0
					,@i_currentstringvalue
					,'insert'
					,@i_userid
					,@o_history_order
					,'effectivedate'
					,@o_error_code OUTPUT
					,@o_error_desc OUTPUT
			END

			IF @v_destinationcolumn = 'finalprice'
			BEGIN
				IF @Debug=1 PRINT '5/IF @v_destinationcolumn = ''finalprice'''

				UPDATE bookprice
				SET finalprice = @v_new_price
					,effectivedate = @v_effdate
					,lastuserid = @i_userid
					,lastmaintdate = GETDATE()
					,history_order = @o_history_order
				WHERE bookkey = @v_bookkey
					AND pricetypecode = @v_pricetypecode
					AND currencytypecode = @v_currencytypecode
					AND activeind = 1

				/*update history*/
				IF @Debug=1 PRINT '/*update history*/'

				SET @i_currentstringvalue = cast(@v_new_price AS VARCHAR(255)) + ' ' + @v_currencytypedatadesc

				EXECUTE qtitle_update_titlehistory 'bookprice'
					,'finalprice'
					,@v_bookkey
					,1
					,0
					,@i_currentstringvalue
					,'insert'
					,@i_userid
					,@o_history_order
					,'finalprice'
					,@o_error_code OUTPUT
					,@o_error_desc OUTPUT

				SET @i_currentstringvalue = cast(@v_effdate AS VARCHAR(255))

				EXECUTE qtitle_update_titlehistory 'bookprice'
					,'effectivedate'
					,@v_bookkey
					,1
					,0
					,@i_currentstringvalue
					,'insert'
					,@i_userid
					,@o_history_order
					,'effectivedate'
					,@o_error_code OUTPUT
					,@o_error_desc OUTPUT
			END
		END
	END
	ELSE
	BEGIN
		IF @v_newtitleind = 0
		BEGIN
			IF @v_hit = 0
			BEGIN
				SELECT @v_newkey = generickey + 1
				FROM keys

				UPDATE keys
				SET generickey = @v_newkey

				IF @v_destinationcolumn = 'budgetprice'
				BEGIN
					IF @Debug=1 PRINT '6/IF @v_destinationcolumn = ''budgetprice'''

					INSERT INTO bookprice (
						pricekey
						,bookkey
						,pricetypecode
						,currencytypecode
						,budgetprice
						,effectivedate
						,activeind
						,lastuserid
						,lastmaintdate
						,sortorder
						,history_order
						)
					VALUES (
						@v_newkey
						,@v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,@v_new_price
						,@v_effdate
						,1
						,@i_userid
						,GETDATE()
						,@v_sortorder
						,@o_history_order
						)

					/*update history*/
					EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,@v_new_price
						,NULL
						,@v_effdate
						,1
						,@i_userid
						,@o_history_order
				END

				IF @v_destinationcolumn = 'finalprice'
				BEGIN
					IF @Debug=1 PRINT '7/IF @v_destinationcolumn = ''finalprice'''

					INSERT INTO bookprice (
						pricekey
						,bookkey
						,pricetypecode
						,currencytypecode
						,finalprice
						,effectivedate
						,activeind
						,lastuserid
						,lastmaintdate
						,sortorder
						,history_order
						)
					VALUES (
						@v_newkey
						,@v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,@v_new_price
						,@v_effdate
						,1
						,@i_userid
						,GETDATE()
						,@v_sortorder
						,@o_history_order
						)

					/*update history*/
					EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,NULL
						,@v_new_price
						,@v_effdate
						,1
						,@i_userid
						,@o_history_order
				END
			END

			IF @v_hit > 0
				AND @v_price_maint = 'INSERT'
			BEGIN
				DELETE
				FROM bookprice
				WHERE pricetypecode = @v_pricetypecode
					AND currencytypecode = @v_currencytypecode
					AND bookkey = @v_bookkey
					AND activeind = 1

				SELECT @v_newkey = generickey + 1
				FROM keys

				UPDATE keys
				SET generickey = @v_newkey

				IF @v_destinationcolumn = 'budgetprice'
				BEGIN
					IF @Debug=1 PRINT '8/IF @v_destinationcolumn = ''budgetprice'''

					INSERT INTO bookprice (
						pricekey
						,bookkey
						,pricetypecode
						,currencytypecode
						,budgetprice
						,effectivedate
						,activeind
						,lastuserid
						,lastmaintdate
						,sortorder
						,history_order
						)
					VALUES (
						@v_newkey
						,@v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,@v_new_price
						,@v_effdate
						,1
						,@i_userid
						,GETDATE()
						,@v_sortorder
						,@o_history_order
						)

					/*update history*/
					EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,@v_new_price
						,NULL
						,@v_effdate
						,1
						,@i_userid
						,@o_history_order
				END

				IF @v_destinationcolumn = 'finalprice'
				BEGIN
					IF @Debug=1 PRINT '9/IF @v_destinationcolumn = ''finalprice'''

					INSERT INTO bookprice (
						pricekey
						,bookkey
						,pricetypecode
						,currencytypecode
						,finalprice
						,effectivedate
						,activeind
						,lastuserid
						,lastmaintdate
						,sortorder
						,history_order
						)
					VALUES (
						@v_newkey
						,@v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,@v_new_price
						,@v_effdate
						,1
						,@i_userid
						,GETDATE()
						,@v_sortorder
						,@o_history_order
						)

					/*update history*/
					EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
						,@v_pricetypecode
						,@v_currencytypecode
						,NULL
						,@v_new_price
						,@v_effdate
						,1
						,@i_userid
						,@o_history_order
				END
			END

			IF @v_hit = 1
				AND @v_price_maint = 'UPDATE'
			BEGIN
				IF @v_destinationcolumn = 'budgetprice'
				BEGIN
					IF @Debug=1 PRINT '10/IF @v_destinationcolumn = ''budgetprice'''

					SELECT @v_cur_price = COALESCE(budgetprice, 0)
					FROM bookprice
					WHERE bookkey = @v_bookkey
						AND pricetypecode = @v_pricetypecode
						AND currencytypecode = @v_currencytypecode
						AND activeind = 1

					IF @v_new_price <> @v_cur_price
					BEGIN
						UPDATE bookprice
						SET budgetprice = @v_new_price
							,effectivedate = @v_effdate
							,lastuserid = @i_userid
							,lastmaintdate = GETDATE()
							,history_order = @o_history_order
						WHERE bookkey = @v_bookkey
							AND pricetypecode = @v_pricetypecode
							AND currencytypecode = @v_currencytypecode
							AND activeind = 1

						/*update history*/
						IF @Debug=1 PRINT '/*update history*/'

						SET @i_currentstringvalue = cast(@v_new_price AS VARCHAR(255)) + ' ' + @v_currencytypedatadesc

						EXECUTE qtitle_update_titlehistory 'bookprice'
							,'budgetprice'
							,@v_bookkey
							,1
							,0
							,@i_currentstringvalue
							,'insert'
							,@i_userid
							,@o_history_order
							,'budgetprice'
							,@o_error_code OUTPUT
							,@o_error_desc OUTPUT

						SET @i_currentstringvalue = cast(@v_effdate AS VARCHAR(255))

						EXECUTE qtitle_update_titlehistory 'bookprice'
							,'effectivedate'
							,@v_bookkey
							,1
							,0
							,@i_currentstringvalue
							,'insert'
							,@i_userid
							,@o_history_order
							,'effectivedate'
							,@o_error_code OUTPUT
							,@o_error_desc OUTPUT
					END
				END

				IF @v_destinationcolumn = 'finalprice'
				BEGIN
					IF @Debug=1 PRINT '11/IF @v_destinationcolumn = ''finalprice'''

					SELECT @v_cur_price = COALESCE(finalprice, 0)
					FROM bookprice
					WHERE bookkey = @v_bookkey
						AND pricetypecode = @v_pricetypecode
						AND currencytypecode = @v_currencytypecode
						AND activeind = 1

					IF @v_new_price <> @v_cur_price
					BEGIN
						UPDATE bookprice
						SET finalprice = @v_new_price
							,effectivedate = @v_effdate
							,lastuserid = @i_userid
							,lastmaintdate = GETDATE()
							,history_order = @o_history_order
						WHERE bookkey = @v_bookkey
							AND pricetypecode = @v_pricetypecode
							AND currencytypecode = @v_currencytypecode
							AND activeind = 1

						/*update history*/
						IF @Debug=1 PRINT '/*update history*/'

						SET @i_currentstringvalue = cast(@v_new_price AS VARCHAR(255))  + ' ' + @v_currencytypedatadesc

						EXECUTE qtitle_update_titlehistory 'bookprice'
							,'finalprice'
							,@v_bookkey
							,1
							,0
							,@i_currentstringvalue
							,'insert'
							,@i_userid
							,@o_history_order
							,'finalprice'
							,@o_error_code OUTPUT
							,@o_error_desc OUTPUT

						SET @i_currentstringvalue = cast(@v_effdate AS VARCHAR(255))

						EXECUTE qtitle_update_titlehistory 'bookprice'
							,'effectivedate'
							,@v_bookkey
							,1
							,0
							,@i_currentstringvalue
							,'insert'
							,@i_userid
							,@o_history_order
							,'effectivedate'
							,@o_error_code OUTPUT
							,@o_error_desc OUTPUT
					END
				END
			END

			IF @v_hit = 1
				AND @v_price_maint = 'APPEND'
			BEGIN
				IF @v_destinationcolumn = 'budgetprice'
				BEGIN
					IF @Debug=1 PRINT '12/IF @v_destinationcolumn = ''budgetprice'''

					SELECT @v_cur_price = COALESCE(budgetprice, 0)
					FROM bookprice
					WHERE bookkey = @v_bookkey
						AND pricetypecode = @v_pricetypecode
						AND currencytypecode = @v_currencytypecode
						AND activeind = 1

					IF @v_new_price <> @v_cur_price
					BEGIN
						UPDATE bookprice
						SET sortorder = sortorder + 1
						WHERE bookkey = @v_bookkey

						UPDATE bookprice
						SET activeind = 0
						WHERE bookkey = @v_bookkey
							AND pricetypecode = @v_pricetypecode
							AND currencytypecode = @v_currencytypecode
							AND activeind = 1

						SELECT @v_newkey = generickey + 1
						FROM keys

						UPDATE keys
						SET generickey = @v_newkey

						INSERT INTO bookprice (
							pricekey
							,bookkey
							,pricetypecode
							,currencytypecode
							,budgetprice
							,effectivedate
							,activeind
							,lastuserid
							,lastmaintdate
							,sortorder
							,history_order
							)
						VALUES (
							@v_newkey
							,@v_bookkey
							,@v_pricetypecode
							,@v_currencytypecode
							,@v_new_price
							,@v_effdate
							,1
							,@i_userid
							,GETDATE()
							,1
							,@o_history_order
							)

						/*update history*/
						EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
							,@v_pricetypecode
							,@v_currencytypecode
							,@v_new_price
							,NULL
							,@v_effdate
							,1
							,@i_userid
							,@o_history_order
					END
				END

				IF @v_destinationcolumn = 'finalprice'
				BEGIN
					IF @Debug=1 PRINT '13/IF @v_destinationcolumn = ''finalprice'''

					SELECT @v_cur_price = COALESCE(finalprice, 0)
					FROM bookprice
					WHERE bookkey = @v_bookkey
						AND pricetypecode = @v_pricetypecode
						AND currencytypecode = @v_currencytypecode
						AND activeind = 1

					IF @v_new_price <> @v_cur_price
					BEGIN
						UPDATE bookprice
						SET sortorder = sortorder + 1
						WHERE bookkey = @v_bookkey

						UPDATE bookprice
						SET activeind = 0
						WHERE bookkey = @v_bookkey
							AND pricetypecode = @v_pricetypecode
							AND currencytypecode = @v_currencytypecode
							AND activeind = 1

						SELECT @v_newkey = generickey + 1
						FROM keys

						UPDATE keys
						SET generickey = @v_newkey

						INSERT INTO bookprice (
							pricekey
							,bookkey
							,pricetypecode
							,currencytypecode
							,finalprice
							,effectivedate
							,activeind
							,lastuserid
							,lastmaintdate
							,sortorder
							,history_order
							)
						VALUES (
							@v_newkey
							,@v_bookkey
							,@v_pricetypecode
							,@v_currencytypecode
							,@v_new_price
							,@v_effdate
							,1
							,@i_userid
							,GETDATE()
							,1
							,@o_history_order
							)

						/*update history*/
						EXECUTE imp_insert_bookprice_record_into_titlehistory @v_bookkey
							,@v_pricetypecode
							,@v_currencytypecode
							,NULL
							,@v_new_price
							,@v_effdate
							,1
							,@i_userid
							,@o_history_order
					END
				END
			END
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_rule_ext_300013000001]
	TO PUBLIC
GO

