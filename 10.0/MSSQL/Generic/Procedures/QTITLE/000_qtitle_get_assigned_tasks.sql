IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_assigned_tasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qtitle_get_assigned_tasks]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qtitle_get_assigned_tasks]
 (@i_bookkey			    integer,
  @i_printingkey      integer,
  @i_roles				    varchar(1000),
  @i_includeactualind smallint,
  @i_globalcontactkey integer,
  @o_error_code			  integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_assigned_tasks
**  Desc: This stored procedure returns a list of tasks assigned to the specified
**        contact with the specified role(s).
**
**  Parameters:
**		@i_bookkey - bookkey column of taqprojecttask table
**    @i_printingkey - printingkey column of taqprojecttask table
**    @i_roles - comma delimited list of role keys
**    @i_includeactualind - 0 = non-actual only, 1 = actual only, 2 = all tasks
**    @i_globalcontactkey - get tasks assigned to this contact
**
**  Auth: Colman
**  Date: 4/14/2016
**
*******************************************************************************
**  Date      Who   Change
**  -------   ---   -------------------------------------------
**
*******************************************************************************/

	SET @o_error_code = 0
	SET @o_error_desc = ''

	DECLARE @error_var    INT
	DECLARE @rowcount_var INT
  DECLARE @in_actuals    VARCHAR(10)
	DECLARE @SelectSQL	  nvarchar(max)

  SET @in_actuals = 
    CASE @i_includeactualind
    WHEN 0 THEN '0'
    WHEN 1 THEN '1'
    ELSE '0,1'
    END

	IF ( len(@i_roles) > 0 )
	BEGIN
	  -- Return task(s) found for this user that match this role.
	  IF ( @i_globalcontactkey > 0 )
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
	    join   bookcontact bc on t.bookkey = bc.bookkey AND t.printingkey = bc.printingkey
	    join   globalcontact g on bc.globalcontactkey = g.globalcontactkey
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    WHERE ( isNull(t.globalcontactkey,0) = ' + convert(varchar(20), @i_globalcontactkey) + '
		         AND t.bookkey = ' + convert(varchar(20), @i_bookkey) + 
		       ' AND t.printingkey = ' + convert(varchar(20), @i_printingkey) + 
		       ' AND g.globalcontactkey = ' + convert(varchar(20), @i_globalcontactkey) +
               ' AND t.rolecode in ( ' + @i_roles + ' )
                 AND t.actualind in (' + @in_actuals + '))
               
	    UNION

        SELECT t.taqtaskkey,
                case when ( len(isNull(tpe.taqelementdesc,'''')) > 0 )
	                then rtrim(ltrim(d.description)) + '' ['' + rtrim(ltrim(tpe.taqelementdesc)) + '']''
	                else rtrim(ltrim(d.description))
	            end as description, 
                t.taqprojectkey, t.rolecode2,
		        t.datetypecode, g.displayname, gt.datadesc, g.globalcontactkey,
			    ''2'' as roleindex  -- used to indicate which rolecode field was read
	    FROM   taqprojecttask t
	    join   datetype d on t.datetypecode = d.datetypecode
	    join   bookcontact bc on t.bookkey = bc.bookkey AND t.printingkey = bc.printingkey
	    join   globalcontact g on bc.globalcontactkey = g.globalcontactkey
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode2
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    WHERE ( isNull(t.globalcontactkey2,0) = ' + convert(varchar(20), @i_globalcontactkey) + '
		         AND t.bookkey = ' + convert(varchar(20), @i_bookkey) + 
		       ' AND t.printingkey = ' + convert(varchar(20), @i_printingkey) + 
		       ' AND g.globalcontactkey = ' + convert(varchar(20), @i_globalcontactkey) +
               ' AND t.rolecode2 in ( ' + @i_roles + ' )
                 AND t.actualind in (' + @in_actuals + '))'
               
	  END
  END
    
	PRINT @SelectSQL
  
	-- EXECUTE the dynamic SELECT statement
	EXECUTE sp_executesql @SelectSQL 

GO

GRANT EXEC on qtitle_get_assigned_tasks TO PUBLIC
GO


