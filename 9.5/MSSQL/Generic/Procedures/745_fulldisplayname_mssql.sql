SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.fulldisplayname') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.fulldisplayname 
  END

GO


/*************************************************************************/
/*                                                			 */
/*  Rod Hamann                                    			 */
/*  02-16-2004                                    			 */
/*  PSS5 SIR 2819                                			 */
/*  Tested on GENMSDEV                           			 */
/*                                               			 */
/*                   MSSQL VERSION                			 */
/*                                                			 */
/*  This stored proc will populate the column     			 */
/*  fullauthordisplayname in bookdetail.          			 */
/*     									*/
/* MODIFICATIONS:								*/	
/*  Anes Hrenovica	Added logic that separate author types with comas nad AND's  */
/*			For example: Author1, Author2 and Author3 <\P> Editor1 and Editor2 */
/* althea ashman crm 02002:  THIS IS SPECIFIC TO IPG.. ADD Middlename and accreditations*/
/*				also change \p to \n 					*/
/**************************************************************************/

CREATE PROCEDURE dbo.fulldisplayname @bookkey INT

AS

DECLARE @v_fulldisplayname VARCHAR(1000)
DECLARE @author_name_txt   VARCHAR(1000)
DECLARE @author_name_html   VARCHAR(1000)
DECLARE @v_crlf            VARCHAR(10)
DECLARE @v_firstname       VARCHAR(75)
DECLARE @v_lastname        VARCHAR(75)
DECLARE @v_suffix          VARCHAR(75)
DECLARE @v_degree          VARCHAR(75)
DECLARE @v_description     VARCHAR(255)
DECLARE @v_qsicode         INT
DECLARE @v_currentqsicode  INT
DECLARE @v_authorcount     INT
DECLARE @v_sepperator      VARCHAR(5)
DECLARE @v_name            VARCHAR(1000)
DECLARE @v_largeobjkey     INT
DECLARE @v_sortorder       INT
DECLARE @v_total_authors   INT
DECLARE @v_total_editors   INT
DECLARE @v_total_foreword  INT	
DECLARE @v_total_prefaced  INT	
DECLARE @v_total_translated INT	
DECLARE @v_total_ilustrator INT	
DECLARE @v_total_photographed INT 
DECLARE @v_total_afterword INT
DECLARE @cnt_authors	   INT
DECLARE @cnt_editors	   INT
DECLARE @cnt_foreword	   INT
DECLARE @cnt_prefaced	   INT
DECLARE @cnt_translated	   INT
DECLARE @cnt_ilustrator	   INT
DECLARE @cnt_photographed  INT
DECLARE @cnt_afterword   INT
DECLARE @v_title varchar(80)
DECLARE @v_middlename       VARCHAR(75)
DECLARE @v_commenttypecode   INT
DECLARE @v_commenttypesubcode   INT
DECLARE @v_tablename	   VARCHAR(11)
DECLARE @v_zero		   INT
DECLARE @v_zero_char	   VARCHAR(1)

DECLARE c_authorlist CURSOR FOR
   SELECT ISNULL(author.firstname, ''), 
          ISNULL(author.lastname, ''), 
          ISNULL(author.middlename, ''),
          ISNULL(author.title, ''),  
          ISNULL(author.authorsuffix, ''), 
          ISNULL(author.authordegree, ''), 
          ISNULL(gentables.alternatedesc2, ''), 
          gentables.gen1ind,
          bookauthor.sortorder 
     FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
          gentables.gen1ind IN (1, 2, 3, 4, 5, 6, 7, 8)
 ORDER BY gentables.gen1ind, bookauthor.sortorder

