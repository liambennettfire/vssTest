IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_base_full_uncond')
BEGIN
  DROP  Procedure  datawarehouse_base_full_uncond
END
GO

  CREATE 
    PROCEDURE dbo.datawarehouse_base_full_uncond 
    AS
       BEGIN
          DECLARE 
            @cursor_row$BOOKKEY integer,
            @err_msg varchar(200),
            @ware_count integer,
            @ware_total integer,
            @ware_count2 integer,
            @ware_warehousekey integer,
            @ware_newhousekey integer,
            @ware_activeind numeric(3, 0),
            @ware_logkey integer,
            @ware_illuspapchgcode integer,
            @ware_textpapchgcode integer,
            @ware_lastbookkey integer,
            @ware_system_date datetime,
            @ware_company varchar(20),
            @ware_lasttypeofbuild varchar(30),
            @ware_laststarttime datetime,
            @ware_lastendtime datetime,
            @ware_lastrowsprocessed integer,
            @ware_lasttotalrows integer,
            @ware_associationtypecode integer,
            @ware_associatedtitles_count integer 
          SET @ware_count = 0
          SET @ware_total = 0
          SET @ware_count2 = 0
          SET @ware_warehousekey = 0
          SET @ware_newhousekey = 0
          SET @ware_activeind = 0
          SET @ware_logkey = 0
          SET @ware_illuspapchgcode = 0
          SET @ware_textpapchgcode = 0
          SET @ware_lastbookkey = 0
          SET @ware_company = ''
          SET @ware_lasttypeofbuild = ''
          SET @ware_lastrowsprocessed = 0
          SET @ware_lasttotalrows = 0
          SET @ware_associationtypecode = 0
          SET @ware_associatedtitles_count = 0


            SELECT @ware_system_date = getdate()

            /*  delete all errors older than 1 week */

            DELETE FROM dbo.WHERRORLOG
              WHERE (dbo.WHERRORLOG.LASTMAINTDATE <= (getdate() - 7))


            SELECT @ware_logkey = count( * )
              FROM dbo.WHERRORLOG


            IF (@ware_logkey > 0)
              BEGIN
                SELECT @ware_logkey = max(dbo.WHERRORLOG.LOGKEY)
                  FROM dbo.WHERRORLOG
              END
            ELSE 
              SET @ware_logkey = 1

            SELECT @ware_warehousekey = max(dbo.WHHISTORYINFO.WAREHOUSEKEY)
              FROM dbo.WHHISTORYINFO

	  if @ware_warehousekey is null begin
	     set @ware_warehousekey = 1
	  end
	



            if @ware_warehousekey is null 
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
                      CAST( @ware_logkey AS varchar(8000)), 
                      CAST( @ware_newhousekey AS varchar(8000)), 
                      'Unable to access whtitlehistory - select max(warehousekey)', 
                      'Warning/data error', 
                      'Stored procedure startup', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )

              END
            ELSE 
              BEGIN

                SET @ware_newhousekey = (@ware_warehousekey + 1)
                SET @ware_logkey = (@ware_logkey + 1)

                SELECT @ware_activeind = isnull(dbo.WHHISTORYINFO.ACTIVERUNIND, 0)
                  FROM dbo.WHHISTORYINFO
                  WHERE (dbo.WHHISTORYINFO.WAREHOUSEKEY = @ware_warehousekey)


                IF (@@ROWCOUNT = 0)
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
                          CAST( @ware_logkey AS varchar(8000)), 
                          CAST( @ware_newhousekey AS varchar(8000)), 
                          'Unable to access whtitlehistory - select max(warehousekey)', 
                          'Warning/data error', 
                          'Stored procedure startup', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )

                  END


                IF (@ware_activeind = 1)
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
                        CAST( @ware_newhousekey AS varchar(8000)), 
                        'Status indicates that a Warehouse build already in progress BUT it will be overwritten', 
                        'Warning/data error', 
                        'Stored procedure startup', 
                        'WARE_STORED_PROC', 
                        @ware_system_date
                      )


              END


            /*  insert row into whhistoryinfo for this build */

            INSERT INTO dbo.WHHISTORYINFO
              (
                dbo.WHHISTORYINFO.WAREHOUSEKEY, 
                dbo.WHHISTORYINFO.STARTTIME, 
                dbo.WHHISTORYINFO.ENDTIME, 
                dbo.WHHISTORYINFO.TYPEOFBUILD, 
                dbo.WHHISTORYINFO.ACTIVERUNIND
              )
              VALUES 
                (
                  @ware_newhousekey, 
                  getdate(), 
                   NULL, 
                  'FULL', 
                  1
                )

            SELECT @ware_total = count( * )
              FROM dbo.BOOK
              WHERE ((dbo.BOOK.TEMPLATETYPECODE IS NULL) OR 
                              (dbo.BOOK.TEMPLATETYPECODE = 0))



            SELECT @ware_count = count( * )
              FROM dbo.DEFAULTS

            IF (@ware_count <> 1)
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
                      CAST( @ware_logkey AS varchar(8000)), 
                      CAST( @ware_newhousekey AS varchar(8000)), 
                      'Unable to access defaults table', 
                      'Warning/data error', 
                      'Stored procedure startup', 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    )
              END

            ELSE 
              BEGIN

                SELECT @ware_illuspapchgcode = dbo.DEFAULTS.TEXTPAPERCHGCODE, @ware_textpapchgcode = dbo.DEFAULTS.ILLUSPAPERCHGCODE
                  FROM dbo.DEFAULTS



                SET @ware_count = 0

                /*  truncate table seems to give error on SSPROD */

                TRUNCATE TABLE dbo.WHTITLEINFO
                TRUNCATE TABLE dbo.WHAUTHOR
                TRUNCATE TABLE dbo.WHTITLECLASS
                TRUNCATE TABLE dbo.WHTITLEDATES
                TRUNCATE TABLE dbo.WHTITLEFILES
                TRUNCATE TABLE dbo.WHTITLECOMMENTS
                TRUNCATE TABLE dbo.WHTITLEPERSONNEL
                TRUNCATE TABLE dbo.WHTITLEPREVWORKS
                TRUNCATE TABLE dbo.WHCATALOG
                TRUNCATE TABLE dbo.WHCATALOGTITLE
                TRUNCATE TABLE dbo.WHPRINTING
                TRUNCATE TABLE dbo.WHFINALCOSTEST
                TRUNCATE TABLE dbo.WHEST
                TRUNCATE TABLE dbo.WHESTCOST
                TRUNCATE TABLE dbo.WHSCHEDULE1
                TRUNCATE TABLE dbo.WHSCHEDULE2
                TRUNCATE TABLE dbo.WHSCHEDULE3
                TRUNCATE TABLE dbo.WHSCHEDULE4
                TRUNCATE TABLE dbo.WHSCHEDULE5
                TRUNCATE TABLE dbo.WHPRINTINGKEYDATES
                TRUNCATE TABLE dbo.WHPRINTINGKEYDATES2
                TRUNCATE TABLE dbo.WHTITLECUSTOM
                TRUNCATE TABLE dbo.WHTITLECOMMENTS2
                TRUNCATE TABLE dbo.WHTITLECOMMENTS3
                TRUNCATE TABLE dbo.WHAUTHORSALESTRACK
                TRUNCATE TABLE dbo.WHCOMPETITIVETITLES
                TRUNCATE TABLE dbo.WHCOMPARATIVETITLES
                TRUNCATE TABLE dbo.WHSCHEDULE6
                TRUNCATE TABLE dbo.WHSCHEDULE7
                TRUNCATE TABLE dbo.WHSCHEDULE8
                TRUNCATE TABLE dbo.WHSCHEDULE9
                TRUNCATE TABLE dbo.WHSCHEDULE10
                TRUNCATE TABLE dbo.WHSCHEDULE11
                TRUNCATE TABLE dbo.WHSCHEDULE12
                TRUNCATE TABLE dbo.WHSCHEDULE13
                TRUNCATE TABLE dbo.WHSCHEDULE14
                TRUNCATE TABLE dbo.WHSCHEDULE15
                TRUNCATE TABLE dbo.WHSCHEDULE16
                TRUNCATE TABLE dbo.WHSCHEDULE17
                TRUNCATE TABLE dbo.WHSCHEDULE18
                TRUNCATE TABLE dbo.WHSCHEDULE19
                TRUNCATE TABLE dbo.WHSCHEDULE20
		TRUNCATE TABLE dbo.WHSCHEDULE21
		TRUNCATE TABLE dbo.WHSCHEDULE22
                TRUNCATE TABLE dbo.WHTITLEPOSITIONING


                BEGIN

                  DECLARE 
                    @cursor_row$BOOKKEY$2 integer                  

                  DECLARE 
                    datawarehouse_base CURSOR LOCAL 
                     FOR 
                      SELECT dbo.BOOK.BOOKKEY
                        FROM dbo.BOOK
                        WHERE ((dbo.BOOK.TEMPLATETYPECODE IS NULL) OR 
                                        (dbo.BOOK.TEMPLATETYPECODE = 0))
		      -- and bookkey between 8399285 and 8400128
                       ORDER BY dbo.BOOK.BOOKKEY DESC
                  
                  OPEN datawarehouse_base

                  FETCH NEXT FROM datawarehouse_base
                    INTO @cursor_row$BOOKKEY$2

                  WHILE  NOT(@@FETCH_STATUS = -1)
                    BEGIN

                      EXEC dbo.DATAWAREHOUSE_AUTHOR @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whauthor */

                      EXEC dbo.DATAWAREHOUSE_BOOKINFO @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleinfo and whtitleclass */

                      EXEC dbo.DATAWAREHOUSE_BISAC @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleclass */

                      EXEC dbo.DATAWAREHOUSE_CATEGORY @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleclass */

                      EXEC dbo.DATAWAREHOUSE_AUDIENCE @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleclass */

                      EXEC dbo.DATAWAREHOUSE_ORGENTRY @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleclass */

                      EXEC dbo.DATAWAREHOUSE_BOOKPRICE @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleinfo */

                      EXEC dbo.DATAWAREHOUSE_BOOKDATES @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitledates */

                      EXEC dbo.DATAWAREHOUSE_BOOKFILES @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitlefiles */

                      EXEC dbo.DATAWAREHOUSE_BOOKROLE @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitlepersonnel */

                      EXEC dbo.DATAWAREHOUSE_BOOKCOMMENT @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitlecomments */

                      EXEC dbo.DATAWAREHOUSE_PREVAUTH @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleprevworks */

                      EXEC dbo.DATAWAREHOUSE_PRINTING @cursor_row$BOOKKEY$2, @ware_illuspapchgcode, @ware_textpapchgcode, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whprinting */

                      EXEC dbo.DATAWAREHOUSE_BOOKMISC @cursor_row$BOOKKEY$2, 'WARE_STORED_PROC', @ware_system_date 

                      EXEC dbo.DATAWAREHOUSE_BOOKQTYBREAKDOWN @cursor_row$BOOKKEY$2, @ware_system_date 

                      EXEC dbo.DATAWAREHOUSE_BOOKCUSTOM @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitlecustom */

                      EXEC dbo.DATAWAREHOUSE_AUDIENCE @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitleclass */

                      EXEC dbo.DATAWAREHOUSE_WHTITLECATALOG @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date 

                      /* whtitlecatalog */

                      SET @ware_associatedtitles_count = 0

                      SET @ware_associationtypecode = 3

                      /*  whauthorsalestrack  */

                      EXEC dbo.DATAWAREHOUSE_TITLEPOSITIONING @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date, @ware_associationtypecode 

                      SET @ware_associationtypecode = 1

                      /*  whcompetitivetitles  */

                      EXEC dbo.DATAWAREHOUSE_TITLEPOSITIONING @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date, @ware_associationtypecode 

                      SET @ware_associationtypecode = 2

                      /*  whcomparativetitles  */

                      EXEC dbo.DATAWAREHOUSE_TITLEPOSITIONING @cursor_row$BOOKKEY$2, @ware_logkey, @ware_newhousekey, @ware_system_date, @ware_associationtypecode 

                      EXEC dbo.dw_whtitlepositioning @cursor_row$BOOKKEY$2, @ware_system_date 

                      /*  whtitlepositioning KB  */

                      SET @ware_lastbookkey = @cursor_row$BOOKKEY$2

                      SET @ware_count2 = 0

                      SELECT @ware_count2 = count( * )
                        FROM dbo.BOOKWHUPDATE
                        WHERE (dbo.BOOKWHUPDATE.BOOKKEY = @cursor_row$BOOKKEY$2)


                      IF ((@@ROWCOUNT > 0) AND 
                              (@ware_count2 > 0))
                        BEGIN
                          DELETE FROM dbo.BOOKWHUPDATE
                            WHERE (dbo.BOOKWHUPDATE.BOOKKEY = @cursor_row$BOOKKEY$2)
                          
                              
                        END

                      SET @ware_count = (@ware_count + 1)

                      FETCH NEXT FROM datawarehouse_base
                        INTO @cursor_row$BOOKKEY$2

                    END

                  CLOSE datawarehouse_base

                  DEALLOCATE datawarehouse_base

                END

                /*  Processing catalog */

                EXEC dbo.DATAWAREHOUSE_CATALOG @ware_logkey, @ware_newhousekey, @ware_system_date 

                /*  whcatalog */

                EXEC dbo.DATAWAREHOUSE_CATALOGTITLE @ware_logkey, @ware_newhousekey, @ware_system_date 

                /* whcatalogtitle */

                /* Processing Estimates */

                SELECT @ware_company = upper(dbo.ORGLEVEL.ORGLEVELDESC)
                  FROM dbo.ORGLEVEL
                  WHERE (dbo.ORGLEVEL.ORGLEVELKEY = 1)



                /*  start: calls to estimates commeneted out due to long run time */

                /* if ware_company <> 'CONSUMER' then  /-*not sure exclude ss since inside script account for SS*-/ */

                /* 	datawarehouse_estimate(ware_company,ware_logkey,ware_newhousekey,ware_system_date);  /-*whest/whestcost*-/ */

                /*  */

                /* /-******    2-26-04  runs  P and L full ******-/ */

                /*    datawarehouse_whest_base_full; */

                /* end if; */

                /*  end: calls to estimates commeneted out due to long run time */

                /*  do only if build complete */

                UPDATE dbo.WHHISTORYINFO
                  SET 
                    dbo.WHHISTORYINFO.ENDTIME = getdate(), 
                    dbo.WHHISTORYINFO.ACTIVERUNIND = 0, 
                    dbo.WHHISTORYINFO.TOTALROWS = @ware_total, 
                    dbo.WHHISTORYINFO.ROWSPROCESSED = @ware_count, 
                    dbo.WHHISTORYINFO.LASTUSERID = 'WARE_STORED_PROC', 
                    dbo.WHHISTORYINFO.LASTMAINTDATE = @ware_system_date, 
                    dbo.WHHISTORYINFO.LASTBOOKKEY = @ware_lastbookkey
                  WHERE (dbo.WHHISTORYINFO.WAREHOUSEKEY = @ware_newhousekey)

              END

            IF (cursor_status(N'local', N'datawarehouse_base') = 1)
              BEGIN
                CLOSE datawarehouse_base
                DEALLOCATE datawarehouse_base
              END

      END
go
grant execute on datawarehouse_base_full_uncond  to public
go




