SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_gentables_category_code') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.get_gentables_category_code
end
GO

/******************************************************************************
**  Name: get_gentables_category_code
**
**  Desc: This stored procedure returns the LOWEST first found occurrence of the
**        input external category code coming in.  Because these strings may
**        not necessarily be unique on 2 & 3rd gentable levels we will return
**        the 'top 1' record found.
**
**  Examples:
**      Gentable        Subgentables    Sub2gentables
**      --------------  --------------  -------------------
**      'Dog'           'Hound'         'Beagle'
**      'Dog'           'Small'         'Beagle'
**      'Cat'           'Small'         null
**      'Cat'           'Cat'           null
**      'Cat'           'Cat'           'Cat'
**      'Animal'        'Small'         'Cat'
**
**      Returns Dog/Hound/Beagle    for externalcode 'Beagle'
**      Returns Dog/null/null       for external code 'Dog'
**      Returns Dog/Hound/null      for external code 'Hound'
**      Returns Dog/Small           for external code 'Small'
**      Returns Cat/Cat/Cat         for external code 'Cat'
**
**    Auth: Lisa Cormier
**    Date: 30 July 2009
*******************************************************************************/

CREATE PROCEDURE [dbo].[get_gentables_category_code] 
  (@i_tableid int, 
   @i_externalcode varchar(30), 
   @o_datacode int OUTPUT,
   @o_datasubcode int OUTPUT,
   @o_datasub2code int OUTPUT )

AS
BEGIN
    if @i_externalcode is null return
    
    set @o_datacode = null
    set @o_datasubcode = 0
    set @o_datasub2code = 0
    
    -- Check the lowest level first
    Select top 1 @o_datacode = datacode, @o_datasubcode = datasubcode, @o_datasub2code = datasub2code 
    from sub2gentables
    where tableid = @i_tableid
    and rtrim(ltrim(externalcode)) = rtrim(ltrim(@i_externalcode))

    -- return if there was a match
    if ( @o_datacode is not null ) return
    
    -- Check 2nd level
    Select top 1 @o_datacode = datacode, @o_datasubcode = datasubcode 
    from subgentables
    where tableid = @i_tableid
    and rtrim(ltrim(externalcode)) = rtrim(ltrim(@i_externalcode))
    
    -- return if there was a match
    if ( @o_datacode is not null ) return

    -- Check top level
    Select @o_datacode = datacode 
    from gentables
    where tableid = @i_tableid
    and rtrim(ltrim(externalcode)) = rtrim(ltrim(@i_externalcode))
END
GO

GRANT EXEC ON get_gentables_category_code TO PUBLIC
GO



