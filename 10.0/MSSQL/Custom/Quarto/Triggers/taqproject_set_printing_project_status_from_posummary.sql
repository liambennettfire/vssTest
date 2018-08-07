IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.taqproject_set_printing_project_status_from_posummary')
      AND OBJECTPROPERTY(id, N'IsTrigger') = 1
    )
  DROP TRIGGER dbo.taqproject_set_printing_project_status_from_posummary
GO

CREATE TRIGGER [dbo].[taqproject_set_printing_project_status_from_posummary] ON [dbo].[taqproject]
FOR UPDATE
AS
/*************************************************************************************
**  Change History
**************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   ------------------------------------------------------------
**  06/13/18    Colman    Case 51948
**************************************************************************************/
DECLARE @i_taqprojectkey INT,
  @i_current_posumstatuscode INT,
  @i_new_posumstatuscode INT,
  @i_printingfinishedcode INT,
  @i_senttovendorcode INT,
  @i_printingactivecode INT

SET NOCOUNT ON;

IF UPDATE (taqprojectstatuscode)
BEGIN
  /*  Get the taqprojectkey and status for the posummary */
  SELECT @i_taqprojectkey = i.taqprojectkey,
    @i_new_posumstatuscode = ISNULL(taqprojectstatuscode, 0)
  FROM inserted i

  SELECT @i_current_posumstatuscode = ISNULL(taqprojectstatuscode, 0)
  FROM deleted

  SELECT @i_printingfinishedcode = datacode
  FROM gentables g
  WHERE g.tableid = 522
    AND g.qsicode = 15 --finished

  SELECT @i_senttovendorcode = datacode
  FROM gentables g
  WHERE g.tableid = 522
    AND g.qsicode = 9 -- sent to vendor

  SELECT @i_printingactivecode = datacode
  FROM gentables g
  WHERE g.tableid = 522
    AND g.qsicode = 3 --active

  -- Only relevant to PO Summary projects
  IF NOT EXISTS (
    SELECT 1
    FROM taqproject p
    INNER JOIN subgentables g
      ON g.tableid = 550
        AND g.qsicode NOT IN (42, 43)
        AND p.searchitemcode = g.datacode
        AND p.usageclasscode = g.datasubcode
    WHERE p.taqprojectkey = @i_taqprojectkey
  )
  BEGIN
    RETURN
  END

  -- If posummary status  = 'sent to vendor' on a finished good po the update the printing status to "finished" if it isn't already
  IF @i_new_posumstatuscode <> @i_current_posumstatuscode
    AND @i_new_posumstatuscode = @i_senttovendorcode
  BEGIN
    UPDATE taqproject
    SET taqprojectstatuscode = @i_printingfinishedcode
    FROM taqproject t
    INNER JOIN dbo.rpt_posummary_to_printing_relationship_view v
      ON t.taqprojectkey = v.printingprojectkey
    WHERE v.finishedgoodpo = 1
      AND v.printingstatuscode <> @i_printingfinishedcode
      AND v.posumstatusqsicode <> 10 --exclude for voids
      AND v.posummaryprojectkey = @i_taqprojectkey
  END

  -- If posummary <> 'sent to vendor' on a finished good po then update the status to "active"
  IF @i_new_posumstatuscode <> @i_current_posumstatuscode
    AND @i_new_posumstatuscode <> @i_senttovendorcode 
  BEGIN
    UPDATE taqproject
    SET taqprojectstatuscode = @i_printingactivecode
    FROM taqproject t
    INNER JOIN dbo.rpt_posummary_to_printing_relationship_view v
      ON t.taqprojectkey = v.printingprojectkey
    WHERE v.finishedgoodpo = 1
      AND v.printingstatuscode <> @i_printingactivecode
      AND v.posummaryprojectkey = @i_taqprojectkey
  END
END
GO


