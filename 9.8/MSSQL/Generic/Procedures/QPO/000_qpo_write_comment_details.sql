/****** Object:  StoredProcedure [dbo].[qpo_write_comment_details]    Script Date: 04/01/2015 15:23:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpo_write_comment_details]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpo_write_comment_details]
GO

/****** Object:  StoredProcedure [dbo].[qpo_write_comment_details]    Script Date: 04/01/2015 15:23:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qpo_write_comment_details]
 (@i_po_projectkey      integer,
  @i_gpokey             integer,
  @i_sectionkey         integer,
  @i_subsectionkey      integer,
  @i_commenttext        nvarchar(max),
  @i_report_format_type integer,
  @i_detaillinenbr      integer out,
  @i_lastuserid         varchar(30))
AS

/******************************************************************************
**  Name: qpo_write_comment_details
**  Desc: This procedure will be called from the Generate PO Details procedure
**        for generating comment details on PO Report (gpodetails).
**
**	Auth: Kate
**	Date: November 13 2015
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:       Author:   Description:
**  ---------   -------   --------------------------------------
**  3/20/2018   Colman    41010 - Increase size of details column to 6000
*******************************************************************************/

DECLARE
  @v_count	INT,
  @v_commenttext NVARCHAR(MAX),
  @v_len  INT,
  @v_maxlen INT,
  @v_new_detailkey  INT,
  @v_reversestring  NVARCHAR(MAX),
  @v_sequence INT,
  @v_spacepos INT,
  @v_string NVARCHAR(MAX),
  @v_substring NVARCHAR(MAX),
  @v_trimmednormalreversestring NVARCHAR(MAX),
  @v_trimmedreversestring NVARCHAR(MAX)
  
BEGIN

  SET @v_sequence = 0
  SET @v_commenttext = ISNULL(@i_commenttext, '')

  IF LEN(@v_commenttext) > 0
  BEGIN
    SET @v_sequence = @v_sequence + 1
    SET @v_maxlen = 5990
											
    WHILE LEN(@v_commenttext) > 0
    BEGIN
      IF LEN(@v_commenttext) <= @v_maxlen
      BEGIN
        SET @v_len = 0
        SET @v_string = @v_commenttext
        SET @v_commenttext = RIGHT(@v_commenttext, (LEN(@v_commenttext) - @v_len))
											      
        IF @v_string <> ''
        BEGIN
          SET @i_detaillinenbr = @i_detaillinenbr + 100
          EXEC get_next_key @i_lastuserid, @v_new_detailkey OUTPUT

          INSERT INTO gpodetail
            (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
          VALUES
            (@i_gpokey, @v_new_detailkey, @i_sectionkey, @i_subsectionkey, @i_detaillinenbr, @v_string, 1, @i_report_format_type, @i_lastuserid, getdate())													  
        END

        BREAK
      END
      ELSE BEGIN  --LEN(@v_commenttext) > @v_maxlen
        SET @v_substring = LEFT(@v_commenttext, @v_maxlen)
									
        --check if last pos is a space
        IF RIGHT(@v_commenttext, @v_maxlen) <> ' '
        BEGIN													
          SET @v_reversestring = REVERSE(@v_substring)
          SET @v_spacepos = CHARINDEX(' ',@v_reversestring)
          SET @v_trimmedreversestring = SUBSTRING(@v_reversestring,@v_spacepos,len(@v_reversestring))
          SET @v_trimmednormalreversestring = REVERSE(@v_trimmedreversestring)
          SET @v_string = @v_trimmednormalreversestring
          SET @v_len = len(@v_trimmednormalreversestring)
          SET @v_commenttext = right(@v_commenttext,(len(@v_commenttext) - @v_len))															
        END
        ELSE
        BEGIN
          SET @v_string =  @v_string
          IF LEN(@v_commenttext) = @v_maxlen OR LEN(@v_commenttext) > @v_maxlen
            SET @v_commenttext = RIGHT(@v_commenttext,LEN(@v_commenttext) - (@v_maxlen - 1))
          ELSE
            SET @v_commenttext = @v_commenttext
        END  
      END		--LEN(@v_commenttext) > @v_maxlen					
												
      IF @v_string <> '' AND @v_string IS NOT NULL
      BEGIN		
        SET @i_detaillinenbr = @i_detaillinenbr + 100
        EXEC get_next_key @i_lastuserid, @v_new_detailkey OUTPUT

        INSERT INTO gpodetail
          (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
        VALUES
          (@i_gpokey, @v_new_detailkey, @i_sectionkey, @i_subsectionkey, @i_detaillinenbr, @v_string, 1, @i_report_format_type, @i_lastuserid, getdate())
      END

      IF (LEN(@v_commenttext)= 0)
        BREAK
												
      SET @v_sequence = @v_sequence + 1
    END --WHILE LEN(@v_commenttext) > 0
  END

 END
 go