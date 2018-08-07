SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.TMM_to_Artesia_Verify_Title') and (type = 'P' or type = 'RF'))
begin
 drop proc TMM_to_Artesia_Verify_Title 
end
go

create PROCEDURE dbo.TMM_to_Artesia_Verify_Title
		     @i_bookkey int,
		     @i_printingkey int,
		     @i_verificationtypecode int,
		     @i_username varchar(15)

AS

/* 
Verify existance of fields needed in Artesia
*/

DECLARE 
  @v_active_date datetime,
  @v_subgen1ind int,
  @v_datatypecode int,
  @v_datacode int,
  @v_Error int,
  @v_Warning int,
  @v_Information int,
  @v_Aborted int,
  @v_Completed int,
  @v_title varchar(255),
  @v_cnt int,
  @v_ean  varchar(50),
  @v_mediatypecode int,
  @v_mediatypesubcode int,
  @v_bestdate datetime,
  @v_numericdesc1 float,
  @v_nextkey int,
  @v_varnings int,
  @v_failed int,
  @v_bisac_status_code int,
  @i_write_msg int,
  @v_count int,
  @v_count2 int,
  @v_titletypecode int,
  @v_digitalshortrun varchar(255),
  @v_revisionlevel varchar(255)

BEGIN 
  -- init variables
  set @v_Error = 2
  set @v_Warning = 3
  set @v_Information = 4
  set @v_Aborted = 5
  set @v_Completed = 6
  set @v_failed = 0 
  set @v_varnings = 0 

  --clean bookverificationmessager for passed bookkey
  delete bookverificationmessage
  where bookkey = @i_bookkey
  and verificationtypecode = @i_verificationtypecode

  --check for titlefrefix, mediatypecode, mediatypesubcode
  select @v_mediatypecode = COALESCE(mediatypecode,0), @v_mediatypesubcode = COALESCE(mediatypesubcode,0),
         @v_bisac_status_code = COALESCE(bisacstatuscode,0)
    from bookdetail
   where bookkey = @i_bookkey

  -- Bisac Status
  if @v_bisac_status_code = 0  begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing BISAC Status Code',@i_username, getdate() )
	  set @v_failed = 1
  end 

  if @v_mediatypecode = 0 begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Media',@i_username, getdate() )
	  set @v_failed = 1
  end

  if @v_mediatypesubcode = 0 begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Book Format',@i_username, getdate() )
	  set @v_failed = 1
  end

  --check for title, titletypecode
  select @v_title = ltrim(rtrim(title)),@v_titletypecode = COALESCE(titletypecode,0)
  from book
  where bookkey = @i_bookkey
  if @v_title is null or  @v_title = '' begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Product Title',@i_username, getdate() )
	  set @v_failed = 1
  end
  if @v_titletypecode = 0 begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Product Type',@i_username, getdate() )
	  set @v_failed = 1
  end

  --check EAN
  select @v_ean = ltrim(rtrim(ean))
  from isbn 
  where bookkey = @i_bookkey

  if @v_ean is null or @v_ean = '' begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing EAN',@i_username, getdate() )
	  set @v_failed = 1
  end 

  --check for pub date 
  select @v_bestdate = bestdate
  from bookdates
  where bookkey = @i_bookkey
  and datetypecode = 8
  and printingkey = 1

  if @v_bestdate is null begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing PUB Date',@i_username, getdate() )
	  set @v_failed = 1
  end 

  --check for Bisac Subject 1
  select @v_cnt = count(bookkey)
  from bookbisaccategory
  where bookkey = @i_bookkey
  and printingkey = 1

  if @v_cnt = 0 begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing at least one BISAC Subject',@i_username, getdate() )
	  set @v_failed = 1
  end 

  --Imprint 
  select @v_cnt = count(bookkey)
  from bookorgentry
  where bookkey = @i_bookkey
  and orglevelkey in(select filterorglevelkey
		  from filterorglevel
		  where filterkey = 15)

  if @v_cnt = 0 begin
	  exec get_next_key @i_username, @v_nextkey out
	  insert into bookverificationmessage
	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Imprint',@i_username, getdate() )
	  set @v_failed = 1
  end
          
--  -- Digital Short Run (Misc field)   
--  SELECT @v_digitalshortrun = COALESCE(dbo.rpt_get_misc_value(@i_bookkey,48,''),'')
--  if @v_digitalshortrun is null OR @v_digitalshortrun='' begin
--	  exec get_next_key @i_username, @v_nextkey out
--	  insert into bookverificationmessage
--	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Digital Short Run',@i_username, getdate() )
--	  set @v_failed = 1
--  end
         
--  -- Revision Level (misc field)    
--  SELECT @v_revisionlevel = COALESCE(dbo.rpt_get_misc_value(@i_bookkey,7,'long'),'')
--  if @v_revisionlevel is null OR @v_revisionlevel='' begin
--	  exec get_next_key @i_username, @v_nextkey out
--	  insert into bookverificationmessage
--	  values(@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Missing Revision Level',@i_username, getdate() )
--	  set @v_failed = 1
--  end
  
  --failed
  if @v_failed = 1 begin
	  select @v_datacode = datacode
	  from gentables 
	  where tableid = 513
	  and qsicode = 2
  	
	  update bookverification
	  set titleverifystatuscode = @v_datacode,
	         lastmaintdate = getdate(),
	         lastuserid = @i_username
	  where bookkey = @i_bookkey	
	  and verificationtypecode = @i_verificationtypecode
  end 

  --passed with warnings
  if @v_failed = 0 and @v_varnings = 1 begin
    select @v_datacode = datacode
    from gentables 
    where tableid = 513
    and qsicode = 4

	  update bookverification
	  set titleverifystatuscode = @v_datacode,
         lastmaintdate = getdate(),
         lastuserid = @i_username
 	  where bookkey = @i_bookkey
	  and verificationtypecode = @i_verificationtypecode
  end 

  --passed
  if @v_failed = 0 and @v_varnings = 0 begin
    select @v_datacode = datacode
    from gentables 
    where tableid = 513
    and qsicode = 3

	  update bookverification
	  set titleverifystatuscode = @v_datacode,
         lastmaintdate = getdate(),
         lastuserid = @i_username
	  where bookkey = @i_bookkey
	  and verificationtypecode = @i_verificationtypecode
  end 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.TMM_to_Artesia_Verify_Title TO PUBLIC
GO