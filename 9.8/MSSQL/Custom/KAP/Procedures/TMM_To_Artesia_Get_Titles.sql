IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMM_To_Artesia_Get_Titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TMM_To_Artesia_Get_Titles]
go

CREATE procedure [dbo].[TMM_To_Artesia_Get_Titles] 
 (@i_batchkey       integer,
  @i_jobkey         integer,
  @i_jobtypecode    integer,
  @i_jobtypesubcode integer,  
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

DECLARE
  @v_error int, 
  @v_error_desc varchar(2000),
  @v_rowcount int,
  @v_count int,
  @v_lastrundate datetime, 
	@v_messagetypecode int,
  @v_msg varchar(4000),
  @v_msgshort varchar(255),
  @v_num_titles int,
  @v_send_to_artesia_misckey int
  
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- checkbox to allow title to be sent to Artesia
  SET @v_send_to_artesia_misckey = 52
  
  IF (@i_batchkey > 0) BEGIN
    /* get endtime of build xml process from last batch */
    SELECT @v_count = count(*)
      FROM qsijob j
     WHERE j.jobtypecode = @i_jobtypecode AND 
           j.jobtypesubcode = @i_jobtypesubcode AND
           j.qsibatchkey <> @i_batchkey

    IF (@v_count > 0) BEGIN
      SELECT @v_lastrundate = max(j.stopdatetime)
        FROM qsijob j
       WHERE j.jobtypecode = @i_jobtypecode AND 
             j.jobtypesubcode = @i_jobtypesubcode AND
             j.qsibatchkey <> @i_batchkey
                
      --EXEC SYSDB.SSMA.db_error_exact_one_row_check @@ROWCOUNT 
    END
    ELSE BEGIN
      -- for now use 3 weeks as the last run date
      SET @v_lastrundate = getdate() - 21
    END

    -- make sure the TMMToArtesia_bookkeys table exists and is empty
    IF not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TMMToArtesia_bookkeys]') and OBJECTPROPERTY(id, N'IsUserTable') = 1) BEGIN
      create table [dbo].[TMMToArtesia_bookkeys] (bookkey int, title_xml xml)
    END
    ELSE BEGIN 
      truncate table [dbo].[TMMToArtesia_bookkeys]
    END

    -- find all the titles that changed since the last time the export was run and Send To Artesia flag set to true
    INSERT INTO TMMToArtesia_bookkeys (bookkey)
    SELECT DISTINCT bookkey
	    FROM book 
     WHERE upper(COALESCE(dbo.rpt_get_misc_value(bookkey,@v_send_to_artesia_misckey,''),'NO')) = 'YES'  -- checkbox to allow title to be sent to Artesia
        AND ((bookkey in (Select bookkey from titlehistory where lastmaintdate > @v_lastrundate))
        or (bookkey in (Select bookkey from associatedtitles where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from book where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from bookdetail where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from booksubjectcategory where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from printing where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from bookauthor where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from bookprice where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from bookdates where lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from bookauthor ba, globalcontact gc
		                     where ba.authorkey = gc.globalcontactkey and gc.lastmaintdate > @v_lastrundate))
		    or (bookkey in (Select bookkey from bookauthor ba, globalcontactmethod gcm
		                     where ba.authorkey = gcm.globalcontactkey and gcm.lastmaintdate > @v_lastrundate))
        or (bookkey in (Select bc.bookkey from bookcontactrole br, bookcontact bc
                         where br.bookcontactkey = bc.bookcontactkey and br.lastmaintdate > @v_lastrundate))
        or (bookkey in (Select s.key1 from gpo g, gposection s
                         where g.gpokey = s.gpokey and upper(ltrim(rtrim(g.gpostatus))) = 'F'
                           and s.lastmaintdate > @v_lastrundate))
        or (bookkey in (Select parentbookkey from bookfamily where lastmaintdate > @v_lastrundate)))
        
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error looking for titles that changed'
      /*  Error */
      SET @v_messagetypecode = 2
      SET @v_msg = 'Error looking for titles that changed'
      SET @v_msgshort = 'Error looking for titles that changed'
      EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
      return 
    END 
 
    -- return the number of titles
    SELECT @v_num_titles = count(*)
      FROM TMMToArtesia_bookkeys

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
      SET @v_num_titles = 0
      /*  Error */
      SET @v_messagetypecode = 2
      SET @v_msg = 'Error accessing TMMToArtesia_bookkeys'
      SET @v_msgshort = 'Error accessing TMMToArtesia_bookkeys'
      EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', 0, 0, 0, @v_messagetypecode, @v_msg, @v_msg, @v_error OUTPUT, @v_error_desc OUTPUT          
      return
    END 
    
    SET @o_error_code = @v_num_titles
  END
  ELSE BEGIN
    -- no batchkey 
    SET @o_error_code = -1
    SET @o_error_desc = 'Batchkey is empty'
    return
  END
END

grant execute on TMM_To_Artesia_Get_Titles  to public
go






