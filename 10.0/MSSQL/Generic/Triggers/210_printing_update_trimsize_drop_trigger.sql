/** Drop trigger if exists - when 6.2 has been sent to clients with clientoption of 7 set to 1 (update actual trim) **/
/** CRM# 3667 **/
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.printing_update_trimsize') AND type = 'TR')
	DROP TRIGGER dbo.printing_update_trimsize
GO