IF EXISTS (
	SELECT
		*
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'[dbo].[HMH_Create_Mktg_Campaigns]')
	AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[HMH_Create_Mktg_Campaigns]
GO
CREATE PROC [dbo].[HMH_Create_Mktg_Campaigns] (
	@i_instancekey int,
	@i_jobkey int,
	@o_error_code integer OUTPUT,
	@o_error_desc varchar(2000) OUTPUT)
	AS
		BEGIN

			/*
			This procedure will take a list of isbns associated with the instancekey on 
			HMHMktgCampaignISBNs table and create marketing campaigns for those isbns 
			associated with the Marketing Plan projectkey stored in the tmwebprocessinstanceitem 
			for the instancekey.  
			
			These marketing campaign projects will be created based on the default marketing campaign template 
			and associated with the title found for the isbn.
			*/

			/*
			Verify that there is only one row on tmwebprocessinstanceitem for this instancekeyand that that key1 is a 
			projectkey for a Marketing plan project (taqusageclasscode has a qsicode of 10 on subgentables where tableid = 550).  
			*/

			DECLARE @qsibatchkey int
			DECLARE @qsijobkey int
			SET @qsijobkey = @i_jobkey
			DECLARE @errorcode int
			DECLARE @errordesc varchar(2000)
			DECLARE @messagedesc varchar(8000)
			DECLARE @prev_createdate datetime
			DECLARE @next_createdate datetime
			DECLARE @prev_jobkey int
			DECLARE @i_bookkey int
			DECLARE @v_printingkey int
			DECLARE @i_JobTypeCode int
			DECLARE @error_var int
			DECLARE @rowcount_var int
			DECLARE @started_job int

      SET @started_job = 0
      
			IF NOT EXISTS (
				SELECT
					1
				FROM gentables
				WHERE tableid = 543
				AND datadesc = 'HMH Mktg Campaign Creation')
			BEGIN

				INSERT INTO
					gentables
					(
						tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate
					)
					SELECT	543,
							(
							SELECT
								MAX(datacode)
							FROM gentables
							WHERE tableid = 543)
							+ 1,
							'HMH Mktg Campaign Creation',
							'N',
							'QSIJOBTYPE',
							'Campaign Creation',
							'qsiadmin',
							GETDATE()

			END

			SELECT @i_JobTypeCode = datacode
			FROM gentables
			WHERE tableid = 543 AND
				datadesc = 'HMH Mktg Campaign Creation'

			SET @qsijobkey = @i_jobkey

      IF coalesce(@qsijobkey,0) = 0 BEGIN     
        -- start the job
			  EXEC [dbo].[write_qsijobmessage]	@qsibatchkey OUTPUT,
												  @qsijobkey OUTPUT,
												  @i_JobTypeCode,
												  0,
												  'Campaign Creation',
												  'Campaign Creation',
												  'fbt',
												  0,
												  0,
												  0,
												  1,
												  'Job Started',
												  'Job Started',
												  @o_error_code OUTPUT,
												  @o_error_desc OUTPUT
												  
        SET @started_job = 1											  
      END
      ELSE BEGIN
        -- job already started - need to get batchkey
        SELECT TOP 1 @qsibatchkey = qsibatchkey
          FROM qsijob
         WHERE qsijobkey = @qsijobkey
      END
      
			DECLARE @v_Count int
			DECLARE @i_marketingplankey int
			SELECT @v_Count = COUNT(*)
			FROM tmwebprocessinstanceitem
			WHERE processinstancekey = @i_instancekey
			SET @i_marketingplankey = (
			SELECT TOP 1
				key1
			FROM tmwebprocessinstanceitem
			WHERE processinstancekey = @i_instancekey)
			IF @v_count = 1
				AND EXISTS (
				SELECT
					1
				FROM taqproject
				WHERE taqprojectkey = @i_marketingplankey
				AND searchitemcode = 3
				AND usageclasscode = 16)
			BEGIN

				IF NOT EXISTS (
					SELECT
						*
					FROM HMHMktgCampaignISBNs
					WHERE processinstancekey = @i_instancekey)
				BEGIN
					/*		If no rows exist on HMHMktgCampaignISBNs for this instancekey
							Write an error message to qsijobmessage “No isbns have been uploaded to the HMHMktgCampaignISBNs table”; end the qsijob and return
					*/

					EXEC [dbo].[write_qsijobmessage]	@qsibatchkey OUTPUT,
														@qsijobkey,
														@i_JobTypeCode,
														0,
														'Campaign Creation',
														'Campaign Creation',
														'fbt',
														0,
														0,
														0,
														5,
														'No isbns have been uploaded to the HMHMktgCampaignISBNs table',
														'No Rows Exist',
														@o_error_code OUTPUT,
														@o_error_desc OUTPUT

					RETURN
				END
				ELSE
				BEGIN
					DECLARE	@v_datacode int,
							@v_datagroup_string varchar(2000),
							@i_searchitemcode int,
							@i_usageclasscode int

					SELECT	@i_searchitemcode = datacode,
							@i_usageclasscode = datasubcode
					FROM subgentables
					WHERE tableid = 550 AND
						qsicode = 9 ---Marketing Campaign

					SET @v_datagroup_string = ''

					DECLARE datagroup_cur CURSOR FOR
					SELECT
						i.datacode
					FROM	gentablesitemtype i,
							gentables g
					WHERE i.tableid = g.tableid
					AND i.datacode = g.datacode
					AND g.tableid = 598
					AND itemtypecode = @i_searchitemcode
					AND COALESCE(itemtypesubcode, 0) IN (0, @i_usageclasscode)
					AND g.datacode NOT IN (
					SELECT
						datacode
					FROM gentables
					WHERE tableid = 598
					AND qsicode IN (10))
					ORDER BY i.sortorder, g.sortorder, g.datadesc

					OPEN datagroup_cur

					FETCH datagroup_cur INTO @v_datacode

					WHILE (@@FETCH_STATUS = 0)
					BEGIN

						IF @v_datagroup_string = ''
							SET @v_datagroup_string = CONVERT(varchar, @v_datacode)
						ELSE
							SET @v_datagroup_string = @v_datagroup_string + ',' + CONVERT(varchar, @v_datacode)

						FETCH datagroup_cur INTO @v_datacode
					END

					CLOSE datagroup_cur
					DEALLOCATE datagroup_cur

					CREATE TABLE #temp
						(
							Seq		int	IDENTITY (1, 1),
							Ean13	varchar(13)
						)

					INSERT INTO
						#temp
						SELECT REPLACE(HMHMktgCampaignISBNs.isbn, '-', '')
						FROM HMHMktgCampaignISBNs
						WHERE processinstancekey = @i_instancekey

					DECLARE @i_Tcount int
					SELECT @i_Tcount = COUNT(*)
					FROM #temp
					DECLARE	@seq int,
							@v_EAN13 varchar(13)
					SET @seq = 1
					WHILE @seq <= @i_Tcount
					BEGIN

						SELECT @v_Ean13 = Ean13
						FROM #temp
						WHERE Seq = @seq
						IF NOT EXISTS (
							SELECT
								1
							FROM isbn
							WHERE Ean13 = @v_ean13)
						BEGIN
							EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																@qsijobkey,
																@i_JobTypeCode,
																0,
																'Campaign Creation',
																'Campaign Creation',
																'fbt',
																0,
																0,
																0,
																5,
																'No Bookkey for ISBN',
																@v_ean13,
																@o_error_code OUTPUT,
																@o_error_desc OUTPUT
							RETURN
						END
						ELSE
						BEGIN
							SET @i_bookkey = dbo.get_bookkey(@v_ean13)
							SET @v_printingkey = 1
							IF EXISTS (
								SELECT
									1
								FROM projectrelationshipview v
									JOIN taqprojecttitle t
										ON t.taqprojectkey = v.relatedprojectkey
								WHERE v.taqprojectkey = @i_marketingplankey
								AND v.relationshipcode = 20
								AND t.bookkey = @i_bookkey)
							BEGIN

								EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																	@qsijobkey,
																	@i_JobTypeCode,
																	0,
																	'Campaign Creation',
																	'Campaign Creation',
																	'fbt',
																	@i_bookkey,
																	@v_printingkey,
																	0,
																	5,
																	'Campaign Already Exists for this ISBN',
																	'Campaign Exists',
																	@o_error_code OUTPUT,
																	@o_error_desc OUTPUT

								RETURN

							END
							ELSE
							BEGIN
								--Select default marketing campaign 
								DECLARE @i_defaultKey int
								--DECLARE @i_searchitemcode int
								--DECLARE @i_usageclasscode int
								DECLARE @i_orgentrykey1 int
								DECLARE @i_orgentrykey2 int
								DECLARE @i_orgentrykey3 int
								DECLARE @v_Count_defaulttemplate int


								--SELECT @i_searchitemcode = datacode, @i_usageclasscode = datasubcode 
								--  FROM subgentables
								--  WHERE tableid = 550 and qsicode = 9 ---Marketing Campaign


								SELECT @i_orgentrykey1 = orgentrykey
								FROM bookorgentry
								WHERE bookkey = @i_bookkey AND
									orglevelkey = 1

								SELECT @i_orgentrykey2 = orgentrykey
								FROM bookorgentry
								WHERE bookkey = @i_bookkey AND
									orglevelkey = 2

								SELECT @i_orgentrykey3 = orgentrykey
								FROM bookorgentry
								WHERE bookkey = @i_bookkey AND
									orglevelkey = 3

								CREATE TABLE #temptable
									(
										taqprojectkey int
									)

								INSERT INTO
									#temptable EXEC dbo.qproject_find_default_template_by_orgentry	@i_searchitemcode,
																									@i_usageclasscode,
																									@i_orgentrykey1,
																									@i_orgentrykey2,
																									@i_orgentrykey3,
																									@o_error_code OUTPUT,
																									@o_error_desc OUTPUT

								SELECT @v_Count_defaulttemplate = COUNT(*)
								FROM #temptable
								IF @v_Count_defaulttemplate = 1
									SELECT @i_defaultkey = taqprojectkey
									FROM #temptable
								ELSE
								IF @v_Count_defaulttemplate = 0
								BEGIN
									INSERT INTO
										#temptable EXEC dbo.qproject_find_default_template_by_orgentry	@i_searchitemcode,
																										@i_usageclasscode,
																										@i_orgentrykey1,
																										@i_orgentrykey2,
																										0,
																										@o_error_code OUTPUT,
																										@o_error_desc OUTPUT

									SELECT @v_Count_defaulttemplate = COUNT(*)
									FROM #temptable
									IF @v_Count_defaulttemplate = 1
										SELECT @i_defaultkey = taqprojectkey
										FROM #temptable
									ELSE
									IF @v_Count_defaulttemplate = 0
									BEGIN
										INSERT INTO
											#temptable EXEC dbo.qproject_find_default_template_by_orgentry	@i_searchitemcode,
																											@i_usageclasscode,
																											@i_orgentrykey1,
																											0,
																											0,
																											@o_error_code OUTPUT,
																											@o_error_desc OUTPUT

										SELECT @v_Count_defaulttemplate = COUNT(*)
										FROM #temptable
										IF @v_Count_defaulttemplate = 1
											SELECT @i_defaultkey = taqprojectkey
											FROM #temptable
										ELSE
											SET @i_defaultkey = NULL
									END
								END

								DROP TABLE #temptable

								--SELECT @i_defaultkey = t.taqprojectkey
								--FROM taqproject t
								--		JOIN taqprojectorgentry o
								--			ON o.taqprojectkey = t.taqprojectkey
								--WHERE defaulttemplateind = 1 AND
								--	dbo.qutl_get_orgentrydesc(1, o.orgentrykey, 'f') = dbo.rpt_get_group_level_1(@i_bookkey, 'f') AND
								--	dbo.qutl_get_orgentrydesc(2, o.orgentrykey, 'f') = dbo.rpt_get_group_level_2(@i_bookkey, 'f') AND
								--	dbo.qutl_get_orgentrydesc(3, o.orgentrykey, 'f') = dbo.rpt_get_group_level_3(@i_bookkey, 'f') AND
								--	dbo.qutl_get_orgentrydesc(4, o.orgentrykey, 'f') = dbo.rpt_get_group_level_4(@i_bookkey, 'f')



								IF @i_defaultkey IS NULL
								BEGIN

									EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																		@qsijobkey,
																		@i_JobTypeCode,
																		0,
																		'Campaign Creation',
																		'Campaign Creation',
																		'fbt',
																		@i_bookkey,
																		@v_printingkey,
																		0,
																		5,
																		'Default Template Does not Exists for ISBNs Org Levels',
																		'No Org Entries',
																		@o_error_code OUTPUT,
																		@o_error_desc OUTPUT

									RETURN
								END
								ELSE
								BEGIN
									DECLARE @i_MarketingCampaignKey int
									EXEC get_next_key	'qsiadmin',
														@i_MarketingCampaignKey OUTPUT
									DECLARE	@v_newtitle varchar(255)
									SET @v_newtitle = dbo.rpt_get_title(@i_bookkey, 't') + ' Campaign'


									INSERT INTO
										taqproject
										(
											taqprojectkey, taqprojectownerkey, taqprojecttitle, taqprojectsubtitle, taqprojecttype, taqprojecteditionnumcode,
											taqprojectseriescode, taqprojectstatuscode, templateind, lockorigdateind, lastuserid, lastmaintdate,
											taqprojecttitleprefix, taqprojecteditiontypecode, taqprojecteditiondesc, taqprojectvolumenumber,
											termsofagreement, subsidyind, idnumber, usageclasscode, searchitemcode, additionaleditioninfo, defaulttemplateind,
											plenteredcurrency, plapprovalcurrency
										)
										SELECT	@i_MarketingCampaignKey,
												-1,
												@v_newtitle,
												taqprojectsubtitle,
												taqprojecttype,
												taqprojecteditionnumcode,
												taqprojectseriescode,
												taqprojectstatuscode,
												0,
												lockorigdateind,
												'QSIDBA',
												GETDATE(),
												taqprojecttitleprefix,
												taqprojecteditiontypecode,
												taqprojecteditiondesc,
												taqprojectvolumenumber,
												termsofagreement,
												subsidyind,
												idnumber,
												@i_usageclasscode,
												@i_searchitemcode,
												additionaleditioninfo,
												0,
												plenteredcurrency,
												plapprovalcurrency
										FROM taqproject
										WHERE taqprojectkey = @i_defaultKey

									SELECT	@error_var = @@ERROR,
											@rowcount_var = @@ROWCOUNT
									IF @error_var <> 0
									BEGIN
										EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																			@qsijobkey,
																			@i_JobTypeCode,
																			0,
																			'Campaign Creation',
																			'Campaign Creation',
																			'fbt',
																			@i_bookkey,
																			@v_printingkey,
																			0,
																			5,
																			'Insert into taqproject failed',
																			'No taqproject row',
																			@o_error_code OUTPUT,
																			@o_error_desc OUTPUT

										RETURN
									END

									INSERT INTO
										taqprojectmisc
										(
											taqprojectkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate
										)
										SELECT DISTINCT	@i_MarketingCampaignKey,
														tpm.misckey,
														longvalue,
														floatvalue,
														textvalue,
														'QSIADMIN',
														GETDATE()
										FROM taqprojectmisc tpm
												JOIN miscitemsection mis
													ON mis.misckey = tpm.misckey
										WHERE taqprojectkey = @i_defaultKey AND
											configobjectkey IN (
											SELECT
												configobjectkey
											FROM qsiconfigobjects
											WHERE sectioncontrolname LIKE '%DetailsSection.ascx')

									SELECT	@error_var = @@ERROR,
											@rowcount_var = @@ROWCOUNT
									IF @error_var <> 0
									BEGIN
										EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																			@qsijobkey,
																			@i_JobTypeCode,
																			0,
																			'Campaign Creation',
																			'Campaign Creation',
																			'fbt',
																			@i_bookkey,
																			@v_printingkey,
																			0,
																			5,
																			'Insert into taqprojectmisc failed',
																			'No taqprojectmisc row',
																			@o_error_code OUTPUT,
																			@o_error_desc OUTPUT

										RETURN
									END


									EXEC dbo.qproject_copy_project	@i_defaultKey,
																	NULL,
																	@i_MarketingCampaignKey,
																	@v_datagroup_string,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	'QSIADMIN',
																	@V_newtitle,
																	NULL,
																	@o_error_code OUT,
																	@o_error_desc OUT


									DECLARE @i_taqprojectrelationshipkey int

									SET @messagedesc = @v_newtitle + ' Created'
									EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																		@qsijobkey,
																		@i_JobTypeCode,
																		0,
																		'Campaign Creation',
																		'Campaign Creation',
																		'fbt',
																		@i_bookkey,
																		@v_printingkey,
																		0,
																		4,
																		@messagedesc,
																		'Campaign Created',
																		@o_error_code OUTPUT,
																		@o_error_desc OUTPUT


									EXEC get_next_key	'qsiadmin',
														@i_taqprojectrelationshipkey OUT
									INSERT INTO
										taqprojectrelationship
										(
											taqprojectrelationshipkey, taqprojectkey1, taqprojectkey2, relationshipcode1, relationshipcode2, lastuserid, lastmaintdate
										)
										SELECT	@i_taqprojectrelationshipkey,
												@i_MarketingCampaignKey,
												@i_marketingplankey,
												20,
												18,
												'qsiadmin',
												GETDATE()

									EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																		@qsijobkey,
																		@i_JobTypeCode,
																		0,
																		'Campaign Creation',
																		'Campaign Creation',
																		'fbt',
																		@i_bookkey,
																		@v_printingkey,
																		0,
																		4,
																		'Campaign and Plan Relationship Created',
																		'Relationship Created',
																		@o_error_code OUTPUT,
																		@o_error_desc OUTPUT


									DECLARE @i_taqprojectformatkey int
									EXEC get_next_key	'qsiadmin',
														@i_taqprojectformatkey OUT
									INSERT INTO
										taqprojecttitle
										(
											taqprojectformatkey, taqprojectkey, bookkey, projectrolecode, titlerolecode, lastuserid, lastmaintdate,
											primaryformatind, printingkey
										)
										SELECT	@i_taqprojectformatkey,
												@i_MarketingCampaignKey,
												@i_bookkey,
												1,
												1,
												'Campaign Job',
												GETDATE(),
												0,
												@v_printingkey

									EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
																		@qsijobkey,
																		@i_JobTypeCode,
																		0,
																		'Campaign Creation',
																		'Campaign Creation',
																		'fbt',
																		@i_bookkey,
																		@v_printingkey,
																		0,
																		4,
																		'Campaign and Title Relationship Created',
																		'Relationship Created',
																		@o_error_code OUTPUT,
																		@o_error_desc OUTPUT


								END


							END

						END

						SET @seq = @seq + 1
					END

				END
			END
			ELSE
			BEGIN
				DECLARE @message varchar(1000)
				SET @message = 'No Instance Keys in tmwebprocessinstanceitem for instancekey ' + CAST(@i_instancekey AS varchar(100)) + ' or No Marketing Plans '
				EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
													@qsijobkey,
													@i_JobTypeCode,
													0,
													'Campaign Creation',
													'Campaign Creation',
													'fbt',
													0,
													0,
													0,
													5,
													@message,
													'Instance Key\Marketing Plan',
													@o_error_code OUTPUT,
													@o_error_desc OUTPUT

				RETURN
			END

      IF @started_job = 1 BEGIN
			  EXEC [dbo].[write_qsijobmessage]	@qsibatchkey,
												  @qsijobkey,
												  @i_JobTypeCode,
												  0,
												  'Campaign Creation',
												  'Campaign Creation',
												  'fbt',
												  0,
												  0,
												  0,
												  6,
												  'Completed Successfully',
												  'Success',
												  @o_error_code OUTPUT,
												  @o_error_desc OUTPUT
		 END

		END
GO

GRANT EXECUTE ON [HMH_Create_Mktg_Campaigns] TO public
GO