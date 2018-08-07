SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bkcomments_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bkcomments_view]
GO


/****** Object:  View dbo.bkcomments_view    Script Date: 5/22/2000 4:22:18 PM ******/
CREATE VIEW dbo.bkcomments_view 
	(bookkey,printingkey,commenttypecode,
	 commenttypesubcode,commentstring,commenttext)
as 
select bookcomments.bookkey,bookcomments.printingkey,
bookcomments.commenttypecode,bookcomments.commenttypesubcode,
bookcomments.commentstring,bookcomments.commenttext 
from bookcomments

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[bkcomments_view]  TO [public]
GO

