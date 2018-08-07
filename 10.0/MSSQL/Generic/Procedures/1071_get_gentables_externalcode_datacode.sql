SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_gentables_externalcode_datacode') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.get_gentables_externalcode_datacode
end
go


Create procedure get_gentables_externalcode_datacode (@i_tableid int, 
													  @v_externalcode varchar(30), 
													  @v_datacode varchar(30) OUTPUT)

AS
BEGIN

    if @v_externalcode is null return
    set @v_datacode = null

    Select @v_datacode = datacode
    from gentables 
    where tableid = @i_tableid 
    and externalcode = @v_externalcode
END

GO

GRANT EXEC ON get_gentables_externalcode_datacode TO PUBLIC
GO
