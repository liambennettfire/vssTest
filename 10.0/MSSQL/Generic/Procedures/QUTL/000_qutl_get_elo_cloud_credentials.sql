
IF OBJECT_ID('qutl_get_elo_cloud_credentials', 'P') IS NOT NULL
  DROP PROC qutl_get_elo_cloud_credentials
GO

CREATE PROCEDURE qutl_get_elo_cloud_credentials
 (@i_customerkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_elo_cloud_credentials
**
**  Desc: This returns cloud access credentials for a given customer key.
**
**    Auth: Derek Kurth
**    Date: 05 August 2016
*******************************************************************************/

    DECLARE @error_var      INT,
            @err            int,
            @dsc            varchar(2000),
            @rowcount_var   INT
            
    SET @o_error_code = 0
    SET @o_error_desc = ''

	select customerkey, cloudaccesskey, cloudaccesssecret, cloudurl from customer where customerkey = @i_customerkey

GO

GRANT EXEC ON qutl_get_elo_cloud_credentials TO PUBLIC
GO
