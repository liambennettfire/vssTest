/******************************************************************************
**  Name: imp_establish_title
**  Desc: IKE find title or create minimum
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_establish_title]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_establish_title]
GO

CREATE PROCEDURE imp_establish_title @i_batchkey INT
	,@i_row_id INT
	,@i_default_orgkeyset VARCHAR(8000)
	,@i_userid VARCHAR(50)
	,@o_bookkey INT OUTPUT
	,@o_printingkey INT OUTPUT
	,@o_orgkeyset VARCHAR(500) OUTPUT
	,@o_newtitleind INT OUTPUT
	,@o_errcode INT OUTPUT
	,@o_errmsg VARCHAR(500) OUTPUT
AS
DECLARE @v_productnumber VARCHAR(50)
	,@v_orglevenumber INT
	,@v_orglevelkey INT
	,@v_orgentrykey INT
	,@v_orgparentkey INT
	,@v_orgleveldesc VARCHAR(50)
	,@v_orglevelnumber INT
	,@v_elementkey BIGINT
	,@v_originalvalue VARCHAR(500)
	,@v_default_orgkey INT
	,@v_default_diff INT
	,@v_default_use INT
	,@v_bookkey INT
	,@v_destinationtable VARCHAR(500)
	,@v_destinationcolumn VARCHAR(500)
	,@v_lead_value VARCHAR(500)
	,@v_product_type VARCHAR(500)
	,@v_product_value VARCHAR(500)
	,@v_elementseq INT
	,@v_count INT
	,@v_sqlblock NVARCHAR(4000)
	,@v_bookkey_parmdef NVARCHAR(2000)
	,@v_returncode INT
	,@v_returnmsg VARCHAR(500)
    ,@v_useAltDesc1 INT
	,@v_mediatypedesc varchar(200)
	,@v_mediatypesubdesc varchar(200)
	,@v_mediatypecode int
	,@v_mediatypesubcode int
	,@v_datadesc varchar(MAX)
	,@v_debug int

BEGIN
	--initialize
	SET @v_debug = 0
	SET @v_productnumber = ''
	SET @v_orglevenumber = 0
	SET @v_orglevelkey = 0
	SET @v_orgentrykey = 0
	SET @v_orgparentkey = 0
	SET @v_orgleveldesc = ''
	SET @v_elementkey = 0
	SET @v_originalvalue = ''
	SET @v_default_orgkey = 0
	SET @v_default_diff = 0
	SET @v_default_use = 0
	SET @o_errcode = 0
	SET @o_errmsg = ''
	SET @o_bookkey = NULL
	SET @o_orgkeyset = ''
	SET @o_newtitleind = 0
	SET @v_bookkey_parmdef = N'@o_bookkey int output'

	DECLARE org_cur CURSOR
	FOR
	SELECT orglevelnumber
		,orglevelkey
		,orgleveldesc
	FROM orglevel
	WHERE deletestatus = 'N'
	ORDER BY orglevelnumber

	DECLARE c_bookkey_leads CURSOR
	FOR
	SELECT bd.elementkey
		,ed.destinationtable
		,ed.destinationcolumn
		,bd.originalvalue
	FROM imp_batch_detail bd
		,imp_element_defs ed
	WHERE bd.elementkey = ed.elementkey
		AND bd.batchkey = @i_batchkey
		AND bd.row_id = @i_row_id
		AND upper(ed.leadkeyname) = 'BOOKKEY'
		AND ed.destinationtable IS NOT NULL
		AND ed.destinationcolumn IS NOT NULL
	ORDER BY bd.elementkey

	--try to retrieve a bookkey
	SET @v_bookkey = NULL

	OPEN c_bookkey_leads

	FETCH c_bookkey_leads
	INTO @v_elementkey
		,@v_destinationtable
		,@v_destinationcolumn
		,@v_lead_value

	WHILE @@fetch_status = 0
		AND @v_bookkey IS NULL
	BEGIN
		SET @v_sqlblock = N'select @o_bookkey=bookkey from ' + @v_destinationtable + ' where ' + @v_destinationcolumn + '=' + CHAR(39) + @v_lead_value + CHAR(39)

		BEGIN
			EXEC @v_returncode = sp_executesql @v_sqlblock
				,@v_bookkey_parmdef
				,@o_bookkey = @v_bookkey OUTPUT

			IF @v_returncode = 1
			BEGIN
				SET @v_returnmsg = 'title look up failure (msg ' + cast(@v_returncode AS VARCHAR(20)) + ')'

				EXECUTE imp_write_feedback @i_batchkey
					,@i_row_id
					,NULL
					,NULL
					,NULL
					,@v_returnmsg
					,3
					,3
			END
		END

		FETCH c_bookkey_leads
		INTO @v_elementkey
			,@v_destinationtable
			,@v_destinationcolumn
			,@v_lead_value
	END

	/*
  if @v_bookkey is null
    begin
      open c_product_types
      fetch c_product_types into @v_elementseq,@v_product_type
      while @@fetch_status=0 and @v_bookkey is null 
        begin
          select @v_count=count(*) 
            from imp_batch_detail
            where batchkey=1
              and row_id=1
              and elementkey=100010009
              and elementseq=@v_elementseq
          if @v_count = 1
            begin
              select @v_product_value=originalvalue
                from imp_batch_detail
                where batchkey=1
                  and row_id=1
                  and elementkey=100010009
                  and elementseq=@v_elementseq
            end
          --if @v_product_type is not null and @v_product_value is not null
          --  begin
          --    set @v_bookkey=resolve_productID_pair(@v_product_type,@v_product_value)
          --  end
          fetch c_product_types into @v_elementseq,@v_product_type
        end
    end
*/
	SET @o_bookkey = @v_bookkey

	CLOSE c_bookkey_leads

	DEALLOCATE c_bookkey_leads

	--try to retrieve a printkey
	SELECT @o_printingkey = 1

	--try to retrieve an orgkeyset
	OPEN org_cur

	FETCH org_cur
	INTO @v_orglevelnumber
		,@v_orglevelkey
		,@v_orgleveldesc

	WHILE @@fetch_status = 0
	BEGIN
		SET @v_useAltDesc1 = 0
		SET @v_originalvalue = NULL
		SET @v_orgentrykey = NULL
		SET @v_default_orgkey = dbo.resolve_keyset(@i_default_orgkeyset, @v_orglevelnumber)

		SELECT @v_count = count(*)
		FROM imp_batch_detail bd
			,imp_element_defs ed
		WHERE bd.elementkey = ed.elementkey
			AND bd.batchkey = @i_batchkey
			AND bd.row_id = @i_row_id
			AND elementmnemonic = 'OrgGroup' + cast(@v_orglevelnumber AS VARCHAR(20))

		IF @v_count > 0
		BEGIN
			SELECT @v_originalvalue = bd.originalvalue
			FROM imp_batch_detail bd
				,imp_element_defs ed
			WHERE bd.elementkey = ed.elementkey
				AND bd.batchkey = @i_batchkey
				AND bd.row_id = @i_row_id
				AND elementmnemonic = 'OrgGroup' + cast(@v_orglevelnumber AS VARCHAR(20))
		END
		ELSE
		BEGIN
			SET @v_originalvalue = NULL
		END

		IF @v_originalvalue IS NOT NULL
		BEGIN
			SELECT @v_count = count(*)
			FROM orgentry
			WHERE CASE 
					WHEN left(orgentrydesc, 36) = left(altdesc1, 36)
						AND len(altdesc1) > 40
						AND EXISTS (
							SELECT *
							FROM customer
							WHERE customerkey = 1
								AND customershortname = 'DAB'
							)
						THEN altdesc1
					ELSE orgentrydesc
					END = @v_originalvalue
				AND orglevelkey = @v_orglevelkey
				AND deletestatus = 'N'
				AND (
					orgentryparentkey = @v_orgparentkey
					OR @v_orgparentkey = 0
					)

			IF @v_count = 0
			BEGIN
				--mk20140327> this hack allows this sproc to look at altdesc1 all the time if orgentry match is not possible
				SELECT @v_count = count(*)
				FROM orgentry
				WHERE altdesc1 = @v_originalvalue
					AND orglevelkey = @v_orglevelkey
					AND deletestatus = 'N'
					AND (
						orgentryparentkey = @v_orgparentkey
						OR @v_orgparentkey = 0
						)

				SET @v_useAltDesc1 = 1
			END

			--select '@v_orglevelkey',@v_orglevelkey,'@v_originalvalue',@v_originalvalue,'@v_count',@v_count
			IF @v_count > 0
			BEGIN
				IF @v_useAltDesc1 = 1
				BEGIN
					--mk20140327> this hack allows this sproc to look at altdesc1 all the time if orgentry match is not possible
					SELECT @v_orgentrykey = orgentrykey
					FROM orgentry
					WHERE altdesc1 = @v_originalvalue
						AND orglevelkey = @v_orglevelkey
						AND deletestatus = 'N'
						AND (
							orgentryparentkey = @v_orgparentkey
							OR @v_orgparentkey = 0
							)
				END
				ELSE
				BEGIN
					SELECT @v_orgentrykey = orgentrykey
					FROM orgentry
					WHERE CASE 
							WHEN left(orgentrydesc, 36) = left(altdesc1, 36)
								AND len(altdesc1) > 40
								AND EXISTS (
									SELECT *
									FROM customer
									WHERE customerkey = 1
										AND customershortname = 'DAB'
									)
								THEN altdesc1
							ELSE orgentrydesc
							END = @v_originalvalue
						AND orglevelkey = @v_orglevelkey
						AND deletestatus = 'N'
						AND (
							orgentryparentkey = @v_orgparentkey
							OR @v_orgparentkey = 0
							)
				END
			END
			ELSE
			BEGIN
				--set @v_orgentrykey = null
				SELECT @v_orgentrykey = orgentrykey
				FROM orgentry
				WHERE altdesc1 = @v_originalvalue
					AND orglevelkey = @v_orglevelkey
					AND deletestatus = 'N'
					AND (
						orgentryparentkey = @v_orgparentkey
						OR @v_orgparentkey = 0
						)
			END
		END

		IF @v_orgentrykey IS NOT NULL
		BEGIN
			IF @o_orgkeyset = ''
				OR @o_orgkeyset IS NULL
			BEGIN
				SET @o_orgkeyset = cast(@v_orgentrykey AS VARCHAR(20))
			END
			ELSE
			BEGIN
				SET @o_orgkeyset = @o_orgkeyset + ',' + cast(@v_orgentrykey AS VARCHAR(20))
			END

			IF @v_orgentrykey <> @v_default_orgkey
			BEGIN
				SET @v_default_diff = 1
			END
		END
		ELSE
		BEGIN
			IF @o_orgkeyset = ''
				OR @o_orgkeyset IS NULL
			BEGIN
				SET @o_orgkeyset = cast(@v_default_orgkey AS VARCHAR(20))
			END
			ELSE
			BEGIN
				SET @o_orgkeyset = @o_orgkeyset + ',' + cast(@v_default_orgkey AS VARCHAR(20))
			END

			SET @v_default_use = 1
		END

		SET @v_orgparentkey = dbo.resolve_keyset(@o_orgkeyset, @v_orglevelnumber)

		FETCH org_cur
		INTO @v_orglevelnumber
			,@v_orglevelkey
			,@v_orgleveldesc
	END

	CLOSE org_cur

	DEALLOCATE org_cur

	IF (
			@v_default_diff = 1
			AND @v_default_use = 1
			)
	BEGIN
		IF dbo.valid_orgkeyset(@o_orgkeyset) = 0
		BEGIN
			SET @o_errcode = - 1
			SET @o_errmsg = 'could not determine organization levels for row ' + cast(@i_row_id AS VARCHAR(20))

			EXEC imp_write_feedback @i_batchkey
				,@i_row_id
				,NULL
				,NULL
				,NULL
				,@o_errmsg
				,3
				,3
		END
	END

	IF @o_orgkeyset IS NULL
	BEGIN
		SET @o_errcode = - 1
		SET @o_errmsg = 'No organization levels for row ' + cast(@i_row_id AS VARCHAR(20))

		EXEC imp_write_feedback @i_batchkey
			,@i_row_id
			,NULL
			,NULL
			,NULL
			,@o_errmsg
			,1
			,3
	END

	--fill in blanks
	IF @o_bookkey IS NULL
		AND @o_errcode <> - 1
	BEGIN
		UPDATE keys
		SET generickey = generickey + 1

		SELECT @o_bookkey = generickey
		FROM keys

		--get media and format code 
		select @v_mediatypesubdesc=originalvalue 
		  from imp_batch_detail
		  where batchkey=@i_batchkey
		    and row_id=@i_row_id
			and elementkey=100012050
		select @v_mediatypedesc=originalvalue 
		  from imp_batch_detail
		  where batchkey=@i_batchkey
		    and row_id=@i_row_id
			and elementkey=100012051

		exec find_gentables_mixed @v_mediatypedesc,312 ,@v_mediatypecode output,@v_datadesc output
		exec find_subgentables_mixed @v_mediatypesubdesc,312 ,@v_mediatypecode output, @v_mediatypesubcode output,@v_datadesc output, null

		if @v_debug<>0 print 'mediatypedesc = '+coalesce(@v_mediatypedesc,'n/a')
		if @v_debug<>0 print 'mediatypecode = '+coalesce(cast(@v_mediatypecode as varchar),'n/a')
		if @v_debug<>0 print 'mediatypesubdesc = '+coalesce(@v_mediatypesubdesc,'n/a')
		if @v_debug<>0 print 'mediatypesubcode = '+coalesce(cast(@v_mediatypesubcode as varchar),'n/a')

		if @v_mediatypecode is null or @v_mediatypesubcode is null
		begin
			EXEC imp_write_feedback @i_batchkey
				,@i_row_id
				,NULL
				,NULL
				,NULL
				,'Missing required Format and Media'
				,3
				,3
			return
		end
		else
		begin
			EXEC create_title_minimum @o_bookkey
			,@o_printingkey
			,@o_orgkeyset
			,@v_mediatypecode
			,@v_mediatypesubcode
			,@i_userid
			,@o_errcode OUTPUT
			,@o_errmsg OUTPUT
		end

		SET @o_newtitleind = 1

		IF @o_errcode = - 1
		BEGIN
			EXEC imp_write_feedback @i_batchkey
				,@i_row_id
				,NULL
				,NULL
				,NULL
				,@o_errmsg
				,1
				,3
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.imp_establish_title
	TO PUBLIC
GO


