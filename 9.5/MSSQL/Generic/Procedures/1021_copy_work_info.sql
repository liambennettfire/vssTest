/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.copy_work_info') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.copy_work_info
END
GO

CREATE PROCEDURE dbo.copy_work_info 
  @v_bookkey_copy_from int, 
  @v_bookkey_copy_to int,
  @i_tablename varchar(100),
  @i_columnname varchar(100)
AS
/*********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:     Author: Description:
**  -----     ------  -------------------------------------------
**  06/09/16  Kusum  Case 35718 - Enable Misc Propagation Configuration by Misc. Item
**  07/19/16  Uday   CASe 39219 
********************************************************************************************************************/
BEGIN

DECLARE
@v_releasetoelo_citation int,
@v_releasetoeloquenceind int,
@v_bookcontactkey int,
@v_new_bookcontactkey int,
@v_bookcontact_bookkey int,
@v_misckey INT,
@v_misctype int,
@v_tablename varchar(100) ,
@v_columnname  varchar(100), 
@v_datatype  varchar(100),
@p_value_char varchar(4000),
@v_sqlstring NVARCHAR(4000),
@v_value_item varchar(4000),
@v_bookkey_copy_torr int,
@v_quote char(1),
@v_title varchar(255),
@v_subtitle varchar(255),
@v_shorttitle varchar(100),
@v_cnt int,
@o_error_code int,
@o_error_desc varchar(250),
@v_user_name varchar(30),
@v_data varchar(100),
@v_price_inserted int,
@v_next_key int,
@v_price_key int,
@v_columndescription varchar(50),
@v_columnkey int,
@v_commentypesubcode INT,
@FieldDescDetail  VARCHAR(255),
@v_count	INT,
@v_parent_ean	VARCHAR(50),
@v_history_order  INT,
@v_primary_releasetoeloqind INT,
@v_subord_commenttypesubcode	INT,
@v_subord_releasetoeloquenceind	INT,
@v_websched_option  INT,
@v_datetypecode INT,
@v_taqtaskkey INT,
@v_workfieldind INT,
@v_filelocationgeneratedkey INT,
@v_new_filelocationgeneratedkey INT,
@v_printingkey INT,
@v_filetypecode SMALLINT,
@v_fileformatcode INT,
@v_filelocationkey INT,
@v_filestatuscode INT,
@v_pathname VARCHAR(255),
@v_notes VARCHAR(MAX),
@v_lastuserid VARCHAR(30),
@v_lastmaintdate datetime,
@v_sendtoeloquenceind INT,
@v_sortorder INT,
@v_taqprojectkey INT,
@v_taqelementkey INT,
@v_globalcontactkey INT,
@v_locationtypecode INT,
@v_stagecode INT,
@v_filedescription VARCHAR(255),
@v_taqtaskkey_temp INT,
@o_taqtaskkey   int,
@o_returncode   int,
@o_restrictioncode	int,
@v_bisaccategorycode  INT,
@v_bisaccategorysubcode INT,
@v_bisaccategorydesc VARCHAR(40),
@v_bisaccategorysubdesc VARCHAR(120),
@v_fielddesc VARCHAR(255),
@v_user VARCHAR(30),
@v_citation_bookkey int,
@v_citationkey int,
@v_qsiobjectkey int,
@v_new_qsiobjectkey int,
@v_new_citationkey int,
@v_datacode int,
@v_datasubcode int,
@v_citation_history_order int,
@v_citation_sortorder int,
@v_citationsource VARCHAR(100),
@v_citationauthor VARCHAR(300),
@v_citationdate DATETIME,
@v_citation_releasetoeloquenceind TINYINT,
@v_citationdesc VARCHAR(40),
@v_citationtypecode INT,
@v_citation_proofedind TINYINT,
@v_citation_webind TINYINT,
@v_citationexternaltypecode INT,
@v_citation_commenthtml NVARCHAR(MAX),
@v_propagatefromcitationkey INT,
@v_citation_titlehistory_columnname  varchar(100),
@v_autoverifytitle INT,
@v_datacode_generatedauthorbio INT,
@v_datasubcode_generatedauthorbio INT,
@v_count_qsicomment INT

 CREATE TABLE #TempDateTypeCode 
   (datetypecode INT)  

 CREATE TABLE #TempInsertedTaskKey 
   (taqtaskkey INT) 
   
 CREATE TABLE #TempBookAuthorKeys 
   (bookkey int null,
	authorkey int null,
	authortypecode smallint null,
	rolecode int null)    

IF ((@i_tablename is not null and ltrim(rtrim(@i_tablename)) <> '') AND
    (@i_columnname is not null and ltrim(rtrim(@i_columnname)) <> '')) BEGIN
  -- tablename and columnname passed in
  IF @i_tablename = 'taqprojecttask' and @i_columnname = 'taqtaskkey' BEGIN
    DECLARE titlehistorycolumns_cur CURSOR FOR
      SELECT tablename, columnname, datatype, columndescription, columnkey
        FROM titlehistorycolumns 
       WHERE columndescription = 'Web Title Dates Propagation'
         AND workfieldind = 1
         AND activeind = 1
  END
  ELSE
  BEGIN
    DECLARE titlehistorycolumns_cur CURSOR FOR
     select tablename, columnname, datatype, columndescription, columnkey
       from titlehistorycolumns 
      where workfieldind = 1
        and activeind = 1
        and tablename = @i_tablename
        and columnname = @i_columnname
   order by tablename
  END
END
ELSE IF (@i_tablename is not null and ltrim(rtrim(@i_tablename)) <> '') BEGIN
  -- tablename passed in - for delete
    DECLARE titlehistorycolumns_cur CURSOR FOR
     select tablename, columnname, datatype, columndescription, columnkey
       from titlehistorycolumns 
      where workfieldind = 1
        and activeind = 1
        and tablename = @i_tablename
   order by tablename
END
ELSE BEGIN
  DECLARE titlehistorycolumns_cur CURSOR FOR
   select tablename, columnname, datatype, columndescription, columnkey
     from titlehistorycolumns 
    where workfieldind = 1
      and activeind = 1
 order by tablename
END

SET @v_user_name = user_name()

IF @v_user_name = 'QSINET' OR @v_user_name = 'dbo' BEGIN
	SELECT @v_parent_ean = ean
	  FROM isbn
	 WHERE bookkey = @v_bookkey_copy_from

	IF @v_parent_ean IS NULL
		SET @v_user_name = 'Propagated - (NO EAN)'
	ELSE
		SET @v_user_name = 'Propagated - ' + @v_parent_ean
END 

SET @v_quote = CHAR(39) 


CREATE TABLE #audiocassettespecs (
	bookkey int NULL,
    printingkey int NULL,
    mastering  int NULL,
    tapestock int NULL,
    premiumind char(1) NULL,
    copyprotected char(1) NULL,
    mastertapestorage int NULL,
    lastuserid varchar(30) NULL,
    lastmaintdate datetime NULL,
    vendorkey int NULL,
    numcassettes int NULL,
    totalruntime varchar(10) NULL,
    shelltypecode int NULL,
    assemblytypecode INT NULL,
    shrinkwrapped char(1) NULL)


CREATE TABLE #filelocation (
	bookkey int null,
	printingkey int null ,
	filetypecode smallint null ,
	fileformatcode int NULL ,
	filelocationkey int null,
	filestatuscode int NULL ,
	pathname varchar (255),
	notes text ,
	lastuserid varchar (30),
	lastmaintdate datetime NULL ,
	sendtoeloquenceind int NULL ,
	sortorder int NULL,
	filelocationgeneratedkey int NOT NULL,
	taqprojectkey int NULL,
	taqelementkey int NULL,
	globalcontactkey int NULL,
	locationtypecode int NULL,
	stagecode int NULL,
	filedescription varchar (255))

CREATE TABLE #bookprice (
	pricekey int null,
	bookkey int null,
	pricetypecode smallint null,
	currencytypecode smallint null,
	activeind tinyint NULL ,
	budgetprice float NULL ,
	finalprice float NULL ,
	effectivedate datetime NULL ,
	expirationdate datetime NULL ,
	lastuserid varchar (30)NULL ,
	lastmaintdate datetime NULL ,
	sortorder int NULL ,
	history_order int NULL ,
	overrideprice float NULL ,
	overrideprintingkey int NULL ,
	applysetdiscountind tinyint)


CREATE TABLE #bookorgentry (
	bookkey int null ,
	orgentrykey int null ,
	orglevelkey int null ,
	lastuserid varchar (30) NULL ,
	lastmaintdate datetime  NULL)

CREATE TABLE #bookmisc (
	bookkey int null,
	misckey int null,
	longvalue int NULL ,
	floatvalue float NULL ,
	textvalue varchar (4000) NULL ,
	lastuserid varchar (30)NULL ,
	lastmaintdate datetime NULL ,
	sendtoeloquenceind tinyint null,
	datevalue datetime NULL)

CREATE TABLE #bookcontact (
  bookcontactkey int NOT NULL,
	bookkey int NOT NULL,
	printingkey int NOT NULL,
	globalcontactkey int NOT NULL,
	participantnote varchar(2000) NULL,
	keyind tinyint NULL ,
    sortorder int NULL,
	lastuserid varchar(30) NULL ,
	lastmaintdate datetime NULL)

CREATE TABLE #bookcontactrole (
  bookcontactkey int NOT NULL,
	rolecode int NOT NULL,
	activeind tinyint NULL,
	workrate float NULL,
	ratetypecode int NULL,
  departmentcode int NULL,
	lastuserid varchar(30) NULL ,
	lastmaintdate datetime NULL)

CREATE TABLE #bookaudience(
	bookkey int null,
	audiencecode int null,
	sortorder int null,
	lastuserid varchar(30) null,
	lastmaintdate datetime null)

CREATE TABLE #bookauthor (
	bookkey int null,
	authorkey int null,
	authortypecode smallint null,
	reportind tinyint null,
	primaryind tinyint null,
	authortypedesc varchar (15)  null,
	lastuserid varchar (30) null ,
	lastmaintdate datetime  null,
	sortorder int  null,
	history_order int null)

CREATE TABLE #bookbisaccategory (
	bookkey int null,
	printingkey int null,
	bisaccategorycode int null,
	bisaccategorysubcode int null,
	sortorder int  null,
	lastuserid varchar(30) null,
	lastmaintdate datetime null) 

CREATE TABLE #citation (
	bookkey int null,
	citationkey int  null,
	citationsource varchar (100) null,
	citationauthor varchar (300)null,
	citationdate datetime  null,
	lastuserid varchar (30) null,
	lastmaintdate datetime  null,
	releasetoeloquenceind tinyint  null,
	sortorder int  null,
	citationdesc varchar (255) null,
	citationtypecode int  null,
	proofedind tinyint null ,
	webind tinyint  null,
	qsiobjectkey int  null,
	qsiobjectrtfkey int  null,
	history_order int null,
    citationexternaltypecode int null,
    propagatefromcitationkey int null)
    
CREATE TABLE #qsicomments (
  commentkey int NULL,
  commenttypecode int NULL,
  commenttypesubcode int NULL,
  parenttable varchar(30) NULL,
  commenttext ntext NULL,
  commenthtml ntext NULL,
  commenthtmllite ntext NULL,
  lastuserid varchar(30) NULL,
  lastmaintdate datetime NULL,
  invalidhtmlind int NULL,
  releasetoeloquenceind tinyint NULL)    

CREATE TABLE #bookcomments (
  bookkey int null,
  printingkey int null,
  commenttypecode int  null,
  commenttypesubcode int  null,
  commentstring varchar (8000)  null,
  commenttext ntext  null,
  lastuserid varchar (30) null,
  lastmaintdate datetime  null,
  releasetoeloquenceind tinyint  null,
  commenthtml ntext  null,
  commenthtmllite ntext null,
  invalidhtmlind int null,
  overridepropagationind tinyint null)

CREATE  table #bookcategory
(
  BOOKKEY       int null,
  CATEGORYCODE  int null,
  SORTORDER     int null,
  LASTUSERID    varchar(30) null,
  LASTMAINTDATE datetime null)

CREATE table #booksubjectcategory
(
  BOOKKEY          int null,
  SUBJECTKEY       int null,
  CATEGORYTABLEID  int null,
  CATEGORYCODE     int null,
  CATEGORYSUBCODE  int null,
  SORTORDER        int null,
  LASTUSERID       varchar(30) null,
  LASTMAINTDATE    datetime null,
  CATEGORYSUB2CODE int null)

SELECT @v_websched_option = optionvalue
	FROM clientoptions
 WHERE optionid = 72


 create table #taqprojecttask
 (
   taqtaskkey   int  NULL,
  taqprojectkey   int  NULL,
  taqelementkey   int  NULL,
  bookkey   int  NULL,
  orgentrykey   int  NULL,
  globalcontactkey   int  NULL,
  rolecode   int  NULL,
  globalcontactkey2   int  NULL,
  rolecode2   int  NULL,
  scheduleind   tinyint  NULL,
  stagecode   int  NULL,
  duration   int  NULL,
  datetypecode   int  NOT NULL,
  activedate   datetime  NULL,
  actualind   tinyint  NULL,
  keyind   tinyint  NULL,
  originaldate   datetime  NULL,
  taqtasknote   varchar (2000) NULL,
  decisioncode   smallint  NULL,
  paymentamt   numeric (9, 2) NULL,
  taqtaskqty   int  NULL,
  sortorder   int  NULL,
  taqprojectformatkey   int  NULL,
  lockind   tinyint  NULL,
  lastuserid   varchar (30) NULL,
  lastmaintdate   datetime  NULL,
  printingkey   int  NULL,
  transactionkey   int  NULL,
  cseventid   uniqueidentifier  NULL,
  reviseddate   datetime  NULL,
  startdate datetime NULL,
  startdateactualind tinyint NULL,
  lag int NULL,
  qsilastuserid varchar(30),
  qsilastmaintdate datetime,
  qsijobkey int)

SET @v_autoverifytitle = 0
select @v_releasetoeloquenceind = count(*)
from titlehistorycolumns
where columnname = 'releasetoeloquenceind'
and tablename = 'bookcomments'
and workfieldind = 1
and activeind = 1

select @v_releasetoelo_citation = count(*)
from titlehistorycolumns
where columnname = 'releasetoeloquenceind'
and tablename = 'citation'
and workfieldind = 1
and activeind = 1

