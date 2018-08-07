if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].get_culture') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].get_culture
GO


CREATE FUNCTION dbo.get_culture (@i_userkey INT ,
 @i_taqprojectkey INT,
 @i_bookkey INT)

RETURNS @culturetable TABLE(
    qsiusersculturecode INT,
    projectculturecode  INT,
    bookculturecode INT
	)
AS
BEGIN

DECLARE
  @v_count	INT,
  @v_qsiusersculturecode   INT,
  @v_taqprojectculturecode INT,
  @v_bookculturecode INT
  
  --SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
  
   --user culture
   IF COALESCE(@i_userkey,0) IS NOT NULL BEGIN
    SELECT @v_qsiusersculturecode = culturecode FROM qsiusers WHERE userkey = @i_userkey
    IF @v_qsiusersculturecode IS NULL OR @v_qsiusersculturecode = 0 BEGIN
		SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
	    IF @v_count = 1 BEGIN
			SELECT @v_qsiusersculturecode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 78
		END
		ELSE IF @v_count = 0 BEGIN
			SELECT @v_qsiusersculturecode = datacode FROM gentables WHERE tableid = 670 and qsicode = 1
		END 
    END 
   END
   ELSE BEGIN    --userkey is null
    SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
    IF @v_count = 1 BEGIN
		SELECT @v_qsiusersculturecode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 78
	END
	ELSE IF @v_count = 0 BEGIN
		SELECT @v_qsiusersculturecode = datacode FROM gentables WHERE tableid = 670 and qsicode = 1
	END 
   END
   

   -- taqproject culture
   IF (@i_taqprojectkey > 0) BEGIN
    SELECT @v_taqprojectculturecode = culturecode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey
	IF @v_taqprojectculturecode IS NULL OR @v_taqprojectculturecode = 0 BEGIN
		IF COALESCE(@i_userkey,0) IS NOT NULL BEGIN
			SELECT @v_taqprojectculturecode = culturecode FROM qsiusers WHERE userkey = @i_userkey  --return user culture code
			IF @v_taqprojectculturecode IS NULL OR @v_taqprojectculturecode = 0 BEGIN
			    SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
				IF @v_count = 1 BEGIN
					SELECT @v_taqprojectculturecode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 78
				END
				ELSE IF @v_count = 0 BEGIN
					SELECT @v_taqprojectculturecode = datacode FROM gentables WHERE tableid = 670 and qsicode = 1
				END 
			END
		END
		ELSE BEGIN   --userkey is null
			SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
			IF @v_count = 1 BEGIN
				SELECT @v_taqprojectculturecode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 78
			END
			ELSE IF @v_count = 0 BEGIN
				SELECT @v_taqprojectculturecode = datacode FROM gentables WHERE tableid = 670 and qsicode = 1
			END 
		END
	END
   END  --taqprojectkey > 0
   ELSE BEGIN  --taqprojectkey = 0
    IF COALESCE(@i_userkey,0) IS NOT NULL BEGIN  --userkey is not null
		SELECT @v_taqprojectculturecode = culturecode FROM qsiusers WHERE userkey = @i_userkey  --return user culture code
		IF @v_taqprojectculturecode IS NULL OR @v_taqprojectculturecode = 0 BEGIN
		    SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
			IF @v_count = 1 BEGIN
				SELECT @v_taqprojectculturecode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 78
			END
			ELSE IF @v_count = 0 BEGIN
				SELECT @v_taqprojectculturecode = datacode FROM gentables WHERE tableid = 670 and qsicode = 1
			END 
		END
	END
	ELSE BEGIN   --userkey is null
		SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
		IF @v_count = 1 BEGIN
			SELECT @v_taqprojectculturecode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 78
		END
		ELSE IF @v_count = 0 BEGIN
			SELECT @v_taqprojectculturecode = datacode FROM gentables WHERE tableid = 670 and qsicode = 1
		END 
	END
   END --taqprojectkey = 0
   
   -- book culture
   SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = 78
   IF @v_count = 1 BEGIN
	SELECT @v_bookculturecode = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 78
   END
   ELSE BEGIN
	SELECT @v_bookculturecode = datacode FROM gentables WHERE tableid = 670 and qsicode = 1
   END
   
   INSERT INTO @culturetable VALUES (@v_qsiusersculturecode,@v_taqprojectculturecode,@v_bookculturecode)
   
   RETURN
END
GO

GRANT SELECT ON dbo.get_culture TO public
GO