SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixcitation_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixcitation_sp]
GO




CREATE proc [dbo].eloonixcitation_sp @i_bookkey int 



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
	
	

	/*truncate the temporary text table */

	truncate table elotemptext

	insert into elotemptext values (1,@c_citationtext)

	select @c_checknulltext = convert (varchar (255),feedtext) from elotemptext

	if @c_checknulltext = NULL
		begin 
            close cursor_citation
            deallocate cursor_citation
			return 0
		end
	else
	   begin
		/* @c_citationauthor = select citationauthor from citation 
		where  bookkey=@i_bookkey and citationkey = @i_count
		@c_citationsource = select citationsource from citation 
		where bookkey=@i_bookkey and citationkey = @i_count
		@d_citationdate = select citationdate from citation 
		where bookkey=@i_bookkey and citationkey = @i_count */

		insert into eloonixfeed (feedtext) values ('<othertext>')
		insert into eloonixfeed (feedtext) 
	  	 values ('<d102>' + @c_texttypecode +'</d102>')

		insert into eloonixfeed (feedtext) values ('<d103>00</d103>')

     		 /* output citationtext from step above */
		exec @i_returncode = elooutputformattedtext_sp '<d104><![CDATA[',']]></d104>', 0
		if @i_returncode=-1
		begin
            close cursor_citation
            deallocate cursor_citation
			rollback tran
			/*exec eloprocesserror_sp @i_bookkey,@@error,'ERROR','SQL Error'*/
			return -1  /** Fatal SQL Error **/
		end
		insert into eloonixfeed (feedtext) 
	   	values ('<d107>' + @c_citationauthor +'</d107>')

		insert into eloonixfeed (feedtext) 
	   	values ('<d108>' + @c_citationsource +'</d108>')
	
		insert into eloonixfeed (feedtext) 
	   	values ('<d109>' + convert(varchar(10), @d_citationdate,101) +'</d109>')
		
		insert into eloonixfeed (feedtext) values ('</othertext>')
	   end /* end else */
end
FETCH NEXT FROM cursor_citation
INTO @c_citationauthor,@c_citationsource,
@d_citationdate,@c_citationtext
      
	select @i_citationcursorstatus = @@FETCH_STATUS
end

close cursor_citation
deallocate cursor_citation



return 0


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

