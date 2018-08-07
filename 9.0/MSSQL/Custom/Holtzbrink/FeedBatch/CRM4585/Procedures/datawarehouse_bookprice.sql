IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_bookprice')
BEGIN
  DROP  Procedure  datawarehouse_bookprice
END
GO

 CREATE 
    PROCEDURE dbo.datawarehouse_bookprice 
        @ware_bookkey integer,
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS
      BEGIN
          DECLARE 
            @cursor_row$PRICETYPECODE integer,
            @cursor_row$CURRENCYTYPECODE integer,
            @cursor_row$BUDGETPRICE integer,
            @cursor_row$FINALPRICE integer,
            @ware_count integer,
            @ware_estus numeric(10, 2),
            @ware_actus numeric(10, 2),
            @ware_bestus numeric(10, 2),
            @ware_estuk numeric(10, 2),
            @ware_actuk numeric(10, 2),
            @ware_bestuk numeric(10, 2),
            @ware_estcan numeric(10, 2),
            @ware_actcan numeric(10, 2),
            @ware_bestcan numeric(10, 2),
            @ware_estfpt numeric(10, 2),
            @ware_actfpt numeric(10, 2),
            @ware_bestfpt numeric(10, 2),
            @ware_netestus numeric(10, 2),
            @ware_netactus numeric(10, 2),
            @ware_netbestus numeric(10, 2),
            @ware_netestcan numeric(10, 2),
            @ware_netactcan numeric(10, 2),
            @ware_netbestcan numeric(10, 2)          
          SET @ware_count = 1
          SET @ware_estus = 0
          SET @ware_actus = 0
          SET @ware_bestus = 0
          SET @ware_estuk = 0
          SET @ware_actuk = 0
          SET @ware_bestuk = 0
          SET @ware_estcan = 0
          SET @ware_actcan = 0
          SET @ware_bestcan = 0
          SET @ware_estfpt = 0
          SET @ware_actfpt = 0
          SET @ware_bestfpt = 0
          SET @ware_netestus = 0
          SET @ware_netactus = 0
          SET @ware_netbestus = 0
          SET @ware_netestcan = 0
          SET @ware_netactcan = 0
          SET @ware_netbestcan = 0
          BEGIN

            BEGIN

              DECLARE 
                @cursor_row$PRICETYPECODE$2 integer,
                @cursor_row$CURRENCYTYPECODE$2 integer,
                @cursor_row$BUDGETPRICE$2 integer,
                @cursor_row$FINALPRICE$2 integer              

              DECLARE 
                warehousebookprice CURSOR LOCAL 
                 FOR 
                  SELECT 
                      isnull(dbo.BOOKPRICE.PRICETYPECODE, 0) AS PRICETYPECODE, 
                      isnull(dbo.BOOKPRICE.CURRENCYTYPECODE, 0) AS CURRENCYTYPECODE, 
                      isnull(dbo.BOOKPRICE.BUDGETPRICE, 0) AS BUDGETPRICE, 
                      isnull(dbo.BOOKPRICE.FINALPRICE, 0) AS FINALPRICE
                    FROM dbo.BOOKPRICE
                    WHERE ((dbo.BOOKPRICE.ACTIVEIND = 1) AND 
                            (dbo.BOOKPRICE.BOOKKEY = @ware_bookkey))
              

              OPEN warehousebookprice

              FETCH NEXT FROM warehousebookprice
                INTO 
                  @cursor_row$PRICETYPECODE$2, 
                  @cursor_row$CURRENCYTYPECODE$2, 
                  @cursor_row$BUDGETPRICE$2, 
                  @cursor_row$FINALPRICE$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BREAK 

                  IF @cursor_row$PRICETYPECODE$2 = 11 AND  @cursor_row$CURRENCYTYPECODE$2 = 6 BEGIN
                      /* list for holt price */

                      SET @ware_estus = @cursor_row$BUDGETPRICE$2
                      SET @ware_actus = @cursor_row$FINALPRICE$2

                      IF (@ware_actus > 0)
                        SET @ware_bestus = @ware_actus
                      ELSE 
                        SET @ware_bestus = @ware_estus

                  END

                  IF @cursor_row$PRICETYPECODE$2 = 11 AND @cursor_row$CURRENCYTYPECODE$2 = 37 BEGIN
                      /* UK */
                      SET @ware_estuk = @cursor_row$BUDGETPRICE$2
                      SET @ware_actuk = @cursor_row$FINALPRICE$2

                      IF (@ware_actuk > 0)
                        SET @ware_bestuk = @ware_actuk
                      ELSE 
                        SET @ware_bestuk = @ware_estuk
                    END

                  IF @cursor_row$PRICETYPECODE$2 = 11 AND @cursor_row$CURRENCYTYPECODE$2 = 11  BEGIN
                     /* CAN */
                      SET @ware_estcan = @cursor_row$BUDGETPRICE$2
                      SET @ware_actcan = @cursor_row$FINALPRICE$2
                      IF (@ware_actcan > 0)
                        SET @ware_bestcan = @ware_actcan
                      ELSE 
                        SET @ware_bestcan = @ware_estcan
                  END

                  IF @cursor_row$PRICETYPECODE$2 = 13 AND @cursor_row$CURRENCYTYPECODE$2 = 6 BEGIN
                      /* fpt price  not used at holt but leave in */
                      SET @ware_estfpt = @cursor_row$BUDGETPRICE$2
                      SET @ware_actfpt = @cursor_row$FINALPRICE$2
                      IF (@ware_actfpt > 0)
                        SET @ware_bestfpt = @ware_actfpt
                      ELSE 
                        SET @ware_bestfpt = @ware_estfpt
                  END
                  IF @cursor_row$PRICETYPECODE$2 = 9 AND @cursor_row$CURRENCYTYPECODE$2 = 6 BEGIN
                      /* US NET PRICE */
                      SET @ware_netestus = @cursor_row$BUDGETPRICE$2
                      SET @ware_netactus = @cursor_row$FINALPRICE$2
                      IF (@ware_netactus > 0)
                        SET @ware_netbestus = @ware_netactus
                      ELSE 
                        SET @ware_netbestus = @ware_netestus
                  END

                  /* CRM 4463 HBPUB -Adjust datawarehouse price proc to select proper price type and currency for Canadian Net Price  */
                 IF @cursor_row$PRICETYPECODE$2 = 13 AND @cursor_row$CURRENCYTYPECODE$2 = 38 BEGIN
                      /* CAN NET PRICE */
                      SET @ware_netestcan = @cursor_row$BUDGETPRICE$2
                      SET @ware_netactcan = @cursor_row$FINALPRICE$2
                      IF (@ware_netactcan > 0)
                        SET @ware_netbestcan = @ware_netactcan
                      ELSE 
                        SET @ware_netbestcan = @ware_netestcan
                 END
                  FETCH NEXT FROM warehousebookprice
                    INTO 
                      @cursor_row$PRICETYPECODE$2, 
                      @cursor_row$CURRENCYTYPECODE$2, 
                      @cursor_row$BUDGETPRICE$2, 
                      @cursor_row$FINALPRICE$2
              END
              CLOSE warehousebookprice
             DEALLOCATE warehousebookprice
           END

            UPDATE dbo.WHTITLEINFO
              SET 
                dbo.WHTITLEINFO.USPRICEEST = @ware_estus, 
                dbo.WHTITLEINFO.USPRICEACT = @ware_actus, 
                dbo.WHTITLEINFO.USPRICEBEST = @ware_bestus, 
                dbo.WHTITLEINFO.UKPRICEEST = @ware_estuk, 
                dbo.WHTITLEINFO.UKPRICEACT = @ware_actuk, 
                dbo.WHTITLEINFO.UKPRICEBEST = @ware_bestuk, 
                dbo.WHTITLEINFO.CANADIANPRICEEST = @ware_estcan, 
                dbo.WHTITLEINFO.CANADIANPRICEACT = @ware_actcan, 
                dbo.WHTITLEINFO.CANADIANPRICEBEST = @ware_bestcan, 
                dbo.WHTITLEINFO.FPTPRICEEST = @ware_estfpt, 
                dbo.WHTITLEINFO.FPTPRICEACT = @ware_actfpt, 
                dbo.WHTITLEINFO.FPTPRICEBEST = @ware_bestfpt, 
                dbo.WHTITLEINFO.USNETPRICEEST = @ware_netestus, 
                dbo.WHTITLEINFO.USNETPRICEACT = @ware_netactus, 
                dbo.WHTITLEINFO.USNETPRICEBEST = @ware_netbestus, 
                dbo.WHTITLEINFO.CANADIANNETPRICEEST = @ware_netestcan, 
                dbo.WHTITLEINFO.CANADIANNETPRICEACT = @ware_netactcan, 
                dbo.WHTITLEINFO.CANADIANNETPRICEBEST = @ware_netbestcan
              WHERE (dbo.WHTITLEINFO.BOOKKEY = @ware_bookkey)

            IF @@ROWCOUNT = 0 BEGIN
                INSERT INTO dbo.WHERRORLOG
                  (
                    dbo.WHERRORLOG.LOGKEY, 
                    dbo.WHERRORLOG.WAREHOUSEKEY, 
                    dbo.WHERRORLOG.ERRORDESC, 
                    dbo.WHERRORLOG.ERRORSEVERITY, 
                    dbo.WHERRORLOG.ERRORFUNCTION, 
                    dbo.WHERRORLOG.LASTUSERID, 
                    dbo.WHERRORLOG.LASTMAINTDATE
                  )
                  VALUES 
                    (
                      CAST( @ware_logkey AS varchar(8000)), 
                      CAST( @ware_warehousekey AS varchar(8000)), 
                      'Unable to update whtitleinfo table - for bookprice', 
                      ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(8000)), '')), 
                      'Stored procedure datawarehouse_bookprice', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
              END

            IF (cursor_status(N'local', N'warehousebookprice') = 1)
              BEGIN
                CLOSE warehousebookprice
                DEALLOCATE warehousebookprice
              END

          END
      END
go
grant execute on datawarehouse_bookprice  to public
go
