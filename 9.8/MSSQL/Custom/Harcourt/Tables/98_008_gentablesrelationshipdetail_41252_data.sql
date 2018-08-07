DECLARE  @o_gentablesrelationshipdetailkey integer,
         @o_error_code	integer,
         @o_error_desc	varchar(2000)

EXEC qutl_insert_gentablesrelationshipdetail_value 36, 'Project', 3, 'Marketing Campaign (Projects)', NULL, 'Marketing Project', 3, NULL, NULL, 0, 
                                    @o_gentablesrelationshipdetailkey output, @o_error_code output, @o_error_desc output
GO
