IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'feedout_titles_sp_v2')
BEGIN
  DROP  Procedure  feedout_titles_sp_v2
END
GO
  CREATE 
    PROCEDURE dbo.feedout_titles_sp_v2 
        @p_location varchar(255)
    AS
      BEGIN
          DECLARE 
	    @OLEResult integer,
	    @@AtEndOfStream integer,
            @lv_count integer,
            @lv_count2 integer,
            @lv_count3 integer,
            @lv_authorkey integer,
            @c_currentdate varchar(10),
            @c_currentdatetime varchar(8),
            @lv_totalcount integer,
            @lv_totalcartonqty integer,
            @lv_totalpagecount integer,
            @lv_totalcount_char varchar(8),
            @lv_totalcartonqty_char varchar(6),
            @lv_totalpagecount_char varchar(8),
            @c_filename varchar(100),
            @c_filename2 varchar(100),
            @lv_file_id_num integer,
            @lv_file_id_num2 integer,
            @lv_output_string varchar(8000),
            @lv_input_seqnum varchar(8),
            @i_sequence_num integer,
            @lv_outfilename varchar(50),
            @lv_defaultstring varchar(18),
            @i_printingkey integer,
            @lv_decimal numeric(10, 2),
            @lv_pos1 integer,
            @lv_pos2 integer,
            @c_recordtype varchar(2),
            @c_college_trade varchar(1),
            @c_isbn varchar(10),
            @c_titleshort varchar(35),
            @c_title varchar(32),
            @c_authordisplayname1 varchar(25),
            @c_illustratordisplayname1 varchar(25),
            @c_titlefull varchar(65),
            @c_grouplevel6grpdesc1_2 varchar(2),
            @c_grouplevel6grpdesc3_4 varchar(2),
            @c_grouplevel6grpdesc5_6 varchar(2),
            @c_formatexternal varchar(2),
            @c_palgravepubexternalcode varchar(3),
            @c_mediaprepack varchar(2),
            @c_formatexternal2 varchar(1),
            @c_palgraveclassexternalcode varchar(4),
            @c_bisacsubject1 varchar(9),
            @c_bisacsubject2 varchar(9),
            @c_bisacsubject3 varchar(9),
            @c_gradelevelfrom varchar(2),
            @c_gradelevelto varchar(2),
            @c_discode varchar(2),
            @c_libaryofcongress varchar(10),
            @c_upc varchar(12),
            @c_ean varchar(13),
            @c_pubdatebest varchar(6),
            @c_releasedatebest varchar(6),
            @c_cartonqty varchar(4),
            @c_trimheight varchar(6),
            @c_trimwidth varchar(6),
            @c_spinesize varchar(6),
            @c_pagecount varchar(6),
            @c_msdeliverydate varchar(6),
            @c_titleandsubtitle varchar(70),
            @c_author1 varchar(30),
            @c_author2 varchar(30),
            @c_author3 varchar(30),
            @c_author4 varchar(30),
            @c_author5 varchar(30),
            @c_author6 varchar(30),
            @c_author7 varchar(30),
            @c_author8 varchar(30),
            @c_author9 varchar(30),
            @c_author10 varchar(30),
            @c_uspricepubprice varchar(7),
            @c_canpubprice varchar(7),
            @c_statuscode varchar(2),
            @c_authortemp varchar(100),
            @c_projectisbn varchar(10),
            @c_usnetprice varchar(7),
            @c_cannetprice varchar(7),
            @c_exppubprice varchar(7),
            @c_expnetprice varchar(7),
            @c_pocketpubflag varchar(1),
            @c_sampltoolflag varchar(1),
            @c_royaltyflag varchar(1),
            @c_limitedallow varchar(1),
            @c_mcnaughtonflag varchar(1),
            @c_pbwatchlistflag varchar(1),
            @c_pricelistflag varchar(1),
            @c_onyxtitleflag varchar(1),
            @c_kronusflag varchar(1),
            @c_summerpubflag varchar(1),
            @c_sampleableflag varchar(1),
            @c_onholdvistaflag varchar(1),
            @c_onholdonyxflag varchar(1),
            @c_createsalesopflag varchar(1),
            @c_fallpubflag varchar(1),
            @c_unused12flag varchar(1),
            @c_oldplflag varchar(1),
            @c_currenteditorplflag varchar(1),
            @c_imsflag varchar(1),
            @c_potodflag varchar(1),
            @c_binderypackflag varchar(1),
            @c_primarysampleflag varchar(1),
            @c_inproductionflag varchar(1),
            @c_reppackflag varchar(1),
            @c_weeklypostrackingflag varchar(1),
            @c_mainsaleablebook varchar(1),
            @c_podflag varchar(1),
            @c_recordpadding varchar(1),
            @c_neversendtoeloquence varchar(1),
            @c_limitedallowed varchar(1),
            @c_altprojectisbn varchar(10),
            @c_copyrightyear varchar(4),
	    @c_copyrightyear_int smallint,
            @c_answercode varchar(3),
            @c_grouplevel6 varchar(20),
            @c_canadarest varchar(2),
            @c_remove_test_org integer,
            @i_bisacstatuscode integer,
            @i_bookkey integer,
            @c_editor varchar(86),
            @c_shorttitle varchar(330),
            @c_edition varchar(20),
            @c_totalruntime varchar(10),
            @c_cassetteunits varchar(10),
            @c_titlereleasedtoelo varchar(1),
            @cursor_row$BOOKKEY integer,
            @cursor_row$ISBN10 varchar(30),
            @cursor_row$SHORTTITLE varchar(100),
            @cursor_row$TITLE varchar(8000),
            @cursor_row$AUTHORDISPLAYNAME1 varchar(100),
            @cursor_row$AUTHORDISPLAYNAME2 varchar(100),
            @cursor_row$AUTHORDISPLAYNAME3 varchar(100),
            @cursor_row$AUTHORDISPLAYNAME4 varchar(100),
            @cursor_row$AUTHORDISPLAYNAME5 varchar(100),
            @cursor_row$GROUPLEVEL6 varchar(100),
            @cursor_row$LCCN varchar(30),
            @cursor_row$UPC varchar(30),
            @cursor_row$EAN varchar(30),
            @cursor_row$SUBTITLE varchar(100),
            @cursor_row$USPRICEBEST integer,
            @cursor_row$CANADIANPRICEBEST integer,
            @cursor_row$DISCOUNTCODE integer,
            @cursor_row1$DISPLAYNAME varchar(100),
            @cursor_row1$SORTORDER integer,
	    @FS integer    ,
	    @c_line_text  varchar(8000),
	    @pos integer,
	    @AtEndOfStream integer
          
          SET @lv_totalcount = 0
          SET @lv_totalcartonqty = 0
          SET @lv_totalpagecount = 0
          SET @lv_totalcount_char = ''
          SET @lv_totalcartonqty_char = ''
          SET @lv_totalpagecount_char = ''
          SET @c_filename = ''
          SET @c_filename2 = ''
          SET @lv_output_string = ''
          SET @i_sequence_num = 0
          SET @c_shorttitle = ''
          SET @c_edition = ''
          SET @c_totalruntime = '0'
          SET @c_cassetteunits = '0'
	  set @AtEndOfStream = 0
          BEGIN

            SET @c_college_trade = 'T'

            /* read input file sequence number then create header record */

            SET @c_filename = 'tmfyi_in_seqnum_v2.txt'
	    set @c_filename = @p_location + '\' + @c_filename

	    /*  Open Output File  */
            --EXEC SYSDB.SSMA.UTL_FILE_FOPEN$IMPL @p_location, @c_filename, 'R', 32767, @lv_file_id_num2 OUTPUT 
		execute @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
		IF @OLEResult <> 0 begin
		  PRINT 'Error: Scripting.FileSystemObject Failed.'
	          goto destroy
	        end

		execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @lv_file_id_num2 OUT, @c_filename, 1, 1
		IF @OLEResult <> 0 begin
		  PRINT 'Error: OpenTextFile Failed1'
	          goto destroy
	        end

		--read laste sequnce from file
		WHILE @AtEndOfStream = 0 
		BEGIN 
			execute @OLEResult = sp_OAMethod @lv_file_id_num2, 'ReadLine', @c_line_text out
		        if @OLEResult <> 0 break
			EXEC @OLEResult = sp_OAMethod @lv_file_id_num2, 'AtEndOfStream', @AtEndOfStream OUTPUT 
			set @i_sequence_num = cast(@c_line_text as integer)

		END 
		
		--close file
		exec @OLEResult = sp_OAMethod @FS, 'Close', @lv_file_id_num2

            IF (@i_sequence_num > 0)
              BEGIN
                SET @lv_input_seqnum = dbo.lpad(CAST( @i_sequence_num AS varchar(8)), 8, '0')
                SET @i_sequence_num = (@i_sequence_num + 1)
              END
            ELSE 
              BEGIN
                SET @i_sequence_num = 1
                SET @lv_input_seqnum = dbo.lpad(CAST( @i_sequence_num AS varchar(8)), 8, '0')
                SET @i_sequence_num = (@i_sequence_num + 1)
              END

            SET @c_currentdate = convert(varchar(10), getdate(), 101)
            SET @c_currentdatetime = convert(varchar(8), getdate(), 108)

            SET @c_filename2 = ('V' + isnull(@lv_input_seqnum, '') + '.FYI_TM_V2')

            /* change file name 11-21-03 */

            /*  Open Output File  */

--            EXEC SYSDB.SSMA.UTL_FILE_FOPEN$IMPL @p_location, @c_filename2, 'W', 32000, @lv_file_id_num OUTPUT 
	    set @c_filename2 = @p_location + '\' + @c_filename2

	    execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @lv_file_id_num OUT, @c_filename2, 8, 1
	    IF @OLEResult <> 0 begin
	       PRINT 'Error: OpenTextFile Failed2'
               goto destroy
           end


            SET @c_filename2 = dbo.lpad(@c_filename2, 25, ' ')

            /* output header record */

            IF (@i_sequence_num > 0)
              BEGIN
                SET @lv_output_string = ('H ' + isnull(@lv_input_seqnum, '') + isnull(@c_currentdate, '') + isnull(@c_currentdatetime, '') + isnull(@c_filename2, '') + 'Y')
