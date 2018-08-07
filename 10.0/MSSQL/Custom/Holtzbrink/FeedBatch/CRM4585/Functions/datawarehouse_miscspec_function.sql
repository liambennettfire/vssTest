IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.datawarehouse_miscspec_function') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION dbo.datawarehouse_miscspec_function
GO

 CREATE   FUNCTION dbo.datawarehouse_miscspec_function
      (
        @ware_estkey integer,
        @ware_versionkey integer,
        @ware_compkey integer,
        @ware_logkey integer,
        @ware_warehousekey integer
      ) 
      RETURNS varchar(8000)
    AS
      BEGIN

        DECLARE 
          @ware_specstring varchar(2000)        
        BEGIN
            DECLARE 
              @cursor_row$TABLEDESCLONG varchar(255),
              @cursor_row$DATADESC varchar(255),
              @cursor_row$QUANTITY integer            
            BEGIN
              BEGIN

                DECLARE 
                  @cursor_row$TABLEDESCLONG$2 varchar(255),
                  @cursor_row$DATADESC$2 varchar(255),
                  @cursor_row$QUANTITY$2 integer                

                DECLARE 
                  warehousemiscspec CURSOR LOCAL 
                   FOR 
                    SELECT isnull(gd.TABLEDESCLONG, '') AS TABLEDESCLONG, 
			   isnull(g.DATADESC, '') AS DATADESC, 
	                   isnull(e.QUANTITY, 0) AS QUANTITY
                      FROM dbo.ESTMISCSPECS e, dbo.GENTABLES g, dbo.GENTABLESDESC gd, dbo.MISCTYPETABLE m
                      WHERE ((e.DATACODE = g.DATACODE) AND 
                              (e.TABLEID = m.DATACODE) AND 
                              (m.TABLECODE = g.TABLEID) AND 
                              (g.TABLEID = gd.TABLEID) AND 
                              (e.MISCTYPETABLEID = m.TABLEID) AND 
                              (m.TABLEID IN (51, 78, 80, 81 )) AND 
                              (m.TABLECODE NOT IN (409, 2, 12, 23, 52, 53, 416, 85 )) AND 
                              (e.ESTKEY = @ware_estkey) AND 
                              (e.VERSIONKEY = @ware_versionkey) AND 
                              (e.COMPKEY = @ware_compkey))

                OPEN warehousemiscspec

                FETCH NEXT FROM warehousemiscspec
                  INTO @cursor_row$TABLEDESCLONG$2, @cursor_row$DATADESC$2, @cursor_row$QUANTITY$2

                WHILE  NOT(@@FETCH_STATUS = -1)
                  BEGIN

                    IF (@@FETCH_STATUS = -1)
                      BREAK 

                    SET @ware_specstring = isnull(@ware_specstring, '') + isnull(@cursor_row$DATADESC$2, '') + ', '

                    FETCH NEXT FROM warehousemiscspec
                      INTO @cursor_row$TABLEDESCLONG$2, @cursor_row$DATADESC$2, @cursor_row$QUANTITY$2

                  END

                CLOSE warehousemiscspec

                DEALLOCATE warehousemiscspec

              END
              RETURN @ware_specstring
            END
        END


        RETURN null
      END
GO
GRANT EXEC ON dbo.datawarehouse_miscspec_function TO public
GO


