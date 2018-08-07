IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'update_bookedi_bookwh_sp')

BEGIN

  DROP  Procedure  update_bookedi_bookwh_sp

END

GO


   CREATE PROCEDURE update_bookedi_bookwh_sp 
        @p_bookkey INT,
        @p_lastuserid char(30)
    AS
      
      DECLARE 

        @feedin_count2 INT,
        @feedin_count3 INT,
        @i_gen1ind INT      
      BEGIN

         -- CRM 4063 7/12/06 PM: The pupose of this procedure is to force a Eloq re-send if a record is updated.  
         -- It also updates the boowhupdate table so that the warehouse changes as well.
         -- The code was taken from titlehistory_insert
         

         -- 1-11-05 edistatuscode update
         --  check status before update gentables.gen1ind=1 then do not update to resend
         

        SET @feedin_count2 = 0

        SELECT @feedin_count2 = count( * )
          FROM bookedipartner
          WHERE ((printingkey = 1) AND (bookkey = @p_bookkey))


        SET @feedin_count3 = 0

        SELECT @feedin_count3 = count( * )
          FROM bookedistatus
          WHERE ((PRINTINGKEY = 1) AND (BOOKKEY = @p_bookkey))
       


        IF (@feedin_count3 > 0)
          BEGIN

            /* rows present on bookedistatus */

            /* check edistatuscode first */

            SELECT DISTINCT @i_gen1ind = g.gen1ind
              FROM bookedistatus b, gentables g
              WHERE ((b.edistatuscode = g.datacode) AND 
                      (g.tableid = 325) AND 
                      (b.printingkey = 1) AND 
                      (b.bookkey = @p_bookkey))
         


            IF (@i_gen1ind IS NULL)
              SET @i_gen1ind = 0

            IF (@i_gen1ind <> 1)
              IF (@feedin_count2 > 0)
                BEGIN
                  UPDATE bookedipartner
                    SET sendtoeloquenceind = 1, lastuserid = @p_lastuserid, lastmaintdate = getdate()
                    WHERE ((printingkey = 1) AND (bookkey = @p_bookkey))

                  UPDATE bookedistatus
                    SET edistatuscode = 3, lastuserid = @p_lastuserid, lastmaintdate = getdate()
                    WHERE ((printingkey = 1) AND (bookkey = @p_bookkey))
                END

          END
        ELSE 
          BEGIN
            /*  no rows present insert values  */
            IF ((@feedin_count2 > 0) AND 
                    (@i_gen1ind <> 1))
              BEGIN

                UPDATE bookedistatus
                  SET edistatuscode = 3, lastuserid = @p_lastuserid, lastmaintdate = getdate()
                  WHERE ((printingkey = 1) AND (bookkey = @p_bookkey))

                INSERT INTO bookedistatus
                  (edipartnerkey,bookkey,printingkey,edistatuscode,lastuserid,lastmaintdate)
                 SELECT 
                      edipartnerkey,@p_bookkey,1, 3, @p_lastuserid, getdate()
                    FROM bookedipartner
                    WHERE ((printingkey = 1) AND (bookkey = @p_bookkey))

                IF (@@TRANCOUNT > 0)
                    COMMIT WORK

              END
          END

        /*  1-28-03 add bookwhupdate insert for changes only */

        SET @feedin_count3 = 0

        SELECT @feedin_count3 = count( * )
          FROM bookwhupdate
          WHERE (bookkey = @p_bookkey)

        IF (@feedin_count3 = 0)
          BEGIN

            /* insert  */

            INSERT INTO bookwhupdate
              (bookkey, lastmaintdate, lastuserid)
              VALUES (@p_bookkey, getdate(), @p_lastuserid)

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

          END

      END
