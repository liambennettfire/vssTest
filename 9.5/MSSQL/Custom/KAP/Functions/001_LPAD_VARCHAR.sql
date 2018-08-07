if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LPAD_varchar]') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].[LPAD_varchar]
GO

CREATE FUNCTION dbo.LPAD_varchar
( @left as varchar(8000), 
  @n as int, 
  @pad as varchar(8000) = ' '
)
returns varchar(8000)

/* 4/16/07 - KW - Created for Kaplan based on the SQL Server 2005 Migration Assistant Extention Pack function:
                  SYSDB.SSMA.LPAD_varchar */
begin

    return dbo.PAD_varchar(1, @left, @n, @pad)
end
