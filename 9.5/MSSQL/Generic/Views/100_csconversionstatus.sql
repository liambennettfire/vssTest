IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csconversionstatus]') AND type in (N'V'))
DROP VIEW [dbo].[csconversionstatus]
GO

CREATE VIEW [csconversionstatus] AS
    SELECT 
        d.datetypecode, 
        d.description, 
        d.datelabel, 
        d.csstatuscode, 
        s.eloquencefieldtag AS cloudstatustag,
        t.qsicode
    FROM datetype d, gentables t, gentables s
    WHERE 
        t.tableid=575 AND 
        d.cstransactioncode=t.datacode AND 
        s.tableid=579 AND 
        d.csstatuscode=s.datacode AND
        t.qsicode=3
        
GO

GRANT  SELECT  ON [dbo].[csconversionstatus]  TO [public]
GO
 