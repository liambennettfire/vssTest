/****** Object:  StoredProcedure [dbo].[author_match_author]    Script Date: 06/06/2011 17:38:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmh_upd_comment_release_elo_ind]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmh_upd_comment_release_elo_ind]

/****** Object:  StoredProcedure [dbo].[hmh_upd_comment_release_elo_ind]    Script Date: 06/06/2011 17:03:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

create procedure [dbo].[hmh_upd_comment_release_elo_ind]
as
begin

set nocount on

declare @userid	varchar(50),
@bookkey	int,
@i_cursor_status	int,
@fielddesc	varchar(50),
@commenttypecode	int,
@commenttypesubcode	int,
@o_error_code		int,
@o_error_desc		varchar(50)

set @userid = 'commentreleloupd'

declare comment_cur cursor for
select bc.bookkey, bc.commenttypecode, bc.commenttypesubcode
from bookcomments bc
join bookdetail bd
on bc.bookkey = bd.bookkey
join subgentables sg
on bc.commenttypecode = sg.datacode
and bc.commenttypesubcode = sg.datasubcode
and sg.tableid = 284
and sg.exporteloquenceind = 1
and sg.eloquencefieldtag is not null
and sg.eloquencefieldtag <> 'N/A'
and sg.eloquencefieldtag <> ''
left outer join bookedistatus be
on bc.bookkey = be.bookkey
and be.edistatuscode not in (5, 6, 7, 8)
where bisacstatuscode in (1, 4)
and (bc.releasetoeloquenceind is null or bc.releasetoeloquenceind = 0)
order by bc.bookkey

OPEN comment_cur

FETCH NEXT FROM comment_cur
INTO @bookkey, @commenttypecode, @commenttypesubcode

select @i_cursor_status = @@FETCH_STATUS

while (@i_cursor_status<>-1 )
begin
	select @fielddesc = '('+ substring(g.datadesc,1,1) + ') ' + sg.datadesc
	from gentables g
	join subgentables sg
	on g.tableid = sg.tableid
	and g.datacode = sg.datacode
	and g.tableid = 284
	where g.datacode = @commenttypecode
	and sg.datasubcode = @commenttypesubcode

	update bookcomments
	set releasetoeloquenceind = 1,
	lastmaintdate = getdate(),
	lastuserid = @userid
	where bookkey = @bookkey
	and commenttypecode = @commenttypecode
	and commenttypesubcode = @commenttypesubcode

	exec qtitle_update_titlehistory 'bookcomments', 'releasetoeloquenceind' , @bookkey, 1, 0, 1, 'Update', @userid, 
			1, @fielddesc, @o_error_code output, @o_error_desc output

	FETCH NEXT FROM comment_cur
	INTO @bookkey, @commenttypecode, @commenttypesubcode

        select @i_cursor_status = @@FETCH_STATUS

end /* End While Cursor*/

close comment_cur
deallocate comment_cur



update qsicomments
set releasetoeloquenceind = 1,
lastmaintdate = getdate(),
lastuserid = @userid
from qsicomments qc
join globalcontact gc
on qc.commentkey = gc.globalcontactkey
join gentables g
on qc.commenttypecode = g.datacode
and g.tableid = 528
and g.exporteloquenceind = 1
where commenttypecode = 2
and commenttypesubcode = 0
and (releasetoeloquenceind = 0 or releasetoeloquenceind is null)

end