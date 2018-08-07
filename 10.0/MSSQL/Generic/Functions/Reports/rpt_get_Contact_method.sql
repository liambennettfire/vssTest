if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_Contact_method') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_Contact_method
GO
CREATE FUNCTION [dbo].[rpt_get_Contact_method]          
     (@i_Global_Contact_Key int,          
      @i_contact_method_code int,          
      @i_contact_method_subcode int)          
          
Returns varchar (100)          
          
AS          
          
BEGIN          
Declare @Return varchar (100)          
Declare @value varchar (100)          
  
Select @value=(Select Top 1 contactmethodvalue From GlobalContactMethod where globalcontactkey=          
@i_Global_Contact_Key and contactmethodcode=@i_contact_method_code and contactmethodsubcode=          
@i_contact_method_subcode and primaryind=1)         
If @value is NULL  or @value=''        
BEGIN          
Select @value=(Select Top 1 contactmethodaddtldesc From GlobalContactMethod where globalcontactkey=          
@i_Global_Contact_Key and contactmethodcode=@i_contact_method_code and contactmethodsubcode=          
@i_contact_method_subcode and primaryind=1)         
END          
Select @Return=@value          
Return @Return          
END 


GO
GRANT EXECUTE ON dbo.rpt_get_Contact_method TO PUBLIC
GO