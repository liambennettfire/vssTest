IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_audio_num_units') )
DROP FUNCTION dbo.rpt_get_audio_num_units
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_audio_num_units]    Script Date: 05/14/2009 12:21:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[rpt_get_audio_num_units] 
(@v_bookkey int, @v_printingkey int)
returns varchar (8000)
as
/** Revision History  **/
/** Created by DSL 6/10/2008  ***/

/** This procedure will return a  number of audio units (i.e. cassettes)
from audiocassettespecs

Written and modified 5/11/2009 by DSL  */
begin

DECLARE @c_output varchar (8000) 
DECLARE @i_numcassettes int

/** Initialize the comment strings **/
select @c_output = ''

select @i_numcassettes = numcassettes
from audiocassettespecs
where bookkey=@v_bookkey
and printingkey = @v_printingkey

if @i_numcassettes is not null
begin
	select @c_output = convert (varchar (25), @i_numcassettes)
end
else
begin
	select @c_output =''
end



/*print 'End Comment:' + @c_output*/

return @c_output
end


GO


grant exec on rpt_get_audio_num_units to public
go