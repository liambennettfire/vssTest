SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloamazoncitations_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloamazoncitations_sp]
GO



CREATE proc [dbo].eloamazoncitations_sp @i_bookkey int 



/*******************************************************/
/*	                                                 */        
/*	    Author   : CT                                */
/*	    Creation Date   : 2/6/03                     */
/*	    Comments : OUTPUT proc to use for citations **/
/*                                                     */
/*******************************************************/     


AS 
DECLARE @c_texttypecode varchar (10)
DECLARE @c_citationtext varchar(8000)
DECLARE @c_citationsource varchar (80)
DECLARE @c_citationauthor varchar (80)
DECLARE @d_citationdate datetime
DECLARE @i_countcitation int
DECLARE @i_citationcursorstatus int
DECLARE @i_processed int
DECLARE @i_count int
DECLARE @i_textlength int
DECLARE @i_returncode int
DECLARE @c_errormessage varchar (255)
DECLARE @c_checknulltext varchar (255)
DECLARE @c_feedstring varchar (8000)
DECLARE @tp_textpointer varbinary(16)

select @c_texttypecode = '08'


DECLARE cursor_citation INSENSITIVE CURSOR
FOR
select citationauthor,citationsource,citationdate,citationtext
 from citation
 where bookkey=@i_bookkey 
 order by citationkey
FOR READ ONLY

OPEN cursor_citation

FETCH NEXT FROM cursor_citation
INTO @c_citationauthor,@c_citationsource,
@d_citationdate,@c_citationtext

select @i_citationcursorstatus = @@FETCH_STATUS

if @i_citationcursorstatus < 0 /** No citations **/
begin 
	close cursor_citation
	deallocate cursor_citation
	return 0
end

while (@i_citationcursorstatus<>-1 )
begin
	IF (@i_citationcursorstatus<>-2)
	begin
		
	if @c_citationtext is  NULL or @c_citationsource = ''
		begin 
			close cursor_citation
			deallocate cursor_citation
			return 0
		end
	else
		begin	 		insert into eloamazonfeed (feedtext) 
values ('REVIEW: ' +  convert(varchar(1000),@c_citationtext) + '(' + @c_citationauthor + ',' + @c_citationsource + ',' + convert(varchar(10), @d_citationdate,101) + ')')

     		end /* end else */
	end

FETCH NEXT FROM cursor_citation
INTO @c_citationauthor,@c_citationsource,
@d_citationdate,@c_citationtext
      
	select @i_citationcursorstatus = @@FETCH_STATUS
	end /* end begin */

close cursor_citation
deallocate cursor_citation



return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

