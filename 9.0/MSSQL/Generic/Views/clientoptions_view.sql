if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[clientoptions_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[clientoptions_view]
GO

CREATE VIEW clientoptions_view AS
SELECT optionid,optioncomment,optionvalue
FROM clientoptions


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[clientoptions_view]  TO [public]
GO