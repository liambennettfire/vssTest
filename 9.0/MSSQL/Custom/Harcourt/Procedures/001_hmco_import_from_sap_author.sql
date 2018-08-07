/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_author]    Script Date: 12/10/2009 16:54:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_author]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_author]

/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_author]    */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jennifer Hurd
-- Create date: 12/10/09
-- =============================================
CREATE PROCEDURE [dbo].[hmco_import_from_SAP_author] 
	@i_bookkey int = 0, 
	@i_printingkey	int,
	@i_update_mode	char(1),
	@i_userid		varchar(30),
	@i_authortypecode	int,
	@i_authorkey	int,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output


AS
BEGIN

declare @v_error			int,
@v_rowcount			int,
@sortorder				int,
@authortypecode		int,
@authortype			varchar(40),
@authorkey			int,
@pathname2			varchar(255),
@primary			int,
@fielddesc			varchar(50),
@author				varchar(255)




--get datacode from gentables for filetype
--check if that datacode exists on filelocation for this bookkey/printing, get filelocationkey if exists
--if exists, check update mode
--	if update mode = A, update existing row with path & elo ind & write history
--	do nothing if mode = B
--if doesn't exist
--	count how many rows exist for that bookkey printing, across all types
--	increment that by 1 for sort order
--	generate new filelocationkey
--	insert new row, for A or B mode
--

select @authortypecode = datacode,
@authortype = datadesc
from gentables
where tableid = 134
and deletestatus = 'N'
and datacode = @i_authortypecode

if @authortypecode is null
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update bookauthor table.  Authortypecode value of '+convert(varchar(5),@i_authortypecode)+' not found.'
	RETURN
end

select @authorkey = globalcontactkey,
@author = substring(displayname,1,255)
from globalcontact
where globalcontactkey = @i_authorkey
and activeind = 1

if @authorkey is null
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update bookauthor table.  Authorkey value of '+convert(varchar(8),@i_authorkey)+' not found as an active author.'
	RETURN
end

select @authorkey = isnull(authorkey,0),
@authortypecode = isnull(authortypecode,0)
from bookauthor
where bookkey = @i_bookkey
and authortypecode = @i_authortypecode
and authorkey = @i_authorkey

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT

if @v_rowcount > 0		--same author already exists for this title with same authortype, no update needed
begin
	set @o_error_code = 0
	return
end

select @sortorder = max(isnull(sortorder,0))
from bookauthor
where bookkey = @i_bookkey

if @sortorder = 0 or @sortorder is null
	set @primary = 1
else
	set @primary = 0

select @sortorder = isnull(@sortorder,0) + 1
	
select @fielddesc = 'Author ' + convert(varchar(4),@sortorder)

insert into bookauthor
(bookkey,authorkey,authortypecode,reportind,primaryind,lastuserid,lastmaintdate,sortorder,history_order)
values (@i_bookkey, @i_authorkey, @i_authortypecode, 1, @primary, @i_userid, getdate(), @sortorder, @sortorder)

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to insert into bookauthor table.   Error #' + cast(@v_error as varchar(20))
	RETURN
END 

exec qtitle_update_titlehistory 'bookauthor', 'authorkey' , @i_bookkey, @i_printingkey, 0, @author, 'Insert', @i_userid, 
		@sortorder, @fielddesc , @o_error_code output, @o_error_desc output

exec qtitle_update_titlehistory 'bookauthor', 'authortypecode' , @i_bookkey, @i_printingkey, 0, @authortype, 'Insert', @i_userid, 
		@sortorder, ''  , @o_error_code output, @o_error_desc output

exec qtitle_update_titlehistory 'bookauthor', 'primaryind' , @i_bookkey, @i_printingkey, 0, @primary, 'Insert', @i_userid, 
		@sortorder, '' , @o_error_code output, @o_error_desc output

set nocount off

end
