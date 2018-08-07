if exists (select * from dbo.sysobjects where id = object_id(N'gentables_shortdesc_function') and xtype in (N'FN', N'IF', N'TF'))
drop function gentables_shortdesc_function
GO

  CREATE 
    FUNCTION dbo.gentables_shortdesc_function 
      (
        @ware_tableid integer,
        @ware_datacode integer
      ) 
      RETURNS varchar(20)
    AS
      BEGIN

        DECLARE 
          @ware_datadescshort varchar(20),
          @ware_count integer        

        SET @ware_count = 0
        BEGIN

          SELECT @ware_count = count( * )
            FROM dbo.GENTABLES
            WHERE ((dbo.GENTABLES.TABLEID = @ware_tableid) AND 
                    (dbo.GENTABLES.DATACODE = @ware_datacode))

          IF ((@@ROWCOUNT > 0) AND 
                  (@ware_count > 0))
            BEGIN

              SELECT @ware_datadescshort = dbo.GENTABLES.DATADESCSHORT
                FROM dbo.GENTABLES
                WHERE ((dbo.GENTABLES.TABLEID = @ware_tableid) AND 
                        (dbo.GENTABLES.DATACODE = @ware_datacode))

              IF (@@ROWCOUNT > 0)
                RETURN @ware_datadescshort
              ELSE 
                RETURN ''

            END
          ELSE 
            RETURN ''

        END
        RETURN null
      END

GO

GRANT EXEC ON dbo.gentables_shortdesc_function TO public
GO