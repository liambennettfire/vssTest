SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_book_lastmaintdate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_book_lastmaintdate]
GO

CREATE FUNCTION dbo.qweb_get_book_lastmaintdate (
    @i_bookkey  INT)
  
  RETURNS datetime
  
AS
BEGIN
  DECLARE 
    @v_lastmaintdate  datetime,
    @v_returndate  datetime
    

  select @v_returndate=lastmaintdate from book where bookkey=@i_bookkey  

  select @v_lastmaintdate=lastmaintdate from bookdetail where bookkey=@i_bookkey  
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookcomments where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookbisaccategory  where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookprice where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  lastmaintdate from bookauthor where bookkey=@i_bookkey order by lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  select top 1 @v_lastmaintdate =  a.lastmaintdate
    from bookauthor ba, author a
    where ba.bookkey=@i_bookkey
      and ba.authorkey=a.authorkey
    order by a.lastmaintdate desc
  if @v_lastmaintdate>@v_returndate and @v_lastmaintdate is not null
    begin
      set @v_returndate=@v_lastmaintdate
    end 

  RETURN @v_returndate 
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