BEGIN

   --get total authors
    SELECT @v_total_authors = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
    	  gentables.gen1ind = 1
    select @cnt_authors = 0

   --get total edited by
    SELECT @v_total_editors = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
          gentables.gen1ind = 2
    select @cnt_editors = 0

   --get total Foreword by
    SELECT @v_total_foreword = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
           gentables.gen1ind = 3
    select @cnt_foreword = 0

   --get total Prefaced by
    SELECT @v_total_prefaced = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
    	  gentables.gen1ind = 4
    select @cnt_prefaced = 0


   --get total Translated  by
    SELECT @v_total_translated = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
    	  gentables.gen1ind = 5
    select @cnt_translated = 0


   --get total Illustrator
    SELECT @v_total_ilustrator = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
          gentables.gen1ind = 6
    select @cnt_ilustrator = 0

   --get total Photographed by
    SELECT @v_total_photographed = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
	      gentables.gen1ind = 7
    select @cnt_photographed = 0

    -- get total Afterword by
    SELECT @v_total_afterword = COUNT(gentables.gen1ind)
    FROM bookauthor, author, gentables
    WHERE bookauthor.bookkey = @bookkey AND
          bookauthor.authorkey = author.authorkey AND
          (bookauthor.authortypecode = gentables.datacode AND
          gentables.tableid = 134) AND
	      gentables.gen1ind = 8
    select @cnt_afterword = 0

   OPEN c_authorlist

   SELECT @v_currentqsicode = 0
   SELECT @v_fulldisplayname = ''
   SELECT @v_authorcount = 0
   SELECT @v_crlf = '#chg#'


   FETCH NEXT FROM c_authorlist
      INTO @v_firstname, @v_lastname, @v_middlename,@v_title,@v_suffix, @v_degree, @v_description, 
		@v_qsicode, @v_sortorder

   WHILE (@@FETCH_STATUS= 0)  /*LOOP*/
      BEGIN
         SELECT @v_name = ''
         IF @v_currentqsicode = @v_qsicode
            BEGIN /* @v_currentqsicode = @v_qsicode */
               SELECT @v_authorcount = @v_authorcount + 1
            END /* @v_currentqsicode = @v_qsicode */
         ELSE
            BEGIN /* @v_currentqsicode <> @v_qsicode */
               /* This is a new contributor type so count is 1 */
               SELECT @v_authorcount = 1
               /* Format description and start a new line */
               IF @v_qsicode > 1  /* The description will NOT appear for the first group */
                  BEGIN
                     IF @v_currentqsicode = 1  /* The 1st and the next group is to be sepperated by an AND then CRLF */
                        BEGIN
                           /* Do not place AND and the crlf when no data yet */
                           IF @v_fulldisplayname <> ''
                              BEGIN      
                                 SELECT @v_fulldisplayname = @v_fulldisplayname + ' ' + @v_crlf + @v_description
                              END
                           ELSE
                              BEGIN
                                 SELECT @v_fulldisplayname = @v_description
                              END
                        END
                     ELSE
                        BEGIN                   
                           /* The other groups are to be sepperated by by just a CRLF */
                           /* Do not place the crlf when no data yet */
                           IF @v_fulldisplayname <> ''
                              BEGIN    
                                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_crlf + @v_description
                              END
                           ELSE
                              BEGIN
                              SELECT @v_fulldisplayname = @v_description
                              END
                        END
                  END 
                  
               /* Assign current type to new type */
               SELECT @v_currentqsicode = @v_qsicode
               
               /* Format sepperator */
               IF @v_currentqsicode = 2
		BEGIN
                SELECT @v_sepperator = ' & '
		END
                   ELSE
		BEGIN
	        SELECT @v_sepperator =  ', '  
	         /* @v_currentqsicode <> @v_qsicode */
		END
	      END

           IF @v_firstname <> ''
              BEGIN
                 SELECT @v_name = @v_firstname 
              END

 	   IF @v_middlename <> ''
             BEGIN
                IF @v_name <> '' 
                   BEGIN
                      SELECT @v_name = @v_name + ' ' + @v_middlename
                   END
                ELSE
                   BEGIN
                      SELECT @v_name = @v_middlename
                   END
             END

          IF @v_lastname <> ''
             BEGIN
                IF @v_name <> '' 
                   BEGIN
                      SELECT @v_name = @v_name + ' ' + @v_lastname
                   END
                ELSE
                   BEGIN
                      SELECT @v_name = @v_lastname
                   END
             END

          IF @v_suffix <> ''
             BEGIN
                IF @v_name <> '' 
                   BEGIN
                      SELECT @v_name = @v_name + ' ' + @v_suffix
                   END
                ELSE
                   BEGIN
                      SELECT @v_name = @v_suffix
                   END
             END

	  IF @v_title <> ''
             BEGIN
                IF @v_name <> '' 
                   BEGIN
                      SELECT @v_name = @v_name + ' ' + @v_title
                   END
                ELSE
                   BEGIN
                      SELECT @v_name = @v_title
                   END
             END

          IF @v_degree <> ''
             BEGIN
                IF @v_name <> '' 
                   BEGIN
                      SELECT @v_name = @v_name + ' ' + @v_degree
                   END
                ELSE
                   BEGIN
                      SELECT @v_name = @v_degree
                   END
             END

         IF @v_authorcount = 1
            BEGIN
               IF @v_fulldisplayname <> ''
                  BEGIN /* Do not place the space when no data yet */
                     SELECT @v_fulldisplayname = @v_fulldisplayname + ' ' + @v_name
                  END
               ELSE
                  BEGIN
                     SELECT @v_fulldisplayname = @v_name
                  END
            END
         ELSE
            BEGIN
               IF @v_fulldisplayname <> ''
                  BEGIN   /* Do not place the sepperator when no data yet */

			
			if @v_qsicode = 1
			begin
			    SELECT  @cnt_authors =  @cnt_authors + 1 
			    IF @v_total_authors - @cnt_authors = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end

			if @v_qsicode = 2
			begin
			    SELECT  @cnt_editors =  @cnt_editors + 1 
			    IF @v_total_editors - @cnt_editors = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end

			if @v_qsicode = 3
			begin
			    SELECT  @cnt_foreword =  @cnt_foreword + 1 
			    IF @v_total_foreword - @cnt_foreword = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end

			if @v_qsicode = 4
			begin
			    SELECT  @cnt_prefaced =  @cnt_prefaced + 1 
			    IF @v_total_prefaced - @cnt_prefaced = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end

			if @v_qsicode = 5
			begin
			    SELECT  @cnt_translated =  @cnt_translated + 1 
			    IF @v_total_translated - @cnt_translated = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end

			if @v_qsicode = 6
			begin
			    SELECT  @cnt_ilustrator =  @cnt_ilustrator + 1 
			    IF @v_total_ilustrator - @cnt_ilustrator = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end

			if @v_qsicode = 7
			begin
			    SELECT  @cnt_photographed =  @cnt_photographed + 1 
			    IF @v_total_photographed - @cnt_photographed = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end
			
			if @v_qsicode = 8
			begin
			    SELECT  @cnt_afterword =  @cnt_afterword + 1 
			    IF @v_total_afterword - @cnt_afterword = 1
			       SELECT @v_sepperator = ' and '
			    ELSE
			       SELECT @v_sepperator = ', '
  	                 SELECT @v_fulldisplayname = @v_fulldisplayname + @v_sepperator + @v_name
			end



                  END
               ELSE
                  BEGIN
                     SELECT @v_fulldisplayname = @v_name
                  END
            END 

         FETCH NEXT FROM c_authorlist
            INTO @v_firstname, @v_lastname, @v_middlename,@v_title,@v_suffix, @v_degree, @v_description, @v_qsicode, @v_sortorder

      END

   SELECT @v_largeobjkey = ISNULL(fullauthordisplaykey, 0)
      FROM bookdetail 
      WHERE bookkey = @bookkey

   SELECT @v_commenttypecode = 3
   SELECT @v_commenttypesubcode = 1
   SELECT @v_tablename = 'qsicomments'
   SELECT @v_zero = 0
   SELECT @v_zero_char = '0'

   IF @v_largeobjkey = 0
      BEGIN
         UPDATE keys SET generickey = generickey + 1

         SELECT @v_largeobjkey = generickey FROM keys

	 /* 12/2/04 - PV - CRM 1363 - RFT to HTML conversion */
	 /* qsilargeobject is now being replaced by qsicomments */
         /* INSERT INTO qsilargeobject
            VALUES(@v_largeobjkey, NULL, NULL, NULL) */
	 INSERT INTO qsicomments (commentkey,commenttypecode,commenttypesubcode,releasetoeloquenceind,lastuserid,lastmaintdate)
	 VALUES (@v_largeobjkey,@v_commenttypecode,@v_commenttypesubcode,0,'FullDisplayName Proc',getdate())

         UPDATE bookdetail 
	 SET fullauthordisplaykey = @v_largeobjkey
         WHERE bookkey = @bookkey

         UPDATE bookdetail SET
            fullauthordisplaykey = @v_largeobjkey
            WHERE bookkey = @bookkey
      END

      /* 12/2/04 - PV - CRM 1363 - RFT to HTML conversion */
      /* qsilargeobject is now being replaced by qsicomments */
      /* UPDATE qsilargeobject
      SET qsibody = @v_fulldisplayname
      WHERE qsiobjectkey = @v_largeobjkey */
	  set @v_fulldisplayname = '<DIV>' + @v_fulldisplayname + '</DIV>'
      EXECUTE book_or_qsi_comments_update @v_fulldisplayname,@v_largeobjkey,@v_zero,@v_commenttypecode,@v_commenttypesubcode,@v_tablename,@v_zero,@v_zero_char

	--Remove #chg# in Full html and text. Keep html lite.
	select @author_name_html = commenthtml, 
	       @author_name_txt = commenttext
	from qsicomments
	where commentkey = @v_largeobjkey
	and   commenttypecode = @v_commenttypecode
	and   commenttypesubcode = @v_commenttypesubcode

	set @author_name_html = replace(@author_name_html, @v_crlf, '')
	set @author_name_txt = replace(@author_name_txt, @v_crlf, '')

	update qsicomments
	set commenthtml = @author_name_html
	where  commentkey = @v_largeobjkey 
	and commenttypecode = @v_commenttypecode
	and   commenttypesubcode = @v_commenttypesubcode

	update qsicomments
	set commenttext = @author_name_txt
	where  commentkey = @v_largeobjkey
	and commenttypecode = @v_commenttypecode
	and   commenttypesubcode = @v_commenttypesubcode

   CLOSE c_authorlist
   DEALLOCATE c_authorlist
END
GO
GRANT EXECUTE ON dbo.fulldisplayname TO PUBLIC
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




