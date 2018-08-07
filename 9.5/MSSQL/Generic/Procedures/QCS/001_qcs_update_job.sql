IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_update_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_update_job]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================
-- Author:		Jason
-- Create date: 4/2/2013
-- Description:	Update job
-- ====================================================================
CREATE PROCEDURE [qcs_update_job]
 (
  @i_qsibatchkey            integer output,
  @i_qsijobkey              integer output,
  @i_jobtypecode            integer,
  @i_jobtypesubcode         integer,
  @i_jobdesc                varchar(2000),
  @i_jobdescshort           varchar(255),
  @i_userid                 varchar(30),
  @i_referencekey1          integer,
  @i_referencekey2          integer,
  @i_referencekey3          integer,
  @i_messagetypecode        integer,
  @i_messagelongdesc        varchar(4000),
  @i_messageshortdesc       varchar(255),
  @i_messagecode            integer,
  @i_messagetypeqsicode     integer
 )
AS
BEGIN
	
	DECLARE @o_error_code INT
	DECLARE @o_error_desc VARCHAR(2000)
	
	EXEC qutl_update_job @i_qsibatchkey OUTPUT, @i_qsijobkey OUTPUT ,@i_jobtypecode,@i_jobtypesubcode,@i_jobdesc,@i_jobdescshort,@i_userid,@i_referencekey1,@i_referencekey2,@i_referencekey3,@i_messagetypecode,@i_messagelongdesc,@i_messageshortdesc,@i_messagecode,@i_messagetypeqsicode, @o_error_code OUTPUT, @o_error_desc OUTPUT
	
	IF @o_error_code = -1
	BEGIN
		RAISERROR(@o_error_desc, 16, 1)
		RETURN
	END
	
    RETURN
    
END
GO

GRANT EXEC ON qcs_update_job TO PUBLIC
GO


