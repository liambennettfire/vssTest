SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_subgentables_externalcode_datacode') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.get_subgentables_externalcode_datacode
end
go

create procedure get_subgentables_externalcode_datacode (@i_tableid int, 
														@i_datacode int,
														@v_externalcode varchar(30), 
														@v_datasubcode int OUTPUT)

AS

BEGIN
    if @v_externalcode is null return
    set @v_datasubcode = null

    Select @v_datasubcode = datasubcode
    from subgentables 
    where tableid = @i_tableid 
    and datacode = @i_datacode
    and externalcode = @v_externalcode
   
END

GO

GRANT EXEC ON get_subgentables_externalcode_datacode TO PUBLIC
GO
