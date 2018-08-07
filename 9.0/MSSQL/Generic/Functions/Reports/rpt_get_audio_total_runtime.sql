IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_audio_total_runtime') )
DROP FUNCTION dbo.rpt_get_audio_total_runtime
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_audio_total_runtime]    Script Date: 05/14/2009 11:53:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 create function [dbo].[rpt_get_audio_total_runtime] 
(@v_bookkey int, @v_printingkey int)
returns varchar (8000)
as
/** Revision History  **/
/** Created by DSL 6/10/2008  ***/

/** This procedure will return a  totalruntime
from audiocassettespecs

Written and modified 5/11/2009 by DSL  */
begin

DECLARE @c_output varchar (8000) 
DECLARE @c_totalruntime varchar (255)

/** Initialize the comment strings **/
select @c_output = ''

select @c_totalruntime = totalruntime
from audiocassettespecs
where bookkey=@v_bookkey
and printingkey = @v_printingkey

if @c_totalruntime is not null
begin
	select @c_output = @c_totalruntime
end
else
begin
	select @c_output =''
end



/*print 'End Comment:' + @c_output*/

return @c_output
end

GO
grant execute on rpt_get_audio_total_runtime to public
go


