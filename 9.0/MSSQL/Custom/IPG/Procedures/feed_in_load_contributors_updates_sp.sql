if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_in_load_contributors_updates_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_in_load_contributors_updates_sp]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE procedure dbo.feed_in_load_contributors_updates_sp 
@i_bookkey int,@c_first_name varchar(100),@c_last_name varchar(100),@c_city varchar(100),
@c_state varchar(100),@i_author_type int,@i_ordernum int, @i_updateind int OUTPUT

AS

/*	IPG  CONTRIBUTOR ROUNTINE 			*/
/*									*/
/*	Loads the Contributors, in order per IPG's Request		*/


DECLARE @c_displayname		VARCHAR(100)
DECLARE @i_primaryind		INT
DECLARE @i_count_auth		INT
DECLARE @i_author_exists		INT
DECLARE @d_rundate	datetime
DECLARE @i_authorkey 	INT
DECLARE @i_statecode 	INT
DECLARE @c_authordesc varchar(100)


/*   The order the contributors in the contributor section is
			Author
			Editor
			Photographer
			Illustrator
			Introduction -- not here
			Preface
			Foreward
			Afterward
			Translator
			Other
*/	

select @d_rundate = getdate()

select @c_displayname = ''
select @c_authordesc = ''
select @i_primaryind = 0
select @i_statecode = 0


select @c_authordesc = datadesc from gentables
	where tableid=134 and datacode = @i_author_type

if @c_state is null 
  begin
	select @c_state = ''
 end
if len(@c_state) > 0
 begin
	select @i_count_auth = 0

	select @i_count_auth = count(*)
	  from gentables
		where rtrim(upper(datadesc) )= rtrim(upper(@c_state))
			and tableid=160

	if @i_count_auth > 0 
	 begin
		select @i_statecode  = datacode
		 from gentables
		 where rtrim(upper(datadesc) )= rtrim(upper(@c_state))
			and tableid=160 
	 end
	else
	  begin
	  	select @i_statecode = null
	  end
end

if @i_ordernum = 1 
  begin
	select @i_primaryind = 1
 end
else
 begin
	select @i_primaryind = null
 end

if @c_first_name is null
  begin
	select @c_first_name = ''
  end

if len(@c_first_name) > 0 
  begin
	select @c_displayname = substring(rtrim(ltrim(@c_last_name)),1,75) +', ' + substring(rtrim(ltrim(@c_first_name)),1,75)
  end
else
  begin
	select @c_displayname = substring(rtrim(ltrim(@c_last_name)) ,1,80)
  end

/* check if author exists  */
select @i_author_exists = 0

select @i_author_exists = count(*) from author
	where upper(rtrim(ltrim(lastname)))=substring(upper(rtrim(ltrim(@c_last_name))),1,75)
		and upper(rtrim(ltrim(firstname)))= substring(upper(rtrim(ltrim(@c_first_name))),1,75)
	
if @i_author_exists > 0 
  begin  /* make sure only 1 if more than 1 get min authorkey*/
	select @i_authorkey = min(authorkey)  from author
	where upper(rtrim(ltrim(lastname))) =  substring(upper(rtrim(ltrim(@c_last_name))),1,75)
		and upper(rtrim(ltrim(firstname)))= substring(upper(rtrim(ltrim(@c_first_name))),1,75)
  end
else
  begin
	if len(@c_first_name)> 0
 	  begin
		UPDATE keys SET generickey = generickey+1, 
		 lastuserid = 'QSIADMIN', 
			lastmaintdate = getdate()

			select @i_authorkey = generickey from Keys
	
		insert into author (authorkey,displayname,lastname,firstname,lastuserid,
		  lastmaintdate,city,statecode)
		values (@i_authorkey,substring(@c_displayname,1,80), substring(rtrim(ltrim(@c_last_name)),1,75),
		   substring(rtrim(ltrim(@c_first_name)),1,75),
		  'feedin',@d_rundate,substring(rtrim(ltrim(@c_city)),1,25),@i_statecode)

	  end
	else
	  begin
		select @i_authorkey = 0  /* NO FIRST NAME*/
	  end
  end		
			
/* now check if author already on bookauthor*/
select @i_count_auth = 0 

select @i_count_auth = count(*) from bookauthor
	where bookkey= @i_bookkey and authorkey = @i_authorkey

if @i_count_auth = 0 and @i_authorkey > 0
  begin

	select @i_updateind = 1

/*insert history only for new bookauthor row*/

	insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
		currentstringvalue,fielddesc)
	values (@i_bookkey,1,6,getdate(),'(Not Present)','feedin',@c_displayname,@c_authordesc + ' ' + convert(varchar (5),@i_ordernum))

	insert into bookauthor (bookkey,authorkey,authortypecode,primaryind,
	  authortypedesc,lastuserid,lastmaintdate,sortorder,history_order)
	values (@i_bookkey,@i_authorkey,@i_author_type,@i_primaryind,@c_authordesc,
		'feedin',@d_rundate,@i_ordernum,@i_ordernum)
 
  end

if @i_updateind is null
  begin  
	select @i_updateind = 0
  end

return @i_updateind

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO