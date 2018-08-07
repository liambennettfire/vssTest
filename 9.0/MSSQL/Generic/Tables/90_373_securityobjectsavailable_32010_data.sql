DECLARE @SummaryWindowID int
DECLARE @CommentWindowID int
DECLARE @availSecurityObjectsKey int
DECLARE @sortNum int

SELECT @SummaryWindowID = (select windowid from qsiwindows where windowname = 'TitleSummary')

update securityobjectsavailable
   set windowid = @SummaryWindowID
 where availobjectid = 'TitleCommentsByStatus' 
go
