IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'onix21_price')
BEGIN
  DROP  Procedure  onix21_price
END
GO


  CREATE 
    PROCEDURE dbo.onix21_price 
        @i_bookkey integer,
        @i_pricetypecode integer,
        @i_currencytypecode integer,
        @o_xml text OUTPUT ,
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(8000) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @v_xml varchar(max),
            @v_xml_temp varchar(max),
            @v_count integer,
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_price numeric(9, 2),
            @v_effectivedate datetime,
            @v_tableid_price integer,
            @v_tableid_currency integer,
            @v_onixcode_price varchar(30),
            @v_onixcode_currency varchar(30),
            @v_onixcodedefault integer,
            @v_record_separator varchar(2),
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer,
            @return_onixcode_notfound integer          

          SET @v_xml = ''
          SET @v_xml_temp = ''
          SET @v_record_separator = char(13) + char(10)
          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @return_onixcode_notfound =  -99


            SET @o_error_code = @return_no_err_code
            SET @o_error_desc = ''
            SET @o_xml = ''
            SET @v_tableid_price = 306
            SET @v_tableid_currency = 122
            IF ((@i_pricetypecode IS NULL) OR 
                    (@i_pricetypecode <= 0) OR 
                    (@i_currencytypecode IS NULL) OR 
                    (@i_currencytypecode <= 0))
              BEGIN

                /*  pricetypecode and currencytypecode need to be filled in */
                SET @o_error_code = @return_sys_err_code
                SET @o_error_desc = 'Pricetype or Currency Type is not filled in.'
                RETURN 
              END

            /*  try to get onix codes - must find onixcodes for both pricetype and currencytype */

            /*  pricetypecode */
            EXEC dbo.GET_ONIXCODE_GENTABLES @v_tableid_price, @i_pricetypecode, @v_onixcode_price OUTPUT, @v_onixcodedefault OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode <= 0)
              BEGIN

                /*  error or not found */
                SET @o_error_code = @v_retcode
                SET @o_error_desc = @v_error_desc
                RETURN 
              END

            IF @v_onixcode_price IS NOT NULL
              BEGIN

                /*  return -99 */
                SET @o_error_code = @return_onixcode_notfound
                SET @o_error_desc = ('Onixcode not found for tableid ' + isnull(CAST( @v_tableid_price AS varchar(50)), '') + ' and datacode ' + isnull(CAST( @i_pricetypecode AS varchar(50)), ''))
                RETURN 
              END

            /*  currencytypecode */
            EXEC dbo.GET_ONIXCODE_GENTABLES @v_tableid_currency, @i_currencytypecode, @v_onixcode_currency OUTPUT, @v_onixcodedefault OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
            IF (@v_retcode <= 0)
              BEGIN
                /*  error or not found */
                SET @o_error_code = @v_retcode
                SET @o_error_desc = @v_error_desc
                RETURN 
              END

            IF @v_onixcode_currency  IS NOT NULL
              BEGIN

                /*  return -99 */
                SET @o_error_code = @return_onixcode_notfound
                SET @o_error_desc = ('Onixcode not found for tableid ' + isnull(CAST( @v_tableid_currency AS varchar(100)), '') + ' and datacode ' + isnull(CAST( @i_currencytypecode AS varchar(100)), ''))
                RETURN 

              END

            /*  Retrieve Data from bookprice */
            SELECT @v_count = count( * )
              FROM dbo.BOOKPRICE
              WHERE ((dbo.BOOKPRICE.BOOKKEY = @i_bookkey) AND 
                      (dbo.BOOKPRICE.PRICETYPECODE = @i_pricetypecode) AND 
                      (dbo.BOOKPRICE.CURRENCYTYPECODE = @i_currencytypecode) AND 
                      (dbo.BOOKPRICE.ACTIVEIND = 1))


            IF (@v_count > 0)
              BEGIN
                SELECT @v_price = isnull(isnull(dbo.BOOKPRICE.FINALPRICE, dbo.BOOKPRICE.BUDGETPRICE), 0), @v_effectivedate = dbo.BOOKPRICE.EFFECTIVEDATE
                  FROM dbo.BOOKPRICE
                  WHERE ((dbo.BOOKPRICE.BOOKKEY = @i_bookkey) AND 
                          (dbo.BOOKPRICE.PRICETYPECODE = @i_pricetypecode) AND 
                          (dbo.BOOKPRICE.CURRENCYTYPECODE = @i_currencytypecode) AND 
                          (dbo.BOOKPRICE.ACTIVEIND = 1))


                IF (@v_price > 0)
                  BEGIN
                    SET @v_xml = '<price>'
                    SET @v_xml = (isnull(@v_xml, '') + '<j148>' + isnull(@v_onixcode_price, '') + '</j148>')
                    SET @v_xml = (isnull(@v_xml, '') + '<j151>' + isnull(ltrim(rtrim(cast(@v_price as varchar(100)))), '') + '</j151>')
                    SET @v_xml = (isnull(@v_xml, '') + '<j152>' + isnull(@v_onixcode_currency, '') + '</j152>')

                    /*  discount code composite */
                    SET @v_xml_temp = ''
                    EXEC dbo.ONIX21_DISCOUNTCODE @i_bookkey, @v_xml_temp OUTPUT, @v_retcode OUTPUT, @v_error_desc OUTPUT 
                    IF (@v_retcode < 0)
                      BEGIN
                        SET @o_error_code = @v_retcode
                        SET @o_error_desc = @v_error_desc
                        RETURN 
                      END

                    IF ((@v_retcode > 0) AND 
                           (len(@v_xml_temp) > 0))
                    SET @v_xml = (isnull(@v_xml, '') + isnull(@v_xml_temp, ''))
                    SET @v_xml = (isnull(@v_xml, '') + '</price>' + isnull(@v_record_separator, ''))
                    SET @o_xml = @v_xml
                  END
                ELSE 
                  BEGIN

                    /*  return 0 */

                    SET @o_error_code = @return_nodata_err_code
                    SET @o_error_desc = ''
                    RETURN 
                  END
              END
            ELSE 
              BEGIN

                /*  return 0 */
                SET @o_error_code = @return_nodata_err_code
                SET @o_error_desc = ('There are no active prices for bookkey ' + isnull(CAST( @i_bookkey AS varchar(100)), '') + ' for pricetypecode ' + isnull(CAST( @i_pricetypecode AS varchar(100)), '') + ' and currencytypecode ' + isnull(CAST( @i_currencytypecode AS varchar(100)), ''))
                RETURN 
              END

      END

go
grant execute on onix21_price  to public
go

