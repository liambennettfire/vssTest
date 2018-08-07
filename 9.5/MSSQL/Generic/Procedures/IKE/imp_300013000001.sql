/******************************************************************************
**  Name: imp_300013000001
**  Desc: IKE price
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/


IF EXISTS (SELECT *
		   FROM
			   sys.objects
		   WHERE
			   object_id = OBJECT_ID(N'[dbo].[imp_300013000001]')
			   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[imp_300013000001]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[imp_300013000001] @i_batch           INT,
                                          @i_row             INT,
                                          @i_dmlkey          BIGINT,
                                          @i_titlekeyset     VARCHAR(500),
                                          @i_contactkeyset   VARCHAR(500),
                                          @i_templatekey     INT,
                                          @i_elementseq      INT,
                                          @i_level           INT,
                                          @i_userid          VARCHAR(50),
                                          @i_newtitleind     INT,
                                          @i_newcontactind   INT,
                                          @o_writehistoryind INT OUTPUT
                                          
AS
	DECLARE @v_elementval        VARCHAR(4000),
            @v_errcode           INT,
            @v_errmsg            VARCHAR(4000),
            @v_elementdesc       VARCHAR(4000),
            @v_elementkey        BIGINT,
            @v_lobcheck          VARCHAR(20),
            @v_lobkey            INT,
            @v_bookkey           INT,
            @v_new_price         FLOAT,
            @v_cur_price         FLOAT,
            @v_hit               INT,
            @v_newkey            INT,
            @v_sortorder         INT,
            @v_pricetypecode     INT,
            @v_currencytypecode  INT,
            @v_destinationcolumn VARCHAR(50),
            @v_pricemaint        VARCHAR(100)
	BEGIN
		SET @v_hit = 0
		SET @v_newkey = 0
		SET @v_sortorder = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1

		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

		SELECT @v_elementval = LTRIM(RTRIM(b.originalvalue))
			 , @v_elementkey = b.elementkey
			 , @v_pricetypecode = e.datacode
			 , @v_currencytypecode = e.datasubcode
			 , @v_destinationcolumn = e.destinationcolumn
		FROM
			imp_batch_detail b, imp_DML_elements d, imp_element_defs e
		WHERE
			b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.dmlkey = @i_dmlkey
			AND d.elementkey = b.elementkey
			AND d.elementkey = e.elementkey

		SELECT @v_new_price = convert(FLOAT, @v_elementval)

		SELECT @v_errmsg = elementdesc + ' Updated '
		FROM
			imp_element_defs
		WHERE
			elementkey = @v_elementkey

		SET @v_new_price = convert(FLOAT, @v_elementval)

		EXECUTE imp_price_maintenance @i_batch, @v_bookkey, @v_new_price, @i_newtitleind, @v_pricetypecode, @v_currencytypecode, @v_destinationcolumn, @i_userid

		IF @v_errcode < 2
		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq, @i_dmlkey, @v_errmsg, @i_level, 3
		END

	END

GO