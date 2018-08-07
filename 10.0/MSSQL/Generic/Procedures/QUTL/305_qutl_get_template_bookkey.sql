IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_template_bookkey')
  DROP  Procedure  qutl_get_template_bookkey
GO

CREATE PROCEDURE qutl_get_template_bookkey
 (@i_orglevelkey        integer,
  @i_orgentrykey        integer,
  @i_usageclass         integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_template_bookkey
**  Desc: Return a list of bookkeys that represent tmm web templates
**        for a orglevel/orgentry.
**
**    Auth: Alan Katzen
**    Date: 10 June 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT b.bookkey, p.printingkey, dbo.qutl_verify_template(b.bookkey,@i_orglevelkey) correcttemplate,
         b.title, dbo.qutl_get_orgentrydesc(@i_orglevelkey,@i_orgentrykey,'F') orgentrydesc
    FROM book b, bookorgentry o, printing p
   WHERE b.bookkey = o.bookkey and
         b.bookkey = p.bookkey and
         upper(b.standardind) = 'Y' and
         b.tmmwebtemplateind = 1 and
         o.orglevelkey = @i_orglevelkey and
         o.orgentrykey = @i_orgentrykey and
         b.usageclasscode = @i_usageclass
ORDER BY correcttemplate desc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no templates found:  orglevelkey:  ' + cast(@i_orglevelkey AS VARCHAR) + ' orgentrykey:  ' + cast(@i_orgentrykey AS VARCHAR)
  END 
GO

GRANT EXEC ON qutl_get_template_bookkey TO PUBLIC
GO
