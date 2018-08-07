IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_base_one_est')
BEGIN
  DROP  Procedure  datawarehouse_base_one_est
END
GO

CREATE PROCEDURE dbo.datawarehouse_base_one_est
   @sortorder int,
   @key1 int,   
   @key2 int,  
   @key3 int,   
   @key4 int,  
   @key5 int,
   @lastuserid varchar(max)
AS 
  
   BEGIN
      BEGIN
         DECLARE
           
            @ware_estkey int, 
            @ware_logkey int,
            @ware_warehousekey int,           
            @ware_newhousekey int, 
            @ware_activeind int,
            @i_count int, 
            @ware_system_date datetime, 
            @ware_count int,
            @ware_bookkey int, 
            @ware_printingkey int, 
            @ware_company varchar(100)

         --BEGIN TRY
            SET @ware_logkey = 0
            SET @ware_warehousekey = 0
            SET @ware_newhousekey = 0
            SET @ware_activeind = 0
            SET @i_count = 0
            SET @ware_count = 0
            SET @ware_bookkey = 0
            SET @ware_printingkey = 0
            SET @ware_company = ''
            SET @ware_estkey = @key1

            SELECT @ware_logkey = count_big(*)
            FROM dbo.WHERRORLOG

            IF @ware_logkey > 0
               BEGIN
                  SELECT @ware_logkey = max(WHERRORLOG.LOGKEY)
                  FROM dbo.WHERRORLOG
               END
            ELSE 
               SET @ware_logkey = 1

            SELECT @ware_warehousekey = max(isnull(WHHISTORYINFO.WAREHOUSEKEY, 0))
            FROM dbo.WHHISTORYINFO
            
            SET @ware_newhousekey = @ware_warehousekey + 1
            SET @ware_logkey = @ware_logkey + 1

            SELECT @ware_activeind = isnull(WHHISTORYINFO.ACTIVERUNIND, 0)
            FROM dbo.WHHISTORYINFO
            WHERE WHHISTORYINFO.WAREHOUSEKEY = @ware_warehousekey
        
            SET @i_count = 1

            /** If active ind = 1, loop until the current warehouse completes ** but we won't wait forever  - stop when count hits limit **/

            WHILE @ware_activeind = 1 AND @i_count < 5000
               BEGIN
                  SELECT @ware_activeind = isnull(WHHISTORYINFO.ACTIVERUNIND, 0)
                  FROM dbo.WHHISTORYINFO
                  WHERE WHHISTORYINFO.WAREHOUSEKEY = @ware_warehousekey
                  
                  IF @ware_activeind = 1 AND @i_count = 4999

                     BEGIN
                       /** This means that another  build is still running even after waiting* and we need to exit*/
                        INSERT dbo.WHERRORLOG(
                           LOGKEY, 
                           WAREHOUSEKEY, 
                           ERRORDESC, 
                           ERRORSEVERITY, 
                           ERRORFUNCTION, 
                           LASTUSERID, 
                           LASTMAINTDATE)
                           VALUES (
                              CAST(@ware_logkey AS varchar(max)), 
                              CAST(@ware_newhousekey AS varchar(max)), 
                              'Status indicates that a Warehouse build already in progress. BASE_ONE_EST ending', 
                              'Warning/data error', 
                              'Stored procedure startup', 
                              'WARE_STORED_PROC', 
                              @ware_system_date)
                        /*                commit;*/

                        BREAK
                     END

                  /* End ware_activeind =1*/

                  SET @i_count = @i_count + 1
               END


            /* insert row into whhistoryinfo for this build*/

            INSERT dbo.WHHISTORYINFO(
               WAREHOUSEKEY, 
               STARTTIME, 
               ENDTIME, 
               TYPEOFBUILD, 
               ACTIVERUNIND)
               VALUES (
                  @ware_newhousekey, 
                  getdate(), 
                  NULL, 
                  'ONE_EST', 
                  1)

            SELECT DISTINCT @ware_bookkey = isnull(eb.BOOKKEY, 0), @ware_printingkey = isnull(eb.PRINTINGKEY, 0)
            FROM dbo.ESTBOOK  AS eb
            WHERE eb.ESTKEY = @ware_estkey            
            DELETE dbo.WHEST
            WHERE WHEST.ESTKEY = @ware_estkey
            DELETE dbo.WHESTCOST
            WHERE WHESTCOST.ESTKEY = @ware_estkey

            /*whest*/
			
            EXECUTE dbo.DATAWAREHOUSE_ESTVERSION 
               @WARE_BOOKKEY = @ware_bookkey, 
               @WARE_PRINTINGKEY = @ware_printingkey, 
               @WARE_ESTKEY = @ware_estkey, 
               @WARE_COMPANY = @ware_company, 
               @WARE_LOGKEY = @ware_logkey, 
               @WARE_WAREHOUSEKEY = @ware_newhousekey, 
               @WARE_SYSTEM_DATE = @ware_system_date

            /*incremental P and L*/

            EXECUTE dbo.DATAWAREHOUSE_WHEST_BASE 
               @WARE_ESTKEY = @ware_estkey, 
               @WARE_COMPANY = @ware_company, 
               @WARE_LOGKEY = @ware_logkey, 
               @WARE_WAREHOUSEKEY = @ware_newhousekey, 
               @WARE_SYSTEM_DATE = @ware_system_date

            DELETE dbo.ESTWHUPDATE
            WHERE ESTWHUPDATE.ESTKEY = @ware_estkey

            /* Close out Build be making Active=0*/

            UPDATE dbo.WHHISTORYINFO
               SET 
                  ENDTIME = getdate(), 
                  ACTIVERUNIND = 0, 
                  TOTALROWS = 1, 
                  ROWSPROCESSED = 1, 
                  LASTUSERID = 'WARE_STORED_PROC', 
                  LASTMAINTDATE = @ware_system_date, 
                  LASTBOOKKEY = @ware_bookkey
            WHERE WHHISTORYINFO.WAREHOUSEKEY = @ware_newhousekey

        -- END TRY

--         BEGIN CATCH
--
--            DECLARE
--               @errornumber int
--
--            SET @errornumber = ERROR_NUMBER()
--
--            DECLARE
--               @errormessage nvarchar(4000)
--            SET @errormessage = ERROR_MESSAGE()
--            DECLARE
--               @exceptionidentifier nvarchar(4000)
--
--            SELECT @exceptionidentifier = sysdb.ssma_oracle.db_error_get_oracle_exception_id(@errormessage, @errornumber)
--
--            IF (@exceptionidentifier LIKE N'ORA+00100%')
--               RETURN 
--            ELSE 
--               BEGIN
--                  IF (@exceptionidentifier IS NOT NULL)
--                     BEGIN
--                        IF @errornumber = 59998
--                           RAISERROR(59998, 16, 1, @exceptionidentifier)
--                        ELSE 
--                           RAISERROR(59999, 16, 1, @exceptionidentifier)
--                     END
--                  ELSE 
--                     BEGIN
--                        --EXECUTE sysdb.ssma_oracle.ssma_rethrowerror
--                     END
--				END
--
--         END CATCH

      END

      /* end of BEGIN loop*/

   END
grant execute on datawarehouse_base_one_est to public

