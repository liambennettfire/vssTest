/*update item type filtering for country rights and country.  
Filtering was set to Contacts instead of Contracts
*/

update gentablesitemtype
set itemtypecode = 10
where tableid in (114, 157) AND itemtypecode = 2
GO