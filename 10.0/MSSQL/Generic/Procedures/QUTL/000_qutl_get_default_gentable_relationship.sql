if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_default_gentable_relationship') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_default_gentable_relationship
GO

CREATE PROCEDURE qutl_get_default_gentable_relationship (
  @i_gentablesrelationshipkey  INT,
  @i_code1                     INT,
  @i_subcode1                  INT,
  @o_error_code                INT OUTPUT,
  @o_error_desc                VARCHAR(2000) OUTPUT)
AS

/*************************************************************************************************
**  Name: qutl_get_default_gentable_relationship
**  Desc: This stored procedure returns data for the default relationship from 
**        gentablesrelationshipdetail
**
**  Auth: Alan Katzen
**  Date: August 26 2008
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:       Author:    Description:
**    ----------  --------   --------------------------------------------------------------------
**    01/08/2018  Colman     Case 49040
*************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount   INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT TOP 1 d.*
  FROM gentablesrelationshipdetail d
  WHERE d.gentablesrelationshipkey = @i_gentablesrelationshipkey  AND 
        d.code1 = @i_code1 AND
        (ISNULL(d.subcode1,0) = 0 OR d.subcode1 = @i_subcode1)
  ORDER BY defaultind DESC

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing gentablesrelationshipdetail (gentablesrelationshipkey=' + CONVERT(VARCHAR, @i_gentablesrelationshipkey) + ').'
  END 
GO

GRANT EXEC ON qutl_get_default_gentable_relationship TO PUBLIC
GO
