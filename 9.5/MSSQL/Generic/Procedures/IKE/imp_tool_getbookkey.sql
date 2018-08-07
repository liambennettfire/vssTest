SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/******************************************************************************
**  Name: imp_tool_getbookkey
**  Desc: IKE feedback utility. Get bookkey from  feedback row
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_tool_getbookkey]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_tool_getbookkey]
GO


CREATE PROCEDURE dbo.imp_tool_getbookkey 
  @i_elementkey bigint,
  @i_elementval varchar(8000),
  @o_bookkey int output,
  @o_errcode int output,
  @o_errmsg varchar(500) output
AS

BEGIN 
  DECLARE 
    @v_count int,
    @v_elementkey int
            
  set @o_bookkey = null
                
  if @i_elementkey = 2 -- isbn10
    begin
      select @o_bookkey=bookkey
        from isbn
        where isbn10=@i_elementval
    end
                    
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_tool_getbookkey to PUBLIC 
GO
