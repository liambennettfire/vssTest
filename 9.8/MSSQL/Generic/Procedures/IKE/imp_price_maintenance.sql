/******************************************************************************
**  Name: imp_price_maintenance
**  Desc: IKE update bookprice table
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_price_maintenance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_price_maintenance]
GO

CREATe PROCEDURE imp_price_maintenance(@i_batch      INT,
          @v_bookkey    INT,
          @v_new_price    FLOAT,
          @v_newtitleind    INT,
          @v_pricetypecode  INT,
          @v_currencytypecode  INT,
          @v_destinationcolumn  VARCHAR(100),
          @i_userid    VARCHAR(30))

AS

DECLARE @v_cur_price    FLOAT,
  @v_hit      INT,
  @v_newkey    INT,
  @v_sortorder    INT,
  @v_price_maint    VARCHAR(100),
  @v_errcode    INT,
  @o_writehistoryind  INT,
  @v_history_order INT,
  @v_error_code INT,
  @v_error_desc VARCHAR(2000)

BEGIN

  SET @v_hit = 0
  SET @v_newkey  = 0
  SET @v_sortorder = 0  
  SET @o_writehistoryind = 0
  SET @v_errcode = 1

  SELECT @v_hit = COUNT(*)
  FROM bookprice
  WHERE pricetypecode = @v_pricetypecode
      AND currencytypecode = @v_currencytypecode
      AND bookkey = @v_bookkey
      AND activeind = 1

      SELECT @v_sortorder = COALESCE(MAX(sortorder),0)+1
      FROM bookprice
      WHERE bookkey = @v_bookkey
/* Get the Price Maintenance Default - the default instructs the procedure on how to handle Price Changes - either update existing prices with the new values or
   inactivate the existing price, and append a new price                            */

  SELECT @v_price_maint = UPPER(COALESCE(td.defaultvalue,'Update'))
  FROM imp_template_detail td, imp_batch_master bm
  WHERE td.templatekey = bm.templatekey
        AND td.elementkey = 100013000
        AND bm.batchkey = @i_batch


/*  IF Book is a new title, check to see if a template copied rows, if no price rows exist, insert the row, otherwise update the existing row  */
  IF @v_newtitleind = 1
    BEGIN
      IF @v_hit = 0
        BEGIN
          SELECT @v_newkey = generickey+1
          FROM keys

          UPDATE keys
          SET generickey = @v_newkey
          
          IF @v_destinationcolumn = 'budgetprice' BEGIN
            EXEC qtitle_get_next_history_order @v_bookkey, 0, 'bookprice', @i_userid, 
              @v_history_order OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
          
            INSERT INTO bookprice(pricekey,bookkey,pricetypecode,currencytypecode,budgetprice,effectivedate,activeind,lastuserid,lastmaintdate,sortorder, history_order)
            VALUES(@v_newkey,@v_bookkey,@v_pricetypecode,@v_currencytypecode,@v_new_price,GETDATE(),1,@i_userid,GETDATE(),@v_sortorder, @v_history_order)
          END
          
          IF @v_destinationcolumn = 'finalprice' BEGIN
            EXEC qtitle_get_next_history_order @v_bookkey, 0, 'bookprice', @i_userid, 
              @v_history_order OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
           
            INSERT INTO bookprice(pricekey,bookkey,pricetypecode,currencytypecode,finalprice,effectivedate,activeind,lastuserid,lastmaintdate,sortorder, history_order)
            VALUES(@v_newkey,@v_bookkey,@v_pricetypecode,@v_currencytypecode,@v_new_price,GETDATE(),1,@i_userid,GETDATE(),@v_sortorder, @v_history_order)
          END
        END


      ELSE
        BEGIN
          IF @v_destinationcolumn = 'budgetprice' 
            BEGIN
              UPDATE bookprice
              SET budgetprice = @v_new_price,
                  effectivedate = GETDATE(),
                  lastuserid = @i_userid,
                  lastmaintdate = GETDATE()
              WHERE bookkey = @v_bookkey
                  AND pricetypecode = @v_pricetypecode
                  AND currencytypecode = @v_currencytypecode
                  AND activeind = 1
            END
          IF @v_destinationcolumn = 'finalprice'    
            BEGIN
              UPDATE bookprice
              SET finalprice = @v_new_price,
                  effectivedate = GETDATE(),
                  lastuserid = @i_userid,
                  lastmaintdate = GETDATE()
              WHERE bookkey = @v_bookkey
                  AND pricetypecode = @v_pricetypecode
                  AND currencytypecode = @v_currencytypecode
                  AND activeind = 1
            END

        END
    END

  ELSE IF @v_newtitleind = 0 
    BEGIN
      IF @v_hit = 0
        BEGIN
          SELECT @v_newkey = generickey+1
          FROM keys

          UPDATE keys
          SET generickey = @v_newkey
          
          IF @v_destinationcolumn = 'budgetprice' BEGIN
            EXEC qtitle_get_next_history_order @v_bookkey, 0, 'bookprice', @i_userid, 
              @v_history_order OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
           
            INSERT INTO bookprice(pricekey,bookkey,pricetypecode,currencytypecode,budgetprice,effectivedate,activeind,lastuserid,lastmaintdate,sortorder, history_order)
            VALUES(@v_newkey,@v_bookkey,@v_pricetypecode,@v_currencytypecode,@v_new_price,GETDATE(),1,@i_userid,GETDATE(),@v_sortorder, @v_history_order)
          END
          
          IF @v_destinationcolumn = 'finalprice' BEGIN
            EXEC qtitle_get_next_history_order @v_bookkey, 0, 'bookprice', @i_userid, 
              @v_history_order OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
          
            INSERT INTO bookprice(pricekey,bookkey,pricetypecode,currencytypecode,finalprice,effectivedate,activeind,lastuserid,lastmaintdate,sortorder, history_order)
            VALUES(@v_newkey,@v_bookkey,@v_pricetypecode,@v_currencytypecode,@v_new_price,GETDATE(),1,@i_userid,GETDATE(),@v_sortorder, @v_history_order)
          END
        END

      IF @v_hit > 0 AND @v_price_maint = 'INSERT'
        BEGIN
          DELETE FROM bookprice
          WHERE pricetypecode = @v_pricetypecode
              AND currencytypecode = @v_currencytypecode
              AND bookkey = @v_bookkey
              AND activeind = 1

          SELECT @v_newkey = generickey+1
          FROM keys

          UPDATE keys
          SET generickey = @v_newkey

          IF @v_destinationcolumn = 'budgetprice' BEGIN
            EXEC qtitle_get_next_history_order @v_bookkey, 0, 'bookprice', @i_userid, 
              @v_history_order OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
          
            INSERT INTO bookprice(pricekey,bookkey,pricetypecode,currencytypecode,budgetprice,effectivedate,activeind,lastuserid,lastmaintdate,sortorder, history_order)
            VALUES(@v_newkey,@v_bookkey,@v_pricetypecode,@v_currencytypecode,@v_new_price,GETDATE(),1,@i_userid,GETDATE(),@v_sortorder, @v_history_order)
          END
        
          IF @v_destinationcolumn = 'finalprice' BEGIN
            EXEC qtitle_get_next_history_order @v_bookkey, 0, 'bookprice', @i_userid, 
              @v_history_order OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
          
            INSERT INTO bookprice(pricekey,bookkey,pricetypecode,currencytypecode,finalprice,effectivedate,activeind,lastuserid,lastmaintdate,sortorder, history_order)
            VALUES(@v_newkey,@v_bookkey,@v_pricetypecode,@v_currencytypecode,@v_new_price,GETDATE(),1,@i_userid,GETDATE(),@v_sortorder, @v_history_order)
          END
        END


      IF @v_hit = 1 AND @v_price_maint = 'UPDATE'
        BEGIN
          IF @v_destinationcolumn = 'budgetprice'    
            BEGIN

              SELECT @v_cur_price = COALESCE(budgetprice,0)
              FROM bookprice
              WHERE bookkey = @v_bookkey
                  AND pricetypecode = @v_pricetypecode
                  AND currencytypecode = @v_currencytypecode
                  AND activeind = 1

              IF @v_new_price <> @v_cur_price
                BEGIN
                  UPDATE bookprice
                  SET budgetprice = @v_new_price,
                        effectivedate = GETDATE(),
                        lastuserid = @i_userid,
                        lastmaintdate = GETDATE()
                  WHERE bookkey = @v_bookkey
                        AND pricetypecode = @v_pricetypecode
                        AND currencytypecode = @v_currencytypecode
                        AND activeind = 1
                END

            END

          IF @v_destinationcolumn = 'finalprice'    
            BEGIN
              SELECT @v_cur_price = COALESCE(finalprice,0)
              FROM bookprice
              WHERE bookkey = @v_bookkey
                  AND pricetypecode = @v_pricetypecode
                  AND currencytypecode = @v_currencytypecode
                  AND activeind = 1

              IF @v_new_price <> @v_cur_price
                UPDATE bookprice
                SET finalprice = @v_new_price,
                      effectivedate = GETDATE(),
                      lastuserid = @i_userid,
                      lastmaintdate = GETDATE()
                WHERE bookkey = @v_bookkey
                      AND pricetypecode = @v_pricetypecode
                      AND currencytypecode = @v_currencytypecode
                      AND activeind = 1
            END

        END

      IF @v_hit = 1 AND @v_price_maint = 'APPEND'
        BEGIN
          UPDATE bookprice
          SET sortorder = sortorder+1
          WHERE bookkey = @v_bookkey

          UPDATE bookprice
          SET activeind = 0
          WHERE bookkey = @v_bookkey
              AND pricetypecode = @v_pricetypecode
              AND currencytypecode = @v_currencytypecode
              AND activeind = 1
    
          
          IF @v_destinationcolumn = 'budgetprice'    
            BEGIN

              SELECT @v_cur_price = COALESCE(budgetprice,0)
              FROM bookprice
              WHERE bookkey = @v_bookkey
                  AND pricetypecode = @v_pricetypecode
                  AND currencytypecode = @v_currencytypecode
                  AND activeind = 1
        
              IF @v_new_price <> @v_cur_price
                UPDATE bookprice
                SET budgetprice = @v_new_price,
                      effectivedate = GETDATE(),
                      sortorder = 1,
                      lastuserid = @i_userid,
                      lastmaintdate = GETDATE()
                WHERE bookkey = @v_bookkey
                      AND pricetypecode = @v_pricetypecode
                      AND currencytypecode = @v_currencytypecode
                      AND activeind = 1
                
            END

          IF @v_destinationcolumn = 'finalprice'    
            BEGIN
              SELECT @v_cur_price = COALESCE(finalprice,0)
              FROM bookprice
              WHERE bookkey = @v_bookkey
                  AND pricetypecode = @v_pricetypecode
                  AND currencytypecode = @v_currencytypecode
                  AND activeind = 1

              IF @v_new_price <> @v_cur_price
                UPDATE bookprice
                SET finalprice = @v_new_price,
                    effectivedate = GETDATE(),
                    sortorder = 1,
                    lastuserid = @i_userid,
                    lastmaintdate = GETDATE()
                WHERE bookkey = @v_bookkey
                    AND pricetypecode = @v_pricetypecode
                    AND currencytypecode = @v_currencytypecode
                    AND activeind = 1
              
            END

        END


    END
END
