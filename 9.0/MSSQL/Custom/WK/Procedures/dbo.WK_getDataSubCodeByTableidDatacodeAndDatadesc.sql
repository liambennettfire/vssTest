if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getDataSubCodeByTableidDatacodeAndDatadesc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getDataSubCodeByTableidDatacodeAndDatadesc
GO

CREATE PROCEDURE dbo.WK_getDataSubCodeByTableidDatacodeAndDatadesc
@TableId int,
@DataCode int,
@Datadesc varchar(512)
AS

BEGIN

select datasubcode from subgentables where tableid = @TableId AND datacode = @DataCode and datadesc like '%' + @Datadesc + '%'

END
