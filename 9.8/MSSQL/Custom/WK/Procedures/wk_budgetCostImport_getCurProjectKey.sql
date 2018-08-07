IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.wk_budgetCostImport_getCurProjectKey'))
  DROP PROCEDURE dbo.wk_budgetCostImport_getCurProjectKey
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.wk_budgetCostImport_getCurProjectKey
(
  @i_projectkey INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
**  Name: wk_budgetCostImport_getCurProjectKey
**  Desc: This stored procedure ...
**
**    Auth: Jonathan Hess
**    Date: 04/12/2012
**
**    Initial Case: 14626
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var                 INT,
          @rowcount_var              INT,
          @inputProjectStatusCode    INT,
          @ApprovedProjectStatusCode INT

  -- Determine if the input projectkey is an approved TA project, if so, get the associated work project key 
  --  instead otherwise pass the input projectkey back as it's valid to continue to work off of.

  -- This datacode will represent an approved title acquisition, test against this datacode to determine if approved
  SET @ApprovedProjectStatusCode = (SELECT datacode
                                      FROM gentables g
                                      WHERE g.tableid = 522
                                        AND qsicode = 1)

  -- Get the status of the incoming TA ( Approved or not )
  SET @inputProjectStatusCode = (
                                 SELECT t.taqprojectstatuscode
                                   FROM taqproject t
                                   WHERE t.usageclasscode IN (SELECT datasubcode
                                                                FROM subgentables s
                                                                WHERE s.tableid = 550
                                                                  AND datacode = 3
                                                                  AND qsicode = 1)
                                     AND t.searchitemcode IN (SELECT datacode
                                                                FROM gentables g
                                                                WHERE g.tableid = 550
                                                                  AND g.qsicode = 3
                                                             )
                                     AND t.taqprojectkey = @i_projectkey)

  -- If it's an approved TA, we need to get the projectkey for the created/associated work.
  IF @inputProjectStatusCode = @ApprovedProjectStatusCode
    BEGIN
      SELECT taqprojectkey2 AS projectkey,
             '1' AS approved
        FROM taqprojectrelationship t
        WHERE t.taqprojectkey1 = @i_projectkey
          AND t.relationshipcode1 IN (SELECT datacode
                                        FROM gentables g
                                        WHERE g.qsicode = 14)
          AND t.relationshipcode2 IN (SELECT datacode
                                        FROM gentables g
                                        WHERE g.qsicode = 15)
      UNION
      SELECT taqprojectkey1 AS projectkey,
             '1' AS approved
        FROM taqprojectrelationship t
        WHERE t.taqprojectkey2 = @i_projectkey
          AND t.relationshipcode1 IN (SELECT datacode
                                        FROM gentables g
                                        WHERE g.qsicode = 15)
          AND t.relationshipcode2 IN (SELECT datacode
                                        FROM gentables g
                                        WHERE g.qsicode = 14)
    END
  ELSE
    BEGIN
      SELECT @i_projectkey AS projectkey,
             '0' AS approved
    END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found on taqprojectrelationship (' + cast(@error_var AS
      VARCHAR) + '): projectkey = ' + cast(@i_projectkey AS VARCHAR)
    END
GO

GRANT EXEC ON wk_budgetCostImport_getCurProjectKey TO PUBLIC
GO

--wkqc examples of TA not approved and one that was.
--EXEC dbo.wk_budgetCostImport_getCurProjectKey 2702408,0,0
--EXEC dbo.wk_budgetCostImport_getCurProjectKey 2702674,0,0