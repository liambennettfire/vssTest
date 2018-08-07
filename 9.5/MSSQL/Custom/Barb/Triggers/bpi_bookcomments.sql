/****** Object:  Trigger [dbo].[bpi_bookcomments]    Script Date: 03/25/2014 14:16:26 ******/
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.bpi_bookcomments') AND type = 'TR')
	DROP TRIGGER dbo.bpi_bookcomments
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[bpi_bookcomments] ON [dbo].[bookcomments]
FOR INSERT, UPDATE AS
BEGIN
	DECLARE @v_bookkey 	INT
	
	SELECT @v_bookkey = i.bookkey
	FROM inserted i

	IF @v_bookkey IS NOT NULL BEGIN
		if exists (select * from dbo.bpiinterface where bookkey=@v_bookkey) 
			update dbo.bpiinterface set status=10 where bookkey=@v_bookkey
		else
			insert into dbo.bpiinterface values(@v_bookkey,10,'BCO')
	END		
END


GO