open titlehistorycolumns_cur
FETCH NEXT FROM titlehistorycolumns_cur into @v_tablename, @v_columnname, @v_datatype, @v_columndescription, @v_columnkey
WHILE (@@FETCH_STATUS <> -1) BEGIN

  SET @v_value_item = ''
  SET @v_autoverifytitle = 1
  
  IF @v_columndescription = 'Web Title Dates Propagation' BEGIN
    SET @v_tablename = 'taqprojecttask'
    SET @v_columnname = 'taqtaskkey'
  END 

  if @v_tablename in('book', 'bookdetail', 'booksimon', 'printing') begin

	    if @v_tablename = 'booksimon' begin
	       select @v_cnt = count(*)
	       from booksimon 
	       where bookkey = @v_bookkey_copy_to
  	    
	       if @v_cnt = 0 begin
	          insert into booksimon (bookkey, lastmaintdate, lastuserid)
	          values(@v_bookkey_copy_to, getdate(), 'qsidba')
	       end	 	
	    end


	    SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from)


	    EXECUTE sp_executesql @v_sqlstring, 
		      N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT

	  	IF @v_value_item is not null and @v_value_item <> ''
      BEGIN
	 		  set @v_value_item = replace(@v_value_item, @v_quote,  CHAR(146));
	 	  END


		  IF @v_value_item is not null AND @v_value_item <> '' begin
			    SET @v_sqlstring = N'UPDATE ' +  @v_tablename  + ' SET ' +  @v_columnname + ' = ' + @v_quote + @v_value_item + @v_quote +
						   ' WHERE bookkey = @p_bookkey'
			END
			ELSE BEGIN
			  SET @v_sqlstring = N'UPDATE ' +  @v_tablename  + ' SET ' +  @v_columnname + ' =  NULL WHERE bookkey = @p_bookkey'
			END

  		
		  EXECUTE sp_executesql @v_sqlstring, N'@p_bookkey INT', @v_bookkey_copy_to

      if @v_columnname = 'title' begin
         select @v_title = title from book where bookkey = @v_bookkey_copy_from
			   set @v_title = replace(@v_title, CHAR(146), CHAR(39))
         update book set title = @v_title where bookkey = @v_bookkey_copy_to
      end

      if @v_columnname = 'subtitle' begin
        select @v_subtitle = subtitle from book where bookkey = @v_bookkey_copy_from
			  set @v_subtitle = replace(@v_subtitle, CHAR(146), CHAR(39))
        update book set subtitle = @v_subtitle where bookkey = @v_bookkey_copy_to
      end

      if @v_columnname = 'shorttitle' begin
         select @v_shorttitle = shorttitle from book where bookkey = @v_bookkey_copy_from
			   set @v_shorttitle = replace(@v_shorttitle, CHAR(146), CHAR(39))
         update book set shorttitle = @v_shorttitle where bookkey = @v_bookkey_copy_to
      end

		  if @v_columnname = 'seriescode' begin
			  select @v_value_item = dbo.get_gentables_desc(327,convert(int,@v_value_item),'long') 
      end

      if @v_tablename = 'book' begin
		  if @v_columnname = 'territoriescode' begin
			  select @v_value_item = dbo.get_gentables_desc(131,convert(int,@v_value_item),'long') 
		  end		      
      end
      
      if @v_tablename = 'bookdetail' begin
		  if @v_columnname = 'bisacstatuscode' begin
			  select @v_value_item = dbo.get_gentables_desc(314,convert(int,@v_value_item),'long') 
		  end		 
		  
		  if @v_columnname = 'languagecode' OR  @v_columnname = 'languagecode2' begin
			  select @v_value_item = dbo.get_gentables_desc(318,convert(int,@v_value_item),'long') 
		  end		
		  
		  if @v_columnname = 'restrictioncode' begin
			  select @v_value_item = dbo.get_gentables_desc(320,convert(int,@v_value_item),'long') 
		  end		
		  
		  if @v_columnname = 'canadianrestrictioncode' begin
			  select @v_value_item = dbo.get_gentables_desc(428,convert(int,@v_value_item),'long') 
		  end	
		  		  
		  if @v_columnname = 'discountcode' begin
			  select @v_value_item = dbo.get_gentables_desc(459,convert(int,@v_value_item),'long') 
		  end	
		  
		  if @v_columnname = 'returncode' begin
			  select @v_value_item = dbo.get_gentables_desc(319,convert(int,@v_value_item),'long') 
		  end		
		  
		  if @v_columnname = 'gradelow' OR  @v_columnname = 'gradehigh' begin 
			if @v_value_item = 'UP' begin
				SET @v_value_item = 'Up'
			end
			else if @v_value_item = 'P' begin
				SET @v_value_item = 'Preschool'			
			end
			else if @v_value_item = 'K' begin
				SET @v_value_item = 'Kindergarten'			
			end	
			else if @v_value_item = '1' begin
				SET @v_value_item = 'First Grade'			
			end
			else if @v_value_item = '2' begin
				SET @v_value_item = 'Second Grade'			
			end
			else if @v_value_item = '3' begin
				SET @v_value_item = 'Second Grade'			
			end
			else if @v_value_item = '4' begin
				SET @v_value_item = 'Fourth Grade'			
			end
			else if @v_value_item = '5' begin
				SET @v_value_item = 'Fifth Grade'			
			end
			else if @v_value_item = '6' begin
				SET @v_value_item = 'Sixth Grade'			
			end
			else if @v_value_item = '7' begin
				SET @v_value_item = 'Seventh Grade'			
			end
			else if @v_value_item = '8' begin
				SET @v_value_item = 'Eighth Grade'			
			end
			else if @v_value_item = '9' begin
				SET @v_value_item = 'Ninth Grade' 			
			end
			else if @v_value_item = '10' begin
				SET @v_value_item = 'Tenth Grade'			
			end
			else if @v_value_item = '11' begin
				SET @v_value_item = 'Eleventh Grade'			
			end
			else if @v_value_item = '12' begin
				SET @v_value_item = 'Twelfth Grade'			
			end
			else if @v_value_item = '13' begin
				SET @v_value_item = 'College Freshman'			
			end
			else if @v_value_item = '14' begin
				SET @v_value_item = 'College Sophomore'			
			end
			else if @v_value_item = '15' begin
				SET @v_value_item = 'College Junior'			
			end
			else if @v_value_item = '16' begin
				SET @v_value_item = 'College Senior'			
			end
			else if @v_value_item = '17' begin
				SET @v_value_item = 'Graduate Student'			
			end																																																											
		  end			  	  		  	  	    
      end	
  	
      IF @v_columnkey <> 107 begin
			  exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			    @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
      END
  end

  if @v_tablename = 'bookprice' begin
	  delete from #bookprice
	  delete from bookprice
	  where bookkey = @v_bookkey_copy_to	

	  insert into #bookprice select * from bookprice where bookkey = @v_bookkey_copy_from
	  update #bookprice set bookkey = @v_bookkey_copy_to

	  DECLARE bookprice_cur CURSOR FOR
	    select pricekey
	    from bookprice 
	    where bookkey = @v_bookkey_copy_from
	    ORDER BY pricekey

	  open bookprice_cur
	  FETCH NEXT FROM bookprice_cur into @v_price_key
  	
    WHILE (@@FETCH_STATUS <> -1) BEGIN
      execute get_next_key 'qsidba', @v_next_key output

      EXEC qtitle_get_next_history_order @v_bookkey_copy_to, 0, 'bookprice', 'qsidba', 
        @v_history_order OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

      update #bookprice
      set pricekey = @v_next_key, history_order = @v_history_order
      where pricekey = @v_price_key

      FETCH NEXT FROM bookprice_cur into @v_price_key
    end
  	
	  close bookprice_cur
	  deallocate bookprice_cur

	  insert into bookprice select * from #bookprice

  end

  if @v_tablename = 'audiocassettespecs' begin
	  delete from #audiocassettespecs
	  delete from audiocassettespecs
	  where bookkey = @v_bookkey_copy_to
  	
	  insert into #audiocassettespecs select * from audiocassettespecs where bookkey = @v_bookkey_copy_from
	  update #audiocassettespecs set bookkey = @v_bookkey_copy_to
	  insert into audiocassettespecs select * from #audiocassettespecs

	  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from)


	   EXECUTE sp_executesql @v_sqlstring, 
		      N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT

	   --IF @v_value_item is not null AND @v_value_item <> '' begin
		    exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			    @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
          
       --END

  end

  if @v_tablename = 'filelocation' begin
	  delete from #filelocation
	  delete from filelocation
	  where bookkey = @v_bookkey_copy_to
  	
	  insert into #filelocation 
		select bookkey, printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, pathname, 
		notes, lastuserid, lastmaintdate, sendtoeloquenceind, sortorder, filelocationgeneratedkey, taqprojectkey, taqelementkey, 
		globalcontactkey, locationtypecode, stagecode, filedescription
		from filelocation 
		where bookkey = @v_bookkey_copy_from

	  DECLARE filelocation_cur CURSOR FOR
	  select printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, pathname, CONVERT(varchar(max), notes), lastuserid, lastmaintdate, 
			 sendtoeloquenceind, sortorder, taqprojectkey, taqelementkey, globalcontactkey, locationtypecode, stagecode, filedescription 
	  from #filelocation
	  open filelocation_cur
	  FETCH NEXT FROM filelocation_cur into @v_printingkey, @v_filetypecode, @v_fileformatcode, @v_filelocationkey, @v_filestatuscode,
	             @v_pathname, @v_notes, @v_lastuserid, @v_lastmaintdate, @v_sendtoeloquenceind, @v_sortorder,
	             @v_taqprojectkey, @v_taqelementkey, @v_globalcontactkey, @v_locationtypecode, @v_stagecode, @v_filedescription
	  WHILE (@@FETCH_STATUS <> -1) BEGIN
	  execute get_next_key 'qsidba',@v_new_filelocationgeneratedkey OUTPUT

	  insert into filelocation 
			(bookkey, printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, pathname, 
			 notes, lastuserid, lastmaintdate, sendtoeloquenceind, sortorder, filelocationgeneratedkey, taqprojectkey, taqelementkey, 
			 globalcontactkey, locationtypecode, stagecode, filedescription)
	  VALUES (@v_bookkey_copy_to,
			 @v_printingkey,
	         @v_filetypecode,
	         @v_fileformatcode,
	         @v_filelocationkey,
	         @v_filestatuscode,
	         @v_pathname,
	         CONVERT(text, @v_notes),
	         @v_lastuserid,
	         @v_lastmaintdate,
	         @v_sendtoeloquenceind,
	         @v_sortorder,
	         @v_new_filelocationgeneratedkey,
	         @v_taqprojectkey,
	         @v_taqelementkey,
	         @v_globalcontactkey,
	         @v_locationtypecode,
	         @v_stagecode,
	         @v_filedescription)
	  FETCH NEXT FROM filelocation_cur into @v_printingkey, @v_filetypecode, @v_fileformatcode, @v_filelocationkey, @v_filestatuscode,
	             @v_pathname, @v_notes, @v_lastuserid, @v_lastmaintdate, @v_sendtoeloquenceind, @v_sortorder,
	             @v_taqprojectkey, @v_taqelementkey, @v_globalcontactkey, @v_locationtypecode, @v_stagecode, @v_filedescription
	  END

	  close filelocation_cur
	  deallocate filelocation_cur

  end

  if @v_tablename = 'bookorgentry' begin
	  delete from #bookorgentry
	  delete from bookorgentry
	  where bookkey = @v_bookkey_copy_to
  	
	  insert into #bookorgentry select * from bookorgentry where bookkey = @v_bookkey_copy_from
	  update #bookorgentry set bookkey = @v_bookkey_copy_to
	  insert into bookorgentry select * from #bookorgentry

  end

  if @v_tablename = 'bookmisc' begin
	  delete from #bookmisc
	  delete from bookmisc
	  where bookkey = @v_bookkey_copy_to
  	
	  insert into #bookmisc select bookmisc.* from bookmisc 
		join bookmiscitems bm on bookmisc.misckey = bm.misckey
		 and COALESCE(bm.propagatemiscitemind,0) = 1 
	   where bookkey = @v_bookkey_copy_from
		
	  update #bookmisc set bookkey = @v_bookkey_copy_to


	  declare notworkfieldind_cur cursor for
   	  select columnkey
     	  from titlehistorycolumns 
    	  where workfieldind = 0
      	  and activeind = 1
	  and lower(tablename) = 'bookmisc'
  	
	  declare misckey_cur cursor for
	  select m.misckey
	  from bookmisc m, bookmiscitems i 
	  where m.misckey = i.misckey 
	  and m.bookkey = @v_bookkey_copy_from
	  and misctype = @v_misctype
  	

	  open notworkfieldind_cur
	  FETCH NEXT FROM notworkfieldind_cur into @v_columnkey
	  WHILE (@@FETCH_STATUS <> -1) BEGIN
	      if @v_columnkey = 225 begin set @v_misctype = 1 end
	      if @v_columnkey = 226 begin set @v_misctype = 2 end
	      if @v_columnkey = 227 begin set @v_misctype = 3 end
	      if @v_columnkey = 247 begin set @v_misctype = 4 end
	      if @v_columnkey = 248 begin set @v_misctype = 5 end

	      open misckey_cur
    	      FETCH NEXT FROM misckey_cur into @v_misckey
	      WHILE (@@FETCH_STATUS <> -1) BEGIN
		  delete from #bookmisc where bookkey = @v_bookkey_copy_to and misckey = @v_misckey
    	      FETCH NEXT FROM misckey_cur into @v_misckey
	      END
	      close misckey_cur
  		
	  FETCH NEXT FROM notworkfieldind_cur into @v_columnkey
	  END
	  close notworkfieldind_cur

	  insert into bookmisc select * from #bookmisc
  	
	  deallocate misckey_cur
	  deallocate notworkfieldind_cur

  end

  if @v_tablename = 'bookcontact' begin
      select @v_count = count(*)
       from bookcontact 
      where bookkey = @v_bookkey_copy_from
      
    if @v_count > 0 BEGIN        
	  delete from #bookcontact 
	  delete from bookcontact
	  where bookkey = @v_bookkey_copy_to

	  delete from #bookcontactrole 

	  delete from bookcontactrole
	  where bookcontactkey in(select bookcontact.bookcontactkey 
							  from bookcontact, bookcontactrole
							  where bookcontact.bookcontactkey  = bookcontactrole.bookcontactkey 
							  and bookkey = @v_bookkey_copy_to)

	  insert into #bookcontact select * from bookcontact where bookkey = @v_bookkey_copy_from
	  insert into #bookcontactrole select * from bookcontactrole where bookcontactkey in(select bookcontact.bookcontactkey 
																						  from bookcontact, bookcontactrole
																						  where bookcontact.bookcontactkey  = bookcontactrole.bookcontactkey 
																						  and bookkey = @v_bookkey_copy_from)

	  update #bookcontact set bookkey = @v_bookkey_copy_to
  	
	  DECLARE bookcontact_cur CURSOR FOR
	  select bookcontactkey
	  from #bookcontact
	  open bookcontact_cur
	  FETCH NEXT FROM bookcontact_cur into @v_bookcontactkey
	  WHILE (@@FETCH_STATUS <> -1) BEGIN
	  execute get_next_key 'qsidba',@v_new_bookcontactkey OUTPUT
	  update #bookcontact set bookcontactkey = @v_new_bookcontactkey where bookcontactkey = @v_bookcontactkey  

	  update #bookcontactrole set bookcontactkey = @v_new_bookcontactkey where bookcontactkey = @v_bookcontactkey  

	  FETCH NEXT FROM bookcontact_cur into @v_bookcontactkey
	  END

	  close bookcontact_cur
	  deallocate bookcontact_cur
	  
	  insert into bookcontact select * from #bookcontact
	  insert into bookcontactrole select * from #bookcontactrole	 
	  
	  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from)

	   EXECUTE sp_executesql @v_sqlstring, 
		      N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT
		      
		if @v_columnname = 'globalcontactkey' begin
		   select @v_value_item = displayname from globalcontact WHERE globalcontactkey = @v_value_item
		end
		      
	   --IF @v_value_item is not null AND @v_value_item <> '' begin
		    exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			    @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
          
       --END	   
    end
  end
  	
  if @v_tablename = 'bookaudience' begin
	  delete from #bookaudience
	  delete from bookaudience
	  where bookkey = @v_bookkey_copy_to
  	
	  insert into #bookaudience select * from bookaudience where bookkey = @v_bookkey_copy_from
	  update #bookaudience set bookkey = @v_bookkey_copy_to
	  insert into bookaudience select * from #bookaudience

  end

  if @v_tablename = 'bookauthor' begin
    select @v_count = count(*)
      from bookauthor 
     where bookkey = @v_bookkey_copy_from

    if @v_count > 0 BEGIN

	    delete from #bookauthor
	    delete from #TempBookAuthorKeys
	    
	    insert into #TempBookAuthorKeys                     
			SELECT T1.bookkey, T1.authorkey, T1.authortypecode, NULL
				FROM bookauthor T1
				WHERE NOT EXISTS(SELECT NULL
									 FROM bookauthor T2
									 WHERE T1.authorkey = T2.authorkey 
										 AND T1.authortypecode = T2.authortypecode
										 AND  T2.bookkey = @v_bookkey_copy_from
										 )                    
										 AND T1.bookkey =@v_bookkey_copy_to 
					
	   update #TempBookAuthorKeys
		set rolecode = (select code2
							from gentablesrelationshipdetail 
						   where gentablesrelationshipkey = 1
						   Group by code1, code2 
						   having code1= t.authortypecode)	        
		from  #TempBookAuthorKeys  t
			    
	    delete from bookauthor
	    where bookkey = @v_bookkey_copy_to
    	
	    insert into #bookauthor select * from bookauthor where bookkey = @v_bookkey_copy_from
	    update #bookauthor set bookkey = @v_bookkey_copy_to
	    insert into bookauthor select * from #bookauthor
  	  
	    SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			      ' FROM ' + @v_tablename +
			      ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from)

	     EXECUTE sp_executesql @v_sqlstring, 
		        N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT
  		      
		  if @v_columnname = 'authorkey' begin
			 select @v_value_item = displayname from globalcontact WHERE globalcontactkey = @v_value_item
		  end
		  		      
		  if @v_columnname = 'authortypecode' begin
		     select @v_value_item = dbo.get_gentables_desc(134,convert(int,@v_value_item),'long') 
		  end
  		      
	     --IF @v_value_item is not null AND @v_value_item <> '' begin
		      exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			      @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
            
         --END

           -- Updating Tasks and elements to clear the contactkey. If they are propagated later they are deleted in the Subordinate titles during deletion of Author.
           IF EXISTS(SELECT * FROM #TempBookAuthorKeys) BEGIN
			UPDATE
				taqprojecttask
			SET
				taqprojecttask.globalcontactkey = NULL
			FROM
				taqprojecttask
			INNER JOIN
				#TempBookAuthorKeys
			ON
				taqprojecttask.bookkey = #TempBookAuthorKeys.bookkey
			AND taqprojecttask.globalcontactkey = #TempBookAuthorKeys.authorkey 
			AND taqprojecttask.rolecode = #TempBookAuthorKeys.rolecode     
			WHERE taqprojecttask.bookkey = @v_bookkey_copy_to     
			
			UPDATE
				taqprojecttask
			SET
				taqprojecttask.globalcontactkey2 = NULL
			FROM
				taqprojecttask
			INNER JOIN
				#TempBookAuthorKeys
			ON
				taqprojecttask.bookkey = #TempBookAuthorKeys.bookkey
			AND taqprojecttask.globalcontactkey2 = #TempBookAuthorKeys.authorkey 
			AND taqprojecttask.rolecode2 = #TempBookAuthorKeys.rolecode
			WHERE taqprojecttask.bookkey = @v_bookkey_copy_to		
			
			UPDATE taqprojectelement SET globalcontactkey = NULL
			 WHERE taqelementkey in ( SELECT taqelementkey 
										FROM taqprojectelement WHERE bookkey = @v_bookkey_copy_to 
																 AND globalcontactkey IN (SELECT authorkey FROM #TempBookAuthorKeys))

			UPDATE taqprojectelement SET globalcontactkey2 = NULL
			 WHERE taqelementkey in ( SELECT taqelementkey 
										FROM taqprojectelement WHERE bookkey = @v_bookkey_copy_to 
																 AND globalcontactkey2 IN (SELECT authorkey FROM #TempBookAuthorKeys))  
							
			---- Propagating tasks to keep it Sync with Author													 
			--IF EXISTS (SELECT * FROM titlehistorycolumns WHERE columndescription = 'Web Title Dates Propagation' AND workfieldind = 1 AND activeind = 1)																                                                        							        	  
			--BEGIN
			--	SET @v_tablename = 'taqprojecttask'
			--	SET @v_columnname = 'taqtaskkey'								
			--END																                                                        							        	  
		  END         		  
    end
  end

  if @v_tablename = 'bookbisaccategory' begin
	  delete from #bookbisaccategory
	  delete from bookbisaccategory
	  where bookkey = @v_bookkey_copy_to and printingkey = 1
	  insert into #bookbisaccategory select * from bookbisaccategory where bookkey = @v_bookkey_copy_from and printingkey = 1 
	  update #bookbisaccategory set bookkey = @v_bookkey_copy_to
    
    SELECT @v_parent_ean = ean
	    FROM isbn
	   WHERE bookkey = @v_bookkey_copy_from

	  IF @v_parent_ean IS NULL
		  SET @v_user = 'Propagated - (NO EAN)'
	  ELSE
		  SET @v_user = 'Propagated - ' + @v_parent_ean

    DECLARE bookbisaccat_cur CURSOR FOR
      SELECT bisaccategorycode,bisaccategorysubcode,sortorder
        FROM #bookbisaccategory
      ORDER BY sortorder ASC

    OPEN bookbisaccat_cur
		
    FETCH NEXT FROM bookbisaccat_cur INTO @v_bisaccategorycode,@v_bisaccategorysubcode,@v_sortorder
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @v_bisaccategorycode IS NOT NULL AND @v_bisaccategorycode > 0 BEGIN
          SELECT @v_bisaccategorydesc = datadesc FROM gentables WHERE tableid = 339 AND datacode = @v_bisaccategorycode
          
          IF @i_columnname = 'bisaccategorycode' BEGIN
            SELECT @v_fielddesc = ltrim(rtrim(@v_bisaccategorydesc)) 
            
			exec qtitle_update_titlehistory @v_tablename, 'bisaccategorycode', @v_bookkey_copy_to, 1, null,
					     @v_fielddesc, 'UPDATE', @v_user, @v_sortorder, @v_bisaccategorydesc, @o_error_code, @o_error_desc
          END
          
          IF @i_columnname = 'bisaccategorysubcode' BEGIN
			  IF @v_bisaccategorysubcode IS NOT NULL AND @v_bisaccategorysubcode > 0 BEGIN
				SELECT @v_bisaccategorysubdesc = datadesc FROM subgentables WHERE tableid = 339 AND datacode = @v_bisaccategorycode
				  AND datasubcode = @v_bisaccategorysubcode
				IF @v_bisaccategorysubdesc IS NOT NULL AND @v_bisaccategorysubdesc <> '' BEGIN
				  SELECT @v_fielddesc = ltrim(rtrim(@v_bisaccategorydesc)) + ' - ' + ltrim(rtrim(@v_bisaccategorysubdesc))
				  --exec qtitle_update_titlehistory @v_tablename, 'bisaccategorycode', @v_bookkey_copy_to, 1, null,
						--	 @v_fielddesc, 'UPDATE', @v_user, @v_sortorder, @v_bisaccategorydesc, @o_error_code, @o_error_desc
				  exec qtitle_update_titlehistory @v_tablename, 'bisaccategorysubcode', @v_bookkey_copy_to, 1, null,
							 @v_bisaccategorysubdesc, 'UPDATE', @v_user, @v_sortorder, @v_bisaccategorydesc, @o_error_code, @o_error_desc
				END
			  END
		   END
        END
        FETCH NEXT FROM bookbisaccat_cur INTO @v_bisaccategorycode,@v_bisaccategorysubcode,@v_sortorder 
    END

    CLOSE bookbisaccat_cur
    DEALLOCATE bookbisaccat_cur

	  insert into bookbisaccategory select * from #bookbisaccategory
  end

  if @v_tablename = 'citation' and EXISTS (select * from titlehistorycolumns where columnkey IN (67, 68)  and workfieldind = 1) begin  
	 DECLARE crCitation CURSOR FOR
		select citationkey,  citationsource, citationauthor, qsiobjectkey from citation where bookkey = @v_bookkey_copy_to and propagatefromcitationkey IS NULL
	  OPEN crCitation 

	  FETCH NEXT FROM crCitation INTO @v_citationkey, @v_citationsource, @v_citationauthor, @v_qsiobjectkey

	  WHILE (@@FETCH_STATUS <> -1)
	  BEGIN 
	  	   SET @v_propagatefromcitationkey = NULL
  		   IF (@v_citationsource IS NOT NULL OR @v_citationauthor IS NOT NULL OR @v_qsiobjectkey IS NOT NULL) BEGIN
				IF EXISTS(SELECT * FROM citation WHERE bookkey = @v_bookkey_copy_from and COALESCE(citationsource, '-999') = COALESCE(@v_citationsource, '-999') and COALESCE(citationauthor, '-999') = COALESCE(@v_citationauthor, '-999') ) BEGIN
					IF @v_qsiobjectkey IS NOT NULL BEGIN
					    SELECT @v_count_qsicomment = COUNT(*) FROM qsicomments WHERE commentkey = @v_qsiobjectkey	
					    IF @v_count_qsicomment > 0 BEGIN					
							SELECT @v_citation_commenthtml = CAST(commenthtml AS NVARCHAR(MAX)) FROM qsicomments WHERE commentkey = @v_qsiobjectkey									
							
							SELECT TOP 1 @v_propagatefromcitationkey = citationkey  from citation c
							INNER JOIN qsicomments q ON q.commentkey = c.qsiobjectkey
							where c.bookkey = @v_bookkey_copy_from and COALESCE(c.citationsource, '-999') = COALESCE(@v_citationsource, '-999') and COALESCE(c.citationauthor, '-999') = COALESCE(@v_citationauthor, '-999')
							AND CAST(q.commenthtml AS NVARCHAR(MAX)) = @v_citation_commenthtml
							AND c.citationkey NOT IN (SELECT propagatefromcitationkey FROM citation c1 WHERE c1.bookkey = @v_bookkey_copy_to AND propagatefromcitationkey IS NOT NULL)
						END
						ELSE BEGIN
							SELECT TOP 1 @v_propagatefromcitationkey = citationkey  from citation c
							where c.bookkey = @v_bookkey_copy_from 
							  and COALESCE(c.citationsource, '-999') = COALESCE(@v_citationsource, '-999') 
							  and COALESCE(c.citationauthor, '-999') = COALESCE(@v_citationauthor, '-999')
							  AND c.citationkey NOT IN (SELECT propagatefromcitationkey FROM citation c1 WHERE c1.bookkey = @v_bookkey_copy_to AND propagatefromcitationkey IS NOT NULL)
							  
							IF @v_propagatefromcitationkey IS NULL BEGIN
								SELECT TOP 1 @v_propagatefromcitationkey = citationkey  from citation c
							     where c.bookkey = @v_bookkey_copy_from 
							       and COALESCE(c.citationsource, '-999') = COALESCE(@v_citationsource, '-999') 
							       and COALESCE(c.citationauthor, '-999') = COALESCE(@v_citationauthor, '-999')
							       AND c.citationkey NOT IN (SELECT propagatefromcitationkey FROM citation c1 WHERE c1.bookkey = @v_bookkey_copy_to AND propagatefromcitationkey IS NULL)
							END  
						END
						
						IF @v_propagatefromcitationkey IS NOT NULL BEGIN				
								UPDATE citation SET propagatefromcitationkey = @v_propagatefromcitationkey, lastmaintdate = GETDATE(), lastuserid = @v_user_name WHERE bookkey = @v_bookkey_copy_to and citationkey = @v_citationkey
							if @@Error <> 0
							BEGIN
							 SET @o_error_code = -1
							 SET @o_error_desc = 'Error updating citation to set propagatefromcitationkey = ' + CONVERT(VARCHAR, @v_propagatefromcitationkey) + ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_to) + ' AND citationkey = ' + CONVERT(VARCHAR, @v_citationkey)
							 return;
							END				
						END					
					END
					ELSE BEGIN 
						SELECT TOP 1 @v_propagatefromcitationkey = citationkey  from citation where bookkey = @v_bookkey_copy_from and COALESCE(citationsource, '-999') = COALESCE(@v_citationsource, '-999') and COALESCE(citationauthor, '-999') = COALESCE(@v_citationauthor, '-999')
						AND qsiobjectkey IS NULL
						AND citationkey NOT IN (SELECT propagatefromcitationkey FROM citation WHERE bookkey = @v_bookkey_copy_to AND propagatefromcitationkey IS NOT NULL)
						
						IF @v_propagatefromcitationkey IS NOT NULL BEGIN				
								UPDATE citation SET propagatefromcitationkey = @v_propagatefromcitationkey, lastmaintdate = GETDATE(), lastuserid = @v_user_name WHERE bookkey = @v_bookkey_copy_to and citationkey = @v_citationkey
							if @@Error <> 0
							BEGIN
							 SET @o_error_code = -1							
							 SET @o_error_desc = 'Error updating citation to set propagatefromcitationkey = ' + CONVERT(VARCHAR, @v_propagatefromcitationkey) + ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_to) + ' AND citationkey = ' + CONVERT(VARCHAR, @v_citationkey)
							 return;
							END					
						END
					END						
				END
  		   END
		FETCH NEXT FROM crCitation INTO @v_citationkey, @v_citationsource, @v_citationauthor, @v_qsiobjectkey
	  END /* WHILE FECTHING */

	  CLOSE crCitation 
	  DEALLOCATE crCitation	  
	   
	  delete from #citation
	  insert into #citation select bookkey ,citationkey ,citationsource,citationauthor,citationdate,lastuserid,getdate(),releasetoeloquenceind,
								  sortorder,citationdesc,citationtypecode,proofedind,webind,qsiobjectkey,qsiobjectrtfkey,history_order,citationexternaltypecode, propagatefromcitationkey 
						    from citation where bookkey = @v_bookkey_copy_to and propagatefromcitationkey IN (select citationkey from citation where bookkey = @v_bookkey_copy_from)
						    
	  delete from citation
	  where bookkey = @v_bookkey_copy_to and propagatefromcitationkey IN (select citationkey from citation where bookkey = @v_bookkey_copy_from)	
	  
	  update #citation set releasetoeloquenceind = 0, lastmaintdate = GETDATE(), lastuserid = @v_user_name WHERE releasetoeloquenceind IS NULL
	  	  
	  DECLARE citation_cur CURSOR FOR -- cleanup for citations that connect to a parent citation via propagatefromcitationkey that has been deleted
		  select bookkey, citationkey, qsiobjectkey, history_order
		  from citation where bookkey = @v_bookkey_copy_to and propagatefromcitationkey IS NOT NULL	 
		  open citation_cur
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey, @v_qsiobjectkey, @v_citation_history_order
	  WHILE (@@FETCH_STATUS <> -1) BEGIN		              
            IF @v_qsiobjectkey IS NOT NULL BEGIN
   				exec qtitle_update_titlehistory 'qsicomments', 'commenttext', @v_bookkey_copy_to, 1, null,
					NULL, 'delete', @v_user_name, @v_citation_history_order, null, @o_error_code, @o_error_desc	    				        
					
				delete from qsicomments where commentkey = @v_qsiobjectkey					
            END
            
		    DECLARE titlehistory_cur CURSOR FOR -- cleanup for citations that connect to a parent citation via propagatefromcitationkey that has been deleted
			   select columnname
				 from titlehistorycolumns  where workfieldind = 1 and tablename = @i_tablename
				  and activeind = 1 order by tablename 				  			  
			  open titlehistory_cur
		    FETCH NEXT FROM titlehistory_cur into @v_citation_titlehistory_columnname
		    WHILE (@@FETCH_STATUS <> -1) BEGIN		                          
	                        
				exec qtitle_update_titlehistory @v_tablename, @v_citation_titlehistory_columnname, @v_bookkey_copy_to, 1, null,
					NULL, 'delete', @v_user_name, @v_citation_history_order, null, @o_error_code, @o_error_desc	
		    FETCH NEXT FROM titlehistory_cur into @v_citation_titlehistory_columnname
		    END  

		    close titlehistory_cur
		    deallocate titlehistory_cur   				
				
		    delete from citation where bookkey = @v_citation_bookkey and citationkey = 	@v_citationkey	
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey, @v_qsiobjectkey, @v_citation_history_order
	  END  

	  close citation_cur
	  deallocate citation_cur
	  
	  DECLARE citation_cur CURSOR FOR
		  select bookkey,citationkey ,citationsource,citationauthor,citationdate,releasetoeloquenceind,
						    citationdesc,citationtypecode, proofedind,webind, sortorder, history_order,citationexternaltypecode
		  
		  from citation where bookkey = @v_bookkey_copy_from
		  open citation_cur
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey,@v_citationsource, @v_citationauthor, @v_citationdate, @v_citation_releasetoeloquenceind, 
										@v_citationdesc, @v_citationtypecode, @v_citation_proofedind, @v_citation_webind, @v_citation_sortorder, @v_citation_history_order, @v_citationexternaltypecode
	  WHILE (@@FETCH_STATUS <> -1) BEGIN		
	  
	  if @v_columnname = 'citationsource' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT
		  insert into #citation (bookkey ,citationkey ,citationsource,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citationsource,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey,@v_new_citationkey)
		end
		else begin
		  update #citation set citationsource = @v_citationsource, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end
	  end
	  else if @v_columnname = 'citationauthor' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,citationauthor,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citationauthor,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set citationauthor = @v_citationauthor, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end	  
	  end
	  else if @v_columnname = 'citationdate' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,citationdate,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citationdate,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set citationdate = @v_citationdate, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end		
	  end
	  else if @v_columnname = 'citationdesc' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,citationdesc,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citationdesc,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set citationdesc = @v_citationdesc, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end			
	  end
	  else if @v_columnname = 'proofedind' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,proofedind,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citation_proofedind,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set proofedind = @v_citation_proofedind, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end			
	  end
	  else if @v_columnname = 'webind' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,webind,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citation_webind,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set webind = @v_citation_webind, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end			
	  end
	  else if @v_columnname = 'releasetoeloquenceind' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,releasetoeloquenceind,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citation_releasetoeloquenceind,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set releasetoeloquenceind = @v_citation_releasetoeloquenceind, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end			
	  end
	  else if @v_columnname = 'citationexternaltypecode' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,citationexternaltypecode,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citationexternaltypecode,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set citationexternaltypecode = @v_citationexternaltypecode, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end				
	  end
	  else if @v_columnname = 'citationtypecode' begin
		if not exists(select * from #citation where propagatefromcitationkey = @v_citationkey) begin
		  execute get_next_key 'qsidba',@v_new_citationkey OUTPUT		
		  insert into #citation (bookkey ,citationkey ,citationtypecode,lastuserid,lastmaintdate, sortorder, history_order, propagatefromcitationkey, qsiobjectkey) 
					  VALUES(@v_bookkey_copy_to ,@v_new_citationkey ,@v_citationtypecode,@v_user_name,GETDATE(), @v_citation_sortorder, @v_citation_history_order, @v_citationkey, @v_new_citationkey)
		end
		else begin
		  update #citation set citationtypecode = @v_citationtypecode, lastmaintdate = GETDATE(), lastuserid = @v_user_name where propagatefromcitationkey = @v_citationkey
		end			
	  end	    
	  
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey,@v_citationsource, @v_citationauthor, @v_citationdate, @v_citation_releasetoeloquenceind, 
										@v_citationdesc, @v_citationtypecode, @v_citation_proofedind, @v_citation_webind, @v_citation_sortorder, @v_citation_history_order, @v_citationexternaltypecode
	  END

	  close citation_cur
	  deallocate citation_cur
	  	  
	  insert into citation (bookkey ,citationkey ,citationsource,citationauthor,citationdate,lastuserid,lastmaintdate,releasetoeloquenceind,
						    sortorder,citationdesc,citationtypecode,proofedind,webind,qsiobjectkey,qsiobjectrtfkey,history_order,citationexternaltypecode, propagatefromcitationkey) 
				  select * from #citation
				  
	  DECLARE citation_cur CURSOR FOR
		  select bookkey, citationkey, qsiobjectkey, history_order
		  from #citation
		  open citation_cur
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey, @v_qsiobjectkey, @v_citation_history_order
	  WHILE (@@FETCH_STATUS <> -1) BEGIN		  
		  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			' FROM ' + @v_tablename +
			' WHERE citationkey = ' + CONVERT(VARCHAR, @v_citationkey) + ' AND bookkey = ' +  CONVERT(VARCHAR,@v_citation_bookkey)


		   EXECUTE sp_executesql @v_sqlstring, 
				   N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT
				   
		    if @v_columnname = 'citationdate' begin
				select @v_value_item = convert(varchar, CONVERT(datetime, @v_value_item, 101), 101)
			end					   

			SET @v_value_item = REPLACE(@v_value_item, '&amp;', '&')
			SET @v_value_item = REPLACE(@v_value_item, '''''', '''')
			
			SET @FieldDescDetail = null
			if @v_columnname = 'citationexternaltypecode' begin
                SELECT @v_value_item = datadesc
                  FROM gentables
                WHERE tableid = 504 
                    AND datacode = @v_value_item			
			end
			else if @v_columnname = 'citationtypecode' begin
                SELECT @v_value_item = datadesc
                  FROM gentables
                WHERE tableid = 503 
                    AND datacode = @v_value_item					
			end				
            
   			exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 1, null,
				@v_value_item, 'UPDATE', @v_user_name, @v_citation_history_order, @FieldDescDetail, @o_error_code, @o_error_desc		
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey, @v_qsiobjectkey, @v_citation_history_order
	  END  

	  close citation_cur
	  deallocate citation_cur     
  end
  
  if @v_tablename = 'qsicomments' and (@v_columndescription = 'Citation Comment') and @v_columnname = 'commenttext' begin
	if EXISTS (select * from titlehistorycolumns where columnkey IN (67, 68)  and workfieldind = 1) begin
	  select @v_datacode = datacode, @v_datasubcode = datasubcode, @FieldDescDetail = COALESCE(datadescshort,datadesc) from subgentables where tableid = 534 AND qsicode = 1	
	  delete from #citation  		  
	  insert into #citation select bookkey ,citationkey ,citationsource,citationauthor,citationdate,lastuserid,getdate(),releasetoeloquenceind,
								  sortorder,citationdesc,citationtypecode,proofedind,webind,qsiobjectkey,qsiobjectrtfkey,history_order,citationexternaltypecode, propagatefromcitationkey 
							from citation where bookkey = @v_bookkey_copy_from   		  
							
	  delete from qsicomments
	  where commentkey IN (select qsiobjectkey from citation where bookkey = @v_bookkey_copy_to and propagatefromcitationkey IN (select citationkey from citation where bookkey = @v_bookkey_copy_from))	
	  update citation set qsiobjectkey = NULL, lastmaintdate = GETDATE(), lastuserid = @v_user_name where bookkey = @v_bookkey_copy_to and propagatefromcitationkey IN (select citationkey from citation where bookkey = @v_bookkey_copy_from)
	  		  
	  DECLARE citation_cur CURSOR FOR
		  select bookkey, citationkey, qsiobjectkey, history_order
		  from #citation
		  open citation_cur
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey, @v_qsiobjectkey, @v_citation_history_order
	  WHILE (@@FETCH_STATUS <> -1) BEGIN	
	  	
		  SELECT @v_count = count(*) from citation where bookkey = @v_bookkey_copy_to and propagatefromcitationkey = @v_citationkey
		  
		  if @v_count = 1 begin
			delete from #qsicomments		  
			insert into #qsicomments
			select * from qsicomments where commentkey = @v_qsiobjectkey and commenttypecode = @v_datacode and commenttypesubcode = @v_datasubcode		
			SELECT @v_new_qsiobjectkey = COALESCE(qsiobjectkey, citationkey) from citation where bookkey = @v_bookkey_copy_to and propagatefromcitationkey = @v_citationkey			
			
			if exists(select * from qsicomments where commentkey = @v_new_qsiobjectkey) begin
				execute get_next_key 'qsidba',@v_new_qsiobjectkey OUTPUT
			end
			
			update #qsicomments set commentkey = @v_new_qsiobjectkey, lastmaintdate = GETDATE(), lastuserid = @v_user_name
			update citation set qsiobjectkey = @v_new_qsiobjectkey, lastmaintdate = GETDATE(), lastuserid = @v_user_name where bookkey = @v_bookkey_copy_to and propagatefromcitationkey = @v_citationkey
			insert into qsicomments select * from #qsicomments	
			
		  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			' FROM ' + @v_tablename +
			' WHERE commentkey = ' + CONVERT(VARCHAR, @v_new_qsiobjectkey) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,@v_datacode) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_datasubcode)


		   EXECUTE sp_executesql @v_sqlstring, 
				   N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT

			SET @v_value_item = REPLACE(@v_value_item, '&amp;', '&')
			SET @v_value_item = REPLACE(@v_value_item, '''''', '''')
            
		   SELECT @v_count = 0

		   SELECT @v_count = count(*)
			  FROM titlehistory
			WHERE bookkey = @v_bookkey_copy_to
				 AND columnkey = 281
				 AND fielddesc = @FieldDescDetail
				 AND currentstringvalue = SUBSTRING(@v_value_item, 1, 255)

		   IF @v_count = 0 
		   BEGIN
       			exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 1, null,
					@v_value_item, 'UPDATE', @v_user_name, @v_citation_history_order, @FieldDescDetail, @o_error_code, @o_error_desc
		   END				
								  	 			
		  end
	 
	  FETCH NEXT FROM citation_cur into @v_citation_bookkey, @v_citationkey, @v_qsiobjectkey, @v_citation_history_order
	  END  

	  close citation_cur
	  deallocate citation_cur	  			  		    
	end	  	  
  end
  
  DECLARE @subord_table TABLE
  (
	  commenttypesubcode	INT,
	  releasetoeloquenceind	INT
  )

  if @v_tablename = 'bookcomments' and (@v_columndescription = 'Title Notes'  OR (@v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1)) begin
	  delete from #bookcomments
	  delete from @subord_table
  	
	  --remember the releasetoeloquenceind in the subord table being copied to so you can set them back after they are replaced
	  INSERT @subord_table
	  SELECT commenttypesubcode, releasetoeloquenceind
	  FROM bookcomments
	  WHERE bookkey = @v_bookkey_copy_to
		  AND commenttypecode = 4
		  AND commenttypesubcode IN (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 4)
  	
	  delete from bookcomments
	  where bookkey = @v_bookkey_copy_to
	  and commenttypecode = 4
	  and commenttypesubcode in (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 4)
	  and COALESCE(overridepropagationind,0) = 0
	  
	  insert into #bookcomments
	  select bookkey, printingkey, commenttypecode, commenttypesubcode, commentstring, commenttext, lastuserid,
			 lastmaintdate, releasetoeloquenceind, commenthtml, commenthtmllite, invalidhtmlind, overridepropagationind
	  from bookcomments a where a.bookkey = @v_bookkey_copy_from and a.commenttypecode = 4
      and not exists (select * from bookcomments b where b.bookkey = @v_bookkey_copy_to and 
                  a.commenttypecode = b.commenttypecode and 
                  a.commenttypesubcode = b.commenttypesubcode)
	  
	  update #bookcomments set bookkey = @v_bookkey_copy_to
	  
	  if @v_releasetoeloquenceind = 0 begin
		  update #bookcomments set releasetoeloquenceind = 0
  		
		  DECLARE subordinate_cur	CURSOR FOR
		  SELECT *
		  FROM @subord_table
  		
		  OPEN subordinate_cur
  		
		  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
  		
		  WHILE (@@FETCH_STATUS <> -1)
		  BEGIN
			  UPDATE #bookcomments 
			  SET releasetoeloquenceind = @v_subord_releasetoeloquenceind
			  WHERE commenttypesubcode = @v_subord_commenttypesubcode
  			
			  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
		  END
		  CLOSE subordinate_cur
		  DEALLOCATE subordinate_cur
	  end
  	
	  insert into bookcomments select * from #bookcomments

      IF @v_columnname = 'commentstring'
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 4 
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN
		    
		    -- Skip writing to titlehistory if override propagation indicator is set for this comment - comment was not propagated
        SELECT @v_count = COUNT(*) 
        FROM bookcomments
        WHERE bookkey = @v_bookkey_copy_to AND 
          commenttypecode = 4 AND 
          commenttypesubcode = @v_commentypesubcode AND 
          COALESCE(overridepropagationind,0) = 1
          
        IF @v_count > 0
        BEGIN
          FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
          CONTINUE
        END 

			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,4) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)


			   EXECUTE sp_executesql @v_sqlstring, 
					   N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT

                SET @v_value_item = REPLACE(@v_value_item, '&amp;', '&')
                SET @v_value_item = REPLACE(@v_value_item, '''''', '''')

                SELECT @FieldDescDetail = COALESCE(datadescshort,datadesc)
                  FROM subgentables
                WHERE tableid = 284 
                    AND datacode = 4
                    AND datasubcode = @v_commentypesubcode
                          
               IF @FieldDescDetail IS NOT NULL
               BEGIN
                    SET @FieldDescDetail = '(T) ' + @FieldDescDetail
               END

               SELECT @v_count = 0

               SELECT @v_count = count(*)
                  FROM titlehistory
                WHERE bookkey = @v_bookkey_copy_to
                     AND columnkey = 70
                     AND fielddesc = @FieldDescDetail
                     AND currentstringvalue = SUBSTRING(@v_value_item, 1, 255)

               IF @v_count = 0 
               BEGIN
				   --IF @v_value_item is not null AND @v_value_item <> '' begin
               	    exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 1, null,
					    @v_value_item, 'UPDATE', @v_user_name, 4, @FieldDescDetail, @o_error_code, @o_error_desc
            	  --	 end
			  END

			  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END
		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
      
	  IF @v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 4 
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN

			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,4) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)

			  EXECUTE sp_executesql @v_sqlstring, N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT
                                                    
            	  exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			  		  @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
  			

			  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END
		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
  end


  if @v_tablename = 'bookcomments' and (@v_columndescription = 'Marketing Notes' OR (@v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1)) begin
	  delete from #bookcomments
	  delete from @subord_table
  	
	  --remember the releasetoeloquenceind in the subord table being copied to so you can set them back after they are replaced
	  INSERT @subord_table
	  SELECT commenttypesubcode, releasetoeloquenceind
	  FROM bookcomments
	  WHERE bookkey = @v_bookkey_copy_to
		  AND commenttypecode = 1
		  AND commenttypesubcode IN (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 1)
  	
	  delete from bookcomments
	  where bookkey = @v_bookkey_copy_to
	  and commenttypecode = 1
	  and commenttypesubcode in (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 1)
	  and COALESCE(overridepropagationind,0) = 0
	  
	  insert into #bookcomments
	  select bookkey, printingkey, commenttypecode, commenttypesubcode, commentstring, commenttext, lastuserid,
			 lastmaintdate, releasetoeloquenceind, commenthtml, commenthtmllite, invalidhtmlind, overridepropagationind 
	  from bookcomments a where a.bookkey = @v_bookkey_copy_from and a.commenttypecode = 1
      and not exists (select * from bookcomments b where b.bookkey = @v_bookkey_copy_to and 
                  a.commenttypecode = b.commenttypecode and 
                  a.commenttypesubcode = b.commenttypesubcode)	
                  
	  update #bookcomments set bookkey = @v_bookkey_copy_to
	  if @v_releasetoeloquenceind = 0 begin
		  update #bookcomments set releasetoeloquenceind = 0
  		
		  DECLARE subordinate_cur	CURSOR FOR
		  SELECT *
		  FROM @subord_table
  		
		  OPEN subordinate_cur
  		
		  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
  		
		  WHILE (@@FETCH_STATUS <> -1)
		  BEGIN
			  UPDATE #bookcomments 
			  SET releasetoeloquenceind = @v_subord_releasetoeloquenceind
			  WHERE commenttypesubcode = @v_subord_commenttypesubcode
  			
			  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
		  END
		  CLOSE subordinate_cur
		  DEALLOCATE subordinate_cur
	  end
  	
	  insert into bookcomments select * from #bookcomments

       IF @v_columnname = 'commentstring'
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 1 
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN

		    -- Skip writing to titlehistory if override propagation indicator is set for this comment - comment was not propagated
        SELECT @v_count = COUNT(*) 
        FROM bookcomments
        WHERE bookkey = @v_bookkey_copy_to AND 
          commenttypecode = 1 AND 
          commenttypesubcode = @v_commentypesubcode AND 
          COALESCE(overridepropagationind,0) = 1
          
        IF @v_count > 0
        BEGIN
          FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
          CONTINUE
        END
        
			  SET @v_value_item = ''
			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,1) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)


			   EXECUTE sp_executesql @v_sqlstring, 
					   N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT

                SET @v_value_item = REPLACE(@v_value_item, '&amp;', '&')
                SET @v_value_item = REPLACE(@v_value_item, '''''', '''')

                SELECT @FieldDescDetail = COALESCE(datadescshort,datadesc)
                  FROM subgentables
                WHERE tableid = 284 
                    AND datacode = 1
                    AND datasubcode = @v_commentypesubcode
                          
               IF @FieldDescDetail IS NOT NULL
               BEGIN
                    SET @FieldDescDetail = '(M) ' + @FieldDescDetail
               END

               SELECT @v_count = 0

               SELECT @v_count = count(*)
                  FROM titlehistory
                WHERE bookkey = @v_bookkey_copy_to
                     AND columnkey =260
                     AND fielddesc = @FieldDescDetail
                     AND currentstringvalue = SUBSTRING(@v_value_item, 1, 255)
  		
                IF @v_count = 0 
                 BEGIN
		  --		 IF @v_value_item is not null AND @v_value_item <> '' begin
					    exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 1, null,
						    @v_value_item, 'UPDATE', @v_user_name, 1, @FieldDescDetail, @o_error_code, @o_error_desc
		  --		end
			   END

  	
			   FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END

		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
      IF @v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 1
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN

			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,4) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)

			  EXECUTE sp_executesql @v_sqlstring, N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT
                                                    
            	  exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			  		  @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
  			

			  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END
		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
  end

  if @v_tablename = 'bookcomments' and (@v_columndescription = 'Editorial Notes'  OR (@v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1)) begin
	  delete from #bookcomments
	  delete from @subord_table
  	
	  --remember the releasetoeloquenceind in the subord table being copied to so you can set them back after they are replaced
	  INSERT @subord_table
	  SELECT commenttypesubcode, releasetoeloquenceind
	  FROM bookcomments
	  WHERE bookkey = @v_bookkey_copy_to
		  AND commenttypecode = 3
		  AND commenttypesubcode IN (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 3)
  	
	  delete from bookcomments
	  where bookkey = @v_bookkey_copy_to
	  and commenttypecode = 3
	  and commenttypesubcode in (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 3)
	  and COALESCE(overridepropagationind,0) = 0
	  
	  insert into #bookcomments
	  select bookkey, printingkey, commenttypecode, commenttypesubcode, commentstring, commenttext, lastuserid,
			 lastmaintdate, releasetoeloquenceind, commenthtml, commenthtmllite, invalidhtmlind, overridepropagationind 
	  from bookcomments a where a.bookkey = @v_bookkey_copy_from and a.commenttypecode = 3
      and not exists (select * from bookcomments b where b.bookkey = @v_bookkey_copy_to and 
                  a.commenttypecode = b.commenttypecode and 
                  a.commenttypesubcode = b.commenttypesubcode)
                  	  
	  update #bookcomments set bookkey = @v_bookkey_copy_to
	  if @v_releasetoeloquenceind = 0 begin
		  update #bookcomments set releasetoeloquenceind = 0
  		
		  DECLARE subordinate_cur	CURSOR FOR
		  SELECT *
		  FROM @subord_table
  		
		  OPEN subordinate_cur
  		
		  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
  		
		  WHILE (@@FETCH_STATUS <> -1)
		  BEGIN
			  UPDATE #bookcomments 
			  SET releasetoeloquenceind = @v_subord_releasetoeloquenceind
			  WHERE commenttypesubcode = @v_subord_commenttypesubcode
  			
			  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
		  END
		  CLOSE subordinate_cur
		  DEALLOCATE subordinate_cur
	  end

    insert into bookcomments select * from #bookcomments

      IF @v_columnname = 'commentstring'
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 3 
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN

		    -- Skip writing to titlehistory if override propagation indicator is set for this comment - comment was not propagated
        SELECT @v_count = COUNT(*) 
        FROM bookcomments
        WHERE bookkey = @v_bookkey_copy_to AND 
          commenttypecode = 3 AND 
          commenttypesubcode = @v_commentypesubcode AND 
          COALESCE(overridepropagationind,0) = 1
          
        IF @v_count > 0
        BEGIN
          FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
          CONTINUE
        END
        
			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,3) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)


			   EXECUTE sp_executesql @v_sqlstring, 
					   N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT

                SET @v_value_item = REPLACE(@v_value_item, '&amp;', '&')
                SET @v_value_item = REPLACE(@v_value_item, '''''', '''')

                SELECT @FieldDescDetail = COALESCE(datadescshort,datadesc)
                  FROM subgentables
                WHERE tableid = 284 
                    AND datacode = 3
                    AND datasubcode = @v_commentypesubcode
                      
               IF @FieldDescDetail IS NOT NULL
               BEGIN
                    SET @FieldDescDetail = '(E) ' + @FieldDescDetail
               END
               
               IF EXISTS(SELECT * FROM subgentables WHERE tableid = 284 AND qsicode = 7) BEGIN
				  SELECT @v_datacode_generatedauthorbio = datacode,  @v_datasubcode_generatedauthorbio = datasubcode
				  FROM subgentables WHERE tableid = 284 AND qsicode = 7                    
	                                    
				  IF @v_datacode_generatedauthorbio = 3 AND @v_commentypesubcode = @v_datasubcode_generatedauthorbio
				  BEGIN
				    SET @FieldDescDetail = '(G) ' + @FieldDescDetail
				  END
               END                 

                SELECT @v_count = 0

               SELECT @v_count = count(*)
                  FROM titlehistory
                WHERE bookkey = @v_bookkey_copy_to
                     AND columnkey =261
                     AND fielddesc = @FieldDescDetail
                     AND currentstringvalue = SUBSTRING(@v_value_item, 1, 255)
  		
                IF @v_count = 0
                BEGIN
				   --IF @v_value_item is not null AND @v_value_item <> '' begin
					    exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 1, null,
						    @v_value_item, 'UPDATE', @v_user_name, 3, @FieldDescDetail, @o_error_code, @o_error_desc
				  --	 end
  			  END

  	
			   FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END

		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
	  IF @v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 3 
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN

			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,3) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)

			  EXECUTE sp_executesql @v_sqlstring, N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT
                                                    
           	  exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			  		  @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
  			
			  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END
		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
  end

  if @v_tablename = 'bookcomments' and (@v_columndescription = 'Publicity Notes'  OR (@v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1)) begin
	  delete from #bookcomments
	  delete from @subord_table
  	
	  --remember the releasetoeloquenceind in the subord table being copied to so you can set them back after they are replaced
	  INSERT @subord_table
	  SELECT commenttypesubcode, releasetoeloquenceind
	  FROM bookcomments
	  WHERE bookkey = @v_bookkey_copy_to
		  AND commenttypecode = 5
		  AND commenttypesubcode IN (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 5)
  	
	  delete from bookcomments
	  where bookkey = @v_bookkey_copy_to
	  and commenttypecode = 5
	  and commenttypesubcode in (select commenttypesubcode from bookcomments where bookkey = @v_bookkey_copy_from and commenttypecode = 5)
	  and COALESCE(overridepropagationind,0) = 0
	  
	  insert into #bookcomments
	  select bookkey, printingkey, commenttypecode, commenttypesubcode, commentstring, commenttext, lastuserid,
			 lastmaintdate, releasetoeloquenceind, commenthtml, commenthtmllite, invalidhtmlind, overridepropagationind
	  from bookcomments a where a.bookkey = @v_bookkey_copy_from and a.commenttypecode = 5
      and not exists (select * from bookcomments b where b.bookkey = @v_bookkey_copy_to and 
                  a.commenttypecode = b.commenttypecode and 
                  a.commenttypesubcode = b.commenttypesubcode)
                  	  
	  update #bookcomments set bookkey = @v_bookkey_copy_to
	  if @v_releasetoeloquenceind = 0 begin
		  update #bookcomments set releasetoeloquenceind = 0
  		
		  DECLARE subordinate_cur	CURSOR FOR
		  SELECT *
		  FROM @subord_table
  		
		  OPEN subordinate_cur
  		
		  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
  		
		  WHILE (@@FETCH_STATUS <> -1)
		  BEGIN
			  UPDATE #bookcomments 
			  SET releasetoeloquenceind = @v_subord_releasetoeloquenceind
			  WHERE commenttypesubcode = @v_subord_commenttypesubcode
  			
			  FETCH NEXT FROM subordinate_cur INTO @v_subord_commenttypesubcode, @v_subord_releasetoeloquenceind
		  END
		  CLOSE subordinate_cur
		  DEALLOCATE subordinate_cur
	  end
  	
	  insert into bookcomments select * from #bookcomments

      IF @v_columnname = 'commentstring'
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 5 
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN

		    -- Skip writing to titlehistory if override propagation indicator is set for this comment - comment was not propagated
        SELECT @v_count = COUNT(*) 
        FROM bookcomments
        WHERE bookkey = @v_bookkey_copy_to AND 
          commenttypecode = 5 AND 
          commenttypesubcode = @v_commentypesubcode AND 
          COALESCE(overridepropagationind,0) = 1
          
        IF @v_count > 0
        BEGIN
          FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
          CONTINUE
        END
        
			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,5) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)


			   EXECUTE sp_executesql @v_sqlstring, 
					   N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT

                SET @v_value_item = REPLACE(@v_value_item, '&amp;', '&')
                SET @v_value_item = REPLACE(@v_value_item, '''''', '''')

                SELECT @FieldDescDetail = COALESCE(datadescshort,datadesc)
                  FROM subgentables
                WHERE tableid = 284 
                    AND datacode = 5
                    AND datasubcode = @v_commentypesubcode
                          
               IF @FieldDescDetail IS NOT NULL
               BEGIN
                    SET @FieldDescDetail = '(P) ' + @FieldDescDetail
               END

               SELECT @v_count = 0

               SELECT @v_count = count(*)
                  FROM titlehistory
                WHERE bookkey = @v_bookkey_copy_to
                     AND columnkey =262
                     AND fielddesc = @FieldDescDetail
                     AND currentstringvalue = SUBSTRING(@v_value_item, 1, 255)
  		
                IF @v_count = 0
                BEGIN
				   --IF @v_value_item is not null AND @v_value_item <> '' begin
					    exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 1, null,
						    @v_value_item, 'UPDATE', @v_user_name, 5, @FieldDescDetail, @o_error_code, @o_error_desc
				   --end
			  END

  	
			   FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END
		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
      IF @v_columnname = 'releasetoeloquenceind' AND @v_releasetoeloquenceind = 1
      BEGIN
		   DECLARE bookcomments_cur CURSOR FOR
			  select commenttypesubcode
			  from bookcomments
			   where bookkey = @v_bookkey_copy_from and commenttypecode = 5 
  	
		  open bookcomments_cur
		  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN

			  SET @v_sqlstring = N'SELECT @p_value_char = ' + @v_columnname + 
			    ' FROM ' + @v_tablename +
			    ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_bookkey_copy_from) + ' AND commenttypecode = ' +  CONVERT(VARCHAR,5) + ' AND commenttypesubcode = ' + CONVERT(VARCHAR,@v_commentypesubcode)

			  EXECUTE sp_executesql @v_sqlstring, N'@p_value_char VARCHAR(4000) OUTPUT', @v_value_item OUTPUT
                                                    
            	  exec qtitle_update_titlehistory @v_tablename, @v_columnname, @v_bookkey_copy_to, 0, null,
			  		  @v_value_item, 'UPDATE', @v_user_name, null, null, @o_error_code, @o_error_desc
  			
			  FETCH NEXT FROM bookcomments_cur into @v_commentypesubcode
		  END
		  close bookcomments_cur
		  deallocate bookcomments_cur
      END
  end


  if @v_tablename = 'bookcategory' begin
	  delete from #bookcategory
	  delete from bookcategory
	  where bookkey = @v_bookkey_copy_to
	  insert into #bookcategory select * from bookcategory where bookkey = @v_bookkey_copy_from 
	  update #bookcategory set bookkey = @v_bookkey_copy_to
	  insert into bookcategory select * from #bookcategory
  end

  if @v_tablename = 'booksubjectcategory' begin
	  delete from #booksubjectcategory
	  delete from booksubjectcategory
	  where bookkey = @v_bookkey_copy_to
	  insert into #booksubjectcategory select * from booksubjectcategory where bookkey = @v_bookkey_copy_from 
	  update #booksubjectcategory set bookkey = @v_bookkey_copy_to
	  insert into booksubjectcategory select * from #booksubjectcategory
  end


  IF @v_tablename = 'taqprojecttask' and @v_columnname = 'taqtaskkey' BEGIN
    IF @v_websched_option = 1 begin

      --update any rows that exist on both the primary and the subordinate title (delete and insert)
      DELETE FROM #taqprojecttask

      DECLARE @datetypecode_table TABLE
        (datetypecode	INT,
         taqtaskkey    INT)

      INSERT @datetypecode_table
      SELECT datetypecode, taqtaskkey
      FROM taqprojecttask
      WHERE bookkey = @v_bookkey_copy_to
        AND keyind = 1
        AND datetypecode in (select datetypecode from taqprojecttask where bookkey = @v_bookkey_copy_from and printingkey = 1 and keyind = 1)
      ORDER BY datetypecode ASC

      DECLARE datetypecode_cur CURSOR FOR
        SELECT datetypecode, taqtaskkey
        FROM @datetypecode_table

      OPEN datetypecode_cur
  
      FETCH NEXT FROM datetypecode_cur into @v_datetypecode, @v_taqtaskkey
  
      WHILE (@@FETCH_STATUS <> -1) BEGIN
        DELETE FROM taqprojecttask 
        WHERE bookkey = @v_bookkey_copy_to AND keyind = 1 AND datetypecode = @v_datetypecode AND taqtaskkey = @v_taqtaskkey
        
        SELECT @v_count = COUNT(*) FROM #TempDateTypeCode WHERE datetypecode = @v_datetypecode
        IF @v_count = 0 BEGIN
          INSERT INTO #TempDateTypeCode (datetypecode) VALUES (@v_datetypecode)	 

          insert into #taqprojecttask 
          select * from taqprojecttask 
          where bookkey = @v_bookkey_copy_from and printingkey = 1 and keyind = 1 
            and datetypecode = @v_datetypecode AND taqtaskkey NOT IN (select taqtaskkey FROM #TempInsertedTaskKey)

          update #taqprojecttask set bookkey = @v_bookkey_copy_to

          select @v_count = count (*) from #taqprojecttask

          IF @v_count > 0 BEGIN
            DECLARE #taqprojecttask_cur CURSOR FOR
              SELECT  taqtaskkey
              FROM #taqprojecttask
          
            OPEN #taqprojecttask_cur
          
            FETCH NEXT FROM #taqprojecttask_cur into @v_taqtaskkey_temp
          
            WHILE (@@FETCH_STATUS <> -1) BEGIN
              IF NOT EXISTS(SELECT * FROM taqprojecttask WHERE taqtaskkey = @v_taqtaskkey) BEGIN
                insert into taqprojecttask 
                select @v_taqtaskkey, taqprojectkey, taqelementkey, bookkey, orgentrykey, globalcontactkey , rolecode, globalcontactkey2,  rolecode2,
                scheduleind, stagecode, duration, datetypecode, activedate, actualind, keyind, originaldate, taqtasknote, decisioncode, 
                paymentamt, taqtaskqty, sortorder, taqprojectformatkey, lockind, lastuserid, lastmaintdate, printingkey, transactionkey,
                cseventid, reviseddate, startdate, startdateactualind, lag, qsilastuserid, qsilastmaintdate, qsijobkey
                FROM #taqprojecttask 
                WHERE taqtaskkey = @v_taqtaskkey_temp

                INSERT INTO #TempInsertedTaskKey (taqtaskkey) values (@v_taqtaskkey_temp)
              END
  
              FETCH NEXT FROM #taqprojecttask_cur into @v_taqtaskkey_temp
            END
            
            CLOSE #taqprojecttask_cur
            DEALLOCATE #taqprojecttask_cur
          END --IF @v_count > 0 (#taqprojecttask)
          
          delete from #taqprojecttask
        END	--IF @v_count = 0 (#TempDateTypeCode)
        
        FETCH NEXT FROM datetypecode_cur into @v_datetypecode, @v_taqtaskkey
      END --WHILE
      
      CLOSE datetypecode_cur
      DEALLOCATE datetypecode_cur

      delete from #TempDateTypeCode
      delete from #TempInsertedTaskKey  
      delete from #taqprojecttask

      -- insert any rows from primary title not on the subordinate title
      DECLARE taqprojecttask_cur CURSOR FOR
        SELECT datetypecode
        FROM taqprojecttask 
        WHERE bookkey = @v_bookkey_copy_from and printingkey = 1 and keyind = 1 
          and datetypecode NOT IN (select datetypecode from taqprojecttask where bookkey = @v_bookkey_copy_to and printingkey = 1 and keyind = 1)
        ORDER BY datetypecode ASC

      OPEN taqprojecttask_cur
        
      FETCH NEXT FROM taqprojecttask_cur into @v_datetypecode
  
      WHILE (@@FETCH_STATUS <> -1) BEGIN
        SELECT @v_count = COUNT(*) FROM #TempDateTypeCode WHERE datetypecode = @v_datetypecode
                
        insert into #taqprojecttask 
        select * from taqprojecttask 
        where bookkey = @v_bookkey_copy_from and printingkey = 1 and keyind = 1 and datetypecode = @v_datetypecode

        update #taqprojecttask set bookkey = @v_bookkey_copy_to
  
        select @v_count = COUNT(*) from #taqprojecttask

        IF @v_count > 0 BEGIN
          DECLARE #taqprojecttask_cur CURSOR FOR
            SELECT taqtaskkey
            FROM #taqprojecttask
            
          OPEN #taqprojecttask_cur
          
          FETCH NEXT FROM #taqprojecttask_cur into @v_taqtaskkey_temp
                    
          WHILE (@@FETCH_STATUS <> -1) BEGIN
            IF (@v_bookkey_copy_to IS NOT NULL AND @v_bookkey_copy_to > 0 AND @v_datetypecode IS NOT NULL) BEGIN
              exec dbo.qutl_check_for_restrictions @v_datetypecode, @v_bookkey_copy_to, 1, NULL, NULL, NULL, NULL, 
                @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
              IF @o_error_code <> 0 BEGIN
                SET @o_error_code = -1
                SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
                RETURN
              END
            END

            IF @o_returncode = 2 BEGIN
              DELETE FROM taqprojecttask WHERE taqtaskkey = @o_taqtaskkey
              IF EXISTS (SELECT * FROM taqprojecttaskoverride WHERE taqtaskkey  = @o_taqtaskkey) BEGIN
                DELETE FROM taqprojecttaskoverride WHERE taqtaskkey = @o_taqtaskkey 
              END
              SET @o_returncode = 0
            END 

            IF @o_returncode = 0 BEGIN
              execute get_next_key 'qsidba', @v_next_key output
              insert into taqprojecttask 
              select @v_next_key, taqprojectkey, taqelementkey, bookkey, orgentrykey, globalcontactkey , rolecode, globalcontactkey2,  rolecode2,
                scheduleind, stagecode, duration, datetypecode, activedate, actualind, keyind, originaldate, taqtasknote, decisioncode, 
                paymentamt, taqtaskqty, sortorder, taqprojectformatkey, lockind, lastuserid, lastmaintdate, printingkey, transactionkey,
                cseventid, reviseddate, startdate, startdateactualind, lag, qsilastuserid, qsilastmaintdate, qsijobkey
              FROM #taqprojecttask WHERE taqtaskkey = @v_taqtaskkey_temp
            END
            
            FETCH NEXT FROM #taqprojecttask_cur into @v_taqtaskkey_temp
          END --WHILE #taqprojecttask_cur)
          
          CLOSE #taqprojecttask_cur
          DEALLOCATE #taqprojecttask_cur
        END --IF @v_count > 0 (#taqprojecttask)

        delete from #taqprojecttask

        FETCH NEXT FROM taqprojecttask_cur into @v_datetypecode
      END --WHILE (taqprojecttask_cur)
      
      CLOSE taqprojecttask_cur
      DEALLOCATE taqprojecttask_cur

      delete from #TempDateTypeCode
    END --IF @v_websched_option = 1
  END --IF @v_tablename = 'taqprojecttask' and @v_columnname = 'taqtaskkey'

  IF @v_tablename = 'bookkeywords' BEGIN
	DELETE FROM bookkeywords
	WHERE bookkey = @v_bookkey_copy_to
	
	INSERT INTO bookkeywords
	(bookkey, keyword, sortorder, lastuserid, lastmaintdate)
	SELECT @v_bookkey_copy_to, keyword, sortorder, lastuserid, lastmaintdate
	FROM bookkeywords
	WHERE bookkey = @v_bookkey_copy_from
  END

  FETCH NEXT FROM titlehistorycolumns_cur into @v_tablename, @v_columnname, @v_datatype, @v_columndescription, @v_columnkey
END

close titlehistorycolumns_cur
deallocate titlehistorycolumns_cur

DROP TABLE #TempDateTypeCode
DROP TABLE #TempInsertedTaskKey
DROP TABLE #TempBookAuthorKeys

IF ((@i_tablename is not null and ltrim(rtrim(@i_tablename)) <> '') AND
    (@i_columnname is not null and ltrim(rtrim(@i_columnname)) <> '')) BEGIN
	IF @v_autoverifytitle = 1 BEGIN
	  exec qtitle_auto_verify_title @v_bookkey_copy_to,1,@v_user_name, @o_error_code, @o_error_desc
	END
END

END
go
GRANT EXECUTE ON dbo.copy_work_info TO PUBLIC
GO