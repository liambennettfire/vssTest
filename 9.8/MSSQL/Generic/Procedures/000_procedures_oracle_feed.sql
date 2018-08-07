SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_create') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_create
GO

CREATE PROCEDURE po_create
	(@i_gpokey INT,
    @o_error_code integer output)
AS
   SELECT @o_error_code = 1
   RETURN
GO

GRANT EXEC ON po_create TO PUBLIC
GO


if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_finalized') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_finalized
GO

CREATE PROCEDURE po_finalized
	(@i_gpokey INT,
    @o_error_code             integer output)
AS
	SELECT @o_error_code = 1
   RETURN
GO

GRANT EXEC ON po_finalized TO PUBLIC
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_cancel') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_cancel
GO

CREATE PROCEDURE po_cancel
	(@i_gpokey INT,
    @o_error_code             integer output)
AS
   SELECT @o_error_code = 1
   RETURN
GO

GRANT EXEC ON po_cancel TO PUBLIC
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_cce') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_cce
GO

CREATE PROCEDURE po_cce
	(@i_bookkey INT,
    @i_printingkey INT,
    @o_error_code             integer output)
AS   
   SELECT @o_error_code = 1
   RETURN
GO

GRANT EXEC ON po_cce TO PUBLIC
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_project') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_project
GO

CREATE PROCEDURE po_project
	(@i_bookkey INT,
    @i_printingkey INT,
    @o_error_code             integer output)
AS
   SELECT @o_error_code = 1
   RETURN
GO

GRANT EXEC ON po_project TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF 
GO