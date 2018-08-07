if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_active_taq_work') and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
  drop function dbo.rpt_get_active_taq_work
GO


CREATE FUNCTION rpt_get_active_taq_work()
RETURNS @active_taq_work TABLE(in_projectkey INT, out_projectkey INT)
AS
BEGIN

/*

Select * FROM dbo.rpt_get_active_taq_work()

*/

DECLARE
  @acq_for_work INT,
  @work_for_acq INT 


SET @acq_for_work = NULL 
SET @work_for_acq = NULL 

SELECT @acq_for_work = datacode FROM gentables WHERE tableid = 582 AND qsicode = 14 -- Acquisition Project (for Work)

SELECT @work_for_acq = datacode FROM gentables WHERE tableid = 582 AND qsicode = 15 -- Work (for Acquisition Project)

--Insert work projectkeys from approved acquisitions first 
INSERT INTO @active_taq_work
SELECT taqprojectkey1, taqprojectkey2 
FROM taqprojectrelationship tpr 
WHERE relationshipcode1 = @acq_for_work 
  AND relationshipcode2 = @work_for_acq
  AND EXISTS (SELECT 1 FROM taqproject tp
              WHERE tp.taqprojectkey = tpr.taqprojectkey1
                AND tp.usageclasscode = 1 AND tp.searchitemcode  =  3 -- qsicodes from tableid = 550, 3, 1 -- Projects->Title Acquisition
  AND EXISTS (SELECT 1 FROM gentables WHERE tableid = 522 AND qsicode = 1 AND datacode = tp.taqprojectstatuscode)) -- Acquisition Approved

-- Insert acquisition projects that are not approved
INSERT INTO @active_taq_work
SELECT taqprojectkey, taqprojectkey 
FROM taqproject tp
WHERE searchitemcode IN (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 3) -- Projects
  AND usageclasscode IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode IN (1,39)) -- Title Acquisition/Additional P&L
  AND NOT EXISTS (SELECT 1 FROM gentables WHERE tableid = 522 AND qsicode = 1 AND datacode = tp.taqprojectstatuscode) -- Acquisition Approved
  
-- Insert works
INSERT INTO @active_taq_work
SELECT taqprojectkey, taqprojectkey 
FROM taqproject tp
WHERE searchitemcode IN (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Works
  AND usageclasscode IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28) -- Works  

RETURN

END
go

GRANT ALL ON rpt_get_active_taq_work TO PUBLIC
go
