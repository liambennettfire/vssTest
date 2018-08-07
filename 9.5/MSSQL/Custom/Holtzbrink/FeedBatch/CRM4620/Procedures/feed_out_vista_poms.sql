IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'feed_out_vista_poms')

BEGIN

  DROP  Procedure  feed_out_vista_poms

END

GO

CREATE PROCEDURE feed_out_vista_poms 
    AS
     BEGIN
          DECLARE 
            @ffeeddate datetime,
            @tfeeddate datetime,
            @feed_system_date datetime,
            @error_msg varchar(200),
            @c_recordtype varchar(1),
            @d_datefinalized datetime,
            @d_lastmaint datetime,
            @i_retailprice numeric(15, 2),
            @i_pokey INT,
            @c_supplier varchar(2),
            @c_potype varchar(1),
            @d_duedate varchar(10),
            @d_duedatedate datetime,
            @c_requestbyname varchar(10),
            @c_packpo varchar(1),
            @c_estdetail varchar(1),
				@i_packsize INT,
				@i_binderyqty INT,
				@i_warehouseqty INT,
				@i_bindery INT,
				@i_cartonpal INT,
				@i_stampdies INT,
				@i_coverprint INT,
				@i_covers INT,
				@i_docutext INT,
				@i_endpaper INT,
				@i_endpaprint INT,
				@i_importduty INT,
				@i_inboundfreight INT,
				@i_insertedition INT,
				@i_jacketcover INT,
				@i_jacketprint INT,
				@i_misc INT,
				@i_misc2 INT,
            @f_misc numeric(15, 4),
            @f_misc2 numeric(15, 4),
				@i_multmedma INT,
				@i_paperstock INT,
				@i_plates INT,
				@i_printsupp INT,
				@i_purchfg INT,
				@i_specialmat INT,
				@i_textprint INT,
				@i_alteration INT,
				@i_art INT,
				@i_authorrel INT,
				@i_componentdesig INT,
				@i_composition INT,
				@i_copyedit INT,
				@i_coverjack INT,
				@i_editrel INT,
				@i_freight INT,
				@i_fullservice INT,
				@i_index INT,
				@i_insertplant INT,
				@i_multedit INT, 
				@i_multprod INT,
				@i_offset INT,
				@i_photo INT,
				@i_other INT, 
				@i_other2 INT,
            @f_other numeric(15, 4),
            @f_other2 numeric(15, 4),
				@i_pod INT,
				@i_proofread INT,
				@i_proofs INT,
				@i_research INT,
				@i_sepscan INT,
                @i_text INT,
				@i_textdesign INT,
				@totalpocost INT,
				@unitpocost INT,
				@totalnonpocost INT,
				@unitnonpocost INT,
				@i_totaleditioncost INT,
				@i_totalplantcost INT,
            @f_totalpocost numeric(15, 4),
            @f_unitpocost numeric(15, 4),
            @f_totalnonpocost numeric(15, 4),
            @f_unitnonpocost numeric(15, 4),
            @f_totaleditioncost numeric(15, 4),
            @f_totalplantcost numeric(15, 4),
				@feedout_count INT,
            @feedout_count2 INT,
            @feedout_count3 INT,
            @firstrow numeric(3, 0),
            @i_unitcost INT,
            @c_tolerance varchar(3),
            @i_estunitcost INT,
            @i_estmfrtot INT,
            @c_delcomplete varchar(1),
            @c_completeqty varchar(1),
            @c_completeqtydate varchar(10),
            @c_completeval varchar(1),
            @c_completevaldate varchar(10),
            @c_pocomment varchar(42),
            @i_ppestcost25 INT,
            @i_ppestcost26 INT,
            @i_ppestcost27 INT,
            @i_ppestcost28 INT,
            @i_ppestcost29 INT,
            @i_ppestcost30 INT,
            @i_oriestcost22 INT,
            @i_oriestcost23 INT,
            @i_oriestcost24 INT,
            @i_oriestcost25 INT,
            @i_oriestcost26 INT,
            @i_oriestcost27 INT,
            @i_oriestcost28 INT,
            @i_oriestcost29 INT,
            @i_oriestcost30 INT,
            @c_statuscode varchar(2),
            @i_orderedqty INT,
            @d_gpodate datetime,
            @i_po_smp_pic_tor numeric(3, 0),
            @i_pofsg numeric(3, 0),
            @c_estdetail_old varchar(10),
            @d_processdate datetime,
            @c_estprepresstotal varchar(10),
            @c_expresspoind varchar(4),
            @i_costpresent numeric(3, 0),
            @i_gposhiptovendor_sectionkey INT,
            @cursor_row_bookkey INT,
            @cursor_row_printingnumber INT,
            @cursor_row_ponumber varchar(10),
            @cursor_row_isbn10 varchar(19),
            @cursor_row_recordtype varchar(1),
            @cursor_row2_datacode INT 
       
          SET @error_msg = ''
          SET @c_recordtype = ''
          SET @i_retailprice = 0
          SET @i_pokey = 0
          SET @c_supplier = ''
          SET @c_potype = ''
          SET @d_duedate = ''
          SET @d_duedatedate = ''
          SET @c_requestbyname = ''
          SET @c_packpo = ''
          SET @c_estdetail = ''
          SET @i_packsize = 0
          SET @i_binderyqty = 0
          SET @i_warehouseqty = 0
          SET @i_bindery = 0
          SET @i_cartonpal = 0
          SET @i_stampdies = 0
          SET @i_coverprint = 0
          SET @i_covers = 0
          SET @i_docutext = 0
          SET @i_endpaper = 0
          SET @i_endpaprint = 0
          SET @i_importduty = 0
          SET @i_inboundfreight = 0
          SET @i_insertedition = 0
          SET @i_jacketcover = 0
          SET @i_jacketprint = 0
          SET @i_misc = 0
          SET @i_misc2 = 0
          SET @f_misc = 0
          SET @f_misc2 = 0
          SET @i_multmedma = 0
          SET @i_paperstock = 0
          SET @i_plates = 0
          SET @i_printsupp = 0
          SET @i_purchfg = 0
          SET @i_specialmat = 0
          SET @i_textprint = 0
          SET @i_alteration = 0
          SET @i_art = 0
          SET @i_authorrel = 0
          SET @i_componentdesig = 0
          SET @i_composition = 0
          SET @i_copyedit = 0
          SET @i_coverjack = 0
          SET @i_editrel = 0
          SET @i_freight = 0
          SET @i_fullservice = 0
          SET @i_index = 0
          SET @i_insertplant = 0
          SET @i_multedit = 0
          SET @i_multprod = 0
          SET @i_offset = 0
          SET @i_photo = 0
          SET @i_other = 0
          SET @i_other2 = 0
          SET @f_other = 0
          SET @f_other2 = 0
          SET @i_pod = 0
          SET @i_proofread = 0
          SET @i_proofs = 0
          SET @i_research = 0
          SET @i_sepscan = 0
          SET @i_text = 0
          SET @i_textdesign = 0
          SET @totalpocost = 0
          SET @unitpocost = 0
          SET @totalnonpocost = 0
          SET @unitnonpocost = 0
          SET @i_totaleditioncost = 0
          SET @i_totalplantcost = 0
          SET @f_totalpocost = 0
          SET @f_unitpocost = 0
          SET @f_totalnonpocost = 0
          SET @f_unitnonpocost = 0
          SET @f_totaleditioncost = 0
          SET @f_totalplantcost = 0
          SET @firstrow = 1
          SET @i_unitcost = 0
          SET @c_tolerance = ''
          SET @i_estunitcost = 0
          SET @i_estmfrtot = 0
          SET @c_delcomplete = ''
          SET @c_completeqty = ''
          SET @c_completeqtydate = ''
          SET @c_completeval = ''
          SET @c_completevaldate = ''
          SET @c_pocomment = ''
          SET @i_ppestcost25 = 0
          SET @i_ppestcost26 = 0
          SET @i_ppestcost27 = 0
          SET @i_ppestcost28 = 0
          SET @i_ppestcost29 = 0
          SET @i_ppestcost30 = 0
          SET @i_oriestcost22 = 0
          SET @i_oriestcost23 = 0
          SET @i_oriestcost24 = 0
          SET @i_oriestcost25 = 0
          SET @i_oriestcost26 = 0
          SET @i_oriestcost27 = 0
          SET @i_oriestcost28 = 0
          SET @i_oriestcost29 = 0
          SET @i_oriestcost30 = 0
          SET @c_statuscode = ''
          SET @i_orderedqty = 0
          SET @i_po_smp_pic_tor = 0
          SET @i_pofsg = 0
          SET @c_expresspoind = ''
          SET @i_costpresent = 0
          SET @i_gposhiptovendor_sectionkey = 0
          BEGIN TRY

            /*  9-1-04 CRM 01801: add est.press total column and change ordetype values */

            /* 9-8-04-- all PO should have estdetails T or D */

            /* 9-14-04 change all cdlist unitcost to totalcost  mapping */

            /*
             -- 9-29-04 use expresspoind to set estdetails, rename editioncost and plantcost columns to totalpocost and unitpocost
             --           no longer need unitcost values but will leave in selects
             --*/

            /* 10-14-04 do not send new po's without cost once cost entered will be sent */

            /* 11-15-04 output all estdetail type with cost.. */

            /*
             -- 11-19-04 was getting misc cost from gpocost select since was not using gpokey  fix -- 12-7-04 unfix
             -- /-*12-8-04 jacketcover->jacketprint and note comment get from gpo.notekey
             -- /-*12-20-04 crm 2231 change duedate column map from boundbook date to warehouse date on bookdates (datetypecode47) for
             --            express po still maps to boundbook date.
             -- /-*12-22-04 crm 2254 remove nonpocost for text paper hbpub supplied, internalcode (PSXX)=740979 remove from gpocost as well
             --            as estnonpocost just in case cost accidentally added to gpocost
             -- 1-4-05  reverse out crm 2254 changes until discuss with john
             --*/

            /* 1-24-05 crm 2386 retailprice modify..map pohistory.retailprice if blank map to bookprice */

            /*  not using the powerbuilder application to run but just in case check  */

            SELECT @ffeeddate = SYSDB.SSMA.TO_CHAR_DATE(dbo.POFEEDDATE.FEEDDATE, 'DD-MON-YYYY'), @tfeeddate = SYSDB.SSMA.TO_CHAR_DATE(dbo.POFEEDDATE.TENTATIVEFEEDDATE, 'DD-MON-YYYY')
              FROM pofeeddate
              WHERE (feeddatekey = 6)


            IF (@ffeeddate = @tfeeddate)
              BEGIN

                /*
                 -- powerbuilder app would have changed so not using
                 -- powerbuilder... update for previous day to now
                 --*/

                UPDATE pofeeddate
                  SET tentativefeeddate = getdate()
                 WHERE (feeddatekey = 6) 

                IF (@@TRANCOUNT > 0)
                    COMMIT WORK

              END

            SELECT @ffeeddate = feeddate, @tfeeddate = tentativefeeddate
              FROM pofeeddate
              WHERE (feeddatekey = 6)


            SELECT @feed_system_date = getdate()
      

            DELETE FROM pofeeddate

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

            /* insert basic information into pofeedout table */

            SET @feedout_count = 0

            SET @feedout_count2 = 0

            SET @feedout_count3 = 0

            SELECT @feedout_count = COUNT( * )
              FROM pohistory p, isbn i, book bo
              WHERE ((i.bookkey = bo.bookkey) AND 
                      (i.bookkey = p.bookkey) AND 
                      ((bo.reuseisbnind IS NULL) OR (bo.reuseisbnind = 0)) AND 
                      (p.lastmaintdate > @ffeeddate))

            --1-31-04 add any cost change on previously sent pos          
            SELECT feedout_count2 = COUNT (*)
              FROM gpocost g,
                   gposection gp,
                   gpo go,
                   pohistory p,
                   isbn i,
             		 book bo
             WHERE g.gpokey = gp.gpokey AND 
                   g.gpokey = go.gpokey AND 
                   go.gpostatus = 'F' AND 
                   i.bookkey = bo.bookkey AND 
                   i.bookkey = p.bookkey AND 
                   p.pokey = gp.gpokey AND 
                   p.printingkey = gp.key2 AND 
                   (bo.reuseisbnind IS NULL OR bo.reuseisbnind = 0) AND 
                   g.lastmaintdate >= @ffeeddate              

				-- 2-9-04  pos that are now void and are the finished goods so make recordtype X
            SELECT feedout_count3 = COUNT (*)
              FROM gposection gp,gpo go,isbn i,book bo,pofeedouthistory p
             WHERE go.gpokey = gp.gpokey AND 
                   RTRIM (i.isbn10) = RTRIM (p.isbn10) AND 
                   go.gpostatus = 'V' AND 
                   i.bookkey = bo.bookkey AND 
                   i.bookkey = gp.key1 AND 
                   gp.key2 = CONVERT (NUMERIC, printingnumber) AND 
                   RTRIM (p.ponumber) = RTRIM (go.gponumber) AND 
                   (bo.reuseisbnind IS NULL OR bo.reuseisbnind = 0) AND 
                   go.lastmaintdate >= @ffeeddate


            IF (@feedout_count > 0)
              BEGIN

                INSERT INTO pofeedout
                  (recordname,isbn10,ponumber,printingnumber,orderedqty)
                SELECT DISTINCT 'D ',i.isbn10, 
                      SYSDB.SSMA.RTRIM2_VARCHAR(SYSDB.SSMA.LTRIM2_VARCHAR(p.PONUMBER, ' '), ' '), 
                      p.printingkey, p.quantity
                    FROM pohistory p, isbn i, book bo
                   WHERE ((i.bookkey = bo.bookkey) AND 
                          (i.bookkey = p.bookkey) AND 
                          ((bo.reuseisbnind IS NULL) OR (bo.reuseisbnind = 0)) AND 
                          (p.lastmaintdate >= @ffeeddate))

                /*
                 -- 1-27-04  not accounting for the time portion of date
                 --          if I do <= tentivedate so just do greater than feeddate..
                 --          hopefully I wont need to do just 1 day
                 --          and p.lastmaintdate <= tfeeddate) ;
                 --*/

                /* and p.lastmaintdate >= ffeeddate ; 8-13-03 OLD SELECT */

                IF (@@TRANCOUNT > 0)
                    COMMIT WORK

              END

            IF (@feedout_count2 > 0)
              BEGIN

               INSERT INTO pofeedout(recordname, isbn10, ponumber, printingnumber,orderedqty)
                  SELECT DISTINCT 'D ', isbn10, LTRIM (RTRIM (ponumber) ),p.printingkey, p.quantity
                    FROM gpocost g,gposection gp,gpo go,pohistory p,isbn i,book bo
                   WHERE g.gpokey = gp.gpokey AND 
                         g.gpokey = go.gpokey AND 
                         go.gpostatus = 'F'   AND 
                         i.bookkey = bo.bookkey AND 
                         i.bookkey = p.bookkey  AND 
                         p.pokey = gp.gpokey AND 
                         p.printingkey = gp.key2 AND 
                         (bo.reuseisbnind IS NULL OR bo.reuseisbnind = 0) AND 
                         g.lastmaintdate >= @ffeeddate AND 
                         RTRIM (LTRIM (p.ponumber) ) NOT IN (SELECT RTRIM (LTRIM (ponumber)) FROM pofeedout)
             
                IF (@@TRANCOUNT > 0)
                    COMMIT WORK
              END

            IF (@feedout_count3 > 0)
              BEGIN

                INSERT INTO pofeedout(recordname, recordtype, isbn10, ponumber,printingnumber)
                   SELECT DISTINCT 'D ', 'X', p.isbn10, ponumber, p.printingnumber
                     FROM gposection gp,gpo go,isbn i,book bo,pofeedouthistory p
                    WHERE go.gpokey = gp.gpokey AND 
                          RTRIM (i.isbn10) = RTRIM (p.isbn10) AND 
                          go.gpostatus = 'V'AND 
                          i.bookkey = bo.bookkey AND 
                          i.bookkey = gp.key1 AND 
                          gp.key2 = CONVERT (NUMERIC,printingnumber) AND 
                          RTRIM (p.ponumber) = RTRIM (go.gponumber) AND 
                          (bo.reuseisbnind IS NULL OR bo.reuseisbnind = 0) AND 
                          go.lastmaintdate >= @ffeeddate AND 
                          RTRIM (LTRIM (p.ponumber)) NOT IN (SELECT RTRIM (LTRIM (ponumber)) FROM pofeedout)
                            
                IF (@@TRANCOUNT > 0)
                    COMMIT WORK
              END

            /*  now start updating using the cursor */

            BEGIN

              DECLARE feed_poms CURSOR LOCAL FOR 
                  SELECT DISTINCT 
                      bo.bookkey, 
                      p.printingnumber, 
                      SYSDB.SSMA.RTRIM2_VARCHAR(SYSDB.SSMA.LTRIM2_VARCHAR(p.PONUMBER, ' '), ' ') AS ponumber, 
                      p.isbn10, 
                      isnull(CASE (p.RECORDTYPE + '.') WHEN '.' THEN NULL ELSE p.RECORDTYPE END, '') AS RECORDTYPE
                    FROM pofeedout p, isbn i, book bo
                    WHERE ((i.isbn10 = p.isbn10) AND 
                            (i.bookkey = bo.bookkey) AND 
                            ((bo.reuseisbnind IS NULL) OR 
                                    (bo.reuseisbnind = 0)))
                  ORDER BY p.isbn10
              

              OPEN feed_poms

              FETCH NEXT FROM feed_poms INTO @cursor_row_bookkey,@cursor_row_printingnumber,@cursor_row_ponumber,@cursor_row_isbn10,@cursor_row_recordtype


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      INSERT INTO feederror(batchnumber,processdate,errordesc)
                        VALUES ('16', @feed_system_date, 'WARNING: No pohistory Records Have Been Written Since The Last Feed')

                      UPDATE pofeedate
                        SET feeddate = tentativefeeddate
                        WHERE (feeddatekey = 6)

                      IF (@@TRANCOUNT > 0)
                          COMMIT WORK

                      BREAK 

                    END

                  IF (@firstrow = 1)
                    BEGIN

                      INSERT INTO feederror(batchnumber,processdate,errordesc)
                        VALUES ('16', @feed_system_date, ('POMS Feed Started on ' + isnull(SYSDB.SSMA.TO_CHAR_DATE(@feed_system_date, 'MM/DD/YY HH24:MI:SS'), '')))

                      IF (@@TRANCOUNT > 0)
                          COMMIT WORK

                      SET @firstrow = (@firstrow + 1)

                    END

                  SET @d_datefinalized = ''

                  SET @d_lastmaint = ''

                  SET @i_retailprice = 0

                  SET @i_pokey = 0

                  SET @i_bindery = 0

                  SET @i_cartonpal = 0

                  SET @i_stampdies = 0

                  SET @i_coverprint = 0

                  SET @i_covers = 0

                  SET @i_docutext = 0

                  SET @i_endpaper = 0

                  SET @i_endpaprint = 0

                  SET @i_importduty = 0

                  SET @i_inboundfreight = 0

                  SET @i_insertedition = 0

                  SET @i_jacketcover = 0

                  SET @i_jacketprint = 0

                  SET @i_misc = 0

                  SET @i_misc2 = 0

                  SET @f_misc = 0

                  SET @f_misc2 = 0

                  SET @i_multmedma = 0

                  SET @i_paperstock = 0

                  SET @i_plates = 0

                  SET @i_printsupp = 0

                  SET @i_purchfg = 0

                  SET @i_specialmat = 0

                  SET @i_textprint = 0

                  SET @i_alteration = 0

                  SET @i_art = 0

                  SET @i_authorrel = 0

                  SET @i_componentdesig = 0

                  SET @i_composition = 0

                  SET @i_copyedit = 0

                  SET @i_coverjack = 0

                  SET @i_editrel = 0

                  SET @i_freight = 0

                  SET @i_fullservice = 0

                  SET @i_index = 0

                  SET @i_insertplant = 0

                  SET @i_multedit = 0

                  SET @i_multprod = 0

                  SET @i_offset = 0

                  SET @i_other = 0

                  SET @i_other2 = 0

                  SET @f_other = 0

                  SET @f_other2 = 0

                  SET @i_photo = 0

                  SET @i_pod = 0

                  SET @i_proofread = 0

                  SET @i_proofs = 0

                  SET @i_research = 0

                  SET @i_sepscan = 0

                  SET @i_text = 0

                  SET @i_textdesign = 0

                  SET @totalpocost = 0

                  SET @unitpocost = 0

                  SET @totalnonpocost = 0

                  SET @unitnonpocost = 0

                  SET @i_totaleditioncost = 0

                  SET @i_totalplantcost = 0

                  SET @f_totalpocost = 0

                  SET @f_unitpocost = 0

                  SET @f_totalnonpocost = 0

                  SET @f_unitnonpocost = 0

                  SET @f_totaleditioncost = 0

                  SET @f_totalplantcost = 0

                  SET @c_potype = 'B'

                  /* 10-27-03 per john always B */

                  SET @c_requestbyname = ''

                  SET @d_duedate = ''

                  SET @d_duedatedate = ''

                  SET @c_packpo = 'N'

                  SET @i_packsize = 0

                  SET @c_recordtype = ''

                  SET @c_estdetail = ''

                  SET @i_unitcost = 0

                  SET @c_tolerance = '000'

                  SET @i_estunitcost = 0

                  SET @i_estmfrtot = 0

                  SET @c_delcomplete = ' '

                  SET @c_completeqty = ' '

                  SET @c_completeqtydate = ' '

                  SET @c_completeval = ' '

                  SET @c_completevaldate = ' '

                  SET @c_pocomment = ''

                  SET @i_ppestcost25 = 0

                  SET @i_ppestcost26 = 0

                  SET @i_ppestcost27 = 0

                  SET @i_ppestcost28 = 0

                  SET @i_ppestcost29 = 0

                  SET @i_ppestcost30 = 0

                  SET @i_oriestcost22 = 0

                  SET @i_oriestcost23 = 0

                  SET @i_oriestcost24 = 0

                  SET @i_oriestcost25 = 0

                  SET @i_oriestcost26 = 0

                  SET @i_oriestcost27 = 0

                  SET @i_oriestcost28 = 0

                  SET @i_oriestcost29 = 0

                  SET @i_oriestcost30 = 0

                  SET @c_statuscode = '  '

                  SET @c_supplier = ''

                  SET @i_binderyqty = 0

                  SET @i_warehouseqty = 0

                  SET @i_orderedqty = 0

                  SET @c_expresspoind = ''

                  SET @c_estprepresstotal = ''

                  SET @i_costpresent = 1

                  /* set to cost present will change later if no cost */

                  IF (ISNULL((@cursor_row_recordtype + '.'), '.') = '.')
                    BEGIN

                      SELECT @d_datefinalized = datefinalized, 
                          @d_lastmaint = lastmaintdate, 
                          @i_pokey = pokey, 
                          @i_orderedqty = quantity, 
                          @c_expresspoind = expresspoind
                        FROM pohistory
                        WHERE ((bookkey = @cursor_row_bookkey) AND (printingkey = @cursor_row_printingnumber))

                      IF (@i_pokey > 0)
                        BEGIN

                          SET @feedout_count = 0

                          SELECT @feedout_count = COUNT( * )
                            FROM gpo g, vendor v
                            WHERE ((g.gpokey = @i_pokey) AND (g.vendorkey = v.vendorkey))

                          
                          IF (@feedout_count > 0)
                            BEGIN
                              SELECT @c_supplier = SYSDB.SSMA.SUBSTR3_VARCHAR(v.vendorid, 1, 2)
                                FROM gpo g, vendor v
                               WHERE ((g.gpokey = @i_pokey) AND (g.vendorkey = v.vendorkey)) 
                            END

                        END

                      IF (@d_lastmaint IS NULL)
                        SET @d_lastmaint = ''

                      IF (@d_datefinalized IS NULL)
                        SET @d_datefinalized = ''

                      IF (ISNULL((@c_supplier + '.'), '.') = '.')
                        SET @c_supplier = ' '

                      /*
                       -- 1-30-04 change how get action code use pofeedouthistory table, if present then was previously sent
                       --                gpodate and gpochangenum not always correct because they finalize and amend on the same day
                       --*/

                      SET @c_recordtype = 'I'

                      SET @feedout_count = 0

                      SELECT @feedout_count = COUNT( * )
                        FROM pofeedouthistory
                        WHERE (ponumber = SYSDB.SSMA.RTRIM2_VARCHAR(SYSDB.SSMA.LTRIM2_VARCHAR(@cursor_row_ponumber, ' '), ' '))

                      IF (@feedout_count > 0)
                        SET @c_recordtype = 'A'

                      SET @feedout_count = 0

                      /* 1-24-05 crm 2386.. check for pohistory.retailprice before do sugg list price */

                      SELECT @i_retailprice = retailprice
                        FROM pohistory
                        WHERE (pokey = @i_pokey)

                      IF (@i_retailprice IS NULL)
                        SET @i_retailprice = 0

                      IF (@i_retailprice = 0)
                        BEGIN

                          SELECT @feedout_count = COUNT( * )
                            FROM bookprice
                            WHERE ((bookkey = @cursor_row_bookkey) AND (activeind = 1) AND (currencytypecode = 6) AND (pricetypecode = 11))

                          IF (@feedout_count > 0)
                            BEGIN

                              SET @feedout_count = 0

                              SELECT @feedout_count = MAX(pricekey)
                                FROM bookprice
                               WHERE ((bookkey = @cursor_row_bookkey) AND (activeind = 1) AND (currencytypecode = 6) AND (pricetypecode = 11))

                              SELECT @i_retailprice = isnull(finalprice, budgetprice)
                                FROM bookprice
                                WHERE (pricekey = @feedout_count)
                            END

                        END

                      IF (@i_retailprice IS NULL)
                        SET @i_retailprice = 0

                      IF (@i_retailprice > 0)
                        SET @i_retailprice = (@i_retailprice * 100)
                      ELSE 
                        SET @i_retailprice = 0

                      /*
                       -- 5-28-04  change duedate from gpo.daterequired to pohistory.boundbookdate
                       --   12-22-04 gang po have same ponumber/key
                       --   but different bookkey,printingkey so both rows will be sent double check with doug/john about this
                       --*/

                      SELECT @d_duedatedate = boundbookdate
                        FROM pohistory
                        WHERE ((bookkey = @cursor_row_bookkey) AND 
                                (printingkey = @cursor_row_printingnumber) AND 
                                (pokey = @i_pokey))

                      /* 12-20-04  change only use boundbookkdate for express po.. use datetypecode 47 for regular PO's */

                      IF (@c_expresspoind <> 'Y')
                        BEGIN

                          SET @d_duedatedate = ''

                          SET @feedout_count = 0

                          SELECT @feedout_count = COUNT( * )
                            FROM bookdates
                            WHERE ((bookkey = @cursor_row_bookkey) AND (printingkey = @cursor_row_printingnumber) AND (datetypecode = 47))

                          IF (@feedout_count > 0)
                            BEGIN
                              SELECT @d_duedatedate = bestdate
                                FROM bookdates
                                WHERE ((bookkey = @cursor_row_bookkey) AND (printingkey = @cursor_row_printingnumber) AND (datetypecode = 47))

                            END

                        END

                      /*  p.potype,  c_potype, 10-28-03 always B per john remove from select  */

                      SELECT @c_requestbyname = g.prodcontact
                        FROM gpo g, potype p
                        WHERE ((g.potypekey = p.potypekey) AND (g.gpokey = @i_pokey))

                      /* 10-2-03 change */

                      IF (@d_duedatedate IS NULL)
                        BEGIN
                          SET @d_duedate = ' '
                          SET @d_duedatedate = ''
                        END
                      ELSE 
                        SET @d_duedate = SYSDB.SSMA.TO_CHAR_DATE(@d_duedatedate, 'MM/DD/YYYY')

                      /* 6-29-04 if date same was clearing based on timestamp */

                      IF (SYSDB.SSMA.TRUNC2_DATE(@d_datefinalized, DEFAULT) > SYSDB.SSMA.TRUNC2_DATE(@d_duedatedate, DEFAULT))
                        BEGIN

                          SET @d_duedate = ' '

                          INSERT INTO feederror(batchnumber,processdate,errordesc)
                            VALUES ('16', @feed_system_date, 'Ordered Date > than Due Date, Due Date Cleared')

                          IF (@@TRANCOUNT > 0)
                              COMMIT WORK

                        END

                      SET @feedout_count = 0

                      SELECT @feedout_count = COUNT( * )
                        FROM bindingspecs
                        WHERE ((bookkey = @cursor_row_bookkey) AND (printingkey = @cursor_row_printingnumber))

                      IF (@feedout_count > 0)
                        BEGIN
                          SELECT @c_packpo = isnull(prepackind, 'N'), @i_packsize = isnull(cartonqty1, 0)
                            FROM bindingspecs
                           WHERE ((bookkey = @cursor_row_bookkey) AND (printingkey = @cursor_row_printingnumber))
                        END

                      BEGIN

                        DECLARE feed_cost CURSOR LOCAL FOR 
                            SELECT datacode
                              FROM gentables
                              WHERE (tableid = 461)
                        

                        OPEN feed_cost

                        FETCH NEXT FROM feed_cost INTO @cursor_row2_datacode
                      

                        WHILE  NOT(@@FETCH_STATUS = -1)
                          BEGIN

                            SET @feedout_count = 0

                            SET @unitpocost = 0

                            SET @totalpocost = 0

                            SET @unitnonpocost = 0

                            SET @totalnonpocost = 0

                            SET @f_unitpocost = 0

                            SET @f_totalpocost = 0

                            SET @f_unitnonpocost = 0

                            SET @f_totalnonpocost = 0


                            SELECT feedout_count = COUNT (*)
                              FROM gpocost g, gposection gp, gpo go
                             WHERE g.gpokey = gp.gpokey AND 
                                   g.gpokey = go.gpokey AND 
                                   g.sectionkey = gp.sectionkey AND 
                                   key1 = @cursor_row_bookkey AND 
                                   key2 = @cursor_row_printingnumber AND 
                                   go.gpostatus = 'F' AND 
                                   g.chgcodecode IN (SELECT internalcode FROM cdlist WHERE pofeedcolumncode = @cursor_row2_datacode)
                            --  1-4-05  undo til discuss with john and internalcode <>740979)
                            

                            SELECT f_totalpocost = SUM (totalcost), f_unitpocost = SUM (unitcost)
                              FROM gpocost g, gposection gp, gpo go
                             WHERE g.gpokey = gp.gpokey AND 
                                   g.gpokey = go.gpokey AND 
                                   g.sectionkey = gp.sectionkey AND 
                                   key1 = @cursor_row_bookkey AND 
                                   key2 = @cursor_row_printingnumber AND 
                                   go.gpostatus = 'F' AND 
                                   g.chgcodecode IN (SELECT internalcode FROM cdlist WHERE pofeedcolumncode = @cursor_row2_datacode)
                            --  1-4-05  undo til discuss with john and internalcode <>740979)

                            SET @feedout_count2 = 0

                            SELECT @feedout_count2 = COUNT( * )
                              FROM estnonpocost g, estbook e
                              WHERE ((g.estkey = e.estkey) AND 
                                      (e.bookkey = @cursor_row_bookkey) AND 
                                      (e.printingkey = @cursor_row_printingnumber) AND 
                                      (g.chgcodecode IN ( 
                                            SELECT internalcode
                                              FROM cdlist
                                              WHERE (pofeedcolumncode =  @cursor_row2_datacode))))

                            /* 1-4-05  undo til discuss with john and internalcode <>740979); */

                            IF (@feedout_count2 > 0)
                              BEGIN
                                SELECT @f_totalnonpocost = SUM(g.totalcost), @f_unitnonpocost = SUM(g.unitcost)
                                  FROM estnonpocost g, estbook e
                                 WHERE ((g.estkey = e.estkey) AND 
                                      (e.bookkey = @cursor_row_bookkey) AND 
                                      (e.printingkey = @cursor_row_printingnumber) AND 
                                      (g.chgcodecode IN ( 
                                            SELECT internalcode
                                              FROM cdlist
                                              WHERE (pofeedcolumncode =  @cursor_row2_datacode))))
                               END

                            IF (@f_totalpocost IS NULL)
                              SET @f_totalpocost = 0

                            IF (@f_unitpocost IS NULL)
                              SET @f_unitpocost = 0

                            IF (@f_totalnonpocost IS NULL)
                              SET @f_totalnonpocost = 0

                            IF (@f_unitnonpocost IS NULL)
                              SET @f_unitnonpocost = 0

                            IF (@f_totalpocost > 0)
                              SET @totalpocost = (@f_totalpocost * 100)
                            ELSE 
                              SET @totalpocost = 0

                            IF (@f_unitpocost > 0)
                              SET @unitpocost = (@f_unitpocost * 100)
                            ELSE 
                              SET @unitpocost = 0

                            IF (@f_totalnonpocost > 0)
                              SET @totalnonpocost = (@f_totalnonpocost * 100)
                            ELSE 
                              SET @totalnonpocost = 0

                            IF (@f_unitnonpocost > 0)
                              SET @unitnonpocost = (@f_unitnonpocost * 100)
                            ELSE 
                              SET @unitnonpocost = 0

                            /* edition */

                            IF ( @cursor_row2_datacode = 1)
                              BEGIN
                                /* bindery-- BIXX */
                                SET @i_bindery = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 2)
                              BEGIN
                                /* Cartoning and Palletizing --CPXX */
                                SET @i_cartonpal = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 3)
                              BEGIN
                                /*  Dies: Case, Cv, and Jkt--SDXX,SD01 */
                                SET @i_stampdies = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 4)
                              BEGIN
                                /*  Cover Printing, Paper, Finish--COXX */
                                SET @i_coverprint = (@totalpocost + @totalnonpocost)
                              END

                            /*
                             -- if cursor_row2.datacode = 5 then   --CVXX not using go to 4
                             --                   i_covers :=  totalpocost + totalnonpocost ;
                             --                end if;
                             --*/

                            IF ( @cursor_row2_datacode = 6)
                              BEGIN
                                /*   --DOXX */
                                SET @i_docutext = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 21)
                              BEGIN
                                /* Old-Endpapers - colored  ENXX */
                                SET @i_endpaper = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 7)
                              BEGIN
                                /*  Endpapers - printed  --EPXX */
                                SET @i_endpaprint = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 8)
                              BEGIN
                                /*  Import Duty  --IDXX */
                                SET @i_importduty = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 9)
                              BEGIN
                                /*  FG freight to VA whse--IWXX,IW01,IW02 */
                                SET @i_inboundfreight = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 10)
                              BEGIN
                                /*  Insert Plates, Paper, Insert Reprint Corrx--ITXX,ISXX */
                                SET @i_insertedition = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 12)
                              BEGIN
                                /*  Jacket Plate,Print,Paper,Fin --JPXX 12-8 change from jacketcover to jacketprint */
                                SET @i_jacketprint = (@totalpocost + @totalnonpocost)
                              END

                            /*  Misc MIXX--do at the end */

                            IF ( @cursor_row2_datacode = 14)
                              BEGIN
                                /*  Multmed MA --MMXX */
                                SET @i_multmedma = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 15)
                              BEGIN
                                /*  Text Paper --PSXX */
                                SET @i_paperstock = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 16)
                              BEGIN
                                /* Old-Reprint Plant Cost:dupe fi  --PLXX,PL01,PL03,PL04,CJ04 */
                                SET @i_plates = (@i_plates + @totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 17)
                              BEGIN
                                /*  Text Paper-Printer Supplied--PPXX */
                                SET @i_printsupp = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 18)
                              BEGIN
                                /*  Purchase Finished Goods--PGXX */
                                SET @i_purchfg = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 19)
                              BEGIN
                                /*  Special Materials/Packaging --SMXX */
                                SET @i_specialmat = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 20)
                              BEGIN
                                /* Text Plates,Print--TEXX */
                                SET @i_textprint = (@totalpocost + @totalnonpocost)
                              END

                            /* plant-- 9-14-04 --all go to totalpocost now */

                            IF ( @cursor_row2_datacode = 31)
                              BEGIN
                                /*  Alteration--AL01,AL02,AL03 */
                                SET @i_alteration = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 32)
                              BEGIN
                                /*  Art-ATXX  */
                                SET @i_art = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 33)
                              BEGIN
                                /*  Author Grants--AR01,AR02,AR03 */
                                SET @i_authorrel = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 34)
                              BEGIN
                                /*  Component -CDXX */
                                SET @i_componentdesig = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 35)
                              BEGIN
                                /*  Composition -CM01,CM02,CM03,CM06,CM07,CM99,CM04,CM05 */
                                SET @i_composition = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 36)
                              BEGIN
                                /*  Copyediting -CEXX */
                                SET @i_copyedit = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 37)
                              BEGIN
                                /*  Cover jacket -CJ06,CJ07,CJ99,CJ01,CJ02,CJ03,CJ08,CJ05 */
                                SET @i_coverjack = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 38)
                              BEGIN
                                /* Cover jacket -ER01,ER99 */
                                SET @i_editrel = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 39)
                              BEGIN
                                /*  Component Freight -FRXX */
                                SET @i_freight = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 40)
                              BEGIN
                                /*  Component Freight -FSXX */
                                SET @i_fullservice = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 41)
                              BEGIN
                                /*  Indexing -INXX */
                                SET @i_index = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 42)
                              BEGIN
                                /*  Insert prep, proofs, blues-ISXX */
                                SET @i_insertplant = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 43)
                              BEGIN
                                /*  Mult Edit -ME01,ME02,ME03,ME04,ME05,ME06,ME07,ME99 */
                                SET @i_multedit = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 44)
                              BEGIN
                                /*  Mult Edit -MP01,MP02,MP03,MP04,MP05,MP06,MP07,MP08,MP09,MP10,MP11,MP12,MP99 */
                                SET @i_multprod = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 45)
                              BEGIN
                                /*  Offset -OFXX */
                                SET @i_offset = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 47)
                              BEGIN
                                /* photo-- PH01,PH02 */
                                SET @i_photo = (@totalpocost + @totalnonpocost)
                              END

                            /*  Other OTXX--do at the end */

                            /*
                             -- not using if cursor_row2.datacode = 39 then  pod-- PDXX go to 48
                             --                   i_pod  :=   totalpocost + totalnonpocost ;
                             --                end if;
                             --*/

                            IF ( @cursor_row2_datacode = 49)
                              BEGIN
                                /* Proofreading-- PRXX */
                                SET @i_proofread = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 50)
                              BEGIN
                                /*  proofs and blues-- PB02,PB03,PB01,PB99 */
                                SET @i_proofs = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 51)
                              BEGIN
                                /*  research -- RS01,RS02 */
                                SET @i_research = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 52)
                              BEGIN
                                /*  Text Seps,Scans,Film -- SSXX */
                                SET @i_sepscan = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 53)
                              BEGIN
                                /*  text -- TX01,TX99 */
                                SET @i_text = (@totalpocost + @totalnonpocost)
                              END

                            IF ( @cursor_row2_datacode = 54)
                              BEGIN
                                /*  Text design -- TD01,TDXX */
                                SET @i_textdesign = (@totalpocost + @totalnonpocost)
                              END

                            IF (@totalpocost IS NULL)
                              SET @totalpocost = 0

                            IF (@unitpocost IS NULL)
                              SET @unitpocost = 0

                            FETCH NEXT FROM feed_cost
                              INTO  @cursor_row2_datacode

                          END

                        CLOSE feed_cost

                        DEALLOCATE feed_cost

                      END

                      /*  get misc 1310's  */

                      SELECT @f_misc = SUM(g.totalcost)
                        FROM gpocost g, cdlist c
                        WHERE ((g.chgcodecode = c.internalcode) AND (c.pofeedcolumncode = 13) AND (g.gpokey = @i_pokey))

                      SELECT @f_misc2 = SUM(g.totalcost)
                        FROM estnonpocost g, estbook e, cdlist c
                        WHERE ((g.chgcodecode = c.internalcode) AND 
                                (g.estkey = e.estkey) AND 
                                (c.pofeedcolumncode = 13) AND 
                                (e.bookkey = @cursor_row_bookkey) AND 
                                (e.printingkey = @cursor_row_printingnumber))

                      /*  get other 1410's  */

                      SELECT @f_other = SUM(g.totalcost)
                        FROM gpocost g, cdlist c
                        WHERE ((g.chgcodecode = c.internalcode) AND (c.pofeedcolumncode = 46) AND (g.gpokey = @i_pokey))

                      SELECT @f_other2 = SUM(g.totalcost)
                        FROM estnonpocost g, estbook e, cdlist c
                        WHERE ((g.chgcodecode = c.internalcode) AND 
                                (g.estkey = e.estkey) AND 
                                (c.pofeedcolumncode = 46) AND 
                                (e.bookkey = @cursor_row_bookkey) AND 
                                (e.printingkey = @cursor_row_printingnumber))

                      IF (@f_misc IS NULL)
                        SET @f_misc = 0

                      IF (@f_other IS NULL)
                        SET @f_other = 0

                      IF (@f_misc2 IS NULL)
                        SET @f_misc2 = 0

                      IF (@f_other2 IS NULL)
                        SET @f_other2 = 0

                      SET @f_misc = (@f_misc + @f_misc2)

                      SET @f_other = (@f_other + @f_other2)

                      SET @i_misc = (@f_misc * 100)

                      SET @i_other = (@f_other * 100)

                      SET @feedout_count = 0


                      SELECT feedout_count = COUNT (*)
                        FROM gpocost g, gposection gp, gpo go
                       WHERE g.gpokey = gp.gpokey AND 
                             g.gpokey = go.gpokey AND 
                             g.sectionkey = gp.sectionkey AND 
                             key1 = @cursor_row_bookkey AND 
                             key2 = @cursor_row_printingnumber AND 
                             go.gpostatus = 'F' AND 
                             potag1 = '1310'
                      
                      IF (@feedout_count > 0)
                        BEGIN

                         SELECT f_totaleditioncost = SUM (totalcost)
                           FROM gpocost g, gposection gp, gpo go
                          WHERE g.gpokey = gp.gpokey AND 
                             g.gpokey = go.gpokey AND 
                             g.sectionkey = gp.sectionkey AND 
                             key1 = @cursor_row_bookkey AND 
                             key2 = @cursor_row_printingnumber AND 
                             go.gpostatus = 'F' AND 
                             potag1 = '1310'
                          
                          SET @i_totaleditioncost = (@f_totaleditioncost * 100)
                        END
                      ELSE 
                        SET @i_totaleditioncost = 0

                        SET @feedout_count = 0

							   SELECT feedout_count = COUNT (*)
                         FROM gpocost g, gposection gp, gpo go
                        WHERE g.gpokey = gp.gpokey AND 
										  g.gpokey = go.gpokey AND 
										  g.sectionkey = gp.sectionkey AND 
										  key1 = @cursor_row_bookkey AND 
										  key2 = @cursor_row_printingnumber AND 
										  go.gpostatus = 'F' AND 
										  potag1 = '1410'
                      

                      IF (@feedout_count > 0)
                        BEGIN


								  SELECT f_totalplantcost = SUM (totalcost)
                            FROM gpocost g, gposection gp, gpo go
                           WHERE g.gpokey = gp.gpokey AND 
                                 g.gpokey = go.gpokey AND 
                                 g.sectionkey = gp.sectionkey AND 
                                 key1 = @cursor_row_bookkey AND 
                                 key2 = @cursor_row_printingnumber AND 
                                 go.gpostatus = 'F' AND 
                                 potag1 = '1410'

                         
                          SET @i_totalplantcost = (@f_totalplantcost * 100)
                        END
                      ELSE 
                        SET @i_totalplantcost = 0

                      SET @feedout_count = 0

                      SET @f_totaleditioncost = 0

                      SET @f_totalplantcost = 0

                      SELECT @feedout_count = COUNT( * )
                        FROM estnonpocost g, estbook e, cdlist c
                        WHERE ((g.chgcodecode = c.internalcode) AND 
                                (g.estkey = e.estkey) AND 
                                (c.tag1 = '1310') AND 
                                (e.bookkey = @cursor_row_bookkey) AND 
                                (e.printingkey = @cursor_row_printingnumber))

                      IF (@feedout_count > 0)
                        BEGIN

                          SELECT @f_totaleditioncost = SUM(g.TOTALCOST)
                            FROM estnonpocost g, estbook e, cdlist c
                           WHERE ((g.chgcodecode = c.internalcode) AND 
                                (g.estkey = e.estkey) AND 
                                (c.tag1 = '1310') AND 
                                (e.bookkey = @cursor_row_bookkey) AND 
                                (e.printingkey = @cursor_row_printingnumber))

                          SET @f_totaleditioncost = (@f_totaleditioncost * 100)

                          SET @i_totaleditioncost = (@i_totaleditioncost + @f_totaleditioncost)

                        END

                      SET @feedout_count = 0

                      SELECT @feedout_count = COUNT( * )
                        FROM estnonpocost g, estbook e, cdlist c
                        WHERE ((g.chgcodecode = c.internalcode) AND 
                                (g.estkey = e.estkey) AND 
                                (c.tag1 = '1410') AND 
                                (e.bookkey = @cursor_row_bookkey) AND 
                                (e.printingkey = @cursor_row_printingnumber))


                      IF (@feedout_count > 0)
                        BEGIN

                          SELECT @f_totalplantcost = SUM(g.TOTALCOST)
                           FROM estnonpocost g, estbook e, cdlist c
									WHERE ((g.chgcodecode = c.internalcode) AND 
											  (g.estkey = e.estkey) AND 
											  (c.tag1 = '1410') AND 
											  (e.bookkey = @cursor_row_bookkey) AND 
											  (e.printingkey = @cursor_row_printingnumber))

                          SET @f_totalplantcost = (@f_totalplantcost * 100)

                          SET @i_totalplantcost = (@i_totalplantcost + @f_totalplantcost)

                        END

                      IF ((@c_delcomplete = 'P') OR 
                              (@c_delcomplete = 'Y'))
                        BEGIN

                          /*  get complete qty date */

                          SET @c_completeqtydate = '          '

                          /* default for now */

                          SET @c_completevaldate = '          '

                        END
                      ELSE 
                        BEGIN
                          SET @c_completeqtydate = '          '
                          SET @c_completevaldate = '          '
                        END

                      /* 12-8-04 map notekey from gpo.notekey instead of bookkey,printingkey */

                      SET @feedout_count = 0

                      SELECT @feedout_count = COUNT( * )
                        FROM note n, gpo g
                        WHERE ((g.notekey = n.notekey) AND (g.gpokey = @i_pokey))
                      
                      IF (@feedout_count > 0)
                        BEGIN

                          SET @feedout_count = 0

                          SELECT @c_pocomment = isnull(CASE (SYSDB.SSMA.SUBSTR3_VARCHAR(n.[TEXT], 1, 42) + '.') WHEN '.' THEN NULL ELSE SYSDB.SSMA.SUBSTR3_VARCHAR(n.[TEXT], 1, 42) END, ' ')
                            FROM note n, gpo g
                           WHERE ((g.notekey = n.notekey) AND (g.gpokey = @i_pokey))

                          
                          /* remove non ascii characters from comment */

								  SET @c_pocomment = dbo.replace_xchars(@c_pocomment)
	
								  SET @c_pocomment = replace(@c_pocomment, char(13), ' ')
	
								  SET @c_pocomment = replace(@c_pocomment, char(10), ' ')

                        END

                      /*
                       -- 5-6-04 change
                       -- use gposection.quantity with gposhiptovendor table.. if quantity exists then warehouse
                       --*/

                      SET @feedout_count = 0

                      /* ship to vendor V */

                      SET @i_gposhiptovendor_sectionkey = 0

                      /*  PM 07/26/06 running into issues with setionkeys = 0; this code was put in place to take care of it. */

                      SELECT @i_gposhiptovendor_sectionkey = count( * )
                        FROM gposhiptovendor
                        WHERE ((gpokey = @i_pokey) AND (shiptovendorkey = 222141))


                      
                      IF (@i_gposhiptovendor_sectionkey > 0)
                        BEGIN
                          SELECT @i_gposhiptovendor_sectionkey = gposhiptovendor.sectionkey
                            FROM gposhiptovendor
                           WHERE ((gpokey = @i_pokey) AND (shiptovendorkey = 222141))
                        END

                      SELECT @feedout_count = COUNT( * )
                        FROM gposhiptovendor g, gposection gp
                        WHERE ((g.gpokey = gp.gpokey) AND 
                                (g.sectionkey = @i_gposhiptovendor_sectionkey) AND 
                                (gp.description = 'Print') AND 
                                (gp.gpokey = @i_pokey) AND 
                                (g.shipquantity IS NOT NULL) AND 
                                (g.shiptovendorkey = 222141))

                      IF (@feedout_count > 0)
                        BEGIN

                          SELECT @i_warehouseqty = g.shipquantity
                            FROM gposhiptovendor g, gposection gp
									WHERE ((g.gpokey = gp.gpokey) AND 
											  (g.sectionkey = @i_gposhiptovendor_sectionkey) AND 
											  (gp.description = 'Print') AND 
											  (gp.gpokey = @i_pokey) AND 
											  (g.shipquantity IS NOT NULL) AND 
											  (g.shiptovendorkey = 222141))
                          SET @i_binderyqty = (@i_orderedqty - @i_warehouseqty)

                        END
                      ELSE 
                        BEGIN

                          SET @feedout_count = 0

                          /* ship to vendor V */

                          SELECT @feedout_count = COUNT( * )
                            FROM gposhiptovendor
                           WHERE ((gpokey = @i_pokey) AND (shiptovendorkey = 222141)) 

                         
                          IF (@feedout_count > 0)
                            BEGIN

                              SET @feedout_count = 0

                              SELECT @feedout_count = COUNT( * )
                                FROM component
                                WHERE ((pokey = @i_pokey) AND 
                                        (bookkey = @cursor_row_bookkey) AND 
                                        (printingkey = @cursor_row_printingnumber) AND 
                                        (compkey = 2))
                              /* bind */

                              IF (@feedout_count > 0)
                                BEGIN
                                  SELECT @i_warehouseqty = quantity
                                    FROM component
											  WHERE ((pokey = @i_pokey) AND 
														 (bookkey = @cursor_row_bookkey) AND 
														 (printingkey = @cursor_row_printingnumber) AND 
														 (compkey = 2))
										  END
									 END

                          SET @i_warehouseqty = (@i_orderedqty - @i_binderyqty)

                        END

                      IF (ISNULL((@c_pocomment + '.'), '.') = '.')
                        SET @c_pocomment = ' '

                      IF (@i_warehouseqty IS NULL)
                        SET @i_warehouseqty = 0

                      IF (@i_orderedqty IS NULL)
                        SET @i_orderedqty = 0

                      /* binderyqty = ordered quantity - warehouse qty per john s. */

                      IF (@i_estunitcost IS NULL)
                        SET @i_estunitcost = 0

                      SET @i_estunitcost = (@i_estunitcost * 1000)

                      /* implied 3 decimal removed */

                      /*  1-21-04 only add totalcost (sum(totalcost) * 100) + (sum(unitcost)* 100) */

                      SELECT @i_estmfrtot = (SUM(g.totalcost) * 100)
                        FROM gpocost g
                        WHERE (g.gpokey = @i_pokey)

                      IF (@i_estmfrtot IS NULL)
                        SET @i_estmfrtot = 0

                      IF (@i_estmfrtot > 0)
                        BEGIN

                          SET @feedout_count = 0

                          SET @feedout_count2 = 0

                          SET @feedout_count2 = SYSDB.SSMA.INSTR2_VARCHAR(CAST( @i_estmfrtot AS varchar(8000)), '.')

                          SET @feedout_count = SYSDB.SSMA.LENGTH_VARCHAR(CAST( @i_estmfrtot AS varchar(8000)))

                          IF (@feedout_count2 > 0)
                            SET @i_estmfrtot = SYSDB.SSMA.SUBSTR3_VARCHAR(@i_estmfrtot, 1, (@feedout_count - @feedout_count2))

                        END

                      /*
                       -- 9-29-04 change estdetail select no longer use print component,
                       -- now use pohistory.expesspoind and cost totals was going to use gposection.sectiontype but pohistory easier
                       --*/

                      IF ((@c_expresspoind = 'Y') AND 
                              (@cursor_row_printingnumber = 1))
                        BEGIN

                          /* T if printing 1  */

                          SET @c_estdetail = 'T'

                          SET @c_estprepresstotal = '00000001'

                        END

                      IF ((@c_expresspoind = 'Y') AND 
                              (@cursor_row_printingnumber > 1))
                        BEGIN

                          /*  R if printing > 1 */

                          SET @c_estdetail = 'R'

                          SET @c_estprepresstotal = '00000000'

                        END

                      IF ((@c_expresspoind = 'N') AND 
                              (@i_purchfg = (@i_totaleditioncost + @i_totalplantcost)))
                        IF (@cursor_row_printingnumber = 1)
                          BEGIN

                            /* T if printing = 1  */

                            SET @c_estdetail = 'T'

                            SET @c_estprepresstotal = '00000001'

                          END
                        ELSE 
                          BEGIN
                            SET @c_estdetail = 'R'
                            SET @c_estprepresstotal = '00000000'
                          END

                      IF (ISNULL((@c_estdetail + '.'), '.') = '.')
                        SET @c_estdetail = ' '

                      IF (@c_estdetail = '')
                        SET @c_estdetail = ' '

                      /*  estdetails not already set from above then check for D on Regular POs */

                      IF ((@c_expresspoind = 'N') AND 
                              (@cursor_row_printingnumber = 1) AND 
                              (@c_estdetail = ' '))
                        BEGIN

                          /* D if printing  = 1 */

                          SET @c_estdetail = 'D'

                          SET @c_estprepresstotal = CAST( SYSDB.SSMA.LPAD_VARCHAR(CAST( @i_totalplantcost AS varchar(8000)), 8, 0) AS varchar(8000))

                        END

                      IF ((@c_expresspoind = 'N') AND 
                              (@cursor_row_printingnumber > 1) AND 
                              (@c_estdetail = ' '))
                        BEGIN

                          /* Q if printing  > 1 */

                          SET @c_estdetail = 'Q'

                          SET @c_estprepresstotal = CAST( SYSDB.SSMA.LPAD_VARCHAR(CAST( @i_totalplantcost AS varchar(8000)), 8, 0) AS varchar(8000))

                        END

                      IF (@c_estdetail = ' ')
                        BEGIN

                          INSERT INTO feederror(batchnumber,processdate,errordesc)
                            VALUES ('16', @feed_system_date, ('Estdetails is empty for PO' + isnull(@cursor_row_ponumber, '')))

                          IF (@@TRANCOUNT > 0)
                              COMMIT WORK

                          SET @c_recordtype =  NULL

                        END

                      /*
                       -- 7-19-04  add fsg titles to output
                       -- 11-23-04  exclude all holt divisions
                       --*/

                      /* i_pofsg := 0; */

                      /* select count(*) into i_pofsg from bookorgentry where orgentrykey in(1) /-*Holt level 1 (parent)*-/ */

                      /* and bookkey = @cursor_row_bookkey and orglevelkey=1; */

                      /*  02-23-05 CRM 2502 Exclude SMP, Tor, Picador from HBPUB PO Feed  */

                      /*  04-26-06 CRM 3858 HBPUB - Include SMP/TOR/PIC in PO Feed  */

                      SELECT @i_po_smp_pic_tor = COUNT( * )
                        FROM bookorgentry
                        WHERE ((orglevelkey = 1) AND 
                                (orgentrykey IN (2, 966, 1058 )) AND 
                                (bookkey = @cursor_row_bookkey))


                      /* 10-14-04 do not send new po's without cost once cost entered will be sent */

                      IF (@c_recordtype = 'I')
                        BEGIN
                          /* make sure have cost */
                          IF ((@i_totaleditioncost + @i_totalplantcost) = 0)
                            SET @i_costpresent = 0
                          ELSE 
                            SET @i_costpresent = 1
                        END

                      /*  update table */

                      IF (((@i_costpresent = 1) AND 
                                      (@i_po_smp_pic_tor = 0)) OR 
                              ((@i_costpresent = 1) AND 
                                      (@i_po_smp_pic_tor = 1) AND 
                                      (@cursor_row_printingnumber > 1)))
                        BEGIN

                          /* 11-15-04 output all estdetail type with cost but no holt */

                          UPDATE pofeedout
                            SET 
                              recordtype = @c_recordtype, 
                              ordereddate = SYSDB.SSMA.TO_CHAR_DATE(@d_datefinalized, 'MM/DD/YYYY'), 
                              supplier = @c_supplier, 
                              editiontotalcost = @i_totaleditioncost, 
                              planttotalcost = @i_totalplantcost, 
                              pubprice = CAST( @i_retailprice AS varchar(8000)), 
                              ordertype = @c_potype, 
                              duedate = @d_duedate, 
                              estdetails = @c_estdetail, 
                              requestioner = @c_requestbyname, 
                              packpo = @c_packpo, 
                              packsize = @i_packsize, 
                              bindings = @i_bindery, 
                              cartoningpalleting = @i_cartonpal, 
                              stampdies = @i_stampdies, 
                              coverprinting = @i_coverprint, 
                              covers = @i_covers, 
                              docutech = @i_docutext, 
                              endpapers = @i_endpaper, 
                              endpaperprinting = @i_endpaprint, 
                              importduty = @i_importduty, 
                              inboundfreight = @i_inboundfreight, 
                              insertedition = @i_insertedition, 
                              jacketcoverpaper = @i_jacketcover, 
                              jacketprinting = @i_jacketprint, 
                              misc = @i_misc, 
                              multmedma = @i_multmedma, 
                              paperstock = @i_paperstock, 
                              plates = @i_plates, 
                              printersuppliedpaper = @i_printsupp, 
                              purchfg = @i_purchfg, 
                              specialmaterialpacking = @i_specialmat, 
                              textprinting = @i_textprint, 
                              alteration = @i_alteration, 
                              art = @i_art, 
                              authorrelated = @i_authorrel, 
                              componentdesignfees = @i_componentdesig, 
                              composition = @i_composition, 
                              copyediting = @i_copyedit, 
                              coverjackets = @i_coverjack, 
                              editorialrelated = @i_editrel, 
                              freight = @i_freight, 
                              fullservicemanagement = @i_fullservice, 
                              indexing = @i_index, 
                              insertplant = @i_insertplant, 
                              multimediaeditorial = @i_multedit, 
                              multimedialproduction = @i_multprod, 
                              offset = @i_offset, 
                              other = @i_other, 
                              photo = @i_photo, 
                              pod = @i_pod, 
                              proofreading = @i_proofread, 
                              proofsblues = @i_proofs, 
                              research = @i_research, 
                              seperationsscansfilms = @i_sepscan, 
                              textplant = @i_text, 
                              textdesign = @i_textdesign, 
                              tolerance = @c_tolerance, 
                              estunitcost = @i_estunitcost, 
                              estmfrtot = @i_estmfrtot, 
                              delcomplete = @c_delcomplete, 
                              completeqty = @c_completeqty, 
                              completeqtydate = @c_completeqtydate, 
                              completeval = @c_completeval, 
                              completevaldate = @c_completevaldate, 
                              pocomment = @c_pocomment, 
                              ppestcost25 = @i_ppestcost25, 
                              ppestcost26 = @i_ppestcost26, 
                              ppestcost27 = @i_ppestcost27, 
                              ppestcost28 = @i_ppestcost28, 
                              ppestcost29 = @i_ppestcost29, 
                              ppestcost30 = @i_ppestcost30, 
                              ORIESTCOST22 = @i_oriestcost22, 
                              oriestcost23 = @i_oriestcost23, 
                              oriestcost24 = @i_oriestcost24, 
                              oriestcost25 = @i_oriestcost25, 
                              oriestcost26 = @i_oriestcost26, 
                              oriestcost27 = @i_oriestcost27, 
                              oriestcost28 = @i_oriestcost28, 
                              oriestcost29 = @i_oriestcost29, 
                              oriestcost30 = @i_oriestcost30, 
                              binderyqty = @i_binderyqty, 
                              warehouseqty = @i_warehouseqty, 
                              statuscode = @c_statuscode, 
                              estprepresstotal = @c_estprepresstotal
                            WHERE ((isbn10 = @cursor_row_isbn10) AND 
                                    (printingnumber = @cursor_row_printingnumber))

                          IF (@@TRANCOUNT > 0)
                              COMMIT WORK

                        END

                    END

                  /* potype not X  */

                  /*  PM 9.19.05 CRM 3182 Feed was sending out printingkey instead of printingnumber */

                  /*  PM 12.7.05 CRM 3182 Was commented out up until today becuse PO's were missing from the file */

                  /*  this update statement will set all printingkeys to printingnumns */

                  /*
                   -- update pofeedout pf
                   -- 		 set printingnumber = (Select printingnum 
                   -- 		 	 				  	from printing pr, isbn i 
                   -- 								where i.isbn10 = pf.isbn10
                   -- 								  and i.bookkey = pr.bookkey
                   -- 								  and pr.printingkey = pf.printingnumber);
                   --*/

                  IF (@cursor_row_recordtype = 'X')
                    BEGIN

                      /* Voided PO's get data from what was previously sent since voided po are deleted from po history */

                      SET @c_estprepresstotal = ''

                      SET @c_estdetail = ''

                      SET @d_processdate = ''

                      SET @feedout_count = 0

                      SELECT @feedout_count = COUNT( * )
                        FROM pofeedouthistory
                        WHERE (ponumber =@cursor_row_ponumber)

                      IF (@feedout_count > 0)
                        BEGIN

                          SELECT @d_processdate = MAX(processdate)
                            FROM pofeedouthistory
                           WHERE (ponumber =@cursor_row_ponumber)

                          IF (SYSDB.SSMA.LENGTH_VARCHAR(CAST( @d_processdate AS varchar(8000))) > 0)
                            BEGIN
                              SELECT @c_estprepresstotal = estprepresstotal, @c_estdetail = estdetails
                                FROM pofeedouthistory
                               WHERE (ponumber =@cursor_row_ponumber) AND (processdate = @d_processdate)
                            END

                          IF (@c_estdetail = '')
                            BEGIN

                              INSERT INTO feederror
                                (batchnumber,processdate,errordesc)
                                VALUES ('16', @feed_system_date, ('Estdetail is empty for PO' + isnull(@cursor_row_ponumber, '')))

                              SET @c_recordtype =  NULL

                              IF (@@TRANCOUNT > 0)
                                  COMMIT WORK

                            END

                        END
                      ELSE 
                        SET @c_recordtype =  NULL

                      UPDATE pofeedout
                        SET recordtype = @c_recordtype, estdetails = @c_estdetail, estprepresstotal = @c_estprepresstotal
                        WHERE ((isbn10 = @cursor_row_isbn10) AND (printingnumber = @cursor_row_printingnumber))

                      IF (@@TRANCOUNT > 0)
                          COMMIT WORK

                    END

                  FETCH NEXT FROM feed_poms INTO @cursor_row_bookkey,@cursor_row_printingnumber,@cursor_row_ponumber,@cursor_row_isbn10,@cursor_row_recordtype

                END

              CLOSE feed_poms

              DEALLOCATE feed_poms

            END

            DELETE FROM pofeedout
              WHERE (ISNULL((recordtype + '.'), '.') = '.')

            DELETE FROM pofeedout
              WHERE (recordtype = '')

            DELETE FROM pofeedout
              WHERE (ponumber = '')

            DELETE FROM pofeedout
              WHERE (ISNULL((ponumber + '.'), '.') = '.')

            /*  insert into pofeedouthistory */

            INSERT INTO pofeedhistory
              (
                RECORDNAME, 
                POFEEDOUTHISTORY.RECORDTYPE, 
                isbn10, 
                ponumber, 
                SUPPLIER, 
                ORDERTYPE, 
                PACKPO, 
                REQUESTIONER, 
                printingnumber, 
                ESTDETAILS, 
                PACKSIZE, 
                BINDERYQTY, 
                WAREHOUSEQTY, 
                ORDEREDQTY, 
                EDITIONTOTALCOST, 
                PLANTTOTALCOST, 
                ORDEREDDATE, 
                DUEDATE, 
                PUBPRICE, 
                BINDINGS, 
                CARTONINGPALLETING, 
                STAMPDIES, 
                COVERPRINTING, 
                COVERS, 
                DOCUTECH, 
                ENDPAPERS, 
                ENDPAPERPRINTING, 
                IMPORTDUTY, 
                INBOUNDFREIGHT, 
                INSERTEDITION, 
                JACKETCOVERPAPER, 
                JACKETPRINTING, 
                MISC, 
                MULTMEDMA, 
                PAPERSTOCK, 
                PLATES, 
                PRINTERSUPPLIEDPAPER, 
                PURCHFG, 
                SPECIALMATERIALPACKING, 
                TEXTPRINTING, 
                ALTERATION, 
                ART, 
                AUTHORRELATED, 
                COMPONENTDESIGNFEES, 
                COMPOSITION, 
                COPYEDITING, 
                COVERJACKETS, 
                EDITORIALRELATED, 
                FREIGHT, 
                FULLSERVICEMANAGEMENT, 
                INDEXING, 
                INSERTPLANT, 
                MULTIMEDIAEDITORIAL, 
                MULTIMEDIALPRODUCTION, 
                OFFSET, 
                OTHER, 
                PHOTO, 
                POD, 
                PROOFREADING, 
                PROOFSBLUES, 
                RESEARCH, 
                SEPERATIONSSCANSFILMS, 
                TEXTPLANT, 
                TEXTDESIGN, 
                TOLERANCE, 
                ESTUNITCOST, 
                ESTMFRTOT, 
                DELCOMPLETE, 
                COMPLETEQTY, 
                COMPLETEQTYDATE, 
                COMPLETEVAL, 
                COMPLETEVALDATE, 
                POCOMMENT, 
                ppestcost25, 
                ppestcost26, 
                ppestcost27, 
                ppestcost28, 
                ppestcost29, 
                ppestcost30, 
                oriestcost22, 
                oriestcost23, 
                oriestcost24, 
                oriestcost25, 
                oriestcost26, 
                oriestcost27, 
                oriestcost28, 
                oriestcost29, 
                oriestcost30, 
                STATUSCODE, 
                PROCESSDATE, 
                ESTPREPRESSTOTAL
              )
              SELECT 
                  RECORDNAME, 
                  RECORDTYPE, 
                  isbn10, 
                  ponumber, 
                  SUPPLIER, 
                  ORDERTYPE, 
                  PACKPO, 
                  REQUESTIONER, 
                  printingnumber, 
                  ESTDETAILS, 
                  PACKSIZE, 
                  BINDERYQTY, 
                  WAREHOUSEQTY, 
                  ORDEREDQTY, 
                  EDITIONTOTALCOST, 
                  PLANTTOTALCOST, 
                  ORDEREDDATE, 
                  DUEDATE, 
                  PUBPRICE, 
                  BINDINGS, 
                  CARTONINGPALLETING, 
                  STAMPDIES, 
                  COVERPRINTING, 
                  COVERS, 
                  DOCUTECH, 
                  ENDPAPERS, 
                  ENDPAPERPRINTING, 
                  IMPORTDUTY, 
                  INBOUNDFREIGHT, 
                  INSERTEDITION, 
                  JACKETCOVERPAPER, 
                  JACKETPRINTING, 
                  MISC, 
                  MULTMEDMA, 
                  PAPERSTOCK, 
                  PLATES, 
                  PRINTERSUPPLIEDPAPER, 
                  PURCHFG, 
                  SPECIALMATERIALPACKING, 
                  TEXTPRINTING, 
                  ALTERATION, 
                  ART, 
                  AUTHORRELATED, 
                  COMPONENTDESIGNFEES, 
                  COMPOSITION, 
                  COPYEDITING, 
                  COVERJACKETS, 
                  EDITORIALRELATED, 
                  FREIGHT, 
                  FULLSERVICEMANAGEMENT, 
                  INDEXING, 
                  INSERTPLANT, 
                  MULTIMEDIAEDITORIAL, 
                  MULTIMEDIALPRODUCTION, 
                  OFFSET, 
                  OTHER, 
                  PHOTO, 
                  POD, 
                  PROOFREADING, 
                  PROOFSBLUES, 
                  RESEARCH, 
                  SEPERATIONSSCANSFILMS, 
                  TEXTPLANT, 
                  TEXTDESIGN, 
                  TOLERANCE, 
                  ESTUNITCOST, 
                  ESTMFRTOT, 
                  DELCOMPLETE, 
                  COMPLETEQTY, 
                  COMPLETEQTYDATE, 
                  COMPLETEVAL, 
                  COMPLETEVALDATE, 
                  POCOMMENT, 
                  ppestcost25, 
                  ppestcost26, 
                  ppestcost27, 
                  ppestcost28, 
                  ppestcost29, 
                  ppestcost30, 
                  oriestcost22, 
                  oriestcost23, 
                  oriestcost24, 
                  oriestcost25, 
                  oriestcost26, 
                  oriestcost27, 
                  oriestcost28, 
                  oriestcost29, 
                  oriestcost30, 
                  STATUSCODE, 
                  getdate(), 
                  ESTPREPRESSTOTAL
                FROM POFEEDOUT

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

            INSERT INTO feederror
              (batchnumber,processdate,errordesc)
              VALUES ('16', @feed_system_date, ('POMS Feed finished on ' + isnull(SYSDB.SSMA.TO_CHAR_DATE(getdate(), 'MM/DD/YY HH24:MI:SS'), '')))

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

            UPDATE POFEEDDATE
              SET POFEEDDATE.FEEDDATE = POFEEDDATE.TENTATIVEFEEDDATE
              WHERE (POFEEDDATE.FEEDDATEKEY = 6)

            IF (@@TRANCOUNT > 0)
                COMMIT WORK

          END TRY
          BEGIN CATCH

            DECLARE 
              @ErrorMessage nvarchar(4000),
              @ErrorNumber int,
              @ExceptionIdentifier nvarchar(4000)            

            SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorNumber = ERROR_NUMBER()

            SELECT @ExceptionIdentifier = SYSDB.SSMA.db_error_get_oracle_exception_id(@ErrorMessage, @ErrorNumber)

            BEGIN

              SET @error_msg = SYSDB.SSMA.SUBSTR3_VARCHAR(SYSDB.SSMA.DB_ERROR_SQLERRM_0(@ExceptionIdentifier), 1, 200)

              INSERT INTO feederror
                (batchnumber,processdate,errordesc)
                VALUES ('16', getdate(), ('POMS Feed failed ' + isnull(@error_msg, '')))

              IF (@@TRANCOUNT > 0)
                  COMMIT WORK

              INSERT INTO POFEEDOUTHISTORY
                (
                  RECORDNAME, 
                  RECORDTYPE, 
                  isbn10, 
                  ponumber, 
                  SUPPLIER, 
                  ORDERTYPE, 
                  PACKPO, 
                  REQUESTIONER, 
                  printingnumber, 
                  ESTDETAILS, 
                  PACKSIZE, 
                  BINDERYQTY, 
                  WAREHOUSEQTY, 
                  ORDEREDQTY, 
                  EDITIONTOTALCOST, 
                  PLANTTOTALCOST, 
                  ORDEREDDATE, 
                  DUEDATE, 
                  PUBPRICE, 
                  BINDINGS, 
                  CARTONINGPALLETING, 
                  STAMPDIES, 
                  COVERPRINTING, 
                  COVERS, 
                  DOCUTECH, 
                  ENDPAPERS, 
                  ENDPAPERPRINTING, 
                  IMPORTDUTY, 
                  INBOUNDFREIGHT, 
                  INSERTEDITION, 
                  JACKETCOVERPAPER, 
                  JACKETPRINTING, 
                  MISC, 
                  MULTMEDMA, 
                  PAPERSTOCK, 
                  PLATES, 
                  PRINTERSUPPLIEDPAPER, 
                  PURCHFG, 
                  SPECIALMATERIALPACKING, 
                  TEXTPRINTING, 
                  ALTERATION, 
                  ART, 
                  AUTHORRELATED, 
                  COMPONENTDESIGNFEES, 
                  COMPOSITION, 
                  COPYEDITING, 
                  COVERJACKETS, 
                  EDITORIALRELATED, 
                  FREIGHT, 
                  FULLSERVICEMANAGEMENT, 
                  INDEXING, 
                  INSERTPLANT, 
                  MULTIMEDIAEDITORIAL, 
                  MULTIMEDIALPRODUCTION, 
                  OFFSET, 
                  OTHER, 
                  PHOTO, 
                  POD, 
                  PROOFREADING, 
                  PROOFSBLUES, 
                  RESEARCH, 
                  SEPERATIONSSCANSFILMS, 
                  TEXTPLANT, 
                  TEXTDESIGN, 
                  TOLERANCE, 
                  ESTUNITCOST, 
                  ESTMFRTOT, 
                  DELCOMPLETE, 
                  COMPLETEQTY, 
                  COMPLETEQTYDATE, 
                  COMPLETEVAL, 
                  COMPLETEVALDATE, 
                  POCOMMENT, 
                  ppestcost25, 
                  ppestcost26, 
                  ppestcost27, 
                  ppestcost28, 
                  ppestcost29, 
                  ppestcost30, 
                  oriestcost22, 
                  oriestcost23, 
                  oriestcost24, 
                  oriestcost25, 
                  oriestcost26, 
                  oriestcost27, 
                  oriestcost28, 
                  oriestcost29, 
                  oriestcost30, 
                  STATUSCODE, 
                  PROCESSDATE, 
                  ESTPREPRESSTOTAL
                )
                SELECT 
                    RECORDNAME, 
                    RECORDTYPE, 
                    isbn10, 
                    ponumber, 
                    SUPPLIER, 
                    ORDERTYPE, 
                    PACKPO, 
                    REQUESTIONER, 
                    printingnumber, 
                    ESTDETAILS, 
                    PACKSIZE, 
                    BINDERYQTY, 
                    WAREHOUSEQTY, 
                    ORDEREDQTY, 
                    EDITIONTOTALCOST, 
                    PLANTTOTALCOST, 
                    ORDEREDDATE, 
                    DUEDATE, 
                    PUBPRICE, 
                    BINDINGS, 
                    CARTONINGPALLETING, 
                    STAMPDIES, 
                    COVERPRINTING, 
                    COVERS, 
                    DOCUTECH, 
                    ENDPAPERS, 
                    ENDPAPERPRINTING, 
                    IMPORTDUTY, 
                    INBOUNDFREIGHT, 
                    INSERTEDITION, 
                    JACKETCOVERPAPER, 
                    JACKETPRINTING, 
                    MISC, 
                    MULTMEDMA, 
                    PAPERSTOCK, 
                    PLATES, 
                    PRINTERSUPPLIEDPAPER, 
                    PURCHFG, 
                    SPECIALMATERIALPACKING, 
                    TEXTPRINTING, 
                    ALTERATION, 
                    ART, 
                    AUTHORRELATED, 
                    COMPONENTDESIGNFEES, 
                    COMPOSITION, 
                    COPYEDITING, 
                    COVERJACKETS, 
                    EDITORIALRELATED, 
                    FREIGHT, 
                    FULLSERVICEMANAGEMENT, 
                    INDEXING, 
                    INSERTPLANT, 
                    MULTIMEDIAEDITORIAL, 
                    MULTIMEDIALPRODUCTION, 
                    OFFSET, 
                    OTHER, 
                    PHOTO, 
                    POD, 
                    PROOFREADING, 
                    PROOFSBLUES, 
                    RESEARCH, 
                    SEPERATIONSSCANSFILMS, 
                    TEXTPLANT, 
                    TEXTDESIGN, 
                    TOLERANCE, 
                    ESTUNITCOST, 
                    ESTMFRTOT, 
                    DELCOMPLETE, 
                    COMPLETEQTY, 
                    COMPLETEQTYDATE, 
                    COMPLETEVAL, 
                    COMPLETEVALDATE, 
                    POCOMMENT, 
                    ppestcost25, 
                    ppestcost26, 
                    ppestcost27, 
                    ppestcost28, 
                    ppestcost29, 
                    ppestcost30, 
                    oriestcost22, 
                    oriestcost23, 
                    oriestcost24, 
                    oriestcost25, 
                    oriestcost26, 
                    oriestcost27, 
                    oriestcost28, 
                    oriestcost29, 
                    oriestcost30, 
                    STATUSCODE, 
                    getdate(), 
                    ESTPREPRESSTOTAL
                  FROM pofeedout
                  WHERE (ISNULL((recordtype + '.'), '.') <> '.')

              IF (@@TRANCOUNT > 0)
                  COMMIT WORK

              IF (cursor_status(N'local', N'feed_poms') = 1)
                BEGIN
                  CLOSE feed_poms
                  DEALLOCATE feed_poms
                END

              IF (cursor_status(N'local', N'feed_cost') = 1)
                BEGIN
                  CLOSE feed_cost
                  DEALLOCATE feed_cost
                END

            END

          END CATCH
      END

GO




