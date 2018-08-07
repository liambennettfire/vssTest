

/****** Object:  UserDefinedFunction [dbo].[rpt_get_all_minimum_category]    Script Date: 3/4/2016 2:02:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_all_minimum_category]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_all_minimum_category]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_all_minimum_category]    Script Date: 3/4/2016 2:02:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[rpt_get_all_minimum_category](@i_taqprojectkey int, @i_bookkey int, @i_category_tableid int, @v_DescType varchar(10),@limit int, @seperator varchar(2))
returns varchar(8000)
begin
declare @return varchar(8000)

if @i_taqprojectkey >0 or @i_bookkey >0


declare @seq int
Set @seq=1
set @return=''

while @seq <=@limit
begin

if @i_taqprojectkey>0 and @i_taqprojectkey is not null begin
	set @return =@return+isnull( dbo.rpt_get_minimum_project_category(@i_taqprojectkey, @i_category_tableid ,@seq,@v_DescType),'')
end
else begin
	set @return = @return+ isnull(dbo.rpt_get_minimum_category(@i_bookkey, @i_category_tableid ,@seq,@v_DescType),'')
end
if @seq <> @limit and right(@return,1)<>isnull(nullif(@seperator,''),';') begin
set @return=@return+isnull(nullif(@seperator,''),';')
end

set @seq=@seq+1
end



return rtrim(ltrim(@return))
end

GO

grant all on rpt_get_all_minimum_category to public