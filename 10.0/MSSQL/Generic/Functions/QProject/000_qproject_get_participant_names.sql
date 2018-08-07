IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qproject_get_participant_names') AND xtype IN (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_participant_names
GO

CREATE FUNCTION dbo.qproject_get_participant_names
(
  @i_projectkey as integer,
  @i_keyind as integer,
  @i_maxcount as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qproject_get_participant_names
**  Desc: Retuns a '/' delimited string of project participant display names
**
**  Parameters:
**    @i_keyind - 0 = non-key
**              - 1 = key
**              - 2 = key followed by non-key
**    @i_maxcount - maximum number of participants to return
**
**  Auth: Colman
**  Date: 08/10/2017
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_participants  VARCHAR(max),
    @v_displayname VARCHAR(255),
    @v_returnvalue VARCHAR(255)
      
  SET @v_returnvalue = NULL
  SET @v_participants = ''
	 
  DECLARE participant_cur CURSOR FOR 
  SELECT TOP(@i_maxcount) ISNULL(gc.displayname,'') displayname
    FROM globalcontact gc, taqproject tp, taqprojectcontact tpc
    WHERE tp.taqprojectkey=@i_projectkey
      AND gc.globalcontactkey=tpc.globalcontactkey
      AND tp.taqprojectkey=tpc.taqprojectkey
      AND (@i_keyind = 2 OR ISNULL(tpc.keyind,0) = @i_keyind)
    ORDER BY tpc.keyind desc, tpc.sortorder

  OPEN participant_cur 
  FETCH participant_cur INTO @v_displayname
 
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF LEN(@v_displayname) > 0
    BEGIN
      IF LEN(@v_participants) > 1
        SET @v_participants = @v_participants + '/'

      SET @v_participants = @v_participants + LTRIM(RTRIM(ISNULL(@v_displayname,'')))
    END
    
    FETCH participant_cur INTO @v_displayname 
  END
  
  CLOSE participant_cur 
  DEALLOCATE participant_cur 

  IF LEN(@v_participants) > 0
    SET @v_returnvalue = SUBSTRING(@v_participants,1,255)

  RETURN @v_returnvalue
  
END
GO

GRANT EXEC ON dbo.qproject_get_participant_names TO PUBLIC
GO
