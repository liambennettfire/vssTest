IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_clouduploadstaging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].qcs_get_clouduploadstaging
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jason
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE qcs_get_clouduploadstaging

AS
BEGIN
SELECT 
    a.*, 
    (
        SELECT Count(b.uploadjobkey) 
        FROM clouduploadstaging b
        Where b.uploadjobkey = a.uploadjobkey
    ) as jobcount 
FROM  clouduploadstaging a
ORDER BY a.uploadjobkey, a.jobendind, a.lastmaintdate

END
GO

GRANT EXEC ON qcs_get_clouduploadstaging TO PUBLIC
GO