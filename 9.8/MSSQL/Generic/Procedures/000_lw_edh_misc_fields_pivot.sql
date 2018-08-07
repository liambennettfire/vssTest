IF EXISTS (SELECT
		*
	FROM dbo.sysobjects
	WHERE id = OBJECT_ID(N'[dbo].[lw_edh_misc_fields_pivot]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[lw_edh_misc_fields_pivot]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[lw_edh_misc_fields_pivot]
as
/** Revision History  **/
/** Created by BDT 2015-07-09  ***/

/** This procedure will alter the swag_misc_fields_pivot view to capture and flatten all misc fields being used for EDH */

--alter the swag_misc_fields_pivot view to capture any new misc fields added
declare @sql nvarchar(max)

set @sql = 
'ALTER view [dbo].[SWAG_misc_fields_pivot]
as
select b.bookkey as pimKey,'

select @sql = @sql + 
'dbo.rpt_lr_edh_get_misc_value_xml(b.bookkey,'+cast(misckey as varchar(5))+')'+' as '+miscName+','
from swag_misc_fields where left(miscname,2) <> 'xr'

set @sql = SUBSTRING(@sql,1,len(@sql)-1)

set @sql = @sql +
' from book b'

--print @sql


execute sp_executesql @sql


GO


