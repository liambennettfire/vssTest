SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.estversion_errorseverity_view') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.estversion_errorseverity_view
GO


CREATE VIEW estversion_errorseverity_view AS 
select v.*,dbo.get_estmessage_errorseverity(v.estkey,v.versionkey) errorseveritycode
from estversion v

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON dbo.estversion_errorseverity_view  TO public
GO

