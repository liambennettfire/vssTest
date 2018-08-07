IF EXISTS (SELECT *
             FROM sysobjects
             WHERE type = 'TR'
               AND name = 'bookdate_taqprojecttask_update')
  BEGIN
    DROP TRIGGER bookdate_taqprojecttask_update
  END
GO

CREATE TRIGGER bookdate_taqprojecttask_update
ON taqprojecttask FOR INSERT, UPDATE
AS
  IF update(datetypecode) OR update(activedate) OR update(actualind) OR update(keyind)
    BEGIN

      --this will prevent bookdates trigger to fire back
      CREATE TABLE #dont_fire_taqprojecttask
      (
        DummyCol INT
      )

      DECLARE @v_keyind            INT,
              @v_bookkey           INT,
              @v_printingkey       INT,
              @v_elementkey        INT,
              @v_datetypecode      INT,
              @v_actualind         INT,
              @v_activedate        DATETIME,
              @v_lastmaindate      DATETIME,
              @v_estdate           DATETIME,
              @v_cur_originaldate  DATETIME,
              @v_originaldate      DATETIME,
              @v_orig_originaldate DATETIME,
              @v_orig_datetypecode INT,
              @v_lastuserid        VARCHAR(50),
              @v_sortorder         INT,
              @v_cnt               INT,
              @v_errcode           INT,
              @v_errdesc           VARCHAR(2000),
              @v_historycolumn     VARCHAR(100),
              @v_action            VARCHAR(25),
              @v_historydate_str   VARCHAR(255),
              @v_taqtaskkey        INT,
              @v_keydate_cnt       INT,
              @v_count             INT

      SELECT @v_keyind = i.keyind,
             @v_bookkey = i.bookkey,
             @v_printingkey = coalesce(i.printingkey, 0),
             @v_elementkey = coalesce(i.taqelementkey, 0),
             @v_datetypecode = i.datetypecode,
             @v_actualind = coalesce(i.actualind, 0),
             @v_activedate = i.activedate,
             @v_cur_originaldate = i.originaldate,
             @v_originaldate = d.activedate,
             @v_orig_originaldate = d.originaldate,
             @v_orig_datetypecode = d.datetypecode,
             @v_lastuserid = i.lastuserid,
             @v_lastmaindate = i.lastmaintdate,
             @v_sortorder = i.sortorder,
             @v_taqtaskkey = i.taqtaskkey
        FROM inserted i
          LEFT OUTER JOIN deleted d
            ON i.bookkey = d.bookkey AND
            i.printingkey = d.printingkey AND
            i.datetypecode = d.datetypecode

      IF @v_printingkey <= 0
        BEGIN
          SET @v_printingkey = 1
        END

      -- 01/08/09 Lisa - Replaced the following code:
      --if @v_cur_originaldate is null begin
      -- 01/08/09 with:  (see case 05831)
      IF @v_orig_originaldate IS NULL AND @v_cur_originaldate IS NULL
        BEGIN
          -- Case 12809 - KW - must take taqelementkey into account
          IF @v_elementkey > 0
            UPDATE taqprojecttask
              SET originaldate = @v_originaldate
              WHERE bookkey = @v_bookkey AND
                printingkey = @v_printingkey AND
                datetypecode = @v_datetypecode AND
                taqelementkey = @v_elementkey AND
                taqtaskkey = @v_taqtaskkey
          ELSE
            UPDATE taqprojecttask
              SET originaldate = @v_originaldate
              WHERE bookkey = @v_bookkey AND
                printingkey = @v_printingkey AND
                datetypecode = @v_datetypecode AND
                taqtaskkey = @v_taqtaskkey
        END

      IF @v_actualind = 0
        BEGIN
          IF @v_elementkey > 0
            UPDATE taqprojecttask
              SET reviseddate = @v_activedate
              WHERE taqtaskkey IN (SELECT taqtaskkey
                                     FROM inserted) AND
                datetypecode = @v_datetypecode AND
                taqelementkey = @v_elementkey AND
                taqtaskkey = @v_taqtaskkey
          ELSE
            UPDATE taqprojecttask
              SET reviseddate = @v_activedate
              WHERE taqtaskkey IN (SELECT taqtaskkey
                                     FROM inserted) AND
                datetypecode = @v_datetypecode AND
                taqtaskkey = @v_taqtaskkey
        END /* actualind  = 0 */


      IF @v_keyind = 1 AND @v_bookkey > 0
        BEGIN
          --check if updates are not comming from bookdates trigger
          IF object_id('tempdb..#dont_fire_bookdates') IS NOT NULL
            BEGIN
              RETURN
            END

          SELECT @v_cnt = count(*)
            FROM bookdates
            WHERE bookkey = @v_bookkey
              AND printingkey = @v_printingkey
              AND datetypecode = @v_datetypecode

          SET @v_estdate = @v_activedate
          IF @v_actualind <> 1
            BEGIN
              SET @v_activedate = NULL
            END

          IF @v_cnt = 0
            BEGIN
              SET @v_action = 'insert'

              IF @v_actualind > 0
                BEGIN
                  SET @v_historycolumn = 'activedate'
                  SET @v_historydate_str = cast(@v_activedate AS VARCHAR)

                  SELECT @v_count = 0

                  SELECT @v_count = count(*)
                    FROM gentablesitemtype
                   WHERE tableid = 323
                     AND datacode = @v_datetypecode
                     AND itemtypecode = 1
                     AND relateddatacode = 2

                  IF @v_count = 1 BEGIN
                    IF @v_datetypecode <> 387 BEGIN
                      INSERT
                        INTO bookdates
                          (bookkey,
                           printingkey,
                           datetypecode,
                           activedate,
                           actualind,
                           recentchangeind,
                           lastuserid,
                           lastmaintdate,
                           sortorder)
                        VALUES (@v_bookkey,
                                @v_printingkey,
                                @v_datetypecode,
                                @v_activedate,
                                @v_actualind,
                                1,
                                @v_lastuserid,
                                @v_lastmaindate,
                                @v_sortorder)
                    END
                    IF @v_datetypecode = 387 BEGIN
                      INSERT
                        INTO bookdates
                          (bookkey,
                           printingkey,
                           datetypecode,
                           activedate,
                           bestdate,
                           actualind,
                           recentchangeind,
                           lastuserid,
                           lastmaintdate,
                           sortorder)
                        VALUES (@v_bookkey,
                                @v_printingkey,
                                @v_datetypecode,
                                NULL,
                                @v_activedate,
                                @v_actualind,
                                1,
                                @v_lastuserid,
                                @v_lastmaindate,
                                @v_sortorder)
                    END

                    EXEC qtitle_update_titlehistory 'bookdates', @v_historycolumn, @v_bookkey,
                      @v_printingkey, @v_datetypecode, @v_historydate_str, @v_action, @v_lastuserid,
                      0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT
                  END
                END
              ELSE
                BEGIN
                  SET @v_historycolumn = 'estdate'
                  SET @v_historydate_str = cast(@v_estdate AS VARCHAR)

                  SELECT @v_count = 0

                  SELECT @v_count = count(*)
                    FROM gentablesitemtype
                   WHERE tableid = 323
                     AND datacode = @v_datetypecode
                     AND itemtypecode = 1
                     AND relateddatacode = 2

                  IF @v_count = 1 BEGIN
                    IF @v_datetypecode <> 387 BEGIN
                      INSERT
                        INTO bookdates
                          (bookkey,
                           printingkey,
                           datetypecode,
                           activedate,
                           actualind,
                           recentchangeind,
                           lastuserid,
                           lastmaintdate,
                           estdate,
                           sortorder)
                        VALUES (@v_bookkey,
                                @v_printingkey,
                                @v_datetypecode,
                                @v_activedate,
                                @v_actualind,
                                1,
                                @v_lastuserid,
                                @v_lastmaindate,
                                @v_estdate,
                                @v_sortorder)
                    END
                    IF @v_datetypecode = 387 BEGIN
                      INSERT
                        INTO bookdates
                          (bookkey,
                           printingkey,
                           datetypecode,
                           activedate,
                           actualind,
                           recentchangeind,
                           lastuserid,
                           lastmaintdate,
                           estdate,
                           bestdate,
                           sortorder)
                        VALUES (@v_bookkey,
                                @v_printingkey,
                                @v_datetypecode,
                                @v_activedate,
                                @v_actualind,
                                1,
                                @v_lastuserid,
                                @v_lastmaindate,
                                NULL,
                                @v_estdate,
                                @v_sortorder)
                    END

                    EXEC qtitle_update_titlehistory 'bookdates', @v_historycolumn, @v_bookkey,
                        @v_printingkey, @v_datetypecode, @v_historydate_str, @v_action, @v_lastuserid,
                        0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT
                  END
              END
            END
          ELSE
            BEGIN
              SET @v_action = 'update'

              IF @v_actualind > 0
                BEGIN
                  SET @v_historycolumn = 'activedate'
                  SET @v_historydate_str = cast(@v_activedate AS VARCHAR)

                  SELECT @v_count = 0

                  SELECT @v_count = count(*)
                    FROM gentablesitemtype
                   WHERE tableid = 323
                     AND datacode = @v_datetypecode
                     AND itemtypecode = 1
                     AND relateddatacode = 2

                  IF @v_count = 1 BEGIN
                    IF @v_datetypecode <> 387 BEGIN
                      UPDATE bookdates
                        SET bookkey = @v_bookkey,
                            printingkey = @v_printingkey,
                            datetypecode = @v_datetypecode,
                            activedate = @v_activedate,
                            actualind = @v_actualind,
                            lastuserid = @v_lastuserid,
                            lastmaintdate = @v_lastmaindate,
                            sortorder = @v_sortorder
                        WHERE bookkey = @v_bookkey
                          AND printingkey = @v_printingkey
                          AND datetypecode = @v_datetypecode
                    END
                    IF @v_datetypecode = 387 BEGIN
                      UPDATE bookdates
                        SET bookkey = @v_bookkey,
                            printingkey = @v_printingkey,
                            datetypecode = @v_datetypecode,
                            activedate = NULL,
                            bestdate = @v_activedate,
                            actualind = @v_actualind,
                            lastuserid = @v_lastuserid,
                            lastmaintdate = @v_lastmaindate,
                            sortorder = @v_sortorder
                        WHERE bookkey = @v_bookkey
                          AND printingkey = @v_printingkey
                          AND datetypecode = @v_datetypecode
                    END

                    EXEC qtitle_update_titlehistory 'bookdates', @v_historycolumn, @v_bookkey,
                      @v_printingkey, @v_datetypecode, @v_historydate_str, @v_action, @v_lastuserid,
                      0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT
                  END
                END
              ELSE
                BEGIN
                  SET @v_historycolumn = 'estdate'
                  SET @v_historydate_str = cast(@v_estdate AS VARCHAR)

                  SELECT @v_count = 0

                  SELECT @v_count = count(*)
                    FROM gentablesitemtype
                   WHERE tableid = 323
                     AND datacode = @v_datetypecode
                     AND itemtypecode = 1
                     AND relateddatacode = 2

                  IF @v_count = 1 BEGIN
                    IF @v_datetypecode <> 387 BEGIN
                      UPDATE bookdates
                        SET bookkey = @v_bookkey,
                            printingkey = @v_printingkey,
                            datetypecode = @v_datetypecode,
                            activedate = @v_activedate,
                            actualind = @v_actualind,
                            lastuserid = @v_lastuserid,
                            lastmaintdate = @v_lastmaindate,
                            sortorder = @v_sortorder,
                            estdate = @v_estdate
                        WHERE bookkey = @v_bookkey
                          AND printingkey = @v_printingkey
                          AND datetypecode = @v_datetypecode
                    END
                    IF @v_datetypecode = 387 BEGIN
                      UPDATE bookdates
                        SET bookkey = @v_bookkey,
                            printingkey = @v_printingkey,
                            datetypecode = @v_datetypecode,
                            activedate = @v_activedate,
                            actualind = @v_actualind,
                            lastuserid = @v_lastuserid,
                            lastmaintdate = @v_lastmaindate,
                            sortorder = @v_sortorder,
                            estdate = NULL,
                            bestdate = @v_estdate
                        WHERE bookkey = @v_bookkey
                          AND printingkey = @v_printingkey
                          AND datetypecode = @v_datetypecode
                    END

                    EXEC qtitle_update_titlehistory 'bookdates', @v_historycolumn, @v_bookkey,
                      @v_printingkey, @v_datetypecode, @v_historydate_str, @v_action, @v_lastuserid,
                      0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT
                 END
                END
            END

--          EXEC qtitle_update_titlehistory 'bookdates', @v_historycolumn, @v_bookkey,
--          @v_printingkey, @v_datetypecode, @v_historydate_str, @v_action, @v_lastuserid,
--          0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT

        END

      IF (@v_keyind = 0 OR @v_keyind IS NULL) AND @v_bookkey > 0
        BEGIN
          IF @v_orig_datetypecode IS NOT NULL AND @v_datetypecode IS NOT NULL
            BEGIN --only on update!    

              IF object_id('tempdb..#dont_fire_bookdates') IS NOT NULL
                BEGIN
                  RETURN
                END

              CREATE TABLE #dont_fire_bookdates_delete
              (
                DummyCol INT
              )
 
              -- see if there is another key task for the datetype 
              -- we do not want to delete it unless there is a key date
              SELECT @v_keydate_cnt = count(*)
                FROM taqprojecttask
                WHERE bookkey = @v_bookkey
                  AND printingkey = @v_printingkey
                  AND datetypecode = @v_datetypecode
                  AND keyind = 1
                  AND taqtaskkey <> @v_taqtaskkey

              SELECT @v_cnt = count(*)
                FROM bookdates
                WHERE bookkey = @v_bookkey
                  AND printingkey = @v_printingkey
                  AND datetypecode = @v_datetypecode

              IF @v_cnt > 0 AND @v_keydate_cnt = 0
                BEGIN
                  SELECT @v_estdate = estdate,
                         @v_activedate = activedate
                    FROM bookdates
                    WHERE bookkey = @v_bookkey
                      AND printingkey = @v_printingkey
                      AND datetypecode = @v_datetypecode

                  DELETE bookdates
                    WHERE bookkey = @v_bookkey
                      AND
                      printingkey = @v_printingkey
                      AND
                      datetypecode = @v_datetypecode

                  IF @v_estdate IS NOT NULL
                    BEGIN
                      SET @v_action = 'delete'
                      SET @v_historycolumn = 'estdate'

                      EXEC qtitle_update_titlehistory 'bookdates', @v_historycolumn, 
                        @v_bookkey,
                      @v_printingkey, @v_datetypecode, '', @v_action, @v_lastuserid,
                      0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT
                    END

                  IF @v_activedate IS NOT NULL
                    BEGIN
                      SET @v_action = 'delete'
                      SET @v_historycolumn = 'activedate'

                      EXEC qtitle_update_titlehistory 'bookdates', @v_historycolumn, 
                        @v_bookkey,
                      @v_printingkey, @v_datetypecode, '', @v_action, @v_lastuserid,
                      0, '', @v_errcode OUTPUT, @v_errdesc OUTPUT
                    END
                END --@v_cnt > 0
            END --@v_orig_datetypecode = null
        END --(@v_keyind = 0 or @v_keyind is null) and @v_bookkey is not

    END
GO