/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_associated_titles]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_associated_titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_associated_titles]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_associated_titles] 
	@i_bookkey int, 
	@i_userid   varchar(30),
	@associatedbookkey	int,
	@associationtypecode	int,
	@associationtypesubcode	int,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @count	int,
@sort	int,
@associsbn	varchar(20),
@v_error	varchar(2000),
@v_rowcount	int,
@releasetoelo	int,
@reciprocalsubcode	int,
@assocallowmulti	int,
@recipallowmulti	int,
@associationdesc	varchar(200),
@associationsubdesc	varchar(200)

if @i_bookkey = @associatedbookkey
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update associatedtitles table.  You cannot associate a title to itself.'
	RETURN
end

select @count = count(*)
from book
where bookkey = @associatedbookkey

if isnull(@count,0) = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update associatedtitles table.  Associated bookkey passed is not valid.'
	RETURN
end

set @count = 0

if isnull(@associationtypesubcode,0) = 0
begin
	select @count = count(*)
	from subgentables
	where tableid = 440
	and datacode = @associationtypecode

	if isnull(@count,0) > 0
	begin
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update associatedtitles table.  Association type passed requires a sub value.'
		RETURN
	end

	select @associationdesc = g.datadesc, @releasetoelo = g.gen2ind
	from gentables g
	where g.tableid = 440
	and g.datacode = @associationtypecode

	SELECT @count = @@ROWCOUNT

	if isnull(@count,0) = 0
	begin
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update associatedtitles table.  Values passed are not a valid combination.'
		RETURN
	end
end 
else
begin
	select @associationdesc = g.datadesc, @associationsubdesc = sg.datadesc, @releasetoelo = g.gen2ind
	from gentables g
	join subgentables sg
	on g.tableid = sg.tableid
	and g.datacode = sg.datacode
	where g.tableid = 440
	and g.datacode = @associationtypecode
	and sg.datasubcode = @associationtypesubcode

	SELECT @count = @@ROWCOUNT

	if isnull(@count,0) = 0
	begin
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update associatedtitles table.  Values passed are not a valid combination.'
		RETURN
	end

	select @reciprocalsubcode = b.datasubcode, @assocallowmulti = a.subgen1ind, @recipallowmulti = b.subgen1ind
	from subgentables a
	left outer join subgentables b
	on a.tableid = b.tableid
	and a.datacode = b.datacode
	and a.numericdesc1 = b.bisacdatacode
	where a.tableid = 440
	and a.datacode = @associationtypecode
	and a.datasubcode = @associationtypesubcode

	if isnull(@assocallowmulti,0) = 0
	begin
		select @count = count(*)
		from associatedtitles
		where bookkey = @i_bookkey
		and associationtypecode = @associationtypecode
		and associationtypesubcode = @associationtypesubcode
		and associatetitlebookkey <> @associatedbookkey

		if isnull(@count,0) > 0
		begin
			SET @o_error_code = -2
			SET @o_error_desc = 'Unable to update associatedtitles table.  An association of that type already exists on this title and there can only be one.'
			RETURN
		END 
	end

	if @reciprocalsubcode > 0 and isnull(@recipallowmulti,0) = 0
	begin
		select @count = count(*)
		from associatedtitles
		where bookkey = @associatedbookkey
		and associationtypecode = @associationtypecode
		and associationtypesubcode = @reciprocalsubcode
		and associatetitlebookkey <> @i_bookkey

		if isnull(@count,0) > 0
		begin
			SET @o_error_code = -2
			SET @o_error_desc = 'Unable to update associatedtitles table.  An association of the reciprocal type already exists on the associated title and there can only be one.'
			RETURN
		END 
	end

end

exec hmco_import_from_SAP_insert_association @i_bookkey, @i_userid, @associatedbookkey, @associationtypecode,	
		@associationtypesubcode, @releasetoelo,	@associationdesc, @associationsubdesc, @o_error_code output, @o_error_desc output

IF @o_error_code < 0 BEGIN
	return
end


if @reciprocalsubcode > 0
begin
	exec hmco_import_from_SAP_insert_association @associatedbookkey, @i_userid, @i_bookkey,	@associationtypecode,
		@reciprocalsubcode,	@releasetoelo, @associationdesc, @associationsubdesc, @o_error_code output,	@o_error_desc output
end

IF @o_error_code < 0 BEGIN
	return
end

end