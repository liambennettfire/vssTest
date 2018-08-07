if exists (select * from dbo.sysobjects where id = object_id(N'dbo.gentables_alternatedesc1') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.gentables_alternatedesc1
GO
  CREATE 
    FUNCTION dbo.gentables_alternatedesc1 
      (
        @ware_tableid integer,
        @ware_datacode integer
      ) 
      RETURNS varchar(255)
    AS
  
      BEGIN
        DECLARE 
          @ware_altdesc1 varchar(40),
          @ware_count integer,
          @ware_altdesc1_255 varchar(255)        

        SET @ware_count = 0
        BEGIN
          SELECT @ware_count = count( * )
            FROM dbo.GENTABLES
            WHERE ((dbo.GENTABLES.TABLEID = @ware_tableid) AND 
                    (dbo.GENTABLES.DATACODE = @ware_datacode))

          IF (@@ROWCOUNT > 0 AND @ware_count > 0)
            BEGIN

              SELECT @ware_altdesc1_255 = dbo.GENTABLES.ALTERNATEDESC1
                FROM dbo.GENTABLES
                WHERE ((dbo.GENTABLES.TABLEID = @ware_tableid) AND 
                        (dbo.GENTABLES.DATACODE = @ware_datacode))

              IF (@@ROWCOUNT > 0)
                BEGIN
                  SET @ware_altdesc1 = substring(@ware_altdesc1_255, 1, 40)
                  RETURN @ware_altdesc1
                END
              ELSE 
                RETURN ''

            END
          ELSE 
            RETURN ''

        END

        RETURN null
      END
go
GRANT EXEC ON dbo.gentables_alternatedesc1 TO public
GO

