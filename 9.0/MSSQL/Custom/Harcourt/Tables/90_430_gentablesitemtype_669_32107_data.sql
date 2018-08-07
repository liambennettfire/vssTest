-- 32107 TM Web Process
-- Necesary itemtype / usage class data to implement Easy Bar show/hide for TM Web Process button
-- JH

DECLARE	@o_error_code int,
		@o_error_desc varchar(2000),
		@o_datacode int,
		@o_datasubcode int,
		@v_tablemnemonic varchar(40),
		@v_tableid int,
		@v_usageclasscode int,
		@v_itemtypecode int

SET @o_error_desc = ''
SET @o_error_code = 0
SET @o_datasubcode = 0

SELECT @v_tableid = 669
SET @o_datacode = 1
SET @v_itemtypecode = 3 -- Projects
SET @v_usageclasscode = 16 -- Marketing Plan

EXEC qutl_insert_gentablesitemtype	@v_tableid,
									@o_datacode,
									0,
									0,
									@v_itemtypecode,
									@v_usageclasscode,
									@o_error_code OUTPUT,
									@o_error_desc OUTPUT