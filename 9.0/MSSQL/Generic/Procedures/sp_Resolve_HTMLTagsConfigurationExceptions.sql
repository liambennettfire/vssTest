/**************************************************************
Created by: Marcus Keyser
Created on: July 16, 2013
Descrption: This routine resolves HTMLTag collisions during upgrades and patches

PARAMETERS:
@HTMLTagsConfigurationExceptionsKey = the Key of the record you want to resolve (in the HTMLTagsConfigurationExceptions table)
@HTMLTagsConfigurationExceptionsType = Identifies the record within the KeyGroup that you want to MAKE PRIMARY RULE
... at the point of creating this sproc the only options for Types are:
	1) ACCEPT NEW RULE = UPDATE the existing generic record with the new information (generally because FB decides to change default behavior)
	2) CREATE NEW CUSTOM RULE = UPDATE the old record to CUSTOM status which means it takes precedence + insert the new generic record which will remain inactive as long as the CUSTOM record exists
	3) KEEP EXISTING CUSTOM RULE = The client already has a custom and a generic rule ... 
		... KEEP their Custom as is
		... UPDATE their generic
	4) DELETE = delete OLD GENERIC RULE
	5) ACCEPT NEW RULE AND REMOVE CUSTOM RULE = UPDATE the existing generic record with the new information AND delete existing CUSTOM
	
USAGE EXAMPLE:
--exec sp_Resolve_HTMLTagsConfigurationExceptions 1,'ACCEPT NEW RULE'
--exec sp_Resolve_HTMLTagsConfigurationExceptions 1,'ACCEPT NEW RULE AND REMOVE CUSTOM RULE'
--exec sp_Resolve_HTMLTagsConfigurationExceptions 1,'CREATE NEW CUSTOM RULE'
--exec sp_Resolve_HTMLTagsConfigurationExceptions 1,'KEEP EXISTING CUSTOM RULE'
--exec sp_Resolve_HTMLTagsConfigurationExceptions 1,'DELETE'

select * from htmltags where HTMLTagString in ('<o:p')
select * from HTMLTagsConfigurationExceptions

**************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[sp_Resolve_HTMLTagsConfigurationExceptions]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[sp_Resolve_HTMLTagsConfigurationExceptions]
GO

CREATE PROCEDURE dbo.sp_Resolve_HTMLTagsConfigurationExceptions 
	@HTMLTagsConfigurationExceptionsKey INT
	,@HTMLTagsConfigurationExceptionsType VARCHAR(255)
AS
BEGIN
	DECLARE @DEBUG AS INT
		,@v_errcode AS INT
		,@v_errmsg AS VARCHAR(4000)

	SET @DEBUG = 0

	BEGIN TRY
		IF @DEBUG <> 0 PRINT 'START: SPROC NAME = dbo.sp_Resolve_HTMLTagsConfigurationExceptions'
		IF @DEBUG <> 0 PRINT '@HTMLTagsConfigurationExceptionsKey =  ' + cast(@HTMLTagsConfigurationExceptionsKey AS VARCHAR(max))
		IF @DEBUG <> 0 PRINT '@HTMLTagsConfigurationExceptionsType =  ' + cast(@HTMLTagsConfigurationExceptionsType AS VARCHAR(max))

		--@HTMLTagsConfigurationExceptionsKey = the Key of the record you want to resolve (in the HTMLTagsConfigurationExceptions table)
		--@HTMLTagsConfigurationExceptionsType = Identifies the record within the KeyGroup that you want to MAKE PRIMARY RULE
		--... at the point of creating this sproc the only options for Types are:
		--1) ACCEPT NEW RULE = UPDATE the existing generic record with the new information (generally because FB decides to change default behavior)
		--2) CREATE NEW CUSTOM RULE = UPDATE the old record to CUSTOM status which means it takes precedence + insert the new generic record which will remain inactive as long as the CUSTOM record exists
		--3) KEEP EXISTING CUSTOM RULE = The client already has a custom and a generic rule ... 
		--	... KEEP their Custom as is
		--	... UPDATE their generic
		--4) DELETE = delete OLD GENERIC RULE
		--5) ACCEPT NEW RULE AND REMOVE CUSTOM RULE = UPDATE the existing generic record with the new information AND delete existing CUSTOM
		
		IF @HTMLTagsConfigurationExceptionsType = 'DELETE'
		BEGIN
			IF @DEBUG <> 0 PRINT 'DELETE existing GENERIC record'
			DELETE
			FROM HTMLTags
			WHERE SYSTEM_RECORD = 1
				AND HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS = (
					SELECT TOP 1 HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS
					FROM HTMLTagsConfigurationExceptions excpt
					WHERE excpt.HTMLTagsConfigurationExceptionsKEY = @HTMLTagsConfigurationExceptionsKEY
					)			
		END 
		ELSE IF @HTMLTagsConfigurationExceptionsType IN ('ACCEPT NEW RULE','ACCEPT NEW RULE AND REMOVE CUSTOM RULE')
		BEGIN
			IF @DEBUG <> 0 PRINT 'Apply new changes to existing GENERIC record'
			UPDATE HTMLTags
			SET ASCIIMode = excpt.ASCIIMode
				,HTMLLiteMode = excpt.HTMLLiteMode
				,ReplacementStringASCIIMode = excpt.ReplacementStringASCIIMode
				,ReplacementStringHTMLLiteMode = excpt.ReplacementStringHTMLLiteMode
				,LastUser = excpt.LastUser
				,LastMaintDate = excpt.LastMaintDate
				,Notes = excpt.Notes
			FROM HTMLTagsConfigurationExceptions excpt
			INNER JOIN HTMLTags AS old ON OLD.HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS= excpt.HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS
			WHERE excpt.HTMLTagsConfigurationExceptionsKEY = @HTMLTagsConfigurationExceptionsKEY
				AND OLD.SYSTEM_RECORD = 1
			
			IF @HTMLTagsConfigurationExceptionsType = 'ACCEPT NEW RULE AND REMOVE CUSTOM RULE'
			BEGIN
				IF @DEBUG <> 0 PRINT '... Delete Old Custom Rule'
				DELETE
				FROM HTMLTags
				WHERE SYSTEM_RECORD = 0
					AND HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS = (
						SELECT TOP 1 HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS
						FROM HTMLTagsConfigurationExceptions excpt
						WHERE excpt.HTMLTagsConfigurationExceptionsKEY = @HTMLTagsConfigurationExceptionsKEY
						)				
			END
		
		END
		ELSE IF @HTMLTagsConfigurationExceptionsType = 'CREATE NEW CUSTOM RULE'
		BEGIN
			IF @DEBUG <> 0 PRINT 'Escalate OLD GENERIC rule to Custom'
			IF @DEBUG <> 0 PRINT '... get rid of any previous custom rule because there can be only one'
			DELETE
			FROM HTMLTags
			WHERE SYSTEM_RECORD = 0
				AND HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS = (
					SELECT TOP 1 HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS
					FROM HTMLTagsConfigurationExceptions excpt
					WHERE excpt.HTMLTagsConfigurationExceptionsKEY = @HTMLTagsConfigurationExceptionsKEY
					)

			IF @DEBUG <> 0 PRINT '... Change existing OLD GENERIC rule to CUSTOM stautus (SYSTEM_RECORD = 0)'
			UPDATE HTMLTags
			SET SYSTEM_RECORD = 0
			FROM HTMLTagsConfigurationExceptions excpt
			INNER JOIN HTMLTags AS old ON OLD.HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS = excpt.HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS
			WHERE excpt.HTMLTagsConfigurationExceptionsKEY = @HTMLTagsConfigurationExceptionsKEY
				AND OLD.SYSTEM_RECORD = 1

			IF @DEBUG <> 0 PRINT '... Insert new GENRIC rule as SYSTEM (SYSTEM_RECORD = 0) ... this wont execute because the CUSTOM rule takes precedence'
			INSERT INTO HTMLTags (
				SYSTEM_RECORD
				,HTMLTagString
				,ASCIIMode
				,HTMLLiteMode
				,ReplacementStringASCIIMode
				,ReplacementStringHTMLLiteMode
				,HTMLEscapeCode
				,LastUser
				,LastMaintDate
				,Notes
				)
			SELECT excpt.SYSTEM_RECORD
				,excpt.HTMLTagString
				,excpt.ASCIIMode
				,excpt.HTMLLiteMode
				,excpt.ReplacementStringASCIIMode
				,excpt.ReplacementStringHTMLLiteMode
				,excpt.HTMLEscapeCode
				,excpt.LastUser
				,excpt.LastMaintDate
				,excpt.Notes
			FROM HTMLTagsConfigurationExceptions excpt
			WHERE excpt.HTMLTagsConfigurationExceptionsKEY = @HTMLTagsConfigurationExceptionsKEY
				AND excpt.HTMLTagsConfigurationExceptionsType = 'ACCEPT NEW RULE'
		END
		ELSE IF @HTMLTagsConfigurationExceptionsType = 'KEEP EXISTING CUSTOM RULE'
		BEGIN
			IF @DEBUG <> 0 PRINT 'Apply new changes to existing GENERIC record'
			IF @DEBUG <> 0 PRINT ' ... leave OLD CUSTOM rule as is - it takes precedence over new GENERIC rule'
			UPDATE HTMLTags
			SET ASCIIMode = excpt.ASCIIMode
				,HTMLLiteMode = excpt.HTMLLiteMode
				,ReplacementStringASCIIMode = excpt.ReplacementStringASCIIMode
				,ReplacementStringHTMLLiteMode = excpt.ReplacementStringHTMLLiteMode
				,LastUser = excpt.LastUser
				,LastMaintDate = excpt.LastMaintDate
				,Notes = excpt.Notes
			FROM HTMLTagsConfigurationExceptions excpt
			INNER JOIN HTMLTags AS old ON OLD.HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS = excpt.HTMLTagString Collate SQL_Latin1_General_CP1_CS_AS 
			WHERE excpt.HTMLTagsConfigurationExceptionsKEY = @HTMLTagsConfigurationExceptionsKEY
				AND OLD.SYSTEM_RECORD = 1
		END
				
	END TRY

	BEGIN CATCH
		--something really bad happened ?!?
		SET @v_errcode = @@ERROR
		SET @v_errmsg = ERROR_MESSAGE()

		IF @DEBUG <> 0 PRINT @v_errcode
		IF @DEBUG <> 0 PRINT @v_errmsg
	END CATCH

	IF @DEBUG <> 0 PRINT 'END: SPROC NAME = dbo.sp_Resolve_HTMLTagsConfigurationExceptions'	
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[sp_Resolve_HTMLTagsConfigurationExceptions]
	TO PUBLIC
GO


