/******************************************************************************
**  HMH was found to have a gentable entry with 0 for datacode on the 
**   languages tableid ( 318 ). This is not plausible as 0 is used for
**   blank datacode options and is negateively effecting TMM dropdown and
**   label usage. When Polish was selected from Classifications->Language
**   It wouldn't show up in view mode for example. This will ensure there
**   isn't any 0 datacode in the languages tableid, it will move whatever 
**   might be there to the end of the list.
*******************************************************************************/

DECLARE @_dataDesc varchar(255)
DECLARE @_maxDataCode INT

SELECT @_dataDesc = dataDesc from gentables g WHERE g.tableid = 318 AND g.datacode = 0
SELECT @_maxDataCode = MAX(datacode) FROM gentables g WHERE g.tableid = 318

UPDATE gentables SET datacode = @_maxDataCode + 1 WHERE tableid = 318 and datacode = 0
