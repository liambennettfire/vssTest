if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whviewcleancolumnname_func]') and OBJECTPROPERTY(id, N'IsFunction') = 1)
drop function [dbo].[whviewcleancolumnname_func]
GO


create function whviewcleancolumnname_func (@c_columnname varchar (255))
returns varchar (255)
as
begin

/** This procedure will clean the column name passed in first parameter **/



/*All Lower Case */
select @c_columnname = lower (@c_columnname)
/*Spaces to Underscore */
select @c_columnname = replace (@c_columnname, ' ','_')
/*Slash to Dash */
select @c_columnname = replace (@c_columnname, '/','-')
/*Slash to Dash */
select @c_columnname = replace (@c_columnname, '\','-')

return @c_columnname

end

