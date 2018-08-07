SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_subgentables_external_datacodes') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.get_subgentables_external_datacodes
end
go

create procedure get_subgentables_external_datacodes (@i_tableid int, 
													  @v_externalcode varchar(30),
													  @v_datacode int OUTPUT,
													  @v_datasubcode int OUTPUT)

AS

BEGIN
    if @v_externalcode is null return
    set @v_datasubcode = null
    set @v_datacode = null

    Select @v_datacode = datacode, @v_datasubcode = datasubcode
    from subgentables 
    where tableid = @i_tableid 
    and externalcode = @v_externalcode
   
END

GO

GRANT EXEC ON get_subgentables_external_datacodes TO PUBLIC
GO
