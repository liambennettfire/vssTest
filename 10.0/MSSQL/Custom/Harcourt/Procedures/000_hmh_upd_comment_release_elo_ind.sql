/****** Object:  StoredProcedure [dbo].[hmh_upd_comment_release_elo_ind]    Script Date: 06/06/2011 17:38:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmh_upd_comment_release_elo_ind]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmh_upd_comment_release_elo_ind]

/****** Object:  StoredProcedure [dbo].[hmh_upd_comment_release_elo_ind]    Script Date: 06/06/2011 17:03:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************************************
**  Name: hmh_upd_comment_release_elo_ind
***************************************************************************************************
**  Change History
***************************************************************************************************
**  Date:        Author:      Description:
**  ----------  -----------   ---------------------------------------------------------------------
**  04/11/2018  Colman        Case 50682
***************************************************************************************************/

create procedure [dbo].[hmh_upd_comment_release_elo_ind]
as
begin

set nocount on

declare @userid  varchar(50),
@bookkey  int,
@fielddesc  varchar(50),
@commenttypecode  int,
@commenttypesubcode  int,
@o_error_code    int,
@o_error_desc    varchar(50)

set @userid = 'commentreleloupd'

declare comment_cur cursor for
  SELECT bc.bookkey, bc.commenttypecode, bc.commenttypesubcode
    FROM bookcomments bc
    JOIN coretitleinfo c on bc.bookkey = c.bookkey
    LEFT JOIN bookdetail bd ON bc.bookkey = bd.bookkey
    JOIN subgentables sg ON bc.commenttypecode = sg.datacode
     AND bc.commenttypesubcode = sg.datasubcode
     AND sg.tableid = 284
     AND sg.exporteloquenceind = 1
     AND sg.eloquencefieldtag is not null
     AND sg.eloquencefieldtag <> 'N/A'
     AND sg.eloquencefieldtag <> ''
    LEFT JOIN bookedistatus be ON bc.bookkey = be.bookkey AND be.edistatuscode not in (5, 6, 7, 8)
   WHERE c.bisacstatuscode in (1, 4)
     -- AND dbo.get_bookmisc_check(bc.bookkey,154) <> 'Yes' -- new miscitem checkbox
     AND (bc.releasetoeloquenceind is null or bc.releasetoeloquenceind = 0)
     order by bc.bookkey

OPEN comment_cur

FETCH NEXT FROM comment_cur INTO @bookkey, @commenttypecode, @commenttypesubcode

while (@@FETCH_STATUS = 0)
begin
  IF dbo.get_bookmisc_check(@bookkey, 154) = 'Yes' -- new miscitem checkbox
    AND (@commenttypecode = 3 AND @commenttypesubcode = 16)
  BEGIN
    FETCH NEXT FROM comment_cur INTO @bookkey, @commenttypecode, @commenttypesubcode
    CONTINUE
  END
  
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

  FETCH NEXT FROM comment_cur INTO @bookkey, @commenttypecode, @commenttypesubcode
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

END
