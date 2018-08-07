IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_materialspecs')
BEGIN
  DROP  Procedure  datawarehouse_materialspecs
END
GO

  CREATE 
    PROCEDURE dbo.datawarehouse_materialspecs 
        @ware_bookkey integer,
        @ware_printingkey integer,
        @ware_logkey integer,
        @ware_warehousekey integer
    AS
      BEGIN
          DECLARE 
            @cursor_row$MATERIALKEY integer,
            @cursor_row$STOCKTYPECODE integer,
            @cursor_row$BASISWEIGHT integer,
            @cursor_row$CALIPER integer,
            @cursor_row$PAPERBULK integer,
            @cursor_row$ALLOCATION integer,
            @cursor_row$REQUESTSTATUS char(8000),
            @ware_count integer,
            @ware_stocktype_long varchar(40),
            @ware_basisweight_long varchar(40),
            @ware_paperstatus varchar(10)          
          SET @ware_count = 1
          SET @ware_stocktype_long = ''
          SET @ware_basisweight_long = ''
          SET @ware_paperstatus = ''
          BEGIN
            BEGIN

              DECLARE 
                @cursor_row$MATERIALKEY$2 integer,
                @cursor_row$STOCKTYPECODE$2 integer,
                @cursor_row$BASISWEIGHT$2 integer,
                @cursor_row$CALIPER$2 integer,
                @cursor_row$PAPERBULK$2 integer,
                @cursor_row$ALLOCATION$2 integer,
                @cursor_row$REQUESTSTATUS$2 char(8000)              

              DECLARE 
                warehousematerial CURSOR LOCAL 
                 FOR 
                  SELECT 
                      isnull(m.MATERIALKEY, 0),
                      isnull(m.STOCKTYPECODE, 0),
                      isnull(m.BASISWEIGHT, 0),
                      isnull(m.CALIPER, 0),
                      isnull(m.PAPERBULK, 0),
                      isnull(m.ALLOCATION, 0),
                      isnull(mq.REQUESTSTATUS, '')
                    FROM dbo.MATERIALSPECS m
                       LEFT JOIN dbo.MATREQUEST mq  ON (m.MATERIALKEY = mq.MATERIALKEY)
                    WHERE ((m.BOOKKEY = @ware_bookkey) AND 
                            (m.PRINTINGKEY = @ware_printingkey))
              

              OPEN warehousematerial

              FETCH NEXT FROM warehousematerial
                INTO 
                  @cursor_row$MATERIALKEY$2, 
                  @cursor_row$STOCKTYPECODE$2, 
                  @cursor_row$BASISWEIGHT$2, 
                  @cursor_row$CALIPER$2, 
                  @cursor_row$PAPERBULK$2, 
                  @cursor_row$ALLOCATION$2, 
                  @cursor_row$REQUESTSTATUS$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BREAK 

                  IF (@ware_count < 3)
                    BEGIN

                      IF (@cursor_row$STOCKTYPECODE$2 > 0)
                        SET @ware_stocktype_long = dbo.GENTABLES_LONGDESC_FUNCTION(27, @cursor_row$STOCKTYPECODE$2)
                      ELSE 
                        SET @ware_stocktype_long = ''

                      IF (@cursor_row$BASISWEIGHT$2 > 0)
                        SET @ware_basisweight_long = dbo.GENTABLES_LONGDESC_FUNCTION(47, @cursor_row$BASISWEIGHT$2)
                      ELSE 
                        SET @ware_basisweight_long = ''

                      IF (@cursor_row$REQUESTSTATUS$2 = 'A')
                        SET @ware_paperstatus = 'A'
                      ELSE 
                        IF (@cursor_row$REQUESTSTATUS$2 = 'R')
                          SET @ware_paperstatus = 'R'
                        ELSE 
                          IF (@cursor_row$REQUESTSTATUS$2 = 'C')
                            SET @ware_paperstatus = 'C'
                          ELSE 
                            SET @ware_paperstatus = ''

                      IF (@ware_count = 1)
                        BEGIN
                          UPDATE dbo.WHPRINTING
                            SET 
                              dbo.WHPRINTING.PAPERTYPE1 = @ware_stocktype_long, 
                              dbo.WHPRINTING.PAPERALLOCATION1 = @cursor_row$ALLOCATION$2, 
                              dbo.WHPRINTING.PAPERSTATUS1 = @ware_paperstatus, 
                              dbo.WHPRINTING.BASISWEIGHT1 = @ware_basisweight_long, 
                              dbo.WHPRINTING.CALIPER1 = @cursor_row$CALIPER$2, 
                              dbo.WHPRINTING.PPI1 = @cursor_row$PAPERBULK$2
                            WHERE ((dbo.WHPRINTING.BOOKKEY = @ware_bookkey) AND 
                                    (dbo.WHPRINTING.PRINTINGKEY = @ware_printingkey))
                          
                             
                        END
                      ELSE 
                        BEGIN
                          UPDATE dbo.WHPRINTING
                            SET 
                              dbo.WHPRINTING.PAPERTYPE2 = @ware_stocktype_long, 
                              dbo.WHPRINTING.PAPERALLOCATION2 = @cursor_row$ALLOCATION$2, 
                              dbo.WHPRINTING.PAPERSTATUS2 = @ware_paperstatus, 
                              dbo.WHPRINTING.BASISWEIGHT2 = @ware_basisweight_long, 
                              dbo.WHPRINTING.CALIPER2 = @cursor_row$CALIPER$2, 
                              dbo.WHPRINTING.PPI2 = @cursor_row$PAPERBULK$2
                            WHERE ((dbo.WHPRINTING.BOOKKEY = @ware_bookkey) AND 
                                    (dbo.WHPRINTING.PRINTINGKEY = @ware_printingkey))
                          
                             
                        END

                      SET @ware_count = (@ware_count + 1)

                    END

                  FETCH NEXT FROM warehousematerial
                    INTO 
                      @cursor_row$MATERIALKEY$2, 
                      @cursor_row$STOCKTYPECODE$2, 
                      @cursor_row$BASISWEIGHT$2, 
                      @cursor_row$CALIPER$2, 
                      @cursor_row$PAPERBULK$2, 
                      @cursor_row$ALLOCATION$2, 
                      @cursor_row$REQUESTSTATUS$2

                END

              CLOSE warehousematerial

              DEALLOCATE warehousematerial

            END
            IF (cursor_status(N'local', N'warehousematerial') = 1)
              BEGIN
                CLOSE warehousematerial
                DEALLOCATE warehousematerial
              END
          END
      END
go
go
grant execute on datawarehouse_materialspecs  to public
go




