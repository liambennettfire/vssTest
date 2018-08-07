SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloschcommentsupdate_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloschcommentsupdate_sp]
GO



CREATE proc [dbo].eloschcommentsupdate_sp  @i_bookkey int

/*******************************************************/
/*	                                                 */        
/*	    Author   : CT                                */
/*	    Creation Date   : 2/6/03                     */
/*	    Comments : update comments**/
/*                                                     */
/*******************************************************/     


AS 
DECLARE @c_brief varchar (8000)




begin tran

/* brief description*/

select @c_brief=comment1 
from eloschcomments where bookkey=@i_bookkey
if @c_brief is not NULL or @c_brief <> ' '
begin
	/* delete old */
	delete from bookcomments where bookkey = @i_bookkey and printingkey = 1 and commenttypecode = 3 and commenttypesubcode = 7
	/* insert new */
	insert into bookcomments select bookkey,1,3,7,NULL,@c_brief,'elo_import',getdate(),1 
	from eloschcomments where bookkey = @i_bookkey
end

/* insert into bookcommentrtf so that proper HTML can be created */

if @c_brief is not NULL or @c_brief <> ' '
begin
	/* delete old */
	delete from bookcommentrtf where bookkey = @i_bookkey and printingkey = 1 and commenttypecode = 3 and commenttypesubcode = 7
	/* insert new */
	insert into bookcommentrtf select bookkey,1,3,7,NULL,@c_brief,'elo_import',getdate(),1 
	from eloschcomments where bookkey = @i_bookkey
end


commit tran

return 0





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO