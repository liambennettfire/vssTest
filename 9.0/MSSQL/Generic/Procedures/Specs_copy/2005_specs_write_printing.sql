/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_Copy_write_printing') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_printing
END
GO

CREATE PROCEDURE Specs_Copy_write_printing 	(
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_specind          INT,
  @i_nextprintingnbr  INT,
  @i_nextjobnbr       INT,
  @i_copy             VARCHAR(10),
  @i_userid           VARCHAR(30),
  @o_printingnum      INT OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT)

AS

DECLARE @v_compkey   INT,
        @v_finishedgoodind INT,
        @v_pagecount_option  TINYINT,
		  @v_actualtrimsize_option  TINYINT,
		  @v_use_impression_number TINYINT,
        @v_jobnumberalpha_gen  TINYINT,
		  @v_tmm_pagecount_used TINYINT,
        @v_tmm_trimsize_used TINYINT,
		  @v_firstprintingqty INT,
        @v_trimsizewidth varchar(10),
		  @v_trimsizelength varchar(10),
        @v_notekey INT,
        @v_newnotekey INT,
        @v_notecount INT,
        @v_bookbulk decimal,
        @v_jobnum INT,
        @v_printingjob varchar(10),
        @v_servicearea INT,
        @v_conversionind INT,
		  @v_nastaind varchar(1),
		  @v_statelabelind varchar(1),
		  @v_statuscode int,
		  @v_esttrimsizewidth varchar(10),
		  @v_esttrimsizelength varchar(10),
		  @v_seasonkey int,
		  @v_estseasonkey int,
	  	  @v_creationdate datetime,
		  @v_tmmpagecount int,
		  @v_impressionnumber varchar(10),
	 	  @v_spinesize varchar(10),
            @v_spinesizeunitofmeasure int,
		  @v_boardtrimsizewidth varchar(10),
		  @v_boardtrimsizelength varchar(10),
        @v_to_trimsizewidth varchar(10),
   	  @v_to_trimsizelength varchar(10),
		  @v_printcode varchar(10),  
        @v_count INT,
        @v_count2 INT,
        @v_prodtrimwidth varchar(10),
        @v_prodtrimheight varchar(10),
        @v_tmmtrimsizewidth varchar(10),
        @v_tmmtrimsizeheight varchar(10), 
        @v_prodpagecount INT, 
        @v_to_pagecount INT,
        @v_tentativepagecount INT,
        @max_printingkey INT,
		  @max_printingnum INT,
        @v_orig_impressionnumber varchar(10),
		  @v_orig_length INT,
		  @v_tempnum INT,
        @v_length_tempnum INT,
        @v_len_diff INT,
        @v_string_tempnum varchar(10),
        @v_count3 INT,
        @v_jobnumberalpha varchar(10),
        @v_right_digit char(1),
        @v_left_digit char(1),
        @v_value INT,
        @v_companycode varchar(10),
        @v_text varchar(5500),
        @v_showonpoind varchar(1),
        @v_copynextprtgind varchar(1),
        @v_detaillinenbr INT,
        @v_cameraitem SMALLINT,
        @v_quantity INT,
        @v_trimfamily smallint,
        @v_pagecount smallint,
        @v_specind smallint,
        @v_printingnum int,
        @max_jobnum int,
        @v_char varchar(1),
        @v_conv_trimsizewidth  varchar(10),
        @v_conv_trimsizelength varchar(10),
        @v_pagecount_str varchar(10),
        @error_var    INT,
        @rowcount_var INT
  --      @v_notekey  INT

DECLARE cameraspec_cur CURSOR FOR
 SELECT cameraitem,quantity,notekey
	FROM cameraspec
  WHERE (bookkey=@i_from_bookkey) AND
		  (printingkey=@i_from_printingkey) 


BEGIN

	--company - needed for titlehistory
  SELECT @v_companycode = upper(companycode)
    FROM pss5licenseinfo
---print '@v_companycode'
---print @v_companycode

 -- Check client's value for pagecount option   
  SELECT @v_pagecount_option = optionvalue
  FROM clientoptions
  WHERE optionid = 4

-- Check client's value for actual trimsize option   
  SELECT @v_actualtrimsize_option = optionvalue
  FROM clientoptions
  WHERE optionid = 7

-- Check client's value for use impression number option  
  SELECT @v_use_impression_number = optionvalue
  FROM clientoptions
  WHERE optionid = 24

