SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elohendrixcommentsinsert_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elohendrixcommentsinsert_sp]
GO



CREATE proc [dbo].elohendrixcommentsinsert_sp  @i_bookkey int

/*******************************************************/
/*	                                                 */        
/*	    Author   : CT                                */
/*	    Creation Date   : 2/6/03                     */
/*	    Comments : insert comments**/
/*                                                     */
/*******************************************************/     


AS 
DECLARE @c_authorbio varchar (8000)
DECLARE @c_brief varchar (8000)
DECLARE @c_main varchar (8000)
DECLARE @c_quote varchar (8000)




begin tran

/* author bio */

select @c_authorbio=comment1 
from elohendrixcomments where bookkey=@i_bookkey
if @c_authorbio is not NULL or @c_authorbio <> ' '
begin
	
	/* insert new */
	insert into bookcomments select bookkey,1,3,10,NULL,@c_authorbio,'elo_import',getdate(),1 
	from elohendrixcomments where bookkey = @i_bookkey
end

/* brief description*/

select @c_brief=comment5 
from elohendrixcomments where bookkey=@i_bookkey
if @c_brief is not NULL or @c_brief <> ' '
begin
	
	/* insert new */
	insert into bookcomments select bookkey,1,3,7,NULL,@c_brief,'elo_import',getdate(),1 
	from elohendrixcomments where bookkey = @i_bookkey
end

/* main description */

select @c_main=comment6 
from elohendrixcomments where bookkey=@i_bookkey
if @c_main is not NULL or @c_main <> ' '
begin
	
	/* insert new */
	insert into bookcomments select bookkey,1,3,8,NULL,@c_main,'elo_import',getdate(),1 
	from elohendrixcomments where bookkey = @i_bookkey
end

/* quote 1*/

select @c_quote=comment7 
from elohendrixcomments where bookkey=@i_bookkey
if @c_quote is not NULL or @c_quote <> ' '
begin
	/* insert new */
	insert into bookcomments select bookkey,1,3,4,NULL,@c_quote,'elo_import',getdate(),1 
	from elohendrixcomments where bookkey = @i_bookkey
end

commit tran

return 0





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO