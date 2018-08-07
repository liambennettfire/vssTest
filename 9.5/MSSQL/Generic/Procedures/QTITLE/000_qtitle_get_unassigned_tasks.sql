IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_unassigned_tasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qtitle_get_unassigned_tasks]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
declare @err int
declare @dsc varchar(2000)
--exec qtitle_get_unassigned_tasks 594072, 1, '23', 0, 0, @err, @dsc
exec qtitle_get_unassigned_tasks 594072, 1, '18', 1, 565391, @err, @dsc

*/

CREATE PROCEDURE [dbo].[qtitle_get_unassigned_tasks]
 (@i_bookkey			integer,
  @i_printingkey        integer,
  @i_roles				varchar(1000),
  @i_addingrole         smallint,
  @i_globalcontactkey   integer,
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_unassigned_tasks
**  Desc: This stored procedure returns a list of unassigned tasks and the
**		  the possible contacts currently linked to the book/title as participants
**		  who have a rolecode from the rolecode list sent in that is on the task.
**
**  Parameters:
**		@i_bookkey - bookkey column of taqprojecttask table
**      @i_printingkey - printingkey column of taqprojecttask table
**
**  Auth: Lisa Cormier
**  Date: 15 Sep 2008
**
*******************************************************************************
**  Date      Who   Change
**  -------   ---   -------------------------------------------
**  13 Oct 08 Lisa  Cloned from qprojet_get_unassigned_tasks case 05591
**                  we decided to make this work for titles as well.
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
	    join   bookcontact bc on t.bookkey = bc.bookkey AND t.printingkey = bc.printingkey
	    join   globalcontact g on bc.globalcontactkey = g.globalcontactkey
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    WHERE ( (isNull(t.globalcontactkey,0) <= 0 and t.rolecode is not null) 
		         AND t.bookkey = ' + convert(varchar(20), @i_bookkey) + 
		       ' AND t.printingkey = ' + convert(varchar(20), @i_printingkey) + 
		       ' AND g.globalcontactkey = ' + convert(varchar(20), @i_globalcontactkey) +
               ' AND t.rolecode in ( ' + @i_roles + ' ) )
               
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
	    WHERE ( (isNull(t.globalcontactkey2,0) <= 0 and t.rolecode2 is not null) 
		         AND t.bookkey = ' + convert(varchar(20), @i_bookkey) + 
		       ' AND t.printingkey = ' + convert(varchar(20), @i_printingkey) + 
		       ' AND g.globalcontactkey = ' + convert(varchar(20), @i_globalcontactkey) +
               ' AND t.rolecode2 in ( ' + @i_roles + ' ) ) '
               
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
	    join   bookcontact bc on t.bookkey = bc.bookkey AND t.printingkey = bc.printingkey
	    join   globalcontact g on bc.globalcontactkey = g.globalcontactkey
	    join   bookcontactrole bcr on bc.bookcontactkey = bcr.bookcontactkey
		       and t.rolecode = bcr.rolecode
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    WHERE ( (isNull(t.globalcontactkey,0) <= 0 and t.rolecode is not null) 
		         AND t.bookkey = ' + convert(varchar(20), @i_bookkey) + 
		       ' AND t.printingkey = ' + convert(varchar(20), @i_printingkey) + 
               ' AND t.rolecode in ( ' + @i_roles + ' ) )
               
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
	    join   bookcontactrole bcr on bc.bookcontactkey = bcr.bookcontactkey
		       and t.rolecode2 = bcr.rolecode
	    join   gentables gt on gt.tableid = 285 and gt.datacode = t.rolecode2
	    left join taqprojectelement tpe on t.taqelementkey = tpe.taqelementkey
	    WHERE ( (isNull(t.globalcontactkey2,0) <= 0 and t.rolecode2 is not null) 
		         AND t.bookkey = ' + convert(varchar(20), @i_bookkey) + 
		       ' AND t.printingkey = ' + convert(varchar(20), @i_printingkey) + 
               ' AND t.rolecode2 in ( ' + @i_roles + ' ) ) '
               
	  END
    END
    
	PRINT @SelectSQL
  
	-- EXECUTE the dynamic SELECT statement
	EXECUTE sp_executesql @SelectSQL 

GO

GRANT EXEC on qtitle_get_unassigned_tasks TO PUBLIC
GO


