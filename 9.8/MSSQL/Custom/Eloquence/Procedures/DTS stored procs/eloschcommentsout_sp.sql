SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloschcommentsout_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloschcommentsout_sp]
GO



CREATE proc [dbo].eloschcommentsout_sp 



/*******************************************************/
/*	                                                 */        
/*	    Author   : CT                                */
/*	    Creation Date   : 2/6/03                     */
/*	    Comments : update comments**/
/*                                                     */
/*******************************************************/     


AS 
DECLARE @i_bookkey int
DECLARE @i_returncode int
DECLARE @i_eloschcommentscursorstatus int

begin tran

DECLARE cursor_eloschcomments INSENSITIVE CURSOR
FOR
select bookkey
 from eloschcomments
FOR READ ONLY

OPEN cursor_eloschcomments

FETCH NEXT FROM cursor_eloschcomments
INTO @i_bookkey

select @i_eloschcommentscursorstatus = @@FETCH_STATUS

if @i_eloschcommentscursorstatus < 0 /** No comments **/
begin 
	close cursor_eloschcomments
	deallocate cursor_eloschcomments
	return 0
end

while (@i_eloschcommentscursorstatus<>-1 )
begin /*begin while */
	IF (@i_eloschcommentscursorstatus<>-2)
	begin
		exec @i_returncode = eloschcommentsupdate_sp @i_bookkey

		if @i_returncode=-1
		begin
			rollback tran
			/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
			return -1  /** Fatal SQL Error **/
		end
	end
FETCH NEXT FROM cursor_eloschcomments
INTO @i_bookkey
      
	select @i_eloschcommentscursorstatus = @@FETCH_STATUS
	end /* end while */

close cursor_eloschcomments
deallocate cursor_eloschcomments

commit tran

return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

