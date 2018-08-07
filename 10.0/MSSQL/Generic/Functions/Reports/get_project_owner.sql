if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_project_owner') and xtype in (N'FN', N'IF', N'TF'))

  drop function dbo.rpt_get_project_owner

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_project_owner]

(

  @i_projectkey as integer,

  @v_column	VARCHAR(1)

) 

RETURNS VARCHAR(255)



/*******************************************************************************************************

**  Name: rpt_get_project_owner

**  Desc: This function returns project owner name (from the Users table. Name type

**  depends on v_column

		@v_column

			D = returns the display name

			F = returns the first name

			L = returns the middle name

											

**  Auth: Doug Lessing

**  Date: April 27 2009

*******************************************************************************************************/



BEGIN 

  DECLARE



    @v_desc  VARCHAR(255),

    @RETURN  VARCHAR(255)



 

	IF @v_column = 'D'

		BEGIN

			SELECT @v_desc = RTRIM(LTRIM("Full Name"))

			from rpt_project_owner_view

			WHERE taqprojectkey = @i_projectkey

		END



	IF @v_column = 'F'

		BEGIN

			SELECT @v_desc = RTRIM(LTRIM(firstname))

			from rpt_project_owner_view

			WHERE taqprojectkey = @i_projectkey

		END



	IF @v_column = 'L'

		BEGIN

			SELECT @v_desc = RTRIM(LTRIM(lastname))

			from rpt_project_owner_view

			WHERE taqprojectkey = @i_projectkey

		END



	

	IF LEN(@v_desc)> 0

		BEGIN

			SELECT @RETURN = @v_desc

		END

	ELSE

		BEGIN

			SELECT @RETURN = ''

		END





RETURN @RETURN





END

go

grant execute on rpt_get_project_owner to public

go



