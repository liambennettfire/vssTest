if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_element_configobjectid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_element_configobjectid
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
 declare @err int
 declare @dsc varchar(2000)

 exec qelement_get_element_configobjectid 20028, 7, @err, @dsc
*/

CREATE PROCEDURE [dbo].[qelement_get_element_configobjectid]
 (@i_elementtype     integer, -- AKA usageclass code
  @i_itemtypecode	 integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qelement_get_element_configobjectid
**  Desc: This stored procedure returns the configobjectid for a given element
**        from the qsiconfigobjects table.
**
**    Auth: Lisa
**    Date: 7/10/08
**
**   KNOWN ISSUES:  The qsiconfigdetail table currently allows multiple
**					usageclasscode/Configobjectid pairs.  By returning the 
**					TOP 1, you are not guaranteed to get the correct row.
**					Discussed this with others and decided it will be fixed
**					later.
**
*******************************************************************************/

DECLARE @error_var int
DECLARE @rowcount_var int

select TOP 1 QO.configobjectid 
--select QO.configobjectid 
from qsiconfigobjects QO
join qsiconfigdetail QD on QO.configobjectkey = QD.configobjectkey
where QD.usageclasscode = @i_elementtype and QO.itemtypecode = @i_itemtypecode

-- Save the @@ERROR and @@ROWCOUNT values in local 
-- variables before they are cleared.
SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 or @rowcount_var = 0 BEGIN
  SET @o_error_code = 1
  SET @o_error_desc = 'no configobjectids found for Element =' + CAST(@i_elementtype AS VARCHAR)
END 

GO
GRANT EXEC ON qelement_get_element_configobjectid TO PUBLIC
GO

