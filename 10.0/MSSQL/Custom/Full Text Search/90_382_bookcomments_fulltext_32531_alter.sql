alter table bookcomments
add BookcommentsKey int identity(1,1)
go

CREATE UNIQUE NONCLUSTERED INDEX [BookComments_FSU01] ON [dbo].[bookcomments] 
(
	[BookcommentsKey] 
)
go
