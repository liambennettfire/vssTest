if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_peer_review_summary') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_peer_review_summary
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_peer_review_summary
 (@i_userkey           integer,
  @i_projectkey        integer,
  @o_error_code        integer output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_peer_review_summary
**  Desc: This stored procedure returns peer review summary
**        from taqprojectreaderiteration table.
**              
**  Auth: Kate
**  Date: 18 August 2004
**
**  Changes:
**        09 December 2009 - Lisa - Modified the FROM clause to use 
**                          JOIN syntax and added datades from gentables 
**                          for readerrecommendation column.
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT e.taqelementdesc, e.taqelementnumber, pc.globalcontactkey, c.displayname, 
      ri.taqprojectkey, ri.taqprojectcontactrolekey, ri.taqelementkey, pr.rolecode,
      g2.datadesc, ri.readitrecommendation,
      CASE WHEN LEN(g2.datadesc) > 0 
           THEN
              CASE WHEN LEN(isNull(ri.readitrecommendation,'')) = 0 THEN g2.datadesc                 
                   ELSE 
                        CASE WHEN LEN(ri.readitrecommendation) > 40 THEN
                             RTRIM(LTRIM(g2.datadesc)) + ': ' + CAST(ri.readitrecommendation AS VARCHAR(40)) + '...'
                        ELSE RTRIM(LTRIM(g2.datadesc)) + ': ' + ri.readitrecommendation
                        END
              END
           ELSE
              CASE WHEN LEN(ri.readitrecommendation) > 40 THEN
                CAST(ri.readitrecommendation AS VARCHAR(40)) + '...'
                ELSE ri.readitrecommendation
              END
      END AS recommendation,      
      CASE WHEN LEN(ri.readitsummary) > 60 THEN
        CAST(ri.readitsummary AS VARCHAR(60)) + '...'
        ELSE ri.readitsummary
      END AS summary,
      ri.recommendationcode, dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate, pr.taqprojectcontactkey
  FROM taqprojectreaderiteration ri 
  JOIN taqprojectcontactrole pr ON ri.taqprojectkey = pr.taqprojectkey AND
                                   ri.taqprojectcontactrolekey = pr.taqprojectcontactrolekey
  JOIN taqprojectcontact pc ON pr.taqprojectkey = pc.taqprojectkey AND
                               pr.taqprojectcontactkey = pc.taqprojectcontactkey
  JOIN corecontactinfo c ON c.contactkey = pc.globalcontactkey 
  JOIN taqprojectelement e ON e.taqelementkey = ri.taqelementkey
  JOIN gentables g ON g.tableid = 287 AND g.qsicode = 1  --Manuscript
  LEFT JOIN gentables g2 ON g2.tableid = 610 AND g2.datacode = ri.recommendationcode
  WHERE ri.taqprojectkey = @i_projectkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectreaderiteration: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)
  END
GO

GRANT EXEC ON qproject_get_peer_review_summary TO PUBLIC
GO