-- Check client's value for jobnumber alpha generation option  
  SELECT @v_jobnumberalpha_gen = optionvalue
  FROM clientoptions
  WHERE optionid = 68

	SET @v_firstprintingqty = NULL
   SET @v_trimfamily = NULL     
   SET @v_pagecount = NULL
   SET @v_trimsizewidth = NULL
   SET @v_trimsizelength = NULL
   SET @v_specind = NULL 
   SET @v_notekey= NULL 
   SET @v_bookbulk = NULL
   SET @v_printingnum = NULL
   SET @v_jobnum = NULL 
   SET @v_printingjob = NULL 
   SET @v_servicearea = NULL 
   SET @v_conversionind = NULL
   SET @v_nastaind = NULL
	SET @v_statelabelind = NULL 
   SET @v_statuscode = NULL 
   SET @v_esttrimsizewidth = NULL 
   SET @v_esttrimsizelength = NULL
	SET @v_seasonkey = NULL
   SET @v_estseasonkey = NULL
   SET @v_creationdate = NULL
   SET @v_tmmpagecount = NULL
	SET @v_impressionnumber = NULL 
   SET @v_spinesize = NULL 
   SET @v_spinesizeunitofmeasure = NULL
   SET @v_boardtrimsizewidth = NULL
   SET @v_boardtrimsizelength = NULL 
   SET @v_printcode = NULL
	SET @v_prodtrimwidth = NULL
   SET @v_prodtrimheight = NULL
   SET @v_tmmtrimsizewidth = NULL
   SET @v_tmmtrimsizeheight = NULL
   SET @v_to_trimsizewidth = NULL
   SET @v_to_trimsizelength = NULL
   SET @v_prodpagecount = NULL
   SET @v_tmmpagecount = NULL
   SET @v_tentativepagecount = NULL
   SET @max_printingkey = 0
	SET @max_printingnum = 0
   SET @v_orig_impressionnumber = NULL
	SET @v_orig_length = 0
	SET @v_tempnum = 0
   SET @v_length_tempnum = 0
   SET @v_len_diff  = 0
   SET @v_string_tempnum = ''
   SET @v_count3 = 0
   SET @v_jobnumberalpha = NULL
   SET @v_right_digit = ''
   SET @v_left_digit = ''
   SET @v_value = 0
   SET @v_text = NULL
   SET @v_showonpoind = NULL
   SET @v_copynextprtgind = NULL
   SET @v_detaillinenbr = NULL
   SET @v_to_pagecount = 0


   SELECT @v_count = count(*)
     FROM printing  
    WHERE ( bookkey = @i_from_bookkey ) AND  
         ( printingkey = @i_from_printingkey ) 

   IF @v_count > 0 
   BEGIN
			SELECT @v_firstprintingqty = firstprintingqty,@v_trimfamily = trimfamily, @v_pagecount = pagecount,@v_trimsizewidth = trimsizewidth,
				 @v_trimsizelength =trimsizelength,@v_specind = specind,@v_notekey= notekey,@v_bookbulk =bookbulk,@v_printingnum = printingnum,
				 @v_jobnum = jobnum,@v_printingjob = printingjob,@v_servicearea = servicearea,@v_conversionind = conversionind,@v_nastaind =nastaind,
				 @v_statelabelind = statelabelind,@v_statuscode = statuscode,@v_esttrimsizewidth = esttrimsizewidth,@v_esttrimsizelength = esttrimsizelength,
				 @v_seasonkey = seasonkey,@v_estseasonkey = estseasonkey,@v_creationdate = creationdate,@v_tmmpagecount = tmmpagecount,
				 @v_impressionnumber = impressionnumber,@v_spinesize = spinesize,@v_spinesizeunitofmeasure = spinesizeunitofmeasure,@v_boardtrimsizewidth = boardtrimsizewidth,
				 @v_boardtrimsizelength = boardtrimsizelength,@v_printcode = printcode
		  FROM printing  
		 WHERE ( bookkey = @i_from_bookkey ) AND  
				( printingkey = @i_from_printingkey ) 
   END
   
	SElECT @v_notecount = count(*)
	  FROM note  
	 WHERE notekey= @v_notekey

	IF @v_notecount > 0 
   BEGIN
		SELECT @v_text = text,@v_showonpoind = showonpoind,@v_copynextprtgind = copynextprtgind,@v_detaillinenbr = detaillinenbr
		  FROM note  
		 WHERE notekey= @v_notekey

      UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

		SELECT @v_newnotekey = generickey from keys
	
		INSERT INTO note (notekey,text,bookkey,printingkey,compkey,showonpoind,copynextprtgind,detaillinenbr,lastuserid,lastmaintdate )
			VALUES (@v_newnotekey,@v_text,@i_to_bookkey,@i_to_printingkey,0,@v_showonpoind,@v_copynextprtgind,@v_detaillinenbr,@i_userid,getdate())
	END
   ELSE
   BEGIN
    	SET @v_newnotekey = NULL
	END

---Specind will always be 1 when copying specifications from one title to another
   IF @i_specind = 1
   BEGIN
		IF @i_to_printingkey = 1 
		BEGIN
			SELECT @v_count2 = count(*)
           FROM printing  
          WHERE ( bookkey = @i_to_bookkey ) AND  
       	  ( printingkey = @i_to_printingkey ) 

			IF @v_count2 < 0
         BEGIN
         	SET @o_error_code = -1
				SET @o_error_desc = 'Unable to access printing table (select).'
				RETURN 
        	END
         ELSE
			BEGIN
				SELECT @v_prodtrimwidth = trimsizelength, @v_prodtrimheight = trimsizewidth, @v_tmmtrimsizewidth = tmmactualtrimwidth,
              	@v_tmmtrimsizeheight = tmmactualtrimlength, @v_prodpagecount = pagecount, @v_tmmpagecount = tmmpagecount,
            	@v_tentativepagecount = tentativepagecount
			     FROM printing  
             WHERE ( bookkey = @i_to_bookkey ) AND  
       	       ( printingkey = @i_to_printingkey )
         END

         IF @v_actualtrimsize_option = 1
         BEGIN
				IF (@v_prodtrimwidth  is not null AND ltrim(rtrim(@v_prodtrimwidth)) <> '') 
                 OR (@v_prodtrimheight is not null AND ltrim(rtrim(@v_prodtrimheight)) <> '')
            BEGIN
              SET @v_trimsizewidth = @v_prodtrimwidth 
              SET @v_trimsizelength = @v_prodtrimheight
				END
            ELSE
            BEGIN
					IF (@v_prodtrimwidth  is NULL OR ltrim(rtrim(@v_prodtrimwidth)) = '') 
                  AND (@v_prodtrimheight is NULL OR ltrim(rtrim(@v_prodtrimheight)) = '' )
               BEGIN
						IF (@v_tmmtrimsizewidth is not null AND ltrim(rtrim(@v_tmmtrimsizewidth)) <> '') 
                    OR (@v_tmmtrimsizeheight is not null OR ltrim(rtrim(@v_tmmtrimsizeheight)) <> '')
                  BEGIN  
       					SET @v_trimsizewidth = @v_tmmtrimsizewidth 
              			SET @v_trimsizelength = @v_tmmtrimsizeheight 
						END
                  ELSE
 						BEGIN
							IF (@v_tmmtrimsizewidth is not null AND ltrim(rtrim(@v_tmmtrimsizewidth)) <> '') 
                         OR (@v_tmmtrimsizeheight is not null OR ltrim(rtrim(@v_tmmtrimsizeheight)) <> '')
							BEGIN  
								SET @v_trimsizewidth = @v_trimsizewidth 
								SET @v_trimsizelength = @v_trimsizelength 
							END
                  END
					END
				END
         END
         ELSE   -- value of actual trimsize option = 0
         BEGIN
				IF (@v_prodtrimwidth  is not null AND ltrim(rtrim(@v_prodtrimwidth))  <> '') 
                OR (@v_prodtrimheight is not null AND ltrim(rtrim(@v_prodtrimheight)) <> '')
            BEGIN
              SET @v_trimsizewidth = @v_prodtrimwidth 
              SET @v_trimsizelength = @v_prodtrimheight
				END
            ELSE
            BEGIN
					IF (@v_prodtrimwidth  is NULL OR ltrim(rtrim(@v_prodtrimwidth)) = '') 
                  AND (@v_prodtrimheight is NULL  OR ltrim(rtrim(@v_prodtrimheight)) = '' )
               BEGIN
						SET @v_trimsizewidth = @v_trimsizewidth 
						SET @v_trimsizelength = @v_trimsizelength 
					END
           	END
			END

			IF @v_pagecount_option = 1
         BEGIN
				IF (@v_prodpagecount  is not null AND @v_prodpagecount  <> 0) 
            BEGIN
              SET @v_pagecount = @v_prodpagecount 
           	END
            ELSE
            BEGIN
					IF (@v_prodpagecount  is NULL OR @v_prodpagecount = 0) 
               BEGIN
						IF (@v_tmmpagecount is not null AND @v_tmmpagecount <> 0) 
                  BEGIN  
       					SET @v_pagecount = @v_tmmpagecount 
              		END
                  ELSE
 						BEGIN
							IF (@v_tentativepagecount is not null AND @v_tentativepagecount <> 0) 
							BEGIN  
								SET @v_pagecount = @v_tentativepagecount 
							END
                     ELSE
                     BEGIN
                        SET @v_pagecount = @v_pagecount
                     END
                  END
					END
				END
         END
         ELSE   -- value of pagecount option = 0
         BEGIN
			IF (@v_prodpagecount  is not null AND @v_prodpagecount  > 0 )
            BEGIN
                SET @v_pagecount = @v_prodpagecount 
          	END
            ELSE
            BEGIN
					IF (@v_prodpagecount  is NULL OR @v_prodpagecount = 0) 
               BEGIN
                  IF (@v_tentativepagecount is null AND @v_tentativepagecount = 0)
                  BEGIN 
							SET @v_pagecount = @v_tentativepagecount
                  END
                  ELSE
                  BEGIN
							SET @v_pagecount = @v_pagecount
                  END
					END
           	END
			END
		END --to printingkey = 1

		IF @o_printingnum is null
			SET @o_printingnum = 0

		IF @i_copy = 'printing'   --copy specs to another printing
      BEGIN
			IF @i_nextprintingnbr is not null
			BEGIN
				SET @o_printingnum = @i_nextprintingnbr
			END
			ELSE
			BEGIN
				SELECT @max_printingkey = max(printingkey)
				  FROM printing  
				 WHERE ( bookkey = @i_to_bookkey ) 
	
				SELECT @max_printingnum = max(printingnum)
				  FROM printing  
				 WHERE ( bookkey = @i_to_bookkey ) AND  
				  ( printingkey = @max_printingkey ) 
	
				SET @o_printingnum = @max_printingnum + 1
			END
      END
      ELSE  -- copy specs to another title
      BEGIN
        	SET @max_printingkey = 0
         SET @max_printingnum = 0
        	SET @o_printingnum = @max_printingnum + 1
      END


      SET @v_printingjob = convert(char(10),@o_printingnum)

	IF @v_jobnum is null
		SET @v_jobnum = 0

      IF @i_copy = 'printing'   --copy specs to another printing
      BEGIN
			IF @i_nextjobnbr is not null
			BEGIN
				SET @v_jobnum = @i_nextjobnbr
			END
			ELSE
			BEGIN
				SELECT @max_printingkey = max(printingkey)
				  FROM printing  
				 WHERE ( bookkey = @i_to_bookkey ) 
	
				SELECT @max_jobnum = max(jobnum)
				  FROM printing  
				 WHERE ( bookkey = @i_to_bookkey ) AND  
				  ( printingkey = @max_printingkey ) 

                  IF @max_jobnum is null
					SET @max_jobnum = 0
	
				SET @v_jobnum = @max_jobnum + 1
			END
		END
      ELSE  -- copy specs to another title
      BEGIN
         SET @max_printingkey = 0
         SET @max_jobnum = 0
         ---SET @o_printingnum = @max_printingnum + 1
         SET @v_jobnum = @max_jobnum + 1
      END

      ---SET @v_printingjob = convert(char(10),@o_printingnum)

      IF @v_use_impression_number = 1
         SET @v_use_impression_number = 0
		IF @v_use_impression_number = 1
      BEGIN
			IF @v_impressionnumber IS NULL
 				SET @v_impressionnumber = convert(char(10),@o_printingnum)
			IF isnumeric(@v_impressionnumber) = 1
			BEGIN
				SET @v_orig_impressionnumber = @v_impressionnumber
            SET @v_orig_length = len(@v_impressionnumber)

            -- increase impressionnumber by 1
				SET @v_tempnum = convert(int,@v_impressionnumber) + 1

				SET @v_string_tempnum = convert(char(10),@v_tempnum)
				SET @v_length_tempnum = len(@v_tempnum)

            IF @v_length_tempnum < @v_orig_length
            BEGIN  
                    SET @v_count3 = 0
					SET @v_len_diff = @v_orig_length - @v_length_tempnum
					WHILE @v_count3 <= @v_len_diff
               BEGIN
						SET @v_char = substring(@v_orig_impressionnumber,@v_count3,1)
						SET @v_string_tempnum = @v_char + @v_string_tempnum
						SET @v_count3 = @v_count3 + 1
					END		
				END
 				SET @v_impressionnumber = @v_string_tempnum
			END
		END
 
      IF @v_jobnumberalpha_gen = 1
         SET @v_jobnumberalpha_gen = 0
      IF @v_jobnumberalpha_gen = 0  -- Standard Job Number Alpha generation
      BEGIN
			EXEC get_next_jobnumber @v_jobnumberalpha OUTPUT
      END 
      ELSE
      BEGIN
			SET @v_right_digit = right(convert(char(10),@i_to_printingkey),1)
---         SET @v_length_tempnum = len(convert(char(10),@i_to_printingkey)
         SET @v_length_tempnum = len(@i_to_printingkey)

         IF @v_length_tempnum = 1
         BEGIN
            SET @v_jobnumberalpha = '00' + @v_right_digit
         END
         IF @v_length_tempnum > 1
         BEGIN
				SET @v_value = @v_length_tempnum - 1
				SET @v_left_digit = left(convert(char(10),@i_to_printingkey),@v_value)
            SET @v_jobnumberalpha = @v_left_digit + '0' + @v_right_digit
         END
		END

      IF @v_count2 = 0
      BEGIN
			INSERT INTO printing
				(bookkey,printingkey,tentativeqty,trimfamily,pagecount,trimsizewidth,trimsizelength,notekey,conversionind,lastuserid,
				 lastmaintdate,statuscode,esttrimsizewidth,esttrimsizelength,seasonkey,estseasonkey,servicearea,specind,bookbulk,printingnum,
				 jobnum,printingjob,nastaind,statelabelind,creationdate,impressionnumber,spinesize,spinesizeunitofmeasure,jobnumberalpha,
				 boardtrimsizewidth,boardtrimsizelength)
				VALUES (@i_to_bookkey,@i_to_printingkey,NULL,@v_trimfamily,@v_pagecount,@v_trimsizewidth,@v_trimsizelength,@v_newnotekey,NULL,@i_userid,
					 getdate(),1,@v_esttrimsizewidth,@v_esttrimsizelength,@v_seasonkey,@v_estseasonkey,@v_servicearea,1,@v_bookbulk,@o_printingnum,
					 @v_jobnum,@v_printingjob,@v_nastaind,@v_statelabelind,@v_creationdate,@v_impressionnumber,@v_spinesize,@v_spinesizeunitofmeasure,@v_jobnumberalpha,
					 @v_boardtrimsizewidth,@v_boardtrimsizelength)
      END
      IF @v_count2 = 1
      BEGIN
			UPDATE printing
               SET tentativeqty=NULL,trimfamily=@v_trimfamily,@v_pagecount=pagecount,trimsizewidth=@v_trimsizewidth,trimsizelength=@v_trimsizelength,
               notekey=@v_newnotekey,conversionind=NULL,lastuserid=@i_userid,lastmaintdate=getdate(),statuscode=1,esttrimsizewidth=@v_esttrimsizewidth,
               esttrimsizelength=@v_esttrimsizelength,seasonkey=@v_seasonkey,estseasonkey=@v_estseasonkey,servicearea=@v_servicearea,
               specind=1,bookbulk=@v_bookbulk,printingnum=@v_printingnum,jobnum=@v_jobnum,printingjob=@v_printingjob,nastaind=@v_nastaind,
               statelabelind=@v_statelabelind,creationdate=@v_creationdate,impressionnumber=@v_impressionnumber,spinesize=@v_spinesize,spinesizeunitofmeasure=@v_spinesizeunitofmeasure,
               jobnumberalpha=@v_jobnumberalpha,boardtrimsizewidth=@v_boardtrimsizewidth,boardtrimsizelength=@v_boardtrimsizelength
			  WHERE ( bookkey = @i_to_bookkey ) AND  
					( printingkey = @i_to_printingkey) 
      END
       
       IF @i_to_printingkey = 1 
       BEGIN
          UPDATE printing
             SET printcode = @v_printcode
            WHERE ( bookkey = @i_to_bookkey ) AND  
       	  ( printingkey = @i_to_printingkey ) 
       END

		 IF @v_pagecount is not null
       BEGIN
       	IF @v_companycode = 'SS' 
         BEGIN
            SET @v_pagecount_str = convert(char(10),@v_pagecount)
				EXECUTE qtitle_update_titlehistory 'printing','pagecount',@i_to_bookkey,@i_to_printingkey,0,
              @v_pagecount_str,'update',@i_userid,null,'PROD Actual Page Count',@o_error_code output,@o_error_desc output

            IF @o_error_code < 0 
            BEGIN
					RETURN
				 END
			END
         ELSE
			BEGIN
            SET @v_pagecount_str = convert(char(10),@v_pagecount)
				EXECUTE qtitle_update_titlehistory 'printing','pagecount',@i_to_bookkey,@i_to_printingkey,0,
              @v_pagecount_str,'insert',@i_userid,null,'Actual Page Count',@o_error_code output,@o_error_desc output

            IF @o_error_code < 0 
				BEGIN
					RETURN
				 END
         END
       END

       IF @v_trimsizewidth is not null
       BEGIN
			EXECUTE qtitle_update_titlehistory 'printing','trimsizewidth',@i_to_bookkey,@i_to_printingkey,0,
              @v_trimsizewidth,'insert',@i_userid,null,'Trim Size Width',@o_error_code output,@o_error_desc output

            IF @o_error_code < 0 
            BEGIN
					RETURN
				 END
       END

		IF @v_trimsizewidth is not null
       BEGIN
			EXECUTE qtitle_update_titlehistory 'printing','trimsizelength',@i_to_bookkey,@i_to_printingkey,0,
              @v_trimsizewidth,'insert',@i_userid,null,'Trim Size Length',@o_error_code output,@o_error_desc output

            IF @o_error_code < 0 
            BEGIN
					RETURN
				 END
       END
	END  -- specind = 1
   ELSE  -- specs already exist for new printing - update - specind = 0
   BEGIN
		SELECT @v_count = count(*)
        FROM printing  
		 WHERE ( bookkey = @i_to_bookkey ) AND  
				( printingkey = @i_to_printingkey) 

		IF @v_count > 0
      BEGIN
			SELECT @v_tentativepagecount = tentativepagecount,@v_firstprintingqty = firstprintingqty,@v_to_pagecount = pagecount,@v_tmmpagecount = tmmpagecount,
					 @v_to_trimsizelength =trimsizelength,@v_to_trimsizewidth = trimsizewidth,@v_esttrimsizewidth = esttrimsizewidth,@v_esttrimsizelength = esttrimsizelength,
					 @v_tmmtrimsizeheight=tmmactualtrimlength,@v_tmmtrimsizewidth=tmmactualtrimwidth
			  FROM printing  
			 WHERE ( bookkey = @i_to_bookkey ) AND  
					( printingkey = @i_to_printingkey) 

         IF @v_pagecount_option IS NULL
            SET @v_pagecount_option = 0

			IF @v_pagecount_option = 1 AND @i_to_printingkey = 1
			BEGIN
				IF @v_to_pagecount IS NULL OR @v_to_pagecount = 0
				BEGIN  
					IF @v_tmmpagecount IS NOT NULL AND @v_tmmpagecount <> 0
					BEGIN
						SET @v_pagecount = @v_tmmpagecount
						SET @v_tmm_pagecount_used = 1
					END
					ELSE
					BEGIN
                  -- use pagecount from title being copied from
						SET @v_pagecount = @v_pagecount
                  -- set this to 1 even though strictly not tmm pagecount written from but will write title history
						SET @v_tmm_pagecount_used = 1
					END
				END
            ELSE
            BEGIN
					SET @v_pagecount = @v_to_pagecount
               SET @v_tmm_pagecount_used = 1
            END
			END
			IF @v_pagecount_option = 0 OR @i_to_printingkey > 1
			BEGIN
				IF @v_pagecount IS NOT NULL AND @v_pagecount <> 0
				BEGIN
					SET @v_pagecount = @v_pagecount
					SET @v_tmm_pagecount_used = 0
				END
	
			END
	
          IF @v_actualtrimsize_option IS NULL
            SET @v_actualtrimsize_option = 0
			IF @v_actualtrimsize_option = 1 AND @i_to_printingkey = 1
			BEGIN
				IF (@v_to_trimsizewidth IS NULL OR ltrim(rtrim(@v_to_trimsizewidth)) = '') 
                  AND (@v_to_trimsizelength IS NULL OR ltrim(rtrim(@v_to_trimsizelength)) = '')
				BEGIN  
					IF (@v_tmmtrimsizewidth IS NOT NULL AND ltrim(rtrim(@v_tmmtrimsizewidth)) <> '') 
                     OR (@v_tmmtrimsizeheight IS NOT NULL AND ltrim(rtrim(@v_tmmtrimsizeheight)) <> '')
					BEGIN
						SET @v_conv_trimsizewidth = @v_tmmtrimsizewidth
						SET @v_conv_trimsizelength = @v_tmmtrimsizeheight
						SET @v_tmm_trimsize_used = 1
					END
               ELSE
               BEGIN
               -- if both trimsize and tmmtrimsize is not present for title being copied to use the trimsize values from title being copied from
						SET @v_conv_trimsizewidth = @v_trimsizewidth
						SET @v_conv_trimsizelength = @v_trimsizelength
                  -- set this to 1 even though strictly not tmm trimsize written from but will write title history
						SET @v_tmm_trimsize_used = 1
               END
				END
				ELSE
				BEGIN
					SET @v_conv_trimsizewidth = @v_to_trimsizewidth
					SET @v_conv_trimsizelength = @v_to_trimsizelength
					SET @v_tmm_trimsize_used = 0
				END
			END
			ELSE IF (@v_actualtrimsize_option = 0 AND @i_to_printingkey = 1) OR @i_to_printingkey > 1
			BEGIN
				IF (@v_trimsizewidth IS NOT NULL AND ltrim(rtrim(@v_trimsizewidth)) <> '') 
                  OR (@v_trimsizelength IS NOT NULL AND ltrim(rtrim(@v_trimsizelength)) <> '')
				BEGIN
					SET @v_conv_trimsizewidth = @v_trimsizewidth
					SET @v_conv_trimsizelength = @v_trimsizelength
					SET @v_tmm_trimsize_used = 0
				END
			END
	
			IF @v_conv_trimsizelength IS NOT NULL AND ltrim(rtrim(@v_conv_trimsizelength)) <> ''
			BEGIN
				SET @v_trimsizelength = @v_conv_trimsizelength
			END
	
			IF @v_conv_trimsizewidth IS NOT NULL AND ltrim(rtrim(@v_conv_trimsizewidth)) <> ''
			BEGIN
				SET @v_trimsizewidth = @v_conv_trimsizewidth
			END

			IF @v_companycode = 'SS'
			BEGIN
				IF @i_to_printingkey = 1
				BEGIN
					IF @v_pagecount IS NOT NULL AND @v_pagecount <> 0 AND @v_tmm_pagecount_used = 1
					BEGIN

                  SET @v_pagecount_str = convert(char(10),@v_pagecount)
						EXECUTE qtitle_update_titlehistory 'printing','pagecount',@i_to_bookkey,@i_to_printingkey,0,
						  @v_pagecount_str,'insert',@i_userid,null,'PROD Actual Page Count',@o_error_code output,@o_error_desc output
		
						IF @o_error_code < 0 BEGIN
							RETURN
						 END
					END
					IF @v_trimsizewidth IS NOT NULL AND @v_trimsizewidth <> '' AND @v_tmm_trimsize_used = 1
					BEGIN
						EXECUTE qtitle_update_titlehistory 'printing','trimsizewidth',@i_to_bookkey,@i_to_printingkey,0,
							  @v_trimsizewidth,'insert',@i_userid,null,'Trim Size Width',@o_error_code output,@o_error_desc output
			
							IF @o_error_code < 0 BEGIN
								RETURN
                     END
					 END
					IF @v_trimsizelength IS NOT NULL AND @v_trimsizelength <> '' AND @v_tmm_trimsize_used = 1
					BEGIN
						EXECUTE qtitle_update_titlehistory 'printing','trimsizelength',@i_to_bookkey,@i_to_printingkey,0,
							  @v_trimsizelength,'insert',@i_userid,null,'Trim Size Length',@o_error_code output,@o_error_desc output
			
							IF @o_error_code < 0 BEGIN
								RETURN
                     END
					 END
	
					SET @v_printingjob = convert(char(10),@i_to_printingkey)

					IF @v_firstprintingqty is not null AND @v_firstprintingqty > 0
					BEGIN
						UPDATE printing
							SET firstprintingqty = @v_firstprintingqty,tentativeqty = @v_firstprintingqty,trimfamily=@v_trimfamily,pagecount = @v_pagecount,
								 trimsizewidth=@v_trimsizewidth,trimsizelength=@v_trimsizelength,notekey=@v_newnotekey,conversionind=0,lastuserid=@i_userid,
								 lastmaintdate=getdate(),statuscode=1,specind=1,printingnum=@i_to_printingkey,jobnum=@v_printingjob,spinesize=@v_spinesize,spinesizeunitofmeasure=@v_spinesizeunitofmeasure,
								 boardtrimsizewidth=@v_boardtrimsizewidth,boardtrimsizelength=@v_boardtrimsizelength
						 WHERE ( bookkey = @i_to_bookkey ) AND  
								 ( printingkey = @i_to_printingkey)
                   SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
						 IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = 'Unable to update printing (' + cast(@error_var AS VARCHAR) + ').'
							RETURN
						 END 
					END
					ELSE
					BEGIN
						UPDATE printing
							SET firstprintingqty = @v_firstprintingqty,trimfamily=@v_trimfamily,pagecount = @v_pagecount,
								 trimsizewidth=@v_trimsizewidth,trimsizelength=@v_trimsizelength,notekey=@v_newnotekey,conversionind=0,lastuserid=@i_userid,
								 lastmaintdate=getdate(),statuscode=1,specind=1,printingnum=@i_to_printingkey,jobnum=@v_printingjob,spinesize=@v_spinesize,spinesizeunitofmeasure=@v_spinesizeunitofmeasure,
								 boardtrimsizewidth=@v_boardtrimsizewidth,boardtrimsizelength=@v_boardtrimsizelength
						 WHERE ( bookkey = @i_to_bookkey ) AND  
								 ( printingkey = @i_to_printingkey)
                  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
						 IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = 'Unable to update printing (' + cast(@error_var AS VARCHAR) + ').'
							RETURN
						 END 
					END
				END   -- printingkey = 1
				ELSE
				BEGIN  -- Schuster and printingkey > 1
					SET @v_printingjob = convert(char(10),@i_to_printingkey)
		
					UPDATE printing
						SET firstprintingqty = @v_firstprintingqty,trimfamily=@v_trimfamily,pagecount = @v_pagecount,
							 trimsizewidth=@v_trimsizewidth,trimsizelength=@v_trimsizelength,notekey=@v_newnotekey,conversionind=0,lastuserid=@i_userid,
							 lastmaintdate=getdate(),statuscode=1,specind=1,printingnum=@i_to_printingkey,jobnum=@v_printingjob,spinesize=@v_spinesize,spinesizeunitofmeasure=@v_spinesizeunitofmeasure,
							 boardtrimsizewidth=@v_boardtrimsizewidth,boardtrimsizelength=@v_boardtrimsizelength
					 WHERE ( bookkey = @i_to_bookkey ) AND  
							 ( printingkey = @i_to_printingkey)
               SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
					 IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
						SET @o_error_code = -1
						SET @o_error_desc = 'Unable to update printing (' + cast(@error_var AS VARCHAR) + ').'
						RETURN
					 END 
				END
			END  -- company is schuster
			ELSE
			BEGIN  -- all other companies with a specind = 0

				IF @v_notekey > 0 AND (@v_newnotekey is null OR @v_newnotekey = 0)
					SET @v_newnotekey = @v_notekey
	
				IF @i_to_printingkey = 1
				BEGIN
					IF @v_pagecount IS NOT NULL AND @v_pagecount <> 0 AND @v_tmm_pagecount_used = 1
					BEGIN
                  SET @v_pagecount_str = convert(char(10),@v_pagecount)
						EXECUTE qtitle_update_titlehistory 'printing','pagecount',@i_to_bookkey,@i_to_printingkey,0,
						  @v_pagecount_str,'insert',@i_userid,null,'PROD Actual Page Count',@o_error_code output,@o_error_desc output
		
						IF @o_error_code < 0 BEGIN
							RETURN
						 END
					END
	
					IF @v_trimsizewidth IS NOT NULL AND ltrim(rtrim(@v_trimsizewidth)) <> '' AND @v_tmm_trimsize_used = 1
					BEGIN
						EXECUTE qtitle_update_titlehistory 'printing','trimsizewidth',@i_to_bookkey,@i_to_printingkey,0,
							  @v_trimsizewidth,'insert',@i_userid,null,'Trim Size Width',@o_error_code output,@o_error_desc output
			
							IF @o_error_code < 0 BEGIN
								RETURN
                     END
					 END
	
					IF @v_trimsizelength IS NOT NULL AND ltrim(rtrim(@v_trimsizelength)) <> '' AND @v_tmm_trimsize_used = 1
					BEGIN
						EXECUTE qtitle_update_titlehistory 'printing','trimsizelength',@i_to_bookkey,@i_to_printingkey,0,
							  @v_trimsizelength,'insert',@i_userid,null,'Trim Size Length',@o_error_code output,@o_error_desc output
			
							IF @o_error_code < 0 BEGIN
								RETURN
                     END
					 END
	
					SET @v_printingjob = convert(char(10),@i_to_printingkey)

--print '@v_printingjob = ' + cast(@v_printingjob as varchar)

               IF @v_use_impression_number = 1
                  SET @v_use_impression_number = 0
					IF @v_use_impression_number = 1
					BEGIN
						IF @v_impressionnumber IS NULL
							SET @v_impressionnumber = convert(char(10),@o_printingnum)
						IF ISNUMERIC(@v_impressionnumber)= 1
						BEGIN
							SET @v_orig_impressionnumber = @v_impressionnumber
							SET @v_orig_length = len(@v_impressionnumber)
			
							-- increase impressionnumber by 1
							SET @v_tempnum = convert(int,@v_impressionnumber) + 1
			
							SET @v_string_tempnum = convert(char(10),@v_tempnum)
							SET @v_length_tempnum = len(@v_tempnum)
			
							IF @v_length_tempnum < @v_orig_length
							BEGIN
  								SET @v_count3 = 0
								SET @v_len_diff = @v_orig_length - @v_length_tempnum
								WHILE @v_count3 <= @v_len_diff
								BEGIN
									SET @v_char = substring(@v_orig_impressionnumber,@v_count3,1)
									SET @v_string_tempnum = @v_char + @v_string_tempnum
									SET @v_count3 = @v_count3 + 1
								END		
							END
							SET @v_impressionnumber = @v_string_tempnum
						END
					 END

					IF @v_jobnumberalpha_gen is NULL
                  SET @v_jobnumberalpha_gen = 0
					IF @v_jobnumberalpha_gen = 0  -- Standard Job Number Alpha generation
					BEGIN
						EXEC get_next_jobnumber @v_jobnumberalpha OUTPUT
					END 
					ELSE
					BEGIN
						SET @v_right_digit = right(convert(char(10),@i_to_printingkey),1)
						SET @v_length_tempnum = len(@i_to_printingkey)
						IF @v_length_tempnum = 1
							SET @v_jobnumberalpha = '00' + @v_right_digit
						IF @v_length_tempnum > 1
						BEGIN
							SET @v_value = @v_length_tempnum - 1
							SET @v_left_digit = left(convert(char(10),@i_to_printingkey),@v_value)
							SET @v_jobnumberalpha = @v_left_digit + '0' + @v_right_digit
						END
					END

					IF @v_firstprintingqty is not null AND @v_firstprintingqty > 0
					BEGIN

						  UPDATE printing
							 SET firstprintingqty = @v_firstprintingqty,tentativeqty = @v_firstprintingqty,trimfamily=@v_trimfamily,pagecount = @v_pagecount,
								  trimsizewidth=@v_trimsizewidth,trimsizelength=@v_trimsizelength,notekey=@v_newnotekey,conversionind=0,lastuserid=@i_userid,
								  lastmaintdate=getdate(),statuscode=1,specind=1,printingnum=@i_to_printingkey,jobnum=@v_jobnum,spinesize=@v_spinesize,spinesizeunitofmeasure=@v_spinesizeunitofmeasure,
								  boardtrimsizewidth=@v_boardtrimsizewidth,boardtrimsizelength=@v_boardtrimsizelength,impressionnumber=@v_impressionnumber,
								  nastaind=@v_nastaind,printcode=@v_printcode,jobnumberalpha=@v_jobnumberalpha
						  WHERE ( bookkey = @i_to_bookkey ) AND  
								  ( printingkey = @i_to_printingkey)

						SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
						 IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = 'Unable to insert into printing (' + cast(@error_var AS VARCHAR) + ').'
							RETURN
						 END 
					END
					ELSE
					BEGIN
						UPDATE printing
							 SET firstprintingqty = @v_firstprintingqty,trimfamily=@v_trimfamily,pagecount = @v_pagecount,
								  trimsizewidth=@v_trimsizewidth,trimsizelength=@v_trimsizelength,notekey=@v_newnotekey,conversionind=0,lastuserid=@i_userid,
								  lastmaintdate=getdate(),statuscode=1,specind=1,printingnum=@i_to_printingkey,jobnum=@v_jobnum,spinesize=@v_spinesize,spinesizeunitofmeasure=@v_spinesizeunitofmeasure,
								  boardtrimsizewidth=@v_boardtrimsizewidth,boardtrimsizelength=@v_boardtrimsizelength,impressionnumber=@v_impressionnumber,
								  nastaind=@v_nastaind,printcode=@v_printcode,jobnumberalpha=@v_jobnumberalpha
						  WHERE ( bookkey = @i_to_bookkey ) AND  
								  ( printingkey = @i_to_printingkey)

						SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
						IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
							SET @o_error_code = -1
							SET @o_error_desc = 'Unable to update printing (' + cast(@error_var AS VARCHAR) + ').'
							RETURN
						END 
					END
				END
			END 
   	END
	END --specind = 0

	-- Copy all notes associated with print specs (cameraspecs/textspecs)
   EXEC Specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,3,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT


	-- Copy all cameraspecs
	OPEN cameraspec_cur
	
	FETCH NEXT FROM cameraspec_cur INTO @v_cameraitem, @v_quantity, @v_notekey
		
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
	
		INSERT INTO cameraspec(bookkey,printingkey,cameraitem,quantity,notekey,lastuserid,lastmaintdate)
			VALUES (@i_to_bookkey,@i_to_printingkey,@v_cameraitem,@v_quantity,@v_notekey,@i_userid,getdate())
					
		FETCH NEXT FROM cameraspec_cur INTO @v_cameraitem, @v_quantity, @v_notekey
				 
	END --cameraspec_cur LOOP
				
	CLOSE cameraspec_cur
	DEALLOCATE cameraspec_cur
END 
go