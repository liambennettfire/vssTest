IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csdistributionstatus]') AND type in (N'V'))
DROP VIEW [dbo].[csdistributionstatus]
GO

CREATE VIEW [csdistributionstatus] AS
    SELECT 
        d.datetypecode, 
        d.description, 
        d.datelabel, 
        d.csstatuscode, 
        s.eloquencefieldtag AS cloudstatustag
    FROM datetype d, gentables t, gentables s
    WHERE 
        t.tableid=575 AND 
        d.cstransactioncode=t.datacode AND 
        s.tableid=576 AND 
        d.csstatuscode=s.datacode AND
        t.qsicode=2
 

GO

GRANT  SELECT  ON [dbo].[csdistributionstatus]  TO [public]
GO
