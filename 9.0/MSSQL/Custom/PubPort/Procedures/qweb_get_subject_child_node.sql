if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_subject_child_node]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_get_subject_child_node]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qweb_get_subject_child_node
 (@i_websitekey      integer,
  @i_subjectcode     integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

    SELECT DISTINCT subjectsubcode,subjectsubdesc
      FROM qweb_wh_titlesubjects
     WHERE websitekey=@i_websitekey
       and subjectcode=@i_subjectcode
  ORDER BY subjectsubdesc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'no subjects found (subjectcode ' + cast(@i_subjectcode AS VARCHAR) + ')'
  END 

GO
GRANT EXEC ON qweb_get_subject_child_node TO PUBLIC
GO



