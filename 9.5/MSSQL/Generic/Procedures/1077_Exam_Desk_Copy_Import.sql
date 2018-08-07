SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.Exam_Desk_Copy_Import') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.Exam_Desk_Copy_Import
end
go

create PROCEDURE dbo.Exam_Desk_Copy_Import
AS
begin
	execute load_contact_main
	execute import_request_spreadsheet_procedure
	execute create_project_from_project_import
end 
go
