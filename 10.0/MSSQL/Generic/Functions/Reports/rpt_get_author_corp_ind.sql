
/****** Object:  UserDefinedFunction [dbo].[rpt_get_author_corp_ind]    Script Date: 03/24/2009 11:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_author_corp_ind') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_author_corp_ind
GO
CREATE FUNCTION [dbo].[rpt_get_author_corp_ind] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	VARCHAR (1)

/*  The purpose of the rpt_get_author_corp_ind function is to return the flag which indicates that 
this is an author is  corporate entity or group as signified by the Corporate Contributor or Group check box on Contacts
Returns 'Y' or 'N'

	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(1)
	DECLARE @v_desc			VARCHAR(1)
	DECLARE @i_authorkey		INT
	DECLARE @i_corporatename	INT



/*  GET  AUTHOR KEY 	*/
	
	SELECT 	 @i_authorkey = dbo.rpt_get_author_key(@i_bookkey, @i_order)

	IF @i_authorkey = 0
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN
		/* GET AUTHOR NAME		*/

			SELECT @i_corporatename = corporatecontributorind
			FROM author
			WHERE authorkey = @i_authorkey


			IF @i_corporatename = 1	
				BEGIN
					SELECT @v_desc = 'Y'
				END

			ELSE
				BEGIN

					SELECT @v_desc = 'N'

				END
		END
	
	IF LEN(@v_desc) > 0
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
Grant All on dbo.rpt_get_author_corp_ind to Public
go