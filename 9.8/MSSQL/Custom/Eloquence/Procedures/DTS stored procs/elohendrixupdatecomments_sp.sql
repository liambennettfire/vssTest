SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[elohendrixupdatecomments_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[elohendrixupdatecomments_sp]
GO



CREATE proc [dbo].elohendrixupdatecomments_sp 



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
DECLARE @i_elohendrixcommentscursorstatus int

begin tran

DECLARE cursor_elohendrixcomments INSENSITIVE CURSOR
FOR
select bookkey
 from elohendrixcomments
FOR READ ONLY

OPEN cursor_elohendrixcomments

FETCH NEXT FROM cursor_elohendrixcomments
INTO @i_bookkey

select @i_elohendrixcommentscursorstatus = @@FETCH_STATUS

if @i_elohendrixcommentscursorstatus < 0 /** No comments **/
begin 
	close cursor_elohendrixcomments
	deallocate cursor_elohendrixcomments
	return 0
end

while (@i_elohendrixcommentscursorstatus<>-1 )
begin /*begin while */
	IF (@i_elohendrixcommentscursorstatus<>-2)
	begin
		exec @i_returncode = elohendrixcommentsupdate_sp @i_bookkey

		if @i_returncode=-1
		begin
			rollback tran
			/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
			return -1  /** Fatal SQL Error **/
		end
	end
FETCH NEXT FROM cursor_elohendrixcomments
INTO @i_bookkey
      
	select @i_elohendrixcommentscursorstatus = @@FETCH_STATUS
	end /* end while */

close cursor_elohendrixcomments
deallocate cursor_elohendrixcomments

commit tran

return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

