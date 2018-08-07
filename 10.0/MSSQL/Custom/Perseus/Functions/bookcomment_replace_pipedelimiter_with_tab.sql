SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.bookcomment_replace_pipedelimiter_with_tab') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.bookcomment_replace_pipedelimiter_with_tab
GO

CREATE FUNCTION dbo.bookcomment_replace_pipedelimiter_with_tab
            	(@i_bookkey 	INT)
RETURNS VARCHAR(8000)
 
BEGIN 
 
  DECLARE @v_text varchar(8000)
  DECLARE @v_tab varchar(10)
  DECLARE @v_string varchar(8000)

	SELECT @v_text = commenttext 
  	  FROM bookcomments 
	WHERE bookkey = @i_bookkey
		AND commenttypecode = 1
		AND commenttypesubcode = 12
  
  set @v_tab = char(9)

  set @v_string = replace(@v_text,'|',@v_tab)
  
  RETURN @v_string
END 
go


Grant All on dbo.bookcomment_replace_pipedelimiter_with_tab to Public
go