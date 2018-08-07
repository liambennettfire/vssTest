IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_get_unassigned_tasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_get_unassigned_tasks]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
declare @err int
declare @dsc varchar(2000)
exec qproject_get_unassigned_tasks 592104, '23', 1, 565027, @err, @dsc

*/

CREATE PROCEDURE [dbo].[qproject_get_unassigned_tasks]
 (@i_projectkey			integer,
  @i_roles				varchar(1000),
  @i_addingrole         smallint,
  @i_globalcontactkey   integer,
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_unassigned_tasks
**  Desc: This stored procedure returns a list of unassigned tasks and the
**		  the possible contacts currently linked to the project as participants
**		  who have a rolecode from the rolecode list sent in that is on the task.
**
**  Parameters:
**		@i_projectkey - projectkey column of taqprojecttask table
**
**  Auth: Lisa Cormier
**  Date: 15 Sep 2008
**
*******************************************************************************
**  Date      Who   Change
**  -------   ---   -------------------------------------------
**  24 Sep 08 Lisa  Was asked to make this procedure run for only a selected
**					list of role codes instead of finding all unassigned tasks.
**					Per Brock and Susan.  See case 05102.
**  13 Oct 08 Lisa  Was asked to return the Element description as well. Case 05590
**  17 Oct 08 Lisa  Case 05620 discovered the assign tasks popup was lost when
**                  the back button is clicked after adding a new role.  Had to
**                  check this before a role is added and display popup then.
**
*******************************************************************************/

	SET @o_error_code = 0
	SET @o_error_desc = ''

	DECLARE @error_var    INT
	DECLARE @rowcount_var INT
	DECLARE @SelectSQL	  nvarchar(max)

	IF ( len(@i_roles) > 0 )
	BEGIN
	  -- The role doesn't exist for this user yet, we are in the process of setting it up.  Return task(s) found 
	  -- for this user that match this role.
	  IF ( @i_addingrole > 0 AND @i_globalcontactkey > 0 )
	  BEGIN
	    SET @SelectSQL = 'SELECT t.taqtaskkey, 
                case when ( len(isNull(tpe.taqelementdesc,'''')) > 0 )
	                then rtrim(ltrim(d.description)) + '' ['' + rtrim(ltrim(tpe.taqelementdesc)) + '']''
	                else rtrim(ltrim(d.description))
	            end as description, 
                t.taqprojectkey, t.rolecode,
		        t.datetypecode, g.displayname, gt.datadesc, g.globalcontactkey,
			    ''1'' as roleindex  -- used to indicate which rolecode field was read
	    FROM   taqprojecttask t
	    join   datetype d on t.datetypecode = d.datetypecode
	    join   taqprojectcontact pc on t.taqprojectkey = pc.taqprojectkey
	    join   globalcontact g on pc.globalcontactkey = g.globalcontactkey
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    WHERE ( (isNull(t.globalcontactkey,0) <= 0 and t.rolecode is not null) 
		       and t.taqprojectkey = ' + convert(varchar(20), @i_projectkey) +
		       ' and g.globalcontactkey = ' + convert(varchar(20), @i_globalcontactkey) +
               ' and t.rolecode in ( ' + @i_roles + ') )

	    UNION

	    SELECT t.taqtaskkey, 
               case when ( len(isNull(tpe.taqelementdesc,'''')) > 0 )
	                then rtrim(ltrim(d.description)) + '' ['' + rtrim(ltrim(tpe.taqelementdesc)) + '']''
	                else rtrim(ltrim(d.description))
	           end as description, t.taqprojectkey, t.rolecode2,
		       t.datetypecode, g.displayname, gt.datadesc, g.globalcontactkey,
			    ''2'' as roleindex -- used to indicate which rolecode field was read
	    FROM   taqprojecttask t
	    join   datetype d on t.datetypecode = d.datetypecode
	    join   taqprojectcontact pc on t.taqprojectkey = pc.taqprojectkey
	    join   globalcontact g on pc.globalcontactkey = g.globalcontactkey
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode2
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    where ( (isNull(t.globalcontactkey2,0) <= 0 and t.rolecode2 is not null) 
		      and t.taqprojectkey = ' + convert(varchar(20), @i_projectkey) +
		      ' and g.globalcontactkey = ' + convert(varchar(20), @i_globalcontactkey) +
		      ' and t.rolecode2 in ( ' + @i_roles + ' ) )'
	  END
	  ELSE
      BEGIN
	    SET @SelectSQL = 'SELECT t.taqtaskkey, 
                case when ( len(isNull(tpe.taqelementdesc,'''')) > 0 )
	                then rtrim(ltrim(d.description)) + '' ['' + rtrim(ltrim(tpe.taqelementdesc)) + '']''
	                else rtrim(ltrim(d.description))
	            end as description, 
                t.taqprojectkey, t.rolecode,
		        t.datetypecode, g.displayname, gt.datadesc, g.globalcontactkey,
			    ''1'' as roleindex  -- used to indicate which rolecode field was read
	    FROM   taqprojecttask t
	    join   datetype d on t.datetypecode = d.datetypecode
	    join   taqprojectcontact pc on t.taqprojectkey = pc.taqprojectkey
	    join   globalcontact g on pc.globalcontactkey = g.globalcontactkey
	    join   taqprojectcontactrole pcr on pc.taqprojectcontactkey = pcr.taqprojectcontactkey
		       and t.rolecode = pcr.rolecode
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    WHERE ( (isNull(t.globalcontactkey,0) <= 0 and t.rolecode is not null) 
		       and t.taqprojectkey = ' + convert(varchar(20), @i_projectkey) +
               ' and t.rolecode in ( ' + @i_roles + ') )

	    UNION

	    SELECT t.taqtaskkey, 
               case when ( len(isNull(tpe.taqelementdesc,'''')) > 0 )
	                then rtrim(ltrim(d.description)) + '' ['' + rtrim(ltrim(tpe.taqelementdesc)) + '']''
	                else rtrim(ltrim(d.description))
	           end as description, t.taqprojectkey, t.rolecode2,
		       t.datetypecode, g.displayname, gt.datadesc, g.globalcontactkey,
			    ''2'' as roleindex -- used to indicate which rolecode field was read
	    FROM   taqprojecttask t
	    join   datetype d on t.datetypecode = d.datetypecode
	    join   taqprojectcontact pc on t.taqprojectkey = pc.taqprojectkey
	    join   globalcontact g on pc.globalcontactkey = g.globalcontactkey
	    join   taqprojectcontactrole pcr on pc.taqprojectcontactkey = pcr.taqprojectcontactkey
		       and t.rolecode2 = pcr.rolecode
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode2
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    where ( (isNull(t.globalcontactkey2,0) <= 0 and t.rolecode2 is not null) 
		      and t.taqprojectkey = ' + convert(varchar(20), @i_projectkey) +
		      ' and t.rolecode2 in ( ' + @i_roles + ' ) )'
      END
    END
	--PRINT @SelectSQL
  
	-- EXECUTE the dynamic SELECT statement
	EXECUTE sp_executesql @SelectSQL 

GO

GRANT EXEC on qproject_get_unassigned_tasks TO PUBLIC
GO


