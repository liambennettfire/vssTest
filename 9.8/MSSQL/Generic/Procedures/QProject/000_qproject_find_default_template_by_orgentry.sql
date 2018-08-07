if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_find_default_template_by_orgentry') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_find_default_template_by_orgentry
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_find_default_template_by_orgentry
 (@i_searchitemcode				integer,
  @i_usageclass					integer,
  @i_orglevelonekey     integer,
  @i_orgleveltwokey			integer,
  @i_orglevelthreekey		integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/************************************************************************************
**  Name: qproject_find_default_template_by_orgentry
**  Desc: Finds the default template(s) for the usageclass and orgentry.
**				Can specify less than all three of the different org levels if needed.
**
**    Auth: Dustin
**    Date: June 20, 2012
*************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_orglevelonekey > 0
  BEGIN
		IF @i_orgleveltwokey > 0
		BEGIN
			IF @i_orglevelthreekey > 0
			BEGIN
				SELECT tp.taqprojectkey 
				FROM taqproject tp
				JOIN taqprojectorgentry ooa
					ON (tp.taqprojectkey = ooa.taqprojectkey
							AND ooa.orglevelkey = 1 AND ooa.orgentrykey = @i_orglevelonekey)
				JOIN taqprojectorgentry oob
					ON (tp.taqprojectkey = oob.taqprojectkey
							AND oob.orglevelkey = 2 AND oob.orgentrykey = @i_orgleveltwokey)
				JOIN taqprojectorgentry ooc
					ON (tp.taqprojectkey = ooc.taqprojectkey
							AND ooc.orglevelkey = 3 AND ooc.orgentrykey = @i_orglevelthreekey)
				WHERE tp.defaulttemplateind = 1
					AND searchitemcode = @i_searchitemcode
					AND usageclasscode = @i_usageclass
			END
			ELSE BEGIN
				SELECT tp.taqprojectkey 
				FROM taqproject tp
				JOIN taqprojectorgentry ooa
					ON (tp.taqprojectkey = ooa.taqprojectkey
							AND ooa.orglevelkey = 1 AND ooa.orgentrykey = @i_orglevelonekey)
				JOIN taqprojectorgentry oob
					ON (tp.taqprojectkey = oob.taqprojectkey
							AND oob.orglevelkey = 2 AND oob.orgentrykey = @i_orgleveltwokey)
				WHERE tp.defaulttemplateind = 1
					AND searchitemcode = @i_searchitemcode
					AND usageclasscode = @i_usageclass
			END
		END
		ELSE BEGIN
			SELECT tp.taqprojectkey 
			FROM taqproject tp
			JOIN taqprojectorgentry ooa
				ON (tp.taqprojectkey = ooa.taqprojectkey
						AND ooa.orglevelkey = 1 AND ooa.orgentrykey = @i_orglevelonekey)
			WHERE tp.defaulttemplateind = 1
			  AND searchitemcode = @i_searchitemcode
			  AND usageclasscode = @i_usageclass
		END
  END
  ELSE BEGIN
		SELECT tp.taqprojectkey
		FROM taqproject tp
		WHERE tp.defaulttemplateind = 1
		  AND searchitemcode = @i_searchitemcode
		  AND usageclasscode = @i_usageclass
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error finding default template by orgentry.'   
  END 

GO

GRANT EXEC ON qproject_find_default_template_by_orgentry TO PUBLIC
GO
