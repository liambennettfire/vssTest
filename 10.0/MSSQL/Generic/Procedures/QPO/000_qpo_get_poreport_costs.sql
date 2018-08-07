if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_get_poreport_costs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpo_get_poreport_costs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_get_poreport_costs
 (@i_projectkey  integer,
  @i_sectionkey integer,
  @i_subsectionkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*******************************************************************************************************
**  Name: qpo_get_poreport_costs
**  Desc: This stored procedure returns all cost related information for PO Report Costs.
**
**  Auth: Uday A. Khisty
**  Date: 09/18/2014
********************************************************************************************************
**  Date:       Author:            Description:
**  -------   ------------      ------------------------------------------------------------------------
**  04/26/17   Uday A. Khisty   Case 44614
********************************************************************************************************/

DECLARE
  @error_var  INT,
  @rowcount_var INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
   
  IF @i_sectionkey = 0 AND @i_subsectionkey = 0
    SELECT g.gpokey as projectkey, g.sectionkey, g.subsectionkey, g.costlinenumber,
	  s.description sectiondesc, ss.description subsectiondesc,
      --dbo.qpo_get_gposection_description(g.gpokey,g.sectionkey,g.subsectionkey) as 'sectiondescription',
      'detail' as 'sectionrowtype',  -- used in poreportcost section
      (SELECT TOP(1) COALESCE(externaldesc, '') FROM cdlist c WHERE c.internalcode = g.chgcodecode) as proddesc,
      (SELECT TOP(1) COALESCE(externalcode, '') FROM cdlist c WHERE c.internalcode = g.chgcodecode) as code,	  
      CASE
        WHEN g.pocostind='Y' OR g.pocostind='y' THEN 1
        ELSE 0	  
      END as pocostind,	  
      g.potag1, g.potag2,
      COALESCE(g.unitcost, 0) AS unitcost, COALESCE(g.totalcost, 0) AS totalcost
    FROM gpocost g
      JOIN gposection s ON s.sectionkey = g.sectionkey AND g.gpokey = s.gpokey
      LEFT OUTER JOIN gposubsection ss ON ss.sectionkey = g.sectionkey AND ss.subsectionkey = g.subsectionkey
    WHERE g.gpokey = @i_projectkey
    ORDER BY g.sectionkey, g.subsectionkey		
  ELSE 
    SELECT g.gpokey as projectkey, g.sectionkey, g.subsectionkey, g.costlinenumber,
      s.description sectiondesc, ss.description subsectiondesc,
      --dbo.qpo_get_gposection_description(g.gpokey,g.sectionkey,g.subsectionkey) as 'sectiondescription',
      'detail' as 'sectionrowtype',  -- used in poreportcost section
      (SELECT TOP(1) COALESCE(externaldesc, '') FROM cdlist c WHERE c.internalcode = g.chgcodecode) as proddesc,
      (SELECT TOP(1) COALESCE(externalcode, '') FROM cdlist c WHERE c.internalcode = g.chgcodecode) as code,	  
      CASE
        WHEN g.pocostind='Y' OR g.pocostind='y' THEN 1
        ELSE 0	  
      END as pocostind,	  
      g.potag1, g.potag2, 
      COALESCE(g.unitcost, 0) AS unitcost, COALESCE(g.totalcost, 0) AS totalcost
    FROM gpocost g
      JOIN gposection s ON s.sectionkey = g.sectionkey AND g.gpokey = s.gpokey
      LEFT OUTER JOIN gposubsection ss ON ss.sectionkey = g.sectionkey AND ss.subsectionkey = g.subsectionkey
    WHERE g.gpokey = @i_projectkey 
      AND g.sectionkey = @i_sectionkey 
      AND COALESCE(g.subsectionkey, 0) = COALESCE(@i_subsectionkey, 0)   
    ORDER BY g.sectionkey, g.subsectionkey  
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve rows from gpocost / cdlist table'
  END  

END
GO

GRANT EXEC ON qpo_get_poreport_costs TO PUBLIC
GO
