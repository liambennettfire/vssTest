if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_plsummaryitemcalc_orglist') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_plsummaryitemcalc_orglist
GO

CREATE PROCEDURE qpl_get_plsummaryitemcalc_orglist
 (@i_plsummaryitemkey integer,
  @i_orglevelkey      integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qpl_get_plsummaryitemcalc_orglist
**  Desc: This stored procedure returns orgentry list for given P&L Item Calculations filterorglevel.
**        NOTE: temporary solution - should be replaced by full Orgentry list treeview later.
**
**  Auth: Kate
**  Date: 24 August 2007
****************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  SELECT o.orglevelkey, o.orgentrykey, o.orgentrydesc, COUNT(c.calcsql) calcsqlexists
  FROM orgentry o, plsummaryitemcalc c
  WHERE o.orglevelkey = c.orglevelkey AND 
      o.orgentrykey = c.orgentrykey AND
      c.plsummaryitemkey = @i_plsummaryitemkey AND
      o.orglevelkey = @i_orglevelkey 
  GROUP BY o.orglevelkey, o.orgentrykey, o.orgentrydesc
  UNION
  SELECT o.orglevelkey, o.orgentrykey, o.orgentrydesc, 0 calcsqlexists
  FROM orgentry o
  WHERE o.orglevelkey = @i_orglevelkey AND
      NOT EXISTS (SELECT * FROM plsummaryitemcalc c 
      WHERE o.orglevelkey = c.orglevelkey AND o.orgentrykey = c.orgentrykey AND c.plsummaryitemkey = @i_plsummaryitemkey)
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access orgentry/plsummaryitemcalc tables (plsummaryitemkey=' + CAST(@i_plsummaryitemkey AS VARCHAR) + 
      ', orglevelkey=' + CAST(@i_orglevelkey AS VARCHAR) + ').'
  END 

GO

GRANT EXEC ON qpl_get_plsummaryitemcalc_orglist TO PUBLIC
GO


