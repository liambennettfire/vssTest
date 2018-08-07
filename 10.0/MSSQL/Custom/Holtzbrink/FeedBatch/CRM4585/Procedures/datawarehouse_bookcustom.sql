IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datawarehouse_bookcustom')
BEGIN
  DROP  Procedure  datawarehouse_bookcustom
END
GO
 
  CREATE 
    PROCEDURE dbo.datawarehouse_bookcustom 
        @ware_bookkey integer,
        @ware_logkey integer,
        @ware_warehousekey integer,
        @ware_system_date datetime
    AS
      BEGIN
          DECLARE 
            @ware_count integer,
            @lv_rowcount integer,
            @LV_CUSTOMIND01 varchar(3),
            @LV_CUSTOMIND02 varchar(3),
            @LV_CUSTOMIND03 varchar(3),
            @LV_CUSTOMIND04 varchar(3),
            @LV_CUSTOMIND05 varchar(3),
            @LV_CUSTOMIND06 varchar(3),
            @LV_CUSTOMIND07 varchar(3),
            @LV_CUSTOMIND08 varchar(3),
            @LV_CUSTOMIND09 varchar(3),
            @LV_CUSTOMIND10 varchar(3),
            @LV_CUSTOMCODE01 integer,
            @LV_CUSTOMCODE02 integer,
            @LV_CUSTOMCODE03 integer,
            @LV_CUSTOMCODE04 integer,
            @LV_CUSTOMCODE05 integer,
            @LV_CUSTOMCODE06 integer,
            @LV_CUSTOMCODE07 integer,
            @LV_CUSTOMCODE08 integer,
            @LV_CUSTOMCODE09 integer,
            @LV_CUSTOMCODE10 integer,
            @lv_gentableid integer,
            @lv_custind1 varchar(3),
            @lv_custind2 varchar(3),
            @lv_custind3 varchar(3),
            @lv_custind4 varchar(3),
            @lv_custind5 varchar(3),
            @lv_custind6 varchar(3),
            @lv_custind7 varchar(3),
            @lv_custind8 varchar(3),
            @lv_custind9 varchar(3),
            @lv_custind10 varchar(3),
            @lv_description1 varchar(40),
            @lv_description2 varchar(40),
            @lv_description3 varchar(40),
            @lv_description4 varchar(40),
            @lv_description5 varchar(40),
            @lv_description6 varchar(40),
            @lv_description7 varchar(40),
            @lv_description8 varchar(40),
            @lv_description9 varchar(40),
            @lv_description10 varchar(40)          
          SET @ware_count = 1
          SET @lv_rowcount = 0
          SET @LV_CUSTOMIND01 = ''
          SET @LV_CUSTOMIND02 = ''
          SET @LV_CUSTOMIND03 = ''
          SET @LV_CUSTOMIND04 = ''
          SET @LV_CUSTOMIND05 = ''
          SET @LV_CUSTOMIND06 = ''
          SET @LV_CUSTOMIND07 = ''
          SET @LV_CUSTOMIND08 = ''
          SET @LV_CUSTOMIND09 = ''
          SET @LV_CUSTOMIND10 = ''
          SET @LV_CUSTOMCODE01 = 0
          SET @LV_CUSTOMCODE02 = 0
          SET @LV_CUSTOMCODE03 = 0
          SET @LV_CUSTOMCODE04 = 0
          SET @LV_CUSTOMCODE05 = 0
          SET @LV_CUSTOMCODE06 = 0
          SET @LV_CUSTOMCODE07 = 0
          SET @LV_CUSTOMCODE08 = 0
          SET @LV_CUSTOMCODE09 = 0
          SET @LV_CUSTOMCODE10 = 0
          SET @lv_gentableid = 0
          SET @lv_custind1 = ''
          SET @lv_custind2 = ''
          SET @lv_custind3 = ''
          SET @lv_custind4 = ''
          SET @lv_custind5 = ''
          SET @lv_custind6 = ''
          SET @lv_custind7 = ''
          SET @lv_custind8 = ''
          SET @lv_custind9 = ''
          SET @lv_custind10 = ''
          SET @lv_description1 = ''
          SET @lv_description2 = ''
          SET @lv_description3 = ''
          SET @lv_description4 = ''
          SET @lv_description5 = ''
          SET @lv_description6 = ''
          SET @lv_description7 = ''
          SET @lv_description8 = ''
          SET @lv_description9 = ''
          SET @lv_description10 = ''
          BEGIN

            /*
             -- do this insert before add whtitlecustom to the incremental -- ONE TIME INSERT
             -- insert into whtitlecustom
             -- (bookkey,lastuserid,lastmaintdate)
             -- select w.bookkey,'WARE_STORED_PROC', sysdate
             -- from whtitleinfo w;
             -- commit;
             --*/

            SET @lv_rowcount = 0

            SELECT @lv_rowcount = count( * )
              FROM dbo.BOOKCUSTOM
              WHERE (dbo.BOOKCUSTOM.BOOKKEY = @ware_bookkey)

            IF (@lv_rowcount = 0)
              BEGIN
                INSERT INTO dbo.WHTITLECUSTOM
                  (dbo.WHTITLECUSTOM.BOOKKEY, dbo.WHTITLECUSTOM.LASTUSERID, dbo.WHTITLECUSTOM.LASTMAINTDATE)
                  VALUES (@ware_bookkey, 'WARE_STORED_PROC', @ware_system_date)
                IF (@@TRANCOUNT > 0)
                    COMMIT WORK
              END
            ELSE 
              BEGIN

                SELECT 
                    @LV_CUSTOMIND01 = dbo.BOOKCUSTOM.CUSTOMIND01, 
                    @LV_CUSTOMIND02 = dbo.BOOKCUSTOM.CUSTOMIND02, 
                    @LV_CUSTOMIND03 = dbo.BOOKCUSTOM.CUSTOMIND03, 
                    @LV_CUSTOMIND04 = dbo.BOOKCUSTOM.CUSTOMIND04, 
                    @LV_CUSTOMIND05 = dbo.BOOKCUSTOM.CUSTOMIND05, 
                    @LV_CUSTOMIND06 = dbo.BOOKCUSTOM.CUSTOMIND06, 
                    @LV_CUSTOMIND07 = dbo.BOOKCUSTOM.CUSTOMIND07, 
                    @LV_CUSTOMIND08 = dbo.BOOKCUSTOM.CUSTOMIND08, 
                    @LV_CUSTOMIND09 = dbo.BOOKCUSTOM.CUSTOMIND09, 
                    @LV_CUSTOMIND10 = dbo.BOOKCUSTOM.CUSTOMIND10, 
                    @LV_CUSTOMCODE01 = dbo.BOOKCUSTOM.CUSTOMCODE01, 
                    @LV_CUSTOMCODE02 = dbo.BOOKCUSTOM.CUSTOMCODE02, 
                    @LV_CUSTOMCODE03 = dbo.BOOKCUSTOM.CUSTOMCODE03, 
                    @LV_CUSTOMCODE04 = dbo.BOOKCUSTOM.CUSTOMCODE04, 
                    @LV_CUSTOMCODE05 = dbo.BOOKCUSTOM.CUSTOMCODE05, 
                    @LV_CUSTOMCODE06 = dbo.BOOKCUSTOM.CUSTOMCODE06, 
                    @LV_CUSTOMCODE07 = dbo.BOOKCUSTOM.CUSTOMCODE07, 
                    @LV_CUSTOMCODE08 = dbo.BOOKCUSTOM.CUSTOMCODE08, 
                    @LV_CUSTOMCODE09 = dbo.BOOKCUSTOM.CUSTOMCODE09, 
                    @LV_CUSTOMCODE10 = dbo.BOOKCUSTOM.CUSTOMCODE10
                  FROM dbo.BOOKCUSTOM
                  WHERE (dbo.BOOKCUSTOM.BOOKKEY = @ware_bookkey)

                IF (@LV_CUSTOMIND01 = 1)
                  SET @lv_custind1 = 'Yes'
                ELSE 
                  SET @lv_custind1 = 'No'

                IF (@LV_CUSTOMIND02 = 1)
                  SET @lv_custind2 = 'Yes'
                ELSE 
                  SET @lv_custind2 = 'No'

                IF (@LV_CUSTOMIND03 = 1)
                  SET @lv_custind3 = 'Yes'
                ELSE 
                  SET @lv_custind3 = 'No'

                IF (@LV_CUSTOMIND04 = 1)
                  SET @lv_custind4 = 'Yes'
                ELSE 
                  SET @lv_custind4 = 'No'

                IF (@LV_CUSTOMIND05 = 1)
                  SET @lv_custind5 = 'Yes'
                ELSE 
                  SET @lv_custind5 = 'No'

                IF (@LV_CUSTOMIND06 = 1)
                  SET @lv_custind6 = 'Yes'
                ELSE 
                  SET @lv_custind6 = 'No'

                IF (@LV_CUSTOMIND07 = 1)
                  SET @lv_custind7 = 'Yes'
                ELSE 
                  SET @lv_custind7 = 'No'

                IF (@LV_CUSTOMIND08 = 1)
                  SET @lv_custind8 = 'Yes'
                ELSE 
                  SET @lv_custind8 = 'No'

                IF (@LV_CUSTOMIND09 = 1)
                  SET @lv_custind9 = 'Yes'
                ELSE 
                  SET @lv_custind9 = 'No'

                IF (@LV_CUSTOMIND10 = 1)
                  SET @lv_custind10 = 'Yes'
                ELSE 
                  SET @lv_custind10 = 'No'

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE01 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE01')
                                        ))

                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE01')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description1 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE01))
                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE02 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE02')
                                        ))



                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE02')
                                            ))


                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description2 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE02))

                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE03 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE03')
                                        ))
                    
                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE03')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description3 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE03))

                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE04 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE04')
                                        ))

                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE04')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description4 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE04))

                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE05 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE05')
                                        ))

                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE05')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description5 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE05))

                          END

                      END

                  END

                SET @lv_gentableid = 0
                SET @ware_count = 0

                IF (@LV_CUSTOMCODE06 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE06')
                                        ))

                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE06')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description6 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE06))

                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE07 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE07')
                                        ))

                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE07')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description7 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE07))

                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE08 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE08')
                                        ))

                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE08')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description8 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE08))
                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE09 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE09')
                                        ))


                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE09')
                                            ))


                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description9 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE09))
                          END

                      END

                  END

                SET @lv_gentableid = 0

                SET @ware_count = 0

                IF (@LV_CUSTOMCODE10 > 0)
                  BEGIN

                    SELECT @ware_count = count( * )
                      FROM dbo.GENTABLESDESC g
                      WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                        ( 
                                          SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                            FROM dbo.CUSTOMFIELDSETUP c
                                            WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE10')
                                        ))


                    IF (@ware_count > 0)
                      BEGIN

                        SELECT @lv_gentableid = g.TABLEID
                          FROM dbo.GENTABLESDESC g
                          WHERE (upper(rtrim(g.TABLEDESCLONG)) = 
                                            ( 
                                              SELECT upper(rtrim(c.CUSTOMFIELDLABEL))
                                                FROM dbo.CUSTOMFIELDSETUP c
                                                WHERE (upper(c.CUSTOMFIELDNAME) = 'CUSTOMCODE10')
                                            ))

                        IF (@lv_gentableid > 0)
                          BEGIN
                            SELECT @lv_description10 = dbo.GENTABLES.DATADESC
                              FROM dbo.GENTABLES
                              WHERE ((dbo.GENTABLES.TABLEID = @lv_gentableid) AND 
                                      (dbo.GENTABLES.DATACODE = @LV_CUSTOMCODE10))

                          END

                      END

                  END

                INSERT INTO dbo.WHTITLECUSTOM
                  (
                    dbo.WHTITLECUSTOM.BOOKKEY, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO01, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO02, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO03, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO04, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO05, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO06, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO07, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO08, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO09, 
                    dbo.WHTITLECUSTOM.CUSTOMYESNO10, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC01, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC02, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC03, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC04, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC05, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC06, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC07, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC08, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC09, 
                    dbo.WHTITLECUSTOM.CUSTOMDESC10, 
                    dbo.WHTITLECUSTOM.CUSTOMINT01, 
                    dbo.WHTITLECUSTOM.CUSTOMINT02, 
                    dbo.WHTITLECUSTOM.CUSTOMINT03, 
                    dbo.WHTITLECUSTOM.CUSTOMINT04, 
                    dbo.WHTITLECUSTOM.CUSTOMINT05, 
                    dbo.WHTITLECUSTOM.CUSTOMINT06, 
                    dbo.WHTITLECUSTOM.CUSTOMINT07, 
                    dbo.WHTITLECUSTOM.CUSTOMINT08, 
                    dbo.WHTITLECUSTOM.CUSTOMINT09, 
                    dbo.WHTITLECUSTOM.CUSTOMINT10, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT01, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT02, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT03, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT04, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT05, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT06, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT07, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT08, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT09, 
                    dbo.WHTITLECUSTOM.CUSTOMFLOAT10, 
                    dbo.WHTITLECUSTOM.LASTUSERID, 
                    dbo.WHTITLECUSTOM.LASTMAINTDATE
                  )
                  SELECT 
                      @ware_bookkey, 
                      @LV_CUSTOMIND01, 
                      @LV_CUSTOMIND02, 
                      @LV_CUSTOMIND03, 
                      @LV_CUSTOMIND04, 
                      @LV_CUSTOMIND05, 
                      @LV_CUSTOMIND06, 
                      @LV_CUSTOMIND07, 
                      @LV_CUSTOMIND08, 
                      @LV_CUSTOMIND09, 
                      @LV_CUSTOMIND10, 
                      @lv_description1, 
                      @lv_description2, 
                      @lv_description3, 
                      @lv_description4, 
                      @lv_description5, 
                      @lv_description6, 
                      @lv_description7, 
                      @lv_description8, 
                      @lv_description9, 
                      @lv_description10, 
                      dbo.BOOKCUSTOM.CUSTOMINT01, 
                      dbo.BOOKCUSTOM.CUSTOMINT02, 
                      dbo.BOOKCUSTOM.CUSTOMINT03, 
                      dbo.BOOKCUSTOM.CUSTOMINT04, 
                      dbo.BOOKCUSTOM.CUSTOMINT05, 
                      dbo.BOOKCUSTOM.CUSTOMINT06, 
                      dbo.BOOKCUSTOM.CUSTOMINT07, 
                      dbo.BOOKCUSTOM.CUSTOMINT08, 
                      dbo.BOOKCUSTOM.CUSTOMINT09, 
                      dbo.BOOKCUSTOM.CUSTOMINT10, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT01, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT02, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT03, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT04, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT05, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT06, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT07, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT08, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT09, 
                      dbo.BOOKCUSTOM.CUSTOMFLOAT10, 
                      'WARE_STORED_PROC', 
                      @ware_system_date
                    FROM dbo.BOOKCUSTOM
                    WHERE (dbo.BOOKCUSTOM.BOOKKEY = @ware_bookkey)

                IF (@@ROWCOUNT = 0) begin
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
                          'Unable to update whtitlecustom table - for book custom', 
                          ('Warning/data error bookkey' + isnull(CAST( @ware_bookkey AS varchar(30)), '')), 
                          'Stored procedure datawarehouse_bookcustom', 
                          'WARE_STORED_PROC', 
                          @ware_system_date
                        )

                  END

              END

          END
      END
go
grant execute on datawarehouse_bookcustom  to public
go
