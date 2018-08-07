IF EXISTS(SELECT * FROM sys.objects WHERE type = 'fn' and name = 'qutl_get_misclabel' ) 
drop function qutl_get_misclabel
go