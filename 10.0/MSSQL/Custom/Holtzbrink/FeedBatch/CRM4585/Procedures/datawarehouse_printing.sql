IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_printing')
BEGIN
  DROP  Procedure  datawarehouse_printing
END
GO
  CREATE 
    PROCEDURE dbo.datawarehouse_printing 
        @ware_bookkey integer,
        @ware_illuspapchgcode integer,
        @ware_textpapchgcode integer,
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS
      BEGIN
          DECLARE 
            @cursor_row$PRINTINGKEY integer,
            @cursor_row$expr$1 integer,
            @cursor_row$TENTATIVEQTY integer,
            @cursor_row$NOTEKEY integer,
            @cursor_row$PRINTINGNUM integer,
            @cursor_row$STATUSCODE integer,
            @cursor_row$CCESTATUS varchar(5),
            @cursor_row$DATECCEFINALIZED datetime,
            @cursor_row$REQUESTBATCHID varchar(30),
            @cursor_row$APPROVEDONDATE datetime,
            @cursor_row$REQUESTSTATUSCODE integer,
            @cursor_row$REQUESTCOMMENT varchar(255),
            @cursor_row$REQUESTID varchar(30),
            @cursor_row$REQUESTBYNAME varchar(100),
            @cursor_row$REQUESTDATETIME datetime,
            @cursor_row$APPROVEDQTY integer,
            @cursor_row$BOOKBULK integer,
            @cursor_row$PCEQTY1 integer,
            @cursor_row$PCEQTY2 integer,
            @cursor_row$IMPRESSIONNUMBER varchar(10),
            @cursor_row$QTYRECEIVED integer,
            @cursor_row$PRINTINGCLOSEDDATE datetime,
            @cursor_row$JOBNUMBERALPHA char(20),
            @cursor_row$BOARDTRIMSIZEWIDTH varchar(20),
            @cursor_row$BOARDTRIMSIZELENGTH varchar(20),
            @ware_count integer,
            @ware_printingnum integer,
            @ware_actbbdate datetime,
            @ware_estbbdate datetime,
            @ware_requeststatus_long varchar(40),
            @ware_printingstatus_long varchar(40),
            @ware_notes varchar(2000),
            @ware_cartonqty integer,
            @ware_prepackind varchar(1),
            @ware_totaleditioncost numeric(15, 4),
            @ware_totalplantcost numeric(15, 4),
            @ware_totalunitcost numeric(15, 4)          
          SET @ware_count = 0
          SET @ware_printingnum = 0
          SET @ware_requeststatus_long = ''
          SET @ware_printingstatus_long = ''
          SET @ware_notes = ''
          SET @ware_cartonqty = 0
          SET @ware_prepackind = 'N'
          SET @ware_totaleditioncost = 0
          SET @ware_totalplantcost = 0
          SET @ware_totalunitcost = 0
          BEGIN
            BEGIN

              DECLARE 
                @cursor_row$PRINTINGKEY$2 integer,
                @cursor_row$expr$1$2 integer,
                @cursor_row$TENTATIVEQTY$2 integer,
                @cursor_row$NOTEKEY$2 integer,
                @cursor_row$PRINTINGNUM$2 integer,
                @cursor_row$STATUSCODE$2 integer,
                @cursor_row$CCESTATUS$2 varchar(5),
                @cursor_row$DATECCEFINALIZED$2 datetime,
                @cursor_row$REQUESTBATCHID$2 varchar(30),
                @cursor_row$APPROVEDONDATE$2 datetime,
                @cursor_row$REQUESTSTATUSCODE$2 integer,
                @cursor_row$REQUESTCOMMENT$2 varchar(255),
                @cursor_row$REQUESTID$2 varchar(30),
                @cursor_row$REQUESTBYNAME$2 varchar(100),
                @cursor_row$REQUESTDATETIME$2 datetime,
                @cursor_row$APPROVEDQTY$2 integer,
                @cursor_row$BOOKBULK$2 integer,
                @cursor_row$PCEQTY1$2 integer,
                @cursor_row$PCEQTY2$2 integer,
                @cursor_row$IMPRESSIONNUMBER$2 varchar(10),
                @cursor_row$QTYRECEIVED$2 integer,
                @cursor_row$PRINTINGCLOSEDDATE$2 datetime,
                @cursor_row$JOBNUMBERALPHA$2 char(20),
                @cursor_row$BOARDTRIMSIZEWIDTH$2 varchar(20),
                @cursor_row$BOARDTRIMSIZELENGTH$2 varchar(20)              

              DECLARE 
                warehouseprinting CURSOR LOCAL 
                 FOR 
                  SELECT 
                      isnull(dbo.PRINTING.PRINTINGKEY, 0) AS PRINTINGKEY, 
                      isnull(dbo.PRINTING.TENTATIVEQTY, 0), 
                      dbo.PRINTING.TENTATIVEQTY, 
                      isnull(dbo.PRINTING.NOTEKEY, 0) AS NOTEKEY, 
                      isnull(dbo.PRINTING.PRINTINGNUM, 0) AS PRINTINGNUM, 
                      isnull(dbo.PRINTING.STATUSCODE, 0) AS STATUSCODE, 
                      isnull(dbo.PRINTING.CCESTATUS, 'XXX') AS CCESTATUS, 
                      isnull(dbo.PRINTING.DATECCEFINALIZED, '') AS DATECCEFINALIZED, 
                      isnull(dbo.PRINTING.REQUESTBATCHID, 0) AS REQUESTBATCHID, 
                      isnull(dbo.PRINTING.APPROVEDONDATE, '') AS APPROVEDONDATE, 
                      isnull(dbo.PRINTING.REQUESTSTATUSCODE, 0) AS REQUESTSTATUSCODE, 
                      isnull(dbo.PRINTING.REQUESTCOMMENT, ' ') AS REQUESTCOMMENT, 
                      isnull(dbo.PRINTING.REQUESTID, ' ') AS REQUESTID, 
                      isnull(dbo.PRINTING.REQUESTBYNAME, ' ') AS REQUESTBYNAME, 
                      isnull(dbo.PRINTING.REQUESTDATETIME, '') AS REQUESTDATETIME, 
                      isnull(dbo.PRINTING.APPROVEDQTY, 0) AS APPROVEDQTY, 
                      isnull(dbo.PRINTING.BOOKBULK, 0) AS BOOKBULK, 
                      isnull(dbo.PRINTING.PCEQTY1, 0) AS PCEQTY1, 
                      isnull(dbo.PRINTING.PCEQTY2, 0) AS PCEQTY2, 
                      isnull(dbo.PRINTING.IMPRESSIONNUMBER, ' ') AS IMPRESSIONNUMBER, 
                      isnull(dbo.PRINTING.QTYRECEIVED, 0) AS QTYRECEIVED, 
                      isnull(dbo.PRINTING.PRINTINGCLOSEDDATE, '') AS PRINTINGCLOSEDDATE, 
                      isnull(dbo.PRINTING.JOBNUMBERALPHA, '') AS JOBNUMBERALPHA, 
                      isnull(dbo.PRINTING.BOARDTRIMSIZEWIDTH, '') AS BOARDTRIMSIZEWIDTH, 
                      isnull(dbo.PRINTING.BOARDTRIMSIZELENGTH, '') AS BOARDTRIMSIZELENGTH
                    FROM dbo.PRINTING
                    WHERE ((dbo.PRINTING.BOOKKEY = @ware_bookkey) AND 
                            (dbo.PRINTING.PRINTINGKEY > 0))
              

              OPEN warehouseprinting

              FETCH NEXT FROM warehouseprinting
                INTO 
                  @cursor_row$PRINTINGKEY$2, 
                  @cursor_row$expr$1$2, 
                  @cursor_row$TENTATIVEQTY$2, 
                  @cursor_row$NOTEKEY$2, 
                  @cursor_row$PRINTINGNUM$2, 
                  @cursor_row$STATUSCODE$2, 
                  @cursor_row$CCESTATUS$2, 
                  @cursor_row$DATECCEFINALIZED$2, 
                  @cursor_row$REQUESTBATCHID$2, 
                  @cursor_row$APPROVEDONDATE$2, 
                  @cursor_row$REQUESTSTATUSCODE$2, 
                  @cursor_row$REQUESTCOMMENT$2, 
                  @cursor_row$REQUESTID$2, 
                  @cursor_row$REQUESTBYNAME$2, 
                  @cursor_row$REQUESTDATETIME$2, 
                  @cursor_row$APPROVEDQTY$2, 
                  @cursor_row$BOOKBULK$2, 
                  @cursor_row$PCEQTY1$2, 
                  @cursor_row$PCEQTY2$2, 
                  @cursor_row$IMPRESSIONNUMBER$2, 
                  @cursor_row$QTYRECEIVED$2, 
                  @cursor_row$PRINTINGCLOSEDDATE$2, 
                  @cursor_row$JOBNUMBERALPHA$2, 
                  @cursor_row$BOARDTRIMSIZEWIDTH$2, 
                  @cursor_row$BOARDTRIMSIZELENGTH$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

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
                            CAST( @ware_logkey AS varchar(100)), 
                            CAST( @ware_warehousekey AS varchar(100)), 
                            'No Printing rows for this title,  inserting blanks in whprinting table', 
                            ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                            'Stored procedure datawarehouse_printing', 
                            'WARE_STORED_PROC', 
                            @ware_system_date
                          )

                      INSERT INTO dbo.WHPRINTING
                        (
                          dbo.WHPRINTING.BOOKKEY, 
                          dbo.WHPRINTING.PRINTINGKEY, 
                          dbo.WHPRINTING.LASTUSERID, 
                          dbo.WHPRINTING.LASTMAINTDATE
                        )
                        VALUES 
                          (
                            @ware_bookkey, 
                            1, 
                            'WARE_STORED_PROC', 
                            @ware_system_date
                          )

                      BREAK 

                    END

                  IF (@cursor_row$REQUESTSTATUSCODE$2 > 0)
                    SET @ware_requeststatus_long = dbo.GENTABLES_LONGDESC_FUNCTION(375, @cursor_row$REQUESTSTATUSCODE$2)
                  ELSE 
                    SET @ware_requeststatus_long = ''

                  IF (@cursor_row$STATUSCODE$2 > 0)
                    SET @ware_printingstatus_long = dbo.GENTABLES_LONGDESC_FUNCTION(64, @cursor_row$STATUSCODE$2)
                  ELSE 
                    SET @ware_printingstatus_long = ''

                  /*  bound book dates specific to printingkey */

                  SET @ware_count = 0

                  SELECT @ware_count = count( * )
                    FROM dbo.BOOKDATES
                    WHERE ((dbo.BOOKDATES.BOOKKEY = @ware_bookkey) AND 
                            (dbo.BOOKDATES.PRINTINGKEY = @cursor_row$PRINTINGKEY$2) AND 
                            (dbo.BOOKDATES.DATETYPECODE = 30))


                  IF ((@@ROWCOUNT > 0) AND 
                          (@ware_count > 0))
                    BEGIN

                      SELECT @ware_actbbdate = isnull(dbo.BOOKDATES.ACTIVEDATE, ''), @ware_estbbdate = isnull(dbo.BOOKDATES.ESTDATE, '')
                        FROM dbo.BOOKDATES
                        WHERE ((dbo.BOOKDATES.BOOKKEY = @ware_bookkey) AND 
                                (dbo.BOOKDATES.PRINTINGKEY = @cursor_row$PRINTINGKEY$2) AND 
                                (dbo.BOOKDATES.DATETYPECODE = 30))


                      IF (@ware_estbbdate = '')
                        SET @ware_estbbdate = @ware_actbbdate
                      ELSE 
                        IF (@ware_actbbdate = '')
                          SET @ware_actbbdate = @ware_estbbdate

                    END

                  /* notes keys  */

                  SET @ware_count = 0

                  SELECT @ware_count = count( * )
                    FROM dbo.NOTE
                    WHERE (dbo.NOTE.NOTEKEY = @cursor_row$NOTEKEY$2)


                  IF ((@@ROWCOUNT > 0) AND 
                          (@ware_count > 0))
                    BEGIN
                      SELECT @ware_notes = isnull(TEXT, '')
                        FROM dbo.NOTE
                        WHERE (dbo.NOTE.NOTEKEY = @cursor_row$NOTEKEY$2)

                    END
                  ELSE 
                    SET @ware_notes = ''

                  INSERT INTO dbo.WHPRINTING
                    (
                      dbo.WHPRINTING.BOOKKEY, 
                      dbo.WHPRINTING.PRINTINGKEY, 
                      dbo.WHPRINTING.PRINTINGNUMBER, 
                      dbo.WHPRINTING.PRINTINGSTATUS, 
                      dbo.WHPRINTING.TENTATIVEQTY, 
                      dbo.WHPRINTING.APPROVEDQTY, 
                      dbo.WHPRINTING.APPROVEDONDATE, 
                      dbo.WHPRINTING.BOOKBULK, 
                      dbo.WHPRINTING.REQUESTBATCHID, 
                      dbo.WHPRINTING.REQUESTSTATUS, 
                      dbo.WHPRINTING.REQUESTID, 
                      dbo.WHPRINTING.REQUESTBYNAME, 
                      dbo.WHPRINTING.REQUESTCOMMENT, 
                      dbo.WHPRINTING.PCEQTY1, 
                      dbo.WHPRINTING.PCEQTY2, 
                      dbo.WHPRINTING.ESTBOUNDBOOKDATE, 
                      dbo.WHPRINTING.ACTUALBOUNDBOOKDATE, 
                      dbo.WHPRINTING.PRINTINGNOTES, 
                      dbo.WHPRINTING.IMPRESSIONNUMBER, 
                      dbo.WHPRINTING.QTYRECEIVED, 
                      dbo.WHPRINTING.PRINTINGCLOSEDDATE, 
                      dbo.WHPRINTING.JOBNUMBERALPHA, 
                      dbo.WHPRINTING.BOARDTRIMSIZEWIDTH, 
                      dbo.WHPRINTING.BOARDTRIMSIZELENGTH, 
                      dbo.WHPRINTING.LASTUSERID, 
                      dbo.WHPRINTING.LASTMAINTDATE
                    )
                    VALUES 
                      (
                        @ware_bookkey, 
                        @cursor_row$PRINTINGKEY$2, 
                        @cursor_row$PRINTINGNUM$2, 
                        @ware_printingstatus_long, 
                        @cursor_row$TENTATIVEQTY$2, 
                        @cursor_row$APPROVEDQTY$2, 
                        @cursor_row$APPROVEDONDATE$2, 
                        @cursor_row$BOOKBULK$2, 
                        @cursor_row$REQUESTBATCHID$2, 
                        @ware_requeststatus_long, 
                        @cursor_row$REQUESTID$2, 
                        @cursor_row$REQUESTBYNAME$2, 
                        @cursor_row$REQUESTCOMMENT$2, 
                        @cursor_row$PCEQTY1$2, 
                        @cursor_row$PCEQTY2$2, 
                        @ware_estbbdate, 
                        @ware_actbbdate, 
                        @ware_notes, 
                        @cursor_row$IMPRESSIONNUMBER$2, 
                        @cursor_row$QTYRECEIVED$2, 
                        @cursor_row$PRINTINGCLOSEDDATE$2, 
                        @cursor_row$JOBNUMBERALPHA$2, 
                        @cursor_row$BOARDTRIMSIZEWIDTH$2, 
                        @cursor_row$BOARDTRIMSIZELENGTH$2, 
                        'WARE_STORED_PROC', 
                        @ware_system_date
                      )

                  IF (@@ROWCOUNT > 0)
                    BEGIN


                      EXEC dbo.DATAWAREHOUSE_COMPONENT @ware_bookkey, @cursor_row$PRINTINGKEY$2, @cursor_row$TENTATIVEQTY$2, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprinting */
                      EXEC dbo.DATAWAREHOUSE_CCE @ware_bookkey, @cursor_row$PRINTINGKEY$2, @cursor_row$TENTATIVEQTY$2, @cursor_row$CCESTATUS$2, @cursor_row$DATECCEFINALIZED$2, @ware_illuspapchgcode, @ware_textpapchgcode, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /*  whfinalcostest */

                      /*  bindingspecs */

                      SET @ware_count = 0
                      SET @ware_cartonqty = 0
                      SET @ware_prepackind = 'N'

                      SELECT @ware_count = count( * )
                        FROM dbo.BINDINGSPECS
                        WHERE ((dbo.BINDINGSPECS.BOOKKEY = @ware_bookkey) AND 
                                (dbo.BINDINGSPECS.PRINTINGKEY = @cursor_row$PRINTINGKEY$2))


                      IF ((@@ROWCOUNT > 0) AND 
                              (@ware_count > 0))
                        BEGIN
                          SELECT @ware_cartonqty = isnull(dbo.BINDINGSPECS.CARTONQTY1, 0), @ware_prepackind = isnull(dbo.BINDINGSPECS.PREPACKIND, 'N')
                            FROM dbo.BINDINGSPECS
                            WHERE ((dbo.BINDINGSPECS.BOOKKEY = @ware_bookkey) AND 
                                    (dbo.BINDINGSPECS.PRINTINGKEY = @cursor_row$PRINTINGKEY$2))


                      /*  materialspecs */

                      EXEC dbo.DATAWAREHOUSE_MATERIALSPECS @ware_bookkey, @cursor_row$PRINTINGKEY$2, @ware_logkey, @ware_warehousekey 

                      /* whprinting */

                      /* printingdates */

                      EXEC dbo.DATAWAREHOUSE_PRINTDATES @ware_bookkey, @cursor_row$PRINTINGKEY$2, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      /* printingdates2 added 12-18-01 not implemented as yet done on DSS5 not PSS5 */

                      EXEC dbo.DATAWAREHOUSE_PRINTDATES2 @ware_bookkey, @cursor_row$PRINTINGKEY$2, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates2 */

                      EXEC dbo.DATAWAREHOUSE_BOOKPRICE_PRTG @ware_bookkey, @cursor_row$PRINTINGKEY$2, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprinting */

                      /* schedules 1 to 20 */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 1, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 2, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 3, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 4, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 5, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 6, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 7, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 8, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 9, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 10, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 11, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 12, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 13, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 14, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 15, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 16, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 17, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 18, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 19, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 20, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 21, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      EXEC dbo.DATAWAREHOUSE_SCHEDULE @ware_bookkey, @cursor_row$PRINTINGKEY$2, 22, @ware_logkey, @ware_warehousekey, @ware_system_date 

                      /* whprintingkeydates */

                      SET @ware_count = 0

                      SELECT @ware_count = count( * )
                        FROM dbo.WHFINALCOSTEST
                        WHERE ((dbo.WHFINALCOSTEST.BOOKKEY = @ware_bookkey) AND 
                                (dbo.WHFINALCOSTEST.PRINTINGKEY = @cursor_row$PRINTINGKEY$2))



                      IF ((@@ROWCOUNT > 0) AND 
                              (@ware_count = 0))
                        BEGIN
                          INSERT INTO dbo.WHFINALCOSTEST
                            (
                              dbo.WHFINALCOSTEST.BOOKKEY, 
                              dbo.WHFINALCOSTEST.PRINTINGKEY, 
                              dbo.WHFINALCOSTEST.CHARGECODEKEY, 
                              dbo.WHFINALCOSTEST.LASTUSERID, 
                              dbo.WHFINALCOSTEST.LASTMAINTDATE
                            )
                            VALUES 
                              (
                                @ware_bookkey, 
                                @cursor_row$PRINTINGKEY$2, 
                                0, 
                                'WARE_STORED_PROC', 
                                @ware_system_date
                              )
                        END

                      SELECT @ware_totaleditioncost = sum(dbo.WHFINALCOSTEST.UNITCOST)
                        FROM dbo.WHFINALCOSTEST
                        WHERE ((dbo.WHFINALCOSTEST.COSTTYPE = 'E') AND 
                                (dbo.WHFINALCOSTEST.BOOKKEY = @ware_bookkey) AND 
                                (dbo.WHFINALCOSTEST.PRINTINGKEY = @cursor_row$PRINTINGKEY$2))




                      SELECT @ware_totalplantcost = sum(dbo.WHFINALCOSTEST.TOTALCOST)
                        FROM dbo.WHFINALCOSTEST
                        WHERE ((dbo.WHFINALCOSTEST.COSTTYPE = 'P') AND 
                                (dbo.WHFINALCOSTEST.BOOKKEY = @ware_bookkey) AND 
                                (dbo.WHFINALCOSTEST.PRINTINGKEY = @cursor_row$PRINTINGKEY$2))


                      IF (@cursor_row$TENTATIVEQTY$2 = 0)
                        SET @ware_totalunitcost = 0
                      ELSE 
                        SET @ware_totalunitcost = (@ware_totaleditioncost + (@ware_totalplantcost / @cursor_row$TENTATIVEQTY$2))

                      UPDATE dbo.WHPRINTING
                        SET dbo.WHPRINTING.TOTALPLANTCOST = @ware_totalplantcost, dbo.WHPRINTING.TOTALEDITIONCOST = @ware_totaleditioncost, dbo.WHPRINTING.UNITCOST = @ware_totalunitcost
                        WHERE ((dbo.WHPRINTING.BOOKKEY = @ware_bookkey) AND 
                                (dbo.WHPRINTING.PRINTINGKEY = @cursor_row$PRINTINGKEY$2))

                    END
                  ELSE 
                    BEGIN
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
                            CAST( @ware_logkey AS varchar(100)), 
                            CAST( @ware_warehousekey AS varchar(100)), 
                            'Unable to insert whprinting table - for printing', 
                            ('Warning/data error bookkey ' + isnull(CAST( @ware_bookkey AS varchar(100)), '') + ' and printingkey ' + isnull(CAST( @cursor_row$PRINTINGKEY$2 AS varchar(100)), '')), 
                            'Stored procedure datawarehouse_printing', 
                            'WARE_STORED_PROC', 
                            @ware_system_date
                          )
                    END

                  FETCH NEXT FROM warehouseprinting
                    INTO 
                      @cursor_row$PRINTINGKEY$2, 
                      @cursor_row$expr$1$2, 
                      @cursor_row$TENTATIVEQTY$2, 
                      @cursor_row$NOTEKEY$2, 
                      @cursor_row$PRINTINGNUM$2, 
                      @cursor_row$STATUSCODE$2, 
                      @cursor_row$CCESTATUS$2, 
                      @cursor_row$DATECCEFINALIZED$2, 
                      @cursor_row$REQUESTBATCHID$2, 
                      @cursor_row$APPROVEDONDATE$2, 
                      @cursor_row$REQUESTSTATUSCODE$2, 
                      @cursor_row$REQUESTCOMMENT$2, 
                      @cursor_row$REQUESTID$2, 
                      @cursor_row$REQUESTBYNAME$2, 
                      @cursor_row$REQUESTDATETIME$2, 
                      @cursor_row$APPROVEDQTY$2, 
                      @cursor_row$BOOKBULK$2, 
                      @cursor_row$PCEQTY1$2, 
                      @cursor_row$PCEQTY2$2, 
                      @cursor_row$IMPRESSIONNUMBER$2, 
                      @cursor_row$QTYRECEIVED$2, 
                      @cursor_row$PRINTINGCLOSEDDATE$2, 
                      @cursor_row$JOBNUMBERALPHA$2, 
                      @cursor_row$BOARDTRIMSIZEWIDTH$2, 
                      @cursor_row$BOARDTRIMSIZELENGTH$2

                END

            --  CLOSE warehouseprinting

           --   DEALLOCATE warehouseprinting

            END
            IF (cursor_status(N'local', N'warehouseprinting') = 1)
              BEGIN
                CLOSE warehouseprinting
                DEALLOCATE warehouseprinting
              END
          END
      END
END
go
grant execute on datawarehouse_printing  to public
go





