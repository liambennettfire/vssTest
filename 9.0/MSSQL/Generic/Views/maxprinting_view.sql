SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[maxprinting_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[maxprinting_view]
GO


/* View will be used in new title search */
CREATE VIEW maxprinting_view AS
SELECT bookkey, max(printingkey) maxprintingkey
FROM printing 
GROUP BY bookkey

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[maxprinting_view]  TO [public]
GO

