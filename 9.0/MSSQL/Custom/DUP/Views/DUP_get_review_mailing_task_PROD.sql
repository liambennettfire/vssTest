

/****** Object:  View [dbo].[DUP_get_review_mailing_task]    Script Date: 08/19/2015 08:36:14 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DUP_get_review_mailing_task]'))
DROP VIEW [dbo].[DUP_get_review_mailing_task]
GO

/****** Object:  View [dbo].[DUP_get_review_mailing_task]    Script Date: 08/19/2015 08:36:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DUP_get_review_mailing_task]   
 (activedate, taqprojectkey,bookkey)  
AS   
select activedate, taqprojectkey,bookkey  
from taqprojecttask   
where   datetypecode=2410 and actualind=1 
GO


