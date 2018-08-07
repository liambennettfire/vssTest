
/****** Object:  StoredProcedure [dbo].[taqversionspecnotes_insert_from_note]    Script Date: 11/11/2014 15:27:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[taqversionspecnotes_insert_from_note]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[taqversionspecnotes_insert_from_note]
GO

/****** Object:  StoredProcedure [dbo].[taqversionspecnotes_insert_from_note]    Script Date: 11/11/2014 15:27:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[taqversionspecnotes_insert_from_note] @i_bookkey int, @i_printingkey int, @i_compkey int, @i_taqversionspeccategorykey int
AS
DECLARE
@v_text varchar(max),
@i_showonpoind int, 
@i_copynextprtngind int,
@i_sortorder int, 
@v_userid varchar(50), 
@d_lastmaintdate datetime,
@i_numberrecords int, 
@i_rowcount int,
@i_notekey int,
@v_copynextprtngind varchar (2),
@v_showonpoind varchar(2)

 
CREATE TABLE #notelist(
rowid int identity (1,1),
notekey int)

INSERT INTO #notelist (notekey)
select notekey from note where bookkey = @i_bookkey and printingkey=@i_printingkey and compkey =@i_compkey
order by compkey,notekey 
	
SET @i_NumberRecords = @@ROWCOUNT
SET @i_RowCount = 1

WHILE @i_rowcount <= @i_numberrecords
BEGIN
 SELECT @i_notekey = notekey 
 FROM #notelist
 WHERE rowid = @i_rowcount

	select @v_text = text, @v_showonpoind = showonpoind, @v_copynextprtngind = copynextprtgind, @i_sortorder = detaillinenbr,@v_userid = lastuserid, @d_lastmaintdate = lastmaintdate
	from note where notekey = @i_notekey
	
	IF coalesce(@v_showonpoind,'') = 'Y'
		select @i_showonpoind = 1
	ELSE select @i_showonpoind = 0
	
	IF coalesce(@v_copynextprtngind,'') = 'Y'
		select @i_copynextprtngind = 1
	ELSE select @i_copynextprtngind = 0
	
	exec dbo.taqversionspecnotes_insert  @i_taqversionspeccategorykey, @v_text, @i_showonpoind, @i_copynextprtngind,@i_sortorder, @v_userid, @d_lastmaintdate 

SET @i_RowCount = @i_RowCount + 1
END

-- drop the temporary table
DROP TABLE #notelist

GO

grant execute on [dbo].[taqversionspecnotes_insert_from_note]  to public
go

