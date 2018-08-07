if exists (select * from dbo.sysobjects where id = object_id(N'dbo.gentables_longdesc_function') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.gentables_longdesc_function
GO

  CREATE 
    FUNCTION dbo.gentables_longdesc_function 
      (
        @ware_tableid integer,
        @ware_datacode integer
      ) 
      RETURNS varchar(40)
    AS
      BEGIN

        DECLARE 
          @ware_datadesc varchar(40),
          @ware_count integer   

        SET @ware_count = 0

        BEGIN

          SELECT @ware_count = count( * )
            FROM GENTABLES
            WHERE ((GENTABLES.TABLEID = @ware_tableid) AND 
                    (GENTABLES.DATACODE = @ware_datacode))


          IF ((@@ROWCOUNT > 0) AND 
                  (@ware_count > 0))
            BEGIN

              SELECT @ware_datadesc = GENTABLES.DATADESC
                FROM GENTABLES
                WHERE ((GENTABLES.TABLEID = @ware_tableid) AND 
                        (GENTABLES.DATACODE = @ware_datacode))

              IF (@@ROWCOUNT > 0)
                RETURN @ware_datadesc
              ELSE 
                RETURN ''

            END
          ELSE 
            RETURN ''

        END


        RETURN null
      END

GO

GRANT EXEC ON dbo.gentables_longdesc_function TO public
GO
