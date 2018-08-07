if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getBookSubjectCategoryDataBySacCode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getBookSubjectCategoryDataBySacCode
GO
 
CREATE PROCEDURE dbo.WK_getBookSubjectCategoryDataBySacCode
@SacCode int
AS

DECLARE @tableId int


SET @tableId = 412

BEGIN

SELECT sg2.tableid, 
       sg2.datacode, 
       sg2.datasubcode, 
       sg2.datasub2code, 
       [dbo].[rpt_get_gentables_desc]( sg2.tableid, sg2.datacode, '1' ) as gentablesdesc,
       [dbo].[rpt_get_subgentables_desc]( sg2.tableid, sg2.datacode, sg2.datasubcode, '1' ) as subgentablesdesc,
       [dbo].[rpt_get_sub2gentables_desc]( sg2.tableid, sg2.datacode, sg2.datasubcode, sg2.datasub2code, '1' ) as sub2gentablesdesc  
FROM  sub2gentables sg2
WHERE tableid = @tableId 
  and externalcode = @SacCode

END

GRANT EXEC ON WK_getBookSubjectCategoryDataBySacCode TO PUBLIC
GO
