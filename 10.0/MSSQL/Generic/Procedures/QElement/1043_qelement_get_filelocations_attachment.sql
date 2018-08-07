if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qelement_get_filelocations_attachment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].qelement_get_filelocations_attachment
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qelement_get_filelocations_attachment]
 (@o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT,
          @rowcount_var INT
   
  SET @error_var = 0
  SET @rowcount_var = 0
  SELECT 
		dbo.get_gentables_desc(287,taqprojectelement.taqelementtypecode,'long') element,
		dbo.get_gentables_desc(354,filelocation.filetypecode,'long') filetypedesc,
        filedescription,
		pathname
  FROM filelocation, taqprojectelement
 --where filelocation.taqelementkey = 586024
  where taqprojectelement.taqelementkey = filelocation.taqelementkey
  order by element


  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error returning file locations.'
    RETURN  
  END 
go
grant execute on qelement_get_filelocations_attachment to public
go


