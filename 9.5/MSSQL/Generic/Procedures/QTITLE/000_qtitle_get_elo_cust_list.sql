if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_elo_cust_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_elo_cust_list
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_elo_cust_list
 (@i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_elo_cust_list
**
**  Desc: This stored procedure returns all eloquence customer keys
**        available for this user based on org security.
**
**    Auth: Lisa Cormier
**    Date: 07 July 2009
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  06/28/2016   UK          Case 38818
*******************************************************************************/

    DECLARE @error_var      INT,
            @rowcount_var   INT,
            @v_lastsentdate datetime,
            @err            int,
            @dsc            varchar(2000),
            @flt            varchar(2000),
            @SQLString_var  NVARCHAR(1000),
            @SQLparams_var  NVARCHAR(1000)
            
    SET @o_error_code = 0
    SET @o_error_desc = ''
    
    exec qutl_get_user_orgsecurityfilter  @i_userkey, 1, 28, @flt output, @err, @dsc

    IF ( @flt = '-1' ) -- probably qsiadmin
    BEGIN
        SELECT @SQLString_var = 'select customerkey, customershortname, eloqcustomerid, 1 sortorder from customer'
    END
    ELSE
    BEGIN
        SELECT @SQLString_var = 'select customerkey, customershortname, eloqcustomerid, 1 sortorder from customer where customerkey in 
                                ( select distinct elocustomerkey from orgentry
                                where orgentrykey in ( ' + @flt + ') AND LTRIM(RTRIM(LOWER(deletestatus))) = ''n'') '                        
    END

    EXECUTE sp_executesql @SQLString_var, @SQLparams_var

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    
    IF @error_var <> 0 or @rowcount_var = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'no data found: userkey = ' + cast(@i_userkey AS VARCHAR)   
    END 

GO
GRANT EXEC ON qtitle_get_elo_cust_list TO PUBLIC
GO



