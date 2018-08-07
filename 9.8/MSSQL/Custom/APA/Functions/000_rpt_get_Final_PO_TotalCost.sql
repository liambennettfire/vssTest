IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_get_gposection_description') )
DROP FUNCTION dbo.rpt_get_Final_PO_TotalCost
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*******************************************************************************************************
**  Name: [rpt_get_Final_PO_TotalCost]
**  Desc: 
**
**  Auth: 
**  Date: 
*******************************************************************************************************
**  Change History
*******************************************************************************************************
**  Date:       Author:            Description:
**  --------   ------------      -----------------------------------------------------------------------
**  03/22/17   Uday A. Khisty    Case 44004
*******************************************************************************************************/

CREATE FUNCTION [dbo].[rpt_get_Final_PO_TotalCost](@projectkey int)
RETURNS FLOAT
AS BEGIN
DECLARE @return FLOAT
SET @return = 0

	SELECT @return = isnull(SUM(gc.totalcost),0) 
	FROM taqprojecttitle t
	join taqprojectrelationship r ON r.taqprojectkey2=t.taqprojectkey
	left join gposection gs on gs.key1=t.bookkey and sectiontype in(2,3)
	left join gpocost gc on gs.sectionkey=gc.sectionkey
	left join gpo g on gs.gpokey=g.gpokey and g.gpokey=gc.gpokey
	WHERE gs.bookkey =t.bookkey and taqprojectkey = @projectkey AND
	gs.key2= (select max(key2) from gposection where key1=gs.key1)
	and g.gpostatus in ('F')
	and g.gpochangenum= (select max(gpochangenum) from gpo where gponumber=g.gponumber and gpostatus in ('F'))
	AND r.relationshipcode1=36 and r.relationshipcode2=35
	RETURN @return

END
GO
GRANT EXEC ON dbo.rpt_get_Final_PO_TotalCost TO public
GO


