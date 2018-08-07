USE [BDS_DEV]
GO
/****** Object:  StoredProcedure [dbo].[UpdFld_Util_AuthorKey_ByName]    Script Date: 06/20/2012 14:31:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[UpdFld_Util_AuthorKey_ByName]  -- get authorkey for given name parameters
(
@bookkey        int,
@orgentrykey    int,
@lastname       varchar(100),
@firstname      varchar(100),
@middlename     varchar(100),
@title          varchar(100),
@authorsuffix   varchar(100),
@authorkey      int output
--,@o_result_code  int output,          -- must be one of UpdFld_XVQ effect codes
--@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
)
AS
BEGIN

declare @count int
declare @specificity int

if OBJECT_ID('tempif_authors') is not null
	truncate table tempif_authors
else
	create table tempif_authors
	(
		authorkey int,
		suffix    varchar(30),
		title     varchar(30)
	)
	

insert	tempif_authors
select	authorkey,
		authorsuffix,
		title
from	author
where	    isnull(lastname,  '') = isnull(@lastname,'')
		and isnull(firstname, '') = isnull(@firstname,'')
		and isnull(middlename,'') = isnull(@middlename,'')


select	@count = count(*),
		@authorkey = max(authorkey)
from	tempif_authors

if @count = 0
	set @authorkey = 0
if @count <= 1
	RETURN


-- Need to refine search to narrow results


if OBJECT_ID('tempif_orgentry') is not null
	truncate table tempif_orgentry
else
	create table tempif_orgentry
	(
		authorkey     int,
		orgentrykey   int,
		orgentrylevel int
	)


insert	tempif_orgentry
select	authorkey,
		orgentrykey,
		orglevelkey
from	tempif_authors
		inner join globalcontactauthor on detailkey = authorkey
		inner join globalcontactorgentry on globalcontactkey = masterkey
where	orgentrykey = @orgentrykey
		and scopetag = 'contact' --'author'

--mk:2012.06.20> START
--	This routine used to return a -1 for @authorkey if the criteria couldn't resolve to just 1 author.
--	This is a problem for reports ... see netsuite CASE 19729 -1 in authorkey field in bookauthor table
--	To fix this I'm adding a query to return the lowest authorkey from the input list of keys ...
--	if the author can't be boiled down to 1 then use this defualt instead
--	search on 'set @authorkey = -1  -- ambiguous - could just return one of the matching authorkey's' to see what's happening

declare @MinAuthorKey INT
select @MinAuthorKey=min(authorkey) from tempif_orgentry
--mk:2012.06.20> END

set @specificity = 1  -- initialize how specific criteria to attempt matching on

while (1=1)
begin
	select	@count = count(*),
			@authorkey = max(authorkey)
	from	tempif_authors
	where	(
				@specificity = 1 and isnull(suffix,'') = isnull(@authorsuffix,'')
			)
			or
			(
				@specificity = 2 and isnull(title,'') = isnull(@title,'')
			)
			or
			(
				@specificity = 3 and isnull(title,'')  = isnull(@title,'')
				                 and isnull(suffix,'') = isnull(@authorsuffix,'')
			)
			or
			(
				@specificity = 4 and isnull(suffix,'') = isnull(@authorsuffix,'')
				                 and authorkey in (select authorkey from bookauthor where bookkey = @bookkey)
			)
			or
			(
				@specificity = 5 and isnull(title,'') = isnull(@title,'')
				                 and authorkey in (select authorkey from bookauthor where bookkey = @bookkey)
			)
			or
			(
				@specificity = 6 and isnull(title,'')  = isnull(@title,'')
				                 and isnull(suffix,'') = isnull(@authorsuffix,'')
				                 and authorkey in (select authorkey from bookauthor where bookkey = @bookkey)
			)
			or
			(
				@specificity = 7 and isnull(suffix,'') = isnull(@authorsuffix,'')
				                 and authorkey in (select authorkey from tempif_orgentry where orgentrykey = @orgentrykey)
				                 /*
				                 and
				                 (
				                     authorkey in (
				                                     select detailkey
				                                     from   globalcontactauthor
				                                            inner join globalcontactorgentry on globalcontactkey = masterkey
				                                     where  orgentrykey = @orgentrykey
				                                  )
				                 )
				                 */
			)
			or
			(
				@specificity = 8 and isnull(title,'') = isnull(@title,'')
				                 and authorkey in (select authorkey from tempif_orgentry where orgentrykey = @orgentrykey)
			)
			or
			(
				@specificity = 9 and isnull(title,'')  = isnull(@title,'')
				                 and isnull(suffix,'') = isnull(@authorsuffix,'')
				                 and authorkey in (select authorkey from tempif_orgentry where orgentrykey = @orgentrykey)
			)
			-- If you add a new specificity clause here, you need to adjust the max @specificity condition below for breaking out of the loop

	if @count = 1
		RETURN

	if @specificity >= 9 begin
		if @count > 1
			--set @authorkey = -1  -- ambiguous - could just return one of the matching authorkey's
			--mk:2012.06.20> START
			begin
				set @authorkey = @MinAuthorKey  -- ambiguous - return the lowest matching authorkey
			end 
			--mk:2012.06.20> END
		else
			set @authorkey = 0
		RETURN
	end
	
	set @specificity = @specificity + 1
end
END