--                EXEC SYSDB.SSMA.UTL_FILE_PUT_LINE @lv_file_id_num, @lv_output_string 
		execute @OLEResult = sp_OAMethod @lv_file_id_num, 'WriteLine', Null, @lv_output_string
	        IF @OLEResult <> 0 begin
		   PRINT 'Error: WriteLine Failed'
	           goto destroy
	        end

              END
            ELSE 
              BEGIN
                INSERT INTO dbo.FEEDERROR
                  (
                    dbo.FEEDERROR.ISBN, 
                    dbo.FEEDERROR.BATCHNUMBER, 
                    dbo.FEEDERROR.PROCESSDATE, 
                    dbo.FEEDERROR.ERRORDESC
                  )
                  VALUES 
                    (
                      'Not Avail', 
                      '1', 
                      getdate(), 
                      'NO SEQUENCE NUMBER FILE, PLEASE ADD FILE tmfyi_in_sequencenum_v2.txt'
                    )
              END

            /* default these values */
            SET @c_recordtype = 'D '
            SET @c_college_trade = 'T'

            /* for now assume all title is trade */
            INSERT INTO dbo.FEEDERROR
              (dbo.FEEDERROR.BATCHNUMBER, dbo.FEEDERROR.PROCESSDATE, dbo.FEEDERROR.ERRORDESC)
              VALUES ('1', getdate(), 'Vista TMM File Start')

            BEGIN

              DECLARE 
                @cursor_row$BOOKKEY$2 integer,
                @cursor_row$ISBN10$2 varchar(30),
                @cursor_row$SHORTTITLE$2 varchar(100),
                @cursor_row$TITLE$2 varchar(100),
                @cursor_row$AUTHORDISPLAYNAME1$2 varchar(100),
                @cursor_row$AUTHORDISPLAYNAME2$2 varchar(100),
                @cursor_row$AUTHORDISPLAYNAME3$2 varchar(100),
                @cursor_row$AUTHORDISPLAYNAME4$2 varchar(100),
                @cursor_row$AUTHORDISPLAYNAME5$2 varchar(100),
                @cursor_row$GROUPLEVEL6$2 varchar(100),
                @cursor_row$LCCN$2 varchar(30),
                @cursor_row$UPC$2 varchar(30),
                @cursor_row$EAN$2 varchar(30),
                @cursor_row$SUBTITLE$2 varchar(100),
                @cursor_row$USPRICEBEST$2 integer,
                @cursor_row$CANADIANPRICEBEST$2 integer,
                @cursor_row$DISCOUNTCODE$2 integer              

              DECLARE 
                titleout_cursor CURSOR LOCAL 
                 FOR 
                  SELECT DISTINCT 
                      w.BOOKKEY, 
                      w.ISBN10, 
                      substring(isnull(w.SHORTTITLE, ''), 1, 35) AS SHORTTITLE, 
                      isnull(w.TITLE , ' ') AS TITLE, 
                      isnull(wa.AUTHORDISPLAYNAME1 , ' ') AS AUTHORDISPLAYNAME1, 
                      isnull(wa.AUTHORDISPLAYNAME2 , ' ') AS AUTHORDISPLAYNAME2, 
                      isnull(wa.AUTHORDISPLAYNAME3 , ' ') AS AUTHORDISPLAYNAME3, 
                      isnull(wa.AUTHORDISPLAYNAME4 , ' ') AS AUTHORDISPLAYNAME4, 
                      isnull(wa.AUTHORDISPLAYNAME5 , ' ') AS AUTHORDISPLAYNAME5, 
                      isnull(wc.GROUPLEVEL6 , ' ') AS GROUPLEVEL6, 
                      substring(isnull(w.LCCN , ' '), 1, 10) AS LCCN, 
                      isnull(w.UPC , ' ') AS UPC, 
                      isnull(w.EAN , ' ') AS EAN, 
                      substring(isnull(w.SUBTITLE, ' '), 1, 70) AS SUBTITLE, 
                      w.USPRICEBEST AS USPRICEBEST, 
                      w.CANADIANPRICEBEST AS CANADIANPRICEBEST, 
                      bd.DISCOUNTCODE
                    FROM dbo.WHTITLEINFO w, dbo.WHTITLECLASS wc, dbo.WHAUTHOR wa, dbo.TITLEHISTORY t, dbo.BOOKDETAIL bd
                    WHERE ((t.BOOKKEY = w.BOOKKEY) AND 
                            (w.BOOKKEY = wc.BOOKKEY) AND 
                            (w.BOOKKEY = wa.BOOKKEY) AND 
                            (w.BOOKKEY = bd.BOOKKEY) AND 
                            (t.PRINTINGKEY = 1) AND 
                            (t.LASTMAINTDATE >= (getdate() - 2)) AND 
                            (isnull(t.LASTUSERID , ' ') NOT IN ('VISTAFEED', 'VISTAFEED2' )) AND 
                            (t.COLUMNKEY NOT IN (70, 97, 104 )) AND 
                            (wc.BISACSTATUSSHORT IN ('NYP', 'NAB', 'PC', 'DC', 'DCR', 'PP' )) AND 
                            (len(w.ISBN10) > 0))
                  UNION
                  SELECT DISTINCT 
                      w.BOOKKEY, 
                      w.ISBN10, 
                      substring(isnull(w.SHORTTITLE , ''), 1, 35) AS SHORTTITLE, 
                      isnull(w.TITLE, ' ') AS TITLE, 
                      isnull(wa.AUTHORDISPLAYNAME1, ' ') AS AUTHORDISPLAYNAME1, 
                      isnull(wa.AUTHORDISPLAYNAME2, ' ') AS AUTHORDISPLAYNAME2, 
                      isnull(wa.AUTHORDISPLAYNAME3, ' ') AS AUTHORDISPLAYNAME3, 
                      isnull(wa.AUTHORDISPLAYNAME4, ' ') AS AUTHORDISPLAYNAME4, 
                      isnull(wa.AUTHORDISPLAYNAME5, ' ') AS AUTHORDISPLAYNAME5, 
                      isnull(wc.GROUPLEVEL6, ' ') AS GROUPLEVEL6, 
                      substring(isnull(w.LCCN , ' '), 1, 10) AS LCCN, 
                      isnull(w.UPC, ' ') AS UPC, 
                      isnull(w.EAN, ' ') AS EAN, 
                      isnull(w.SUBTITLE , ' ') AS SUBTITLE, 
                      w.USPRICEBEST AS USPRICEBEST, 
                      w.CANADIANPRICEBEST AS CANADIANPRICEBEST, 
                      bd.DISCOUNTCODE
                    FROM dbo.WHTITLEINFO w, dbo.WHTITLECLASS wc, dbo.WHAUTHOR wa, dbo.DATEHISTORY t, dbo.BOOKDETAIL bd
                    WHERE ((t.BOOKKEY = w.BOOKKEY) AND 
                            (w.BOOKKEY = wc.BOOKKEY) AND 
                            (w.BOOKKEY = wa.BOOKKEY) AND 
                            (w.BOOKKEY = bd.BOOKKEY) AND 
                            (t.PRINTINGKEY = 1) AND 
                            (t.DATETYPECODE IN (4, 8, 32, 466 )) AND 
                            (t.LASTMAINTDATE >= (getdate() - 2)) AND 
                            (wc.BISACSTATUSSHORT IN ('NYP', 'NAB', 'PC', 'DC', 'DCR', 'PP' )) AND 
                            (len(w.ISBN10) > 0))
                  ORDER BY w.ISBN10
              

              OPEN titleout_cursor

              FETCH NEXT FROM titleout_cursor
                INTO 
                  @cursor_row$BOOKKEY$2, 
                  @cursor_row$ISBN10$2, 
                  @cursor_row$SHORTTITLE$2, 
                  @cursor_row$TITLE$2, 
                  @cursor_row$AUTHORDISPLAYNAME1$2, 
                  @cursor_row$AUTHORDISPLAYNAME2$2, 
                  @cursor_row$AUTHORDISPLAYNAME3$2, 
                  @cursor_row$AUTHORDISPLAYNAME4$2, 
                  @cursor_row$AUTHORDISPLAYNAME5$2, 
                  @cursor_row$GROUPLEVEL6$2, 
                  @cursor_row$LCCN$2, 
                  @cursor_row$UPC$2, 
                  @cursor_row$EAN$2, 
                  @cursor_row$SUBTITLE$2, 
                  @cursor_row$USPRICEBEST$2, 
                  @cursor_row$CANADIANPRICEBEST$2, 
                  @cursor_row$DISCOUNTCODE$2


              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      INSERT INTO dbo.FEEDERROR
                        (
                          dbo.FEEDERROR.ISBN, 
                          dbo.FEEDERROR.BATCHNUMBER, 
                          dbo.FEEDERROR.PROCESSDATE, 
                          dbo.FEEDERROR.ERRORDESC
                        )
                        VALUES 
                          (
                            'Not Avail', 
                            '1', 
                            getdate(), 
                            'NO ROWS TO PROCESS'
                          )

                    END

                  SET @c_isbn = ''
                  SET @c_titleshort = ''
                  SET @c_title = ''
                  SET @c_authordisplayname1 = ''
                  SET @c_illustratordisplayname1 = ''
                  SET @c_titlefull = ''
                  SET @c_grouplevel6grpdesc1_2 = ''
                  SET @c_grouplevel6grpdesc3_4 = ''
                  SET @c_grouplevel6grpdesc5_6 = ''
                  SET @c_formatexternal = ''
                  SET @c_palgravepubexternalcode = ''
                  SET @c_mediaprepack = ''
                  SET @c_formatexternal2 = ''
                  SET @c_palgraveclassexternalcode = ''
                  SET @c_bisacsubject1 = ''
                  SET @c_bisacsubject2 = ''
                  SET @c_bisacsubject3 = ''
                  SET @c_gradelevelfrom = ''
                  SET @c_gradelevelto = ''
                  SET @c_discode = ''
                  SET @c_libaryofcongress = ''
                  SET @c_upc = ''
                  SET @c_ean = ''
                  SET @c_pubdatebest = ''
                  SET @c_releasedatebest = ''
                  SET @c_cartonqty = ''
                  SET @c_trimheight = ''
                  SET @c_trimwidth = ''
                  SET @c_spinesize = ''
                  SET @c_pagecount = ''
                  SET @c_msdeliverydate = ''
                  SET @c_titleandsubtitle = ''
                  SET @c_author1 = ''
                  SET @c_author2 = ''
                  SET @c_author3 = ''
                  SET @c_author4 = ''
                  SET @c_author5 = ''
                  SET @c_author6 = ''
                  SET @c_author7 = ''
                  SET @c_author8 = ''
                  SET @c_author9 = ''
                  SET @c_author10 = ''
                  SET @c_uspricepubprice = ''
                  SET @c_canpubprice = ''
                  SET @c_statuscode = '  '
                  SET @c_projectisbn = ''
                  SET @c_usnetprice = ''
                  SET @c_cannetprice = ''
                  SET @c_exppubprice = ''
                  SET @c_expnetprice = ''
                  SET @c_pocketpubflag = ''
                  SET @c_sampltoolflag = ''
                  SET @c_royaltyflag = ''
                  SET @c_answercode = ''
                  SET @c_grouplevel6 = ''
                  SET @c_canadarest = ''
                  SET @c_remove_test_org = 0
                  SET @i_bisacstatuscode = 0
                  SET @i_bookkey = @cursor_row$BOOKKEY$2
                  SET @c_editor = ''
                  SET @c_edition = ''
                  SET @c_shorttitle = ''
                  SET @c_totalruntime = '0'
                  SET @c_cassetteunits = '0'
                  SET @c_imsflag = ''
                  SET @c_potodflag = ''
                  SET @c_podflag = ''
                  SET @c_mcnaughtonflag = ''
                  SET @c_pbwatchlistflag = ''
                  SET @c_pocketpubflag = ''
                  SET @c_sampleableflag = ''
                  SET @c_sampltoolflag = ''
                  SET @c_binderypackflag = ''
                  SET @c_primarysampleflag = ''
                  SET @c_inproductionflag = ''
                  SET @c_reppackflag = ''
                  SET @c_limitedallowed = ''
                  SET @c_altprojectisbn = ''
                  SET @c_copyrightyear = ''
                  SET @c_recordpadding = ' '
                  SET @c_isbn = @cursor_row$ISBN10$2

                  SET @c_titleshort = dbo.rpad(substring(@cursor_row$SHORTTITLE$2, 1, 35), 35, ' ')
                  SET @c_title = dbo.rpad(substring(@cursor_row$TITLE$2, 1, 32), 32, ' ')
                  SET @c_titlefull = dbo.rpad(substring(@cursor_row$TITLE$2, 1, 65), 65, ' ')

                  SET @c_isbn = ISNULL(@c_isbn, '')

                  IF @c_titleshort Is null
                    BEGIN
                      /*  12-4-03 use title no shorttitle */
                      SET @c_titleshort = dbo.rpad(substring(@cursor_row$TITLE$2, 1, 35), 35, ' ')
                    END


		  SET @c_titleshort = ISNULL(@c_titleshort, ' ')
		  SET @c_title = ISNULL(@c_title, '')
		  SET @c_titlefull = ISNULL(@c_titlefull, '')

                  SET @c_isbn = dbo.rpad(@c_isbn, 10, ' ')
                  SET @c_titleshort = dbo.rpad(@c_titleshort, 35, ' ')
                  SET @c_title = dbo.rpad(substring(@c_title, 1, 32), 32, ' ')

                  SET @c_titlefull = dbo.rpad(substring(@c_titlefull, 1, 65), 65, ' ')

                  IF (len(rtrim(@cursor_row$AUTHORDISPLAYNAME1$2)) > 0)
                    BEGIN
                      SET @c_author1 = dbo.rpad(substring(rtrim(@cursor_row$AUTHORDISPLAYNAME1$2), 1, 30), 30, ' ')
                      SET @c_authordisplayname1 = dbo.rpad(substring(rtrim(@cursor_row$AUTHORDISPLAYNAME1$2), 1, 25), 25, ' ')
                    END
                  ELSE 
                    BEGIN
                      SET @c_authordisplayname1 = ' '
                      SET @c_author1 = ' '
                    END

                  IF (len(rtrim(@cursor_row$AUTHORDISPLAYNAME2$2)) > 0)
                    SET @c_author2 = dbo.rpad(substring(rtrim(@cursor_row$AUTHORDISPLAYNAME2$2), 1, 30), 30, ' ')

                  IF (len(rtrim(@cursor_row$AUTHORDISPLAYNAME3$2)) > 0)
                    SET @c_author3 = dbo.rpad(substring(rtrim(@cursor_row$AUTHORDISPLAYNAME3$2), 1, 30), 30, ' ')

                  IF (len(rtrim(@cursor_row$AUTHORDISPLAYNAME4$2)) > 0)
                    SET @c_author4 = dbo.rpad(substring(rtrim(@cursor_row$AUTHORDISPLAYNAME4$2), 1, 30), 30, ' ')

                  IF (len(rtrim(@cursor_row$AUTHORDISPLAYNAME5$2)) > 0)
                    SET @c_author5 = dbo.rpad(substring(rtrim(@cursor_row$AUTHORDISPLAYNAME5$2), 1, 30), 30, ' ')

                  IF @c_authordisplayname1 is null
                    BEGIN
                      SET @c_authordisplayname1 = ' '
                      SET @c_author1 = ' '
                    END

                  SET @c_authordisplayname1 = dbo.rpad(@c_authordisplayname1, 25, ' ')

                  SET @c_author1 = dbo.rpad(@c_author1, 30, ' ')

                  SET @c_author2 =  ISNULL(@c_author2, ' ')
                  SET @c_author2 = dbo.rpad(@c_author2, 30, ' ')

                  SET @c_author3 = ISNULL(@c_author3, ' ')
                  SET @c_author3 = dbo.rpad(@c_author3, 30, ' ')

                  SET @c_author4 = ISNULL(@c_author4, ' ')
                  SET @c_author4 = dbo.rpad(@c_author4, 30, ' ')

                  SET @c_author5 = ISNULL(@c_author5, ' ')
                  SET @c_author5 = dbo.rpad(@c_author5, 30, ' ')

                  SET @c_libaryofcongress = dbo.rpad(@cursor_row$LCCN$2, 10, ' ')

                  SET @c_upc = dbo.rpad(@cursor_row$UPC$2, 12, ' ')

                  /*  09-01-05 Pull EAN from isbn instead of whtitleinfo as per JS */

                  /*   c_ean := RPAD(replace(cursor_row.ean,'-',''),13,' '); */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.ISBN
                    WHERE ean is not null  AND 
                          dbo.ISBN.BOOKKEY = @cursor_row$BOOKKEY$2

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_ean = dbo.rpad(replace(dbo.ISBN.EAN, '-', ''), 13, ' ')
                        FROM dbo.ISBN
                        WHERE (dbo.ISBN.BOOKKEY = @cursor_row$BOOKKEY$2)
                    END
                  ELSE 
                    SET @c_ean = '             '

                  IF (len(@cursor_row$SUBTITLE$2) > 0)
                    SET @c_titleandsubtitle = dbo.rpad(@cursor_row$SUBTITLE$2, 70, ' ')
                  ELSE 
                    SET @c_titleandsubtitle = ' '

                  SET @c_titleandsubtitle = dbo.rpad(@c_titleandsubtitle, 70, ' ')

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL b, dbo.GENTABLES g
                    WHERE ((b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (g.TABLEID = 314) AND 
                            (b.BISACSTATUSCODE = g.DATACODE) AND 
                            (b.BISACSTATUSCODE > 0))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_answercode = dbo.rpad(substring(isnull(g.EXTERNALCODE, ' '), 1, 3), 3, ' '), @i_bisacstatuscode = g.DATACODE
                        FROM dbo.BOOKDETAIL b, dbo.GENTABLES g
                        WHERE ((b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (g.TABLEID = 314) AND 
                                (b.BISACSTATUSCODE = g.DATACODE))

                    END
                  ELSE 
                    SET @c_answercode = '   '

                  SET @c_answercode = ISNULL(@c_answercode, ' ')

                  IF (@i_bisacstatuscode IS NULL)
                    SET @i_bisacstatuscode = 0

                  SET @c_answercode = dbo.rpad(@c_answercode, 3, ' ')

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL b, dbo.GENTABLES g
                    WHERE ((b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (g.TABLEID = 459) AND 
                            (b.DISCOUNTCODE > 0))


                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_discode = dbo.rpad(substring(isnull(g.EXTERNALCODE, ' '), 1, 2), 2, ' ')
                        FROM dbo.BOOKDETAIL b, dbo.GENTABLES g
                        WHERE ((b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (g.TABLEID = 459) AND 
                                (b.DISCOUNTCODE = g.DATACODE))

                    END
                  ELSE 
                    SET @c_discode = '  '

                  SET @c_discode = ISNULL(@c_discode, ' ')
                  SET @c_uspricepubprice = dbo.lpad(CAST( (@cursor_row$USPRICEBEST$2 * 100) AS varchar(30)), 7, '0')
                  SET @c_canpubprice = dbo.lpad(CAST( (@cursor_row$CANADIANPRICEBEST$2 * 100) AS varchar(30)), 7, '0')

                  IF (@c_uspricepubprice = 0)
                    SET @c_uspricepubprice = '0000000'

                  IF (@c_canpubprice = '0')
                    BEGIN
                      /* 11-12-03 # sign vista will ignore,zero will process */
                      SET @c_canpubprice = '0000000'
                    END

                  SET @c_uspricepubprice = dbo.lpad(@c_uspricepubprice, 7, '0')
                  SET @c_canpubprice = dbo.lpad(@c_canpubprice, 7, '0')

                  /* 1-29-04 only do discountcode, list and canada price for nab,nyp */

                  IF ((@i_bisacstatuscode = 4) OR 
                          (@i_bisacstatuscode = 10))
                    BEGIN
                      SET @c_uspricepubprice = dbo.lpad(@c_uspricepubprice, 7, '0')
                      SET @c_canpubprice = dbo.lpad(@c_canpubprice, 7, '0')
                    END
                  ELSE 
                    BEGIN

                      SET @c_canpubprice = '#######'

                      SET @c_uspricepubprice = '#######'

                      SET @c_discode = '##'

                    END

                  IF (ISNULL((@c_libaryofcongress + '.'), '.') = '.')
                    SET @c_libaryofcongress = ''

                  SET @c_upc = ISNULL(@c_upc, '')
                  SET @c_ean = ISNULL(@c_ean, '')

                  SET @c_libaryofcongress = dbo.rpad(@c_libaryofcongress, 10, ' ')
                  SET @c_upc = dbo.rpad(@c_upc, 12, ' ')
                  SET @c_ean = dbo.rpad(@c_ean, 13, ' ')
                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKAUTHOR
                    WHERE ((dbo.BOOKAUTHOR.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (dbo.BOOKAUTHOR.AUTHORTYPECODE = 20))


                  IF (@lv_count > 1)
                    BEGIN

                      SET @lv_count2 = 0

                      SELECT @lv_count2 = min(dbo.BOOKAUTHOR.SORTORDER)
                        FROM dbo.BOOKAUTHOR
                        WHERE ((dbo.BOOKAUTHOR.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (dbo.BOOKAUTHOR.AUTHORTYPECODE = 20))

                      SET @lv_count3 = 0

                      SELECT @lv_count3 = count( * )
                        FROM dbo.BOOKAUTHOR ba, dbo.AUTHOR a
                        WHERE ((ba.AUTHORKEY = a.AUTHORKEY) AND 
                                (ba.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (ba.AUTHORTYPECODE = 20) AND 
                                (ba.SORTORDER = @lv_count2))

                      IF (@lv_count3 > 1)
                        BEGIN

                          SELECT @lv_authorkey = min(ba.AUTHORKEY)
                            FROM dbo.BOOKAUTHOR ba, dbo.AUTHOR a
                            WHERE ((ba.AUTHORKEY = a.AUTHORKEY) AND 
                                    (ba.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                    (ba.AUTHORTYPECODE = 20) AND 
                                    (ba.SORTORDER = @lv_count2))


                          SELECT @c_illustratordisplayname1 = dbo.rpad(substring(a.DISPLAYNAME, 1, 25), 25, ' ')
                            FROM dbo.BOOKAUTHOR ba, dbo.AUTHOR a
                            WHERE ((ba.AUTHORKEY = a.AUTHORKEY) AND 
                                    (ba.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                    (ba.AUTHORTYPECODE = 20) AND 
                                    (ba.AUTHORKEY = @lv_authorkey))
                        END

                      IF (@lv_count3 = 1)
                        BEGIN
                          SELECT @c_illustratordisplayname1 = dbo.rpad(substring(a.DISPLAYNAME, 1, 25), 25, ' ')
                            FROM dbo.BOOKAUTHOR ba, dbo.AUTHOR a
                            WHERE ((ba.AUTHORKEY = a.AUTHORKEY) AND 
                                    (ba.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                    (ba.AUTHORTYPECODE = 20) AND 
                                    (ba.SORTORDER = @lv_count2))
                        END

                    END

                  IF (@lv_count = 1)
                    BEGIN
                      SELECT @c_illustratordisplayname1 = dbo.rpad(substring(a.DISPLAYNAME, 1, 25), 25, ' ')
                        FROM dbo.BOOKAUTHOR ba, dbo.AUTHOR a
                        WHERE ((ba.AUTHORKEY = a.AUTHORKEY) AND 
                                (ba.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (ba.AUTHORTYPECODE = 20))
                    END

                  IF (@lv_count = 0)
                    BEGIN
                      SET @c_illustratordisplayname1 = ' '
                      SET @c_illustratordisplayname1 = dbo.rpad(@c_illustratordisplayname1, 25, ' ')
                    END

                  if @pos > 0 begin
                   SET @c_illustratordisplayname1 = substring(@c_illustratordisplayname1, 1, @pos)
		  end

                  SET @c_illustratordisplayname1 = dbo.rpad(@c_illustratordisplayname1, 25, ' ')

                  /* 10-01-03 add author 6 to 10  */

                  BEGIN

                    DECLARE 
                      @cursor_row1$DISPLAYNAME$2 varchar(100),
                      @cursor_row1$SORTORDER$2 integer                    

                    DECLARE 
                      author6to10 CURSOR LOCAL 
                       FOR 
                        SELECT isnull(a.DISPLAYNAME , ' ') AS DISPLAYNAME, isnull(b.SORTORDER, 0) AS SORTORDER
                          FROM dbo.BOOKAUTHOR b, dbo.AUTHOR a
                          WHERE ((b.BOOKKEY = @i_bookkey) AND 
                                  (b.AUTHORKEY = a.AUTHORKEY) AND 
                                  (b.SORTORDER > 5))
                        ORDER BY b.SORTORDER
                    

                    OPEN author6to10

                    FETCH NEXT FROM author6to10
                      INTO @cursor_row1$DISPLAYNAME$2, @cursor_row1$SORTORDER$2

                    WHILE  NOT(@@FETCH_STATUS = -1)
                      BEGIN
                        IF (@@FETCH_STATUS = -1)
                          BREAK 
                        SET @c_authortemp = ''
                        IF (len(rtrim(@cursor_row1$DISPLAYNAME$2)) > 0)
                          SET @c_authortemp = dbo.rpad(substring(rtrim(@cursor_row1$DISPLAYNAME$2), 1, 30), 30, ' ')
                        SET @c_authortemp = ISNULL(@c_authortemp, ' ')

                        SET @c_authortemp = dbo.rpad(@c_authortemp, 30, ' ')

                        IF (@cursor_row1$SORTORDER$2 = 6)
                          SET @c_author6 = @c_authortemp

                        IF (@cursor_row1$SORTORDER$2 = 7)
                          SET @c_author7 = @c_authortemp

                        IF (@cursor_row1$SORTORDER$2 = 8)
                          SET @c_author8 = @c_authortemp

                        IF (@cursor_row1$SORTORDER$2 = 9)
                          SET @c_author9 = @c_authortemp

                        IF (@cursor_row1$SORTORDER$2 = 10)
                          SET @c_author10 = @c_authortemp

                        FETCH NEXT FROM author6to10
                          INTO @cursor_row1$DISPLAYNAME$2, @cursor_row1$SORTORDER$2

                      END

                    CLOSE author6to10

                    DEALLOCATE author6to10

                  END

                  /* author loop */

                  IF (cursor_status(N'local', N'author6to10') = 1)
                    BEGIN
                      CLOSE author6to10
                      DEALLOCATE author6to10
                    END

                  SET @c_author6 = ISNULL(@c_author6, ' ')
                  SET @c_author7 = ISNULL(@c_author7, ' ')
		  SET @c_author8 = ISNULL(@c_author8, ' ')
		  SET @c_author9 = ISNULL(@c_author9, ' ')
		  SET @c_author10 = ISNULL(@c_author10, ' ')

                  SET @c_author6 = dbo.rpad(@c_author6, 30, ' ')
                  SET @c_author7 = dbo.rpad(@c_author7, 30, ' ')
                  SET @c_author8 = dbo.rpad(@c_author8, 30, ' ')
                  SET @c_author9 = dbo.rpad(@c_author9, 30, ' ')
                  SET @c_author10 = dbo.rpad(@c_author10, 30, ' ')

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKORGENTRY b, dbo.ORGENTRY o
                    WHERE ((b.ORGENTRYKEY = o.ORGENTRYKEY) AND 
                            (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (b.ORGLEVELKEY = 6))

                  IF (@lv_count > 0)
                    BEGIN

                      SELECT @c_grouplevel6 = o.ORGENTRYSHORTDESC
                        FROM dbo.BOOKORGENTRY b, dbo.ORGENTRY o
                        WHERE ((b.ORGENTRYKEY = o.ORGENTRYKEY) AND 
                                (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (b.ORGLEVELKEY = 6))
                      SET @c_grouplevel6 = ISNULL(@c_grouplevel6, ' ')
                    END
                  ELSE 
                    SET @c_grouplevel6 = ' '

                  /* 1-29-04 remove test titles */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKORGENTRY b, dbo.ORGENTRY o
                    WHERE ((b.ORGENTRYKEY = o.ORGENTRYKEY) AND 
                            (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (b.ORGLEVELKEY = 1) AND 
                            (o.ORGENTRYKEY IN (1380 )))

                  /* 05/05/05 PM CRM 2662 Including Bedford (1485) in College Enhanced feed (Removed */

                  IF (@lv_count > 0)
                    SET @c_remove_test_org = 1
                  ELSE 
                    BEGIN
                      /*  2-6-04 do not count test titles */
                      SET @lv_totalcount = (@lv_totalcount + 1)
                    END

                  SET @c_grouplevel6grpdesc1_2 = dbo.rpad(substring(@c_grouplevel6, 1, 2), 2, ' ')
                  SET @c_grouplevel6grpdesc3_4 = dbo.rpad(substring(@c_grouplevel6, 3, 2), 2, ' ')
                  SET @c_grouplevel6grpdesc5_6 = dbo.rpad(substring(@c_grouplevel6, 5, 2), 2, ' ')
                  SET @c_grouplevel6grpdesc1_2 = ISNULL(@c_grouplevel6grpdesc1_2, ' ')
                  SET @c_grouplevel6grpdesc3_4 = ISNULL(@c_grouplevel6grpdesc3_4, ' ')
                  SET @c_grouplevel6grpdesc5_6 = ISNULL(@c_grouplevel6grpdesc5_6, ' ')

                  /*  BEGIN FORMAT OUTPUT */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL b, dbo.SUBGENTABLES g
                    WHERE ((b.MEDIATYPECODE = g.DATACODE) AND 
                            (b.MEDIATYPESUBCODE = g.DATASUBCODE) AND 
                            (g.TABLEID = 312) AND 
                            (b.BOOKKEY = @cursor_row$BOOKKEY$2))

                  /*  PM 04-05-06 CRM 3786 Use Child Format externalcode if it exists         */

                  SET @lv_count2 = 0

                  SELECT @lv_count2 = count( * )
                    FROM dbo.BOOKSIMON b, dbo.GENTABLES g
                    WHERE b.FORMATCHILDCODE = g.DATACODE AND 
                            g.TABLEID = 300 AND 
                            g.EXTERNALCODE is not null AND 
                            b.BOOKKEY = @cursor_row$BOOKKEY$2



                  IF (@lv_count2 > 0)
                    PRINT @cursor_row$BOOKKEY$2

                  IF (@lv_count > 0)
                    BEGIN

                      /* 1-20-04 change external2 to externalcode from datadescshort */

                      SELECT @c_formatexternal = dbo.rpad(substring(isnull(g.DATADESCSHORT, ' '), 1, 2), 2, ' '),
			 @c_formatexternal2 = dbo.rpad(substring(isnull(g.EXTERNALCODE , ''), 1, 1), 1, ' '), 
			 @c_shorttitle = g.ALTERNATEDESC1
                        FROM dbo.BOOKDETAIL b, dbo.SUBGENTABLES g
                        WHERE ((b.MEDIATYPECODE = g.DATACODE) AND 
                                (b.MEDIATYPESUBCODE = g.DATASUBCODE) AND 
                                (g.TABLEID = 312) AND 
                                (b.BOOKKEY = @cursor_row$BOOKKEY$2))


                      SET @lv_count = 0

                      /* not sure what this is as yet */

                      SELECT @lv_count = count( * )
                        FROM dbo.BOOKDETAIL b
                        WHERE ((b.MEDIATYPECODE IN (13, 15 )) AND 
                                (b.BOOKKEY = @cursor_row$BOOKKEY$2))

                      IF (@lv_count > 0)
                        SET @c_mediaprepack = 'P1'
                      ELSE 
                        SET @c_mediaprepack = '  '

                      IF (@lv_count2 > 0)
                        BEGIN
                          SELECT @c_formatexternal = dbo.rpad(g.EXTERNALCODE, 2, ' ')
                            FROM dbo.BOOKSIMON b, dbo.GENTABLES g
                            WHERE b.FORMATCHILDCODE = g.DATACODE AND 
                                    g.TABLEID = 300 AND 
                                    g.EXTERNALCODE is not null AND 
                                    b.BOOKKEY = @cursor_row$BOOKKEY$2


                        END

                    END
                  ELSE 
                    BEGIN

                      SET @c_formatexternal = '  '

                      SET @c_formatexternal2 = ' '

                      SET @c_mediaprepack = '  '

                    END

                  /*  END FORMAT OUTPUT   */
		SET @c_formatexternal = ISNULL(@c_formatexternal, ' ')
		SET @c_formatexternal2 = ISNULL(@c_formatexternal2, ' ')
		SET @c_mediaprepack = ISNULL(@c_mediaprepack, ' ')


                  /*  END FORMAT OUTPUT */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g
                    WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (bs.CATEGORYTABLEID = 420) AND 
                            (g.TABLEID = 420) AND 
                            (g.DATACODE = bs.CATEGORYCODE))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_palgravepubexternalcode = dbo.rpad(substring(isnull(g.EXTERNALCODE , ''), 1, 3), 3, ' ')
                        FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g
                        WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (bs.CATEGORYTABLEID = 420) AND 
                                (g.TABLEID = 420) AND 
                                (g.DATACODE = bs.CATEGORYCODE))

                    END
                  ELSE 
                    SET @c_palgravepubexternalcode = '   '

                  SET @lv_count = 0

                  /* see if sub2gentables present */

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g, dbo.SUB2GENTABLES sg
                    WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (bs.CATEGORYTABLEID = 435) AND 
                            (g.TABLEID = 435) AND 
                            (g.DATACODE = bs.CATEGORYCODE) AND 
                            (sg.TABLEID = 435) AND 
                            (sg.DATACODE = bs.CATEGORYCODE) AND 
                            (sg.DATASUBCODE = bs.CATEGORYSUBCODE) AND 
                            (sg.DATASUB2CODE = bs.CATEGORYSUB2CODE))



                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_palgraveclassexternalcode = dbo.rpad(substring(isnull(sg.EXTERNALCODE , ''), 1, 4), 4, ' ')
                        FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g, dbo.SUB2GENTABLES sg
                        WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (bs.CATEGORYTABLEID = 435) AND 
                                (g.TABLEID = 435) AND 
                                (g.DATACODE = bs.CATEGORYCODE) AND 
                                (sg.TABLEID = 435) AND 
                                (sg.DATACODE = bs.CATEGORYCODE) AND 
                                (sg.DATASUBCODE = bs.CATEGORYSUBCODE) AND 
                                (sg.DATASUB2CODE = bs.CATEGORYSUB2CODE))
                  end ELSE 
                    BEGIN

                      /*  if no sub2gentables then see if subgentables present */

                      SET @lv_count = 0

                      SELECT @lv_count = count( * )
                        FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g, dbo.SUBGENTABLES sg
                        WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (bs.CATEGORYTABLEID = 435) AND 
                                (g.TABLEID = 435) AND 
                                (g.DATACODE = bs.CATEGORYCODE) AND 
                                (sg.TABLEID = 435) AND 
                                (sg.DATACODE = bs.CATEGORYCODE) AND 
                                (sg.DATASUBCODE = bs.CATEGORYSUBCODE))

                      IF (@lv_count > 0)
                        BEGIN
                          SELECT @c_palgraveclassexternalcode = dbo.rpad(substring(isnull(sg.EXTERNALCODE , ''), 1, 4), 4, ' ')
                            FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g, dbo.SUBGENTABLES sg
                            WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                    (bs.CATEGORYTABLEID = 435) AND 
                                    (g.TABLEID = 435) AND 
                                    (g.DATACODE = bs.CATEGORYCODE) AND 
                                    (sg.TABLEID = 435) AND 
                                    (sg.DATACODE = bs.CATEGORYCODE) AND 
                                    (sg.DATASUBCODE = bs.CATEGORYSUBCODE))


                        END
                      ELSE 
                        BEGIN

                          /*  if no sub2gentables and subgentables then see if gentables present */

                          SET @lv_count = 0

                          SELECT @lv_count = count( * )
                            FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g
                            WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                    (bs.CATEGORYTABLEID = 435) AND 
                                    (g.TABLEID = 435) AND 
                                    (g.DATACODE = bs.CATEGORYCODE))



                          IF (@lv_count = 1)
                            BEGIN
                              SELECT @c_palgraveclassexternalcode = dbo.rpad(substring(isnull(g.EXTERNALCODE , ''), 1, 4), 4, ' ')
                                FROM dbo.BOOKSUBJECTCATEGORY bs, dbo.GENTABLES g
                                WHERE ((bs.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                        (bs.CATEGORYTABLEID = 435) AND 
                                        (g.TABLEID = 435) AND 
                                        (g.DATACODE = bs.CATEGORYCODE))

                            END

                        END

                    END

		  SET @c_palgravepubexternalcode = ISNULL(@c_palgravepubexternalcode, ' ')
		  SET @c_palgraveclassexternalcode = ISNULL(@c_palgraveclassexternalcode, ' ')

                  SET @c_palgraveclassexternalcode = dbo.rpad(@c_palgraveclassexternalcode, 4, ' ')

                  SET @c_palgravepubexternalcode = dbo.rpad(@c_palgravepubexternalcode, 3, ' ')

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKBISACCATEGORY b, dbo.SUBGENTABLES s
                    WHERE ((b.BISACCATEGORYCODE = s.DATACODE) AND 
                            (b.BISACCATEGORYSUBCODE = s.DATASUBCODE) AND 
                            (s.TABLEID = 339) AND 
                            (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (b.PRINTINGKEY = 1) AND 
                            (b.SORTORDER = 1))


                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_bisacsubject1 = dbo.rpad(substring(isnull(s.BISACDATACODE , ' '), 1, 9), 9, ' ')
                        FROM dbo.BOOKBISACCATEGORY b, dbo.SUBGENTABLES s
                        WHERE ((b.BISACCATEGORYCODE = s.DATACODE) AND 
                                (b.BISACCATEGORYSUBCODE = s.DATASUBCODE) AND 
                                (s.TABLEID = 339) AND 
                                (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (b.PRINTINGKEY = 1) AND 
                                (b.SORTORDER = 1))
                    END
                  ELSE 
                    SET @c_bisacsubject1 = '         '

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKBISACCATEGORY b, dbo.SUBGENTABLES s
                    WHERE ((b.BISACCATEGORYCODE = s.DATACODE) AND 
                            (b.BISACCATEGORYSUBCODE = s.DATASUBCODE) AND 
                            (s.TABLEID = 339) AND 
                            (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (b.SORTORDER = 2))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_bisacsubject2 = dbo.rpad(substring(isnull(s.BISACDATACODE, ' '), 1, 9), 9, ' ')
                        FROM dbo.BOOKBISACCATEGORY b, dbo.SUBGENTABLES s
                        WHERE ((b.BISACCATEGORYCODE = s.DATACODE) AND 
                                (b.BISACCATEGORYSUBCODE = s.DATASUBCODE) AND 
                                (s.TABLEID = 339) AND 
                                (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (b.SORTORDER = 2))

                    END
                  ELSE 
                    SET @c_bisacsubject2 = '         '

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKBISACCATEGORY b, dbo.SUBGENTABLES s
                    WHERE ((b.BISACCATEGORYCODE = s.DATACODE) AND 
                            (b.BISACCATEGORYSUBCODE = s.DATASUBCODE) AND 
                            (s.TABLEID = 339) AND 
                            (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (b.SORTORDER = 3))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_bisacsubject3 = dbo.rpad(substring(isnull(s.BISACDATACODE, ' '), 1, 9), 9, ' ')
                        FROM dbo.BOOKBISACCATEGORY b, dbo.SUBGENTABLES s
                        WHERE ((b.BISACCATEGORYCODE = s.DATACODE) AND 
                                (b.BISACCATEGORYSUBCODE = s.DATASUBCODE) AND 
                                (s.TABLEID = 339) AND 
                                (b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (b.SORTORDER = 3))

                    END
                  ELSE 
                    SET @c_bisacsubject3 = '         '

                  SET @lv_count = 0

                  /*  2-3-04 added gradelow/high upind  */

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL
                    WHERE ((dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (len(dbo.BOOKDETAIL.GRADELOW) > 0))


                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_gradelevelfrom = dbo.rpad(substring(isnull(dbo.BOOKDETAIL.GRADELOW, ' '), 1, 2), 2, ' ')
                        FROM dbo.BOOKDETAIL
                        WHERE (dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2)

                    END
                  ELSE 
                    BEGIN

                      SET @lv_count = 0

                      SELECT @lv_count = count( * )
                        FROM dbo.BOOKDETAIL
                        WHERE ((dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (len(CAST( dbo.BOOKDETAIL.GRADELOWUPIND AS varchar(8000))) > 0))


                      IF (@lv_count > 0)
                        SET @c_gradelevelfrom = 'UP'
                      ELSE 
                        SET @c_gradelevelfrom = '  '

                    END

                  SET @c_gradelevelfrom = ISNULL(@c_gradelevelfrom, ' ')
                  SET @c_gradelevelfrom = dbo.rpad(@c_gradelevelfrom, 2, ' ')

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL
                    WHERE ((dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (len(dbo.BOOKDETAIL.GRADEHIGH) > 0))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_gradelevelto = dbo.rpad(substring(isnull(dbo.BOOKDETAIL.GRADEHIGH, ' '), 1, 2), 2, ' ')
                        FROM dbo.BOOKDETAIL
                        WHERE (dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2)
                    END
                  ELSE 
                    BEGIN

                      SET @lv_count = 0

                      SELECT @lv_count = count( * )
                        FROM dbo.BOOKDETAIL
                        WHERE ((dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (len(CAST( dbo.BOOKDETAIL.GRADEHIGHUPIND AS varchar(50))) > 0))


                      IF (@lv_count > 0)
                        SET @c_gradelevelto = 'UP'
                      ELSE 
                        SET @c_gradelevelto = '  '

                    END

                  SET @c_gradelevelto = ISNULL(@c_gradelevelto, ' ')
                  SET @c_gradelevelto = dbo.rpad(@c_gradelevelto, 2, ' ')

                  /*  per john use printingkey=1 */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.PRINTING p, dbo.WHPRINTINGKEYDATES wp, dbo.WHPRINTING wp2
                    WHERE ((p.BOOKKEY = wp.BOOKKEY) AND 
                            (p.PRINTINGKEY = wp.PRINTINGKEY) AND 
                            (p.BOOKKEY = wp2.BOOKKEY) AND 
                            (p.PRINTINGKEY = wp2.PRINTINGKEY) AND 
                            (p.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (p.PRINTINGKEY = 1))


                  IF (@lv_count > 0)
                    BEGIN

                      SELECT 
                          @c_pubdatebest = SYSDB.SSMA.TO_CHAR_DATE(wp.BESTDATE1, 'MMDDYY'), 
                          @c_releasedatebest = SYSDB.SSMA.TO_CHAR_DATE(wp.BESTDATE2, 'MMDDYY'), 
                          @c_cartonqty = dbo.lpad(CAST( isnull(wp2.CARTONQTY, 0) AS varchar(8000)), 4, '0'), 
                          @c_trimheight = substring(p.TRIMSIZELENGTH, 1, 6), 
                          @c_trimwidth = substring(p.TRIMSIZEWIDTH, 1, 6), 
                          @c_spinesize = substring(p.SPINESIZE, 1, 6), 
                          @c_pagecount = CASE WHEN (isnull(p.PAGECOUNT, 0) <> 0) THEN substring(dbo.lpad(CAST( isnull(p.PAGECOUNT, 0) AS varchar(8000)), 6, '0'), 1, 6) WHEN (isnull(p.TENTATIVEPAGECOUNT, 0) <> 0) THEN substring(dbo.lpad(CAST( isnull(p.TENTATIVEPAGECOUNT, 0) AS varchar(8000)), 6, '0'), 1, 6) ELSE '000000' END
                        FROM dbo.PRINTING p, dbo.WHPRINTINGKEYDATES wp, dbo.WHPRINTING wp2
                        WHERE ((p.BOOKKEY = wp.BOOKKEY) AND 
                                (p.PRINTINGKEY = wp.PRINTINGKEY) AND 
                                (p.BOOKKEY = wp2.BOOKKEY) AND 
                                (p.PRINTINGKEY = wp2.PRINTINGKEY) AND 
                                (p.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (p.PRINTINGKEY = 1))



                      SET @c_pubdatebest = ISNULL(@c_pubdatebest, ' ')

                      /*  PM 10/19/05 CRM 3311 - Modify title feed so that release dates are not sent for specified discount codes  */

                      IF ((ISNULL((@c_releasedatebest + '.'), '.') = '.') OR 
                                      (@cursor_row$DISCOUNTCODE$2 IN (1, 2, 7, 11, 23, 26, 12 )))
                        SET @c_releasedatebest = ' '

                      SET @c_pubdatebest = dbo.rpad(@c_pubdatebest, 6, ' ')

                      SET @c_releasedatebest = dbo.rpad(@c_releasedatebest, 6, ' ')

                      SET @c_trimheight = ISNULL(@c_trimheight, ' ')
		      SET @c_trimwidth = ISNULL(@c_trimwidth, ' ')
		      SET @c_spinesize = ISNULL(@c_spinesize, ' ')
		      SET @c_pagecount = ISNULL(@c_pagecount, '0')


                      IF (len(ltrim(rtrim(@c_trimheight))) = 0)
                        SET @c_trimheight = ' '

                      IF (len(ltrim(rtrim(@c_trimwidth))) = 0)
                        SET @c_trimwidth = ' '

                      IF (len(ltrim(rtrim(@c_spinesize))) = 0)
                        SET @c_spinesize = ' '

                      /* get decimal form for trim */

                      SET @lv_count = 0
                      SET @lv_count2 = 0
                      SET @lv_count3 = 0
                      SET @lv_decimal = 0
                      SET @lv_pos1 = 0
                      SET @lv_pos2 = 0
                      SET @c_trimheight = '000000'
                      SET @c_trimwidth = '000000'
                      SET @c_spinesize = '000000'
                    END
                  ELSE 
                    BEGIN
                      SET @c_pubdatebest = '      '
                      SET @c_releasedatebest = '      '
                      SET @c_cartonqty = '0000'

                      /*
                       -- c_trimheight := '      ';
                       --   c_trimwidth := '      ';
                       --   c_spinesize := '      ';
                       --*/

                      SET @c_trimheight = '000000'
                      SET @c_trimwidth = '000000'
                      SET @c_spinesize = '000000'
                      SET @c_pagecount = '000000'
                    END

                  SET @lv_count = 0
                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDATES
                    WHERE ((dbo.BOOKDATES.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (dbo.BOOKDATES.PRINTINGKEY = 1) AND 
                            (dbo.BOOKDATES.DATETYPECODE = 4))

                  IF (@lv_count > 0)
                    BEGIN

                      SELECT @c_msdeliverydate = convert(varchar(6), dbo.BOOKDATES.BESTDATE, 1)
                        FROM dbo.BOOKDATES
                        WHERE ((dbo.BOOKDATES.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (dbo.BOOKDATES.PRINTINGKEY = 1) AND 
                                (dbo.BOOKDATES.DATETYPECODE = 4))

			set @c_msdeliverydate = replace(@c_msdeliverydate, '/', '')
                    END

                  SET @c_msdeliverydate = ISNULL(@c_msdeliverydate, ' ')
                  SET @c_msdeliverydate = dbo.rpad(@c_msdeliverydate, 6, ' ')

                  IF (@c_remove_test_org <> 1)
                    BEGIN
                      /* remove test titles */
                      IF (CAST( @c_cartonqty AS integer) > 0)
                        SET @lv_totalcartonqty = (@lv_totalcartonqty + CAST( @c_cartonqty AS integer))

                      IF (CAST( @c_pagecount AS integer) > 0)
                        SET @lv_totalpagecount = (@lv_totalpagecount + CAST( @c_pagecount AS integer))
                    END

                  /*  CRM 2662 - Populate Existing fields  */

                  /*  US Net Price */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKPRICE
                    WHERE ((dbo.BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (dbo.BOOKPRICE.PRICETYPECODE = 9) AND 
                            (dbo.BOOKPRICE.CURRENCYTYPECODE = 6) AND 
                            ((dbo.BOOKPRICE.BUDGETPRICE IS NOT NULL) OR 
                                    (dbo.BOOKPRICE.FINALPRICE IS NOT NULL)))

                  IF (@lv_count > 0)
                    BEGIN

                      SELECT @c_usnetprice = CASE WHEN (dbo.BOOKPRICE.FINALPRICE IS NULL) 
						THEN dbo.BOOKPRICE.BUDGETPRICE 
						WHEN (dbo.BOOKPRICE.BUDGETPRICE IS NULL) 
						THEN dbo.BOOKPRICE.FINALPRICE 
						ELSE dbo.BOOKPRICE.FINALPRICE 
						END
                        FROM dbo.BOOKPRICE
                        WHERE ((dbo.BOOKPRICE.PRICETYPECODE = 9) AND 
                                (dbo.BOOKPRICE.CURRENCYTYPECODE = 6) AND 
                                (dbo.BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$2))



                      SET @c_usnetprice = dbo.lpad(CAST( (CAST( @c_usnetprice AS float) * 100) AS varchar(50)), 7, '0')

                    END
                  ELSE 
                    SET @c_usnetprice = '0000000'

                  /*  Canadian Net Price Changed to Price type code 13 10-13-05 js */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKPRICE
                    WHERE ((dbo.BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (dbo.BOOKPRICE.PRICETYPECODE = 13) AND 
                            (dbo.BOOKPRICE.CURRENCYTYPECODE = 38))


                  IF (@lv_count > 0)
                    BEGIN

                      SELECT @c_cannetprice = CASE WHEN (dbo.BOOKPRICE.FINALPRICE IS NULL) 
							THEN dbo.BOOKPRICE.BUDGETPRICE 
							WHEN (dbo.BOOKPRICE.BUDGETPRICE IS NULL) 
							THEN dbo.BOOKPRICE.FINALPRICE 
							ELSE dbo.BOOKPRICE.FINALPRICE 
						   END
                        FROM dbo.BOOKPRICE
                        WHERE ((dbo.BOOKPRICE.PRICETYPECODE = 13) AND 
                                (dbo.BOOKPRICE.CURRENCYTYPECODE = 38) AND 
                                (dbo.BOOKPRICE.BOOKKEY = @cursor_row$BOOKKEY$2))

                      SET @c_cannetprice = dbo.lpad(CAST( (CAST( @c_cannetprice AS float) * 100) AS varchar(8000)), 7, '0')

                    END
                  ELSE 
                    SET @c_cannetprice = '0000000'

                  /*  Project ISBN */
                  SET @lv_count = 0
                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL
                    WHERE dbo.BOOKDETAIL.VISTAPROJECTNUMBER is not null AND 
                          dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2

                  IF (@lv_count > 0)
                    BEGIN

                      SELECT @c_projectisbn = substring(dbo.BOOKDETAIL.VISTAPROJECTNUMBER, 1, 10)
                        FROM dbo.BOOKDETAIL
                        WHERE (dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2)


                      SET @c_projectisbn = dbo.rpad(@c_projectisbn, 10, ' ')

                    END
                  ELSE 
                    SET @c_projectisbn = '          '

                  /*  Alternate Project ISBN JS 09-16-05 */
                  SET @lv_count = 0
                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL
                    WHERE dbo.BOOKDETAIL.ALTERNATEPROJECTISBN is not null AND 
                          dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2


                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_altprojectisbn = substring(dbo.BOOKDETAIL.ALTERNATEPROJECTISBN, 1, 10)
                        FROM dbo.BOOKDETAIL
                        WHERE (dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2)
                    END
                  ELSE 
                    SET @c_altprojectisbn = '          '

                  /*  Copyright Year JS 09-16/05 */
                  SET @lv_count = 0
                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL
                    WHERE ((dbo.BOOKDETAIL.COPYRIGHTYEAR IS NOT NULL) AND 
                            (dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_copyrightyear_int = dbo.BOOKDETAIL.COPYRIGHTYEAR
                        FROM dbo.BOOKDETAIL
                        WHERE (dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2)


 		set @c_copyrightyear = cast(@c_copyrightyear_int as varchar(10))
		set @c_copyrightyear = substring(@c_copyrightyear, 1, 4)

                    END
                  ELSE 
                    SET @c_copyrightyear = '    '

                  /*  Never send to eloquence flag */
                  SET @lv_count = 0
                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKEDISTATUS
                    WHERE ((dbo.BOOKEDISTATUS.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (dbo.BOOKEDISTATUS.EDISTATUSCODE = 8) AND 
                            (dbo.BOOKEDISTATUS.PRINTINGKEY = 1))

                  IF (@lv_count > 0)
                    SET @c_neversendtoeloquence = 'N'
                  ELSE 
                    SET @c_neversendtoeloquence = 'Y'

                  /* c_usnetprice := '#######'; */

                  /* c_cannetprice := '#######'; */

                  SET @c_exppubprice = '#######'
                  SET @c_expnetprice = '#######'

                  /* c_projectisbn := '          '; */
                  /* c_pocketpubflag := ' '; */
                  /* c_sampltoolflag := ' '; */
                  /* c_royaltyflag := ' '; */

                  SET @c_statuscode = '  '
                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKDETAIL b, dbo.GENTABLES g
                    WHERE ((b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                            (g.TABLEID = 428) AND 
                            (b.CANADIANRESTRICTIONCODE = g.DATACODE) AND 
                            (b.CANADIANRESTRICTIONCODE > 0))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_canadarest = dbo.rpad(substring(isnull(g.EXTERNALCODE , ' '), 1, 2), 2, ' ')
                        FROM dbo.BOOKDETAIL b, dbo.GENTABLES g
                        WHERE ((b.BOOKKEY = @cursor_row$BOOKKEY$2) AND 
                                (g.TABLEID = 428) AND 
                                (b.CANADIANRESTRICTIONCODE = g.DATACODE))

                    END
                  ELSE 
                    SET @c_canadarest = '  '

                  SET @c_canadarest = ISNULL(@c_canadarest, ' ')
                    SET @c_canadarest = '  '

                  /*  5-13-05 PM Add count check  */

                  SELECT @lv_count = count( * )
                    FROM dbo.WHTITLEPERSONNEL
                    WHERE (dbo.WHTITLEPERSONNEL.BOOKKEY = @cursor_row$BOOKKEY$2)


                  IF (@lv_count > 0)
                    BEGIN

                      /* 3-31-04 whtitlepersonnel.displayname1 editor */

                      SELECT @c_editor = substring(isnull(dbo.WHTITLEPERSONNEL.DISPLAYNAME1, ' '), 1, 86)
                        FROM dbo.WHTITLEPERSONNEL
                        WHERE (dbo.WHTITLEPERSONNEL.BOOKKEY = @cursor_row$BOOKKEY$2)

                    END
                  ELSE 
                    SET @c_editor = ' '

                  SET @c_editor = dbo.rpad(@c_editor, 86, ' ')

                  /*
                   -- if audio  then shorttitle = shorttitle + editon shortdesc (tableid=200) + format (tableid=312)
                   -- altdesc1
                   --*/

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKORGENTRY
                    WHERE ((dbo.BOOKORGENTRY.ORGENTRYKEY = 1314) AND 
                            (dbo.BOOKORGENTRY.BOOKKEY = @cursor_row$BOOKKEY$2))

                  IF (@lv_count > 0)
                    BEGIN

                      SET @lv_count = 0

                      SELECT @lv_count = dbo.BOOKDETAIL.EDITIONCODE
                        FROM dbo.BOOKDETAIL
                        WHERE (dbo.BOOKDETAIL.BOOKKEY = @cursor_row$BOOKKEY$2)
                      IF (@lv_count > 0)
                        BEGIN
                          SELECT @c_edition = dbo.GENTABLES.DATADESCSHORT
                            FROM dbo.GENTABLES
                            WHERE ((dbo.GENTABLES.TABLEID = 200) AND 
                                    (dbo.GENTABLES.DATACODE = @lv_count))
                        END
                      ELSE 
                        SET @c_edition = ''

                      /* got altdesc1 already in c_shorttitle */

                      SET @c_edition = ISNULL(@c_edition, ' ')
                      SET @c_shorttitle = ISNULL(@c_shorttitle, ' ')
                      SET @c_shorttitle = rtrim(@cursor_row$SHORTTITLE$2) + ' ' + rtrim(@c_edition) + ' ' + rtrim(@c_shorttitle)
                      SET @c_shorttitle = replace(@c_shorttitle, '  ', ' ')
                      SET @c_shorttitle = rtrim(@c_shorttitle)

                      SET @c_shorttitle = dbo.rpad(substring(@c_shorttitle, 1, 35), 35, ' ')

                      /*  move into field outputting */
                      SET @c_titleshort = @c_shorttitle

                    END

                  /* 6-29-04  add cassette units and runtime at end of file */

                  SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.AUDIOCASSETTESPECS
                    WHERE ((dbo.AUDIOCASSETTESPECS.PRINTINGKEY = 1) AND 
                            (dbo.AUDIOCASSETTESPECS.BOOKKEY = @cursor_row$BOOKKEY$2))

                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_cassetteunits = substring(CAST( isnull(dbo.AUDIOCASSETTESPECS.NUMCASSETTES, '0') AS varchar(100)), 0, 1), 
			     @c_totalruntime = substring(isnull(dbo.AUDIOCASSETTESPECS.TOTALRUNTIME , '0'), 0, 1)
                        FROM dbo.AUDIOCASSETTESPECS
                        WHERE ((dbo.AUDIOCASSETTESPECS.PRINTINGKEY = 1) AND 
                                (dbo.AUDIOCASSETTESPECS.BOOKKEY = @cursor_row$BOOKKEY$2))
                    END

                  SET @c_cassetteunits = ISNULL(@c_cassetteunits, '0')
                  SET @c_totalruntime = ISNULL(@c_totalruntime, '0')

                  SET @c_totalruntime = dbo.lpad(@c_totalruntime, 10, '0')
                  SET @c_cassetteunits = dbo.lpad(@c_cassetteunits, 10, '0')

                  /*  5/13/05 PM  - could be multiple partner rows - if 1 has sendtoeloquenceind = 1, then set  lv_titlereleasedtoeloquenceind = 'Y'  */
                  SET @lv_count = 0
                  SET @c_titlereleasedtoelo = ''

                  SELECT @lv_count = count( * )
                    FROM dbo.BOOKEDIPARTNER
                    WHERE ((dbo.BOOKEDIPARTNER.PRINTINGKEY = 1) AND 
                            (dbo.BOOKEDIPARTNER.SENDTOELOQUENCEIND = 1) AND 
                            (dbo.BOOKEDIPARTNER.BOOKKEY = @cursor_row$BOOKKEY$2))

                  IF ((@@ROWCOUNT > 0) AND 
                          (@lv_count > 0))
                    SET @c_titlereleasedtoelo = 'Y'
                  ELSE 
                    SET @c_titlereleasedtoelo = 'N'

                  SELECT 
                      @c_imsflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO1 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_potodflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO2 WHEN 'Yes' THEN 'Y' ELSE ' ' END, 
                      @c_podflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO3 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_mcnaughtonflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO4 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_pbwatchlistflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO5 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_pocketpubflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO6 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_sampleableflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO7 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_sampltoolflag = CASE dbo.WHBOOKMISC.BOOKMISCGENTABLECODE4 WHEN 1 THEN ' ' WHEN 2 THEN 'Y' WHEN 3 THEN 'N' ELSE ' ' END, 
                      @c_primarysampleflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO10 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_inproductionflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO11 WHEN 'Yes' THEN 'Y' ELSE 'N' END, 
                      @c_royaltyflag = CASE dbo.WHBOOKMISC.BOOKMISCYESNO13 WHEN 'Yes' THEN 'N' ELSE 'Y' END, 
                      @c_binderypackflag = CASE dbo.WHBOOKMISC.BOOKMISCGENTABLECODE1 WHEN 1 THEN 'Y' ELSE ' ' END, 
                      @c_reppackflag = CASE dbo.WHBOOKMISC.BOOKMISCGENTABLECODE1 WHEN 2 THEN 'Y' ELSE ' ' END
                    FROM dbo.WHBOOKMISC
                    WHERE (dbo.WHBOOKMISC.BOOKKEY = @cursor_row$BOOKKEY$2)

                 SET @lv_count = 0

                  SELECT @lv_count = count( * )
                    FROM dbo.SUBGENTABLES g, dbo.BOOKMISC b
                    WHERE ((b.MISCKEY = 48) AND 
                            (g.TABLEID = 525) AND 
                            (g.DATACODE = 1) AND 
                            (b.LONGVALUE = g.DATASUBCODE) AND 
                            (b.BOOKKEY = @cursor_row$BOOKKEY$2))


                  IF (@lv_count > 0)
                    BEGIN
                      SELECT @c_limitedallowed = substring(CAST( g.EXTERNALCODE AS varchar(100)), 0, 1)
                        FROM dbo.SUBGENTABLES g, dbo.BOOKMISC b
                        WHERE ((b.MISCKEY = 48) AND 
                                (g.TABLEID = 525) AND 
                                (g.DATACODE = 1) AND 
                                (b.LONGVALUE = g.DATASUBCODE) AND 
                                (b.BOOKKEY = @cursor_row$BOOKKEY$2))

                    END
                  ELSE 
                    SET @c_limitedallowed = ' '

                  /* output record */

                 IF (@c_remove_test_org <> 1)
                    BEGIN

                      /* remove test titles */

                      SET @lv_output_string = (isnull(@c_recordtype, '') + isnull(@c_college_trade, '') + isnull(@c_isbn, '') + isnull(@c_titleshort, '') + isnull(@c_authordisplayname1, '') + isnull(@c_illustratordisplayname1, '') + isnull(@c_titlefull, '') + isnull(@c_grouplevel6grpdesc1_2, '') + isnull(@c_grouplevel6grpdesc3_4, '') + isnull(@c_grouplevel6grpdesc5_6, '') + isnull(@c_formatexternal, '') + isnull(@c_palgravepubexternalcode, '') + isnull(@c_mediaprepack, '') + isnull(@c_formatexternal2, '') + isnull(@c_palgraveclassexternalcode, '') + isnull(@c_bisacsubject1, '') + isnull(@c_bisacsubject2, '') + isnull(@c_bisacsubject3, '') + isnull(@c_gradelevelfrom, '') + isnull(@c_gradelevelto, '') + isnull(@c_discode, '') + isnull(@c_libaryofcongress, '') + isnull(@c_ean, '') + isnull(@c_pubdatebest, '') + isnull(@c_releasedatebest, '') + isnull(@c_cartonqty, '') + isnull(@c_trimheight, '') + isnull(@c_trimwidth, '') + isnull(@c_spinesize, '') + isnull(@c_pagecount, '') + isnull(@c_msdeliverydate, '') + isnull(@c_titleandsubtitle, '') + isnull(@c_author1, '') + isnull(@c_author2, '') + isnull(@c_author3, '') + isnull(@c_author4, '') + isnull(@c_author5, '') + isnull(@c_author6, '') + isnull(@c_author7, '') + isnull(@c_author8, '') + isnull(@c_author9, '') + isnull(@c_author10, '') + isnull(@c_uspricepubprice, '') + isnull(@c_usnetprice, '') + isnull(@c_canpubprice, '') + isnull(@c_cannetprice, '') + isnull(@c_exppubprice, '') + isnull(@c_expnetprice, '') + isnull(@c_projectisbn, '') + isnull(@c_pocketpubflag, '') + isnull(@c_sampltoolflag, '') + isnull(@c_royaltyflag, '') + isnull(@c_answercode, '') + isnull(@c_canadarest, '') + isnull(@c_statuscode, '') + isnull(@c_editor, '') + isnull(@c_cassetteunits, '') + isnull(@c_totalruntime, '') + isnull(@c_titlereleasedtoelo, '') + isnull(@c_neversendtoeloquence, '') + '    ' + isnull(@c_sampleableflag, '') + '       ' + isnull(@c_imsflag, '') + isnull(@c_potodflag, '') + isnull(@c_binderypackflag, '') + isnull(@c_primarysampleflag, '') + isnull(@c_inproductionflag, '') + isnull(@c_reppackflag, '') + '  ' + isnull(@c_podflag, '') + isnull(@c_recordpadding, '') + isnull(@c_limitedallowed, '') + isnull(@c_altprojectisbn, '') + isnull(@c_copyrightyear, ''))

                      EXEC SYSDB.SSMA.UTL_FILE_PUT_LINE @lv_file_id_num, @lv_output_string 

                    END

                  FETCH NEXT FROM titleout_cursor
                    INTO 
                      @cursor_row$BOOKKEY$2, 
                      @cursor_row$ISBN10$2, 
                      @cursor_row$SHORTTITLE$2, 
                      @cursor_row$TITLE$2, 
                      @cursor_row$AUTHORDISPLAYNAME1$2, 
                      @cursor_row$AUTHORDISPLAYNAME2$2, 
                      @cursor_row$AUTHORDISPLAYNAME3$2, 
                      @cursor_row$AUTHORDISPLAYNAME4$2, 
                      @cursor_row$AUTHORDISPLAYNAME5$2, 
                      @cursor_row$GROUPLEVEL6$2, 
                      @cursor_row$LCCN$2, 
                      @cursor_row$UPC$2, 
                      @cursor_row$EAN$2, 
                      @cursor_row$SUBTITLE$2, 
                      @cursor_row$USPRICEBEST$2, 
                      @cursor_row$CANADIANPRICEBEST$2, 
                      @cursor_row$DISCOUNTCODE$2

                END

              CLOSE titleout_cursor

              DEALLOCATE titleout_cursor

            END

            /* * Output New Sequence Number * */

            /*  Open Sequence File  */

            --EXEC SYSDB.SSMA.UTL_FILE_FOPEN$IMPL @p_location, 'tmfyi_in_seqnum_v2.txt', 'W', 32000, @lv_file_id_num2 OUTPUT 
	   set @c_filename = @p_location + '\' + 'tmfyi_in_seqnum_v2.txt'
	   execute @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @lv_file_id_num2 OUT, @c_filename, 8, 1
	   IF @OLEResult <> 0 begin
	      PRINT 'Error: OpenTextFile Failed3'
              goto destroy
           end

            SET @lv_output_string = CAST( @i_sequence_num AS varchar(100))

--            EXEC SYSDB.SSMA.UTL_FILE_PUT_LINE @lv_file_id_num2, @lv_output_string 
	  execute @OLEResult = sp_OAMethod @lv_file_id_num2, 'WriteLine', Null, @lv_output_string
	   IF @OLEResult <> 0 begin
	      PRINT 'Error: WriteLine Failed'
              goto destroy
           end

--            EXEC SYSDB.SSMA.UTL_FILE_FCLOSE @lv_file_id_num2 
	  exec @OLEResult = sp_OAMethod @FS, 'Close', @lv_file_id_num2

            /* create footer record */

            /*  default college detail lines to 8 zeros  */

            SET @lv_defaultstring = '00000000'

            /* total 8 zeros for college total */

            IF (@lv_totalcount IS NULL)
              SET @lv_totalcount_char = '0'
            ELSE 
              SET @lv_totalcount_char = CAST( @lv_totalcount AS varchar(8000))

            SET @lv_totalcount_char = dbo.lpad(@lv_totalcount_char, 8, '0')

            IF (@lv_totalpagecount IS NULL)
              SET @lv_totalpagecount_char = '0'
            ELSE 
              SET @lv_totalpagecount_char = CAST( @lv_totalpagecount AS varchar(30))

            SET @lv_totalpagecount_char = dbo.lpad(@lv_totalpagecount_char, 8, '0')

            IF (@lv_totalcartonqty IS NULL)
              SET @lv_totalcartonqty_char = '0'
            ELSE 
              SET @lv_totalcartonqty_char = CAST( @lv_totalcartonqty AS varchar(30))

            SET @lv_totalcartonqty_char = dbo.lpad(@lv_totalcartonqty_char, 6, '0')

            SET @lv_output_string = ('T ' + isnull(@lv_totalcount_char, '') + isnull(@c_currentdate, '') + isnull(@c_currentdatetime, '') + isnull(@lv_defaultstring, '') + isnull(@lv_totalcount_char, '') + isnull(@lv_totalcartonqty_char, '') + isnull(@lv_totalpagecount_char, ''))

           -- EXEC SYSDB.SSMA.UTL_FILE_PUT_LINE @lv_file_id_num, @lv_output_string 
	    execute @OLEResult = sp_OAMethod @lv_file_id_num, 'WriteLine', Null, @lv_output_string
	     IF @OLEResult <> 0 begin
	        PRINT 'Error: WriteLine Failed'
                goto destroy
             end

            INSERT INTO dbo.FEEDERROR
              (dbo.FEEDERROR.BATCHNUMBER, dbo.FEEDERROR.PROCESSDATE, dbo.FEEDERROR.ERRORDESC)
              VALUES ('1', getdate(), 'Vista TMM File Completed')


            IF (cursor_status(N'local', N'titleout_cursor') = 1)
              BEGIN
                CLOSE titleout_cursor
                DEALLOCATE titleout_cursor
              END

          END
destroy:
EXECUTE @OLEResult = sp_OADestroy @lv_file_id_num
EXECUTE @OLEResult = sp_OADestroy @lv_file_id_num2
EXECUTE @OLEResult = sp_OADestroy @FS
END
go
grant execute on feedout_titles_sp_v2  to public
go
