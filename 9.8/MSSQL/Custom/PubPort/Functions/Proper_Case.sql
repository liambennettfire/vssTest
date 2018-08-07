SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proper_Case]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Proper_Case]
GO



CREATE FUNCTION Proper_Case
    ( @i_string as varchar(2000) ) 

RETURNS varchar(2000)

BEGIN 
   DECLARE @o_string varchar(2000)
   DECLARE @v_string varchar(2000)
   DECLARE @v_charcnt int
   DECLARE @v_capflag int

   set @v_string = LOWER(@i_string)
   set @o_string = ''
   set @v_charcnt = 1
   set @v_capflag = 1

   while    @v_charcnt <=len(@i_string)
     begin
       if @v_capflag = 1 
         set @o_string = @o_string + UPPER(substring(@v_string,@v_charcnt,1))
       else
         set @o_string = @o_string + substring(@v_string,@v_charcnt,1)
       
       if substring(@v_string,@v_charcnt,1)>='a' and 
          substring(@v_string,@v_charcnt,1)<='z'
         set @v_capflag = 0
       else
         set @v_capflag = 1

       set @v_charcnt = @v_charcnt+1

     end

  RETURN @o_string
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

