/******************************************************************************
**  Name: imp_load_serverside_excel 
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_load_serverside_excel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_load_serverside_excel]
GO


CREATE PROCEDURE dbo.imp_load_serverside_excel  
  @i_batch int,
  @i_file varchar(500)
AS

declare 
  @v_sql nvarchar(4000),
  @v_link nvarchar(1000),
  @v_tempfile varchar(4000),
  @v_rowcnt int,
  @v_squote char

begin

 -- initalize 
  set @v_squote = char(39)
  set @v_link = replace('ikelink'+cast(@i_batch as varchar(20)),' ','')
  set @v_sql = 'EXEC sp_addlinkedserver N'+@v_squote+@v_link+@v_squote+', '
  set @v_sql = @v_sql + '@srvproduct = N'+@v_squote+@v_squote+',@provider = N'+@v_squote+'Microsoft.Jet.OLEDB.4.0'+@v_squote+' '
  set @v_sql = @v_sql + '@datasrc = N'+@v_squote+@i_file+@v_squote+', ' 
  set @v_sql = @v_sql + '@provstr = N'+@v_squote+'Excel 8.0;'+@v_squote

print @v_sql

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_load_serverside_excel  TO PUBLIC 
GO


