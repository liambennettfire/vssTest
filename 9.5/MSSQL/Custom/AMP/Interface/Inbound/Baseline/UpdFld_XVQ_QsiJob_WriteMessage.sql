
IF OBJECT_ID('dbo.UpdFld_XVQ_QsiJob_WriteMessage') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_QsiJob_WriteMessage
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_QsiJob_WriteMessage
 (@i_qsijobkey              integer,
  @i_userid                 varchar(30),
  @i_referencekey1          integer,
  @i_referencekey2          integer,
  @i_referencekey3          integer,
  @i_messagetypecode        integer,
  @i_messagelongdesc        varchar(4000),
  @i_messageshortdesc       varchar(255),
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS
BEGIN

-- A running qsijob doesn't require jobtypecode, jobtypesubcode, jobdesc, or jobshortdesc input data in order to write a
-- proper qsijob message, so this write_qsijobmessage "wrapper" stored procedure doesn't take them as parameters and
-- just passes null values in their place in call to write_qsijobmessage.

-- write_qsijobmessage (which generates the qsi keys when a job is started) always generates a qsibatchkey value that is
-- the same as qsijobkey, so consolidate parameters by just using @i_qsijobkey.

EXEC write_qsijobmessage @i_qsijobkey, @i_qsijobkey, null, null, null, null, @i_userid,
	@i_referencekey1, @i_referencekey2, @i_referencekey3,
	@i_messagetypecode, @i_messagelongdesc, @i_messageshortdesc,
	@o_error_code output, @o_error_desc output

END
GO
