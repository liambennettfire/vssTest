if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_in_load_comments_updates_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_in_load_comments_updates_sp]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE procedure dbo.feed_in_load_comments_updates_sp 
@i_bookkey int,@c_comments varchar(4000), @i_linenumber int, @i_historyind int OUTPUT

AS

/*	IPG insert comments ROUNTINE 			*/
/*	Loads the Comments, 			*/										

DECLARE @i_count_com	INT
DECLARE @i_releaseind	INT
DECLARE @d_rundate	datetime
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @c_com_name  varchar(50)
DECLARE @c_old_comment varchar (250)

select @d_rundate = getdate()
select @i_count_com = 0
select @c_com_name = '' 


select @i_count_com = count(*) from whccommenttype where linenumber=@i_linenumber
if @i_count_com > 0
  begin
	   select @i_commenttypecode= commenttypecode, @i_commenttypesubcode= commenttypesubcode
		from whccommenttype where linenumber=@i_linenumber
  end

if @i_commenttypecode >0 and  @i_commenttypesubcode > 0
  begin

	select @c_com_name = '(' + upper(substring(g.datadesc,1,1)) + ') ' + sg.datadesc
	   from gentables g, subgentables sg
		where g.tableid=sg.tableid
			and g.datacode=sg.datacode
			and sg.tableid=284
			and sg.datacode=@i_commenttypecode
			and sg.datasubcode = @i_commenttypesubcode

	select @i_count_com = 0
/* check if comment exists if yes then get other columns */

	select @i_count_com = count(*) from bookcomments
		where printingkey = 1 and bookkey=@i_bookkey and commenttypecode= @i_commenttypecode
			and commenttypesubcode = @i_commenttypesubcode

	if @i_count_com > 0
	  begin
		select @c_old_comment = ''
		select @i_releaseind = releasetoeloquenceind ,@c_old_comment = substring(commenttext,1,250) from bookcomments
		where printingkey = 1 and bookkey=@i_bookkey and commenttypecode= @i_commenttypecode
			and commenttypesubcode = @i_commenttypesubcode

		delete from bookcomments
		  where printingkey = 1 and bookkey=@i_bookkey and commenttypecode= @i_commenttypecode
			and commenttypesubcode = @i_commenttypesubcode
	
		delete from bookcommentrtf
		  where printingkey = 1 and bookkey=@i_bookkey and commenttypecode= @i_commenttypecode
			and commenttypesubcode = @i_commenttypesubcode
	 end


	/*comment titlehistory*/
	if len(@c_old_comment) > 0
 	begin
		if @c_old_comment <> substring(@c_comments,1,250) and len(@c_old_comment)> 0
 		begin
			select @i_historyind = 1
			insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
				currentstringvalue,fielddesc)
			values (@i_bookkey,1,70,getdate(),@c_old_comment,'feedin',
				substring(@c_comments,1,250),@c_com_name)
 		end
	 end
	else
 	 begin
		if  len(@c_comments)>0
		  begin
			select @i_releaseind = null
			select @i_historyind = 1
			insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
				currentstringvalue,fielddesc)
			values (@i_bookkey,1,70,getdate(),'(Not Present)','feedin',
				substring(@c_comments,1,250),@c_com_name)
	  	end
  	end

/*insert comments*/
	if  @i_historyind =1
 	 begin
  		 insert into bookcomments
		  (bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,lastuserid,lastmaintdate,RELEASETOELOQUENCEIND)
		values (@i_bookkey,1,@i_commenttypecode,@i_commenttypesubcode,
      		   @c_comments,'feedin',@d_rundate,@i_releaseind)

/*9-21-04 add tag to comments*/

	select @c_comments =  replace(cast(@c_comments as varchar(4000)),char(13)+char(10),'{\par}') 

		insert into bookcommentrtf
		  (bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,lastuserid,lastmaintdate,RELEASETOELOQUENCEIND)
		values (@i_bookkey,1,@i_commenttypecode,@i_commenttypesubcode,
			@c_comments ,'feedin',@d_rundate,@i_releaseind)
  	end
 end

if @i_historyind is null
  begin
	select @i_historyind = 0
  end

return @i_historyind

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
