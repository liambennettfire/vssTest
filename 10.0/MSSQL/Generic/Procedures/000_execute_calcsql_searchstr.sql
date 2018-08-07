if exists (select * from dbo.sysobjects where id = Object_id('dbo.execute_calcsql_searchstr') and (type = 'P' or type = 'RF'))
  drop proc dbo.execute_calcsql_searchstr
GO

/******************************************************************************
**  Name: execute_calcsql_searchstr
**  Desc: Return the calculated value for a 'Calculated Search Text' misc item
**
**  Auth: Colman
**  Case: 48094
**  Date: 1/11/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
*******************************************************************************/

CREATE PROC dbo.execute_calcsql_searchstr
  @i_misckey  INT,
  @o_result   VARCHAR(255) OUTPUT
AS

BEGIN
  SELECT @o_result = ISNULL(misclabel, 'Search') FROM bookmiscitems WHERE misckey = @i_misckey
END
GO

GRANT EXECUTE ON dbo.execute_calcsql_searchstr TO PUBLIC
GO
