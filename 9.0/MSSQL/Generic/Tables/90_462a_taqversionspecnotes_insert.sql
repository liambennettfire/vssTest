/****** Object:  StoredProcedure [dbo].[taqversionspecnotes_insert]    Script Date: 11/11/2014 15:27:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[taqversionspecnotes_insert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[taqversionspecnotes_insert]
GO

/****** Object:  StoredProcedure [dbo].[taqversionspecnotes_insert]    Script Date: 11/11/2014 15:27:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[taqversionspecnotes_insert]  @i_taqversionspeccategorykey int, @v_text varchar(max), @i_showonpoind int, @i_copynextprtngind int,@i_sortorder int, @v_userid varchar(50),@d_lastmaintdate datetime
AS
DECLARE 
@i_taqversionspecnotekey int

BEGIN
exec dbo.get_next_key @v_userid,@i_taqversionspecnotekey OUTPUT

insert into taqversionspecnotes (taqversionspecnotekey,taqversionspecategorykey,text,showonpoind,copynextprtgind,sortorder,lastuserid,lastmaintdate)
select @i_taqversionspecnotekey,@i_taqversionspeccategorykey,@v_text,@i_showonpoind,@i_copynextprtngind,@i_sortorder,@v_userid, GETDATE()

END

GO

grant execute on [dbo].[taqversionspecnotes_insert]  to public
go
