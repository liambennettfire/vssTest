if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_compprocscaleitems') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_compprocscaleitems
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_compprocscaleitems
 (@i_scaletabkey					integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_compprocscaleitems
**  Desc: This procedure returns relevant component processes, scale item, and item detail options
**
**	Auth: Dustin Miller
**	Date: February 20 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT g.datacode, g.datadesc, s.datacode AS subgendatacode, s.datasubcode AS subgendatasubcode, s.datadesc AS subgendatadesc,
  coalesce(g.deletestatus, 'N') AS deletestatus, coalesce(s.deletestatus, 'N') AS subdeletestatus
  FROM gentables g, subgentables s, taqscaleadminspecitem i
  WHERE g.tableid=616 
  AND s.tableid=g.tableid 
  AND g.datacode=i.itemcategorycode 
  AND s.datasubcode=i.itemcode
  AND i.parametertypecode=3
  AND i.scaletabkey=@i_scaletabkey
	AND s.datacode=g.datacode

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning component process/itemdetails information (scaletabkey=' + cast(@i_scaletabkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_compprocscaleitems TO PUBLIC
GO