if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_historycolumnsinfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_historycolumnsinfo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_historycolumnsinfo
 (@i_itemtypecode   integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_historycolumnsinfo
**  Desc: Returns History Changes Info for a specific Itemtype/UsageClass.
**              
**  Auth: Alan Katzen
**  Date: 24 February 2011
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT distinct cd.columnkey, cd.historylabel 
    FROM historytablecolumndefs cd, historygrouping hg
   WHERE cd.columnkey = hg.columnkey
     and hg.itemtypecode = @i_itemtypecode
     and hg.usageclass = @i_usageclasscode
  ORDER BY cd.historylabel

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing isbnlabels table.'
  END 
GO

GRANT EXEC ON qutl_get_historycolumnsinfo TO PUBLIC
GO
