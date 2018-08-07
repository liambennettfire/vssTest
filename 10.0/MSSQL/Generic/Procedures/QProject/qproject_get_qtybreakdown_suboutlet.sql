if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_qtybreakdown_suboutlet') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_qtybreakdown_suboutlet
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_qtybreakdown_suboutlet
 (@i_projectkey      integer,
  @i_itemtypecode    integer,
  @i_itemtypesubcode integer,
  @i_datacode        integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_qtybreakdown_suboutlet
**  Desc: This stored procedure returns a list of distinct qtybreakdowns
**        from gentables filtered by usageclass. 
**
**  Auth: Alan Katzen
**  Date: 25 January 2008
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  -------   ---------   ----------------------------------------------------
**  03/03/08	LC	  Added two columns, Estimated Quantity and Quantity
**			  notes for Duke University.
*******************************************************************************/

  DECLARE 
    @error_var    INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT DISTINCT s.datadesc, s.datadescshort, o.orgentrykey, 
      COALESCE(b.qty,0) qty,  COALESCE(b.estqty,0) estqty, qtynote,
		  COALESCE(b.taqprojectkey,0) taqprojectkey,
      COALESCE(b.qtyoutletcode,s.datacode,0) qtyoutletcode, 
      COALESCE(b.qtyoutletsubcode,s.datasubcode, 0) qtyoutletsubcode,
      COALESCE(s.sortorder,0) sortorder
    FROM subgentables s LEFT OUTER JOIN subgentablesorglevel o ON s.tableid = o.tableid and 
                                        s.datacode = o.datacode and s.datasubcode = o.datasubcode
                        LEFT OUTER JOIN taqprojectqtybreakdown b ON s.datacode = b.qtyoutletcode and  
                                        s.datasubcode = b.qtyoutletsubcode and b.taqprojectkey = @i_projectkey,
         gentablesitemtype i
   WHERE s.tableid = i.tableid AND
         s.datacode = i.datacode AND
         s.datasubcode = i.datasubcode AND
         upper(s.deletestatus) = 'N' AND
         s.tableid = 527 AND
         s.datacode = @i_datacode AND
         i.itemtypecode = @i_itemtypecode AND
         COALESCE(i.itemtypesubcode,0) in (@i_itemtypesubcode,0)
ORDER BY sortorder, s.datadesc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: qtybreakdown.'   
  END 

GO

GRANT EXEC ON qproject_get_qtybreakdown_suboutlet TO PUBLIC
GO

