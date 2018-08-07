if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_csCustomers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  PRINT 'Dropping Procedure qcs_get_csCustomers'
  DROP PROCEDURE  qcs_get_csCustomers
END
GO

PRINT 'Creating Procedure qcs_get_csCustomers'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcs_get_csCustomers]

AS

  select * from customer
  where cloudaccesskey is not null
  AND cloudaccesssecret is not null

GO
GRANT EXEC ON qcs_get_csCustomers TO PUBLIC
GO


