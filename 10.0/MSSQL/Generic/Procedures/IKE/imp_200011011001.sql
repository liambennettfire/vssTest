/******************************************************************************
**  Name: imp_200011011001
**  Desc: IKE OrgLevel is validation
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_200011011001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_200011011001]
GO

CREATE PROCEDURE [dbo].[imp_200011011001] 
	@i_batch INT
	,@i_row INT
	,@i_elementkey INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_rpt INT
AS
DECLARE 
	@v_elementval VARCHAR(4000)
	,@v_errcode INT
	,@v_count INT
	,@v_errlevel INT
	,@v_msg VARCHAR(4000)
	,@v_elementdesc VARCHAR(4000)
	,@v_elementmnemonic VARCHAR(100)
	,@v_ElementMnemonicOrgLevel INT
	,@v_OrgEntryOrgLevel INT
	,@v_errmsg VARCHAR(100)
	,@v_orgleveldesc varchar(200)

BEGIN
	-- get the OrgLevel Number from the elementmnemonic based on the current elementkey
	select	@v_elementmnemonic=elementmnemonic
	from	imp_element_defs
	where	elementkey=@i_elementkey
	
	set @v_ElementMnemonicOrgLevel=cast (RIGHT(@v_elementmnemonic,1) as int)

	select @v_orgleveldesc=orgleveldesc
	  from orglevel
	  where orglevelkey=@v_ElementMnemonicOrgLevel
	set @v_orgleveldesc=coalesce(@v_orgleveldesc,'n/a')

	-- get the value of the incoming element
	select	@v_elementval=originalvalue
    from	imp_batch_detail
    where	batchkey=@i_batch 
			and row_id=@i_row
			and elementkey=@i_elementkey
			and elementseq=@i_elementseq	
	
	-- lookup the value in orgentry and return the OrgLevel
	if exists(select * from customer where customerkey=1 and customershortname='DAB')
	begin
		select	@v_OrgEntryOrgLevel=coalesce(orglevelkey,0)
		from	orgentry
		where	@v_elementval=CASE WHEN left(orgentrydesc,36)=left(altdesc1,36) and len(altdesc1)>40 THEN altdesc1 ELSE orgentrydesc END
				AND orglevelkey=@v_ElementMnemonicOrgLevel
	end 
	else 
	begin
		select	@v_OrgEntryOrgLevel=coalesce(orglevelkey,0)
		from	orgentry
		where	@v_elementval=orgentrydesc 
				AND orglevelkey=@v_ElementMnemonicOrgLevel
		if @v_OrgEntryOrgLevel is null
		begin
			select	@v_OrgEntryOrgLevel=coalesce(orglevelkey,0)
			from	orgentry
			where	@v_elementval=altdesc1 
					AND orglevelkey=@v_ElementMnemonicOrgLevel			
		end
	end 
	
	--print ''
	--print ''
	--print 'START [imp_200011011001]'
	--print @v_ElementMnemonicOrgLevel
	--print @v_elementval
	--print @v_OrgEntryOrgLevel
	--print 'END [imp_200011011001]'

	
	-- make sure the orgentry.OrgLevel = OrgLevel Number from the elementmnemonic and write result to feedback
	if @v_OrgEntryOrgLevel=@v_ElementMnemonicOrgLevel
		begin
			SET @v_errmsg = 'OrgLevel is valid for element: ' + @v_elementmnemonic
			SET @v_errlevel = 1
		end
	else
		begin
			SET @v_errmsg = '"'+@v_elementval+'" is invalid for '+@v_elementmnemonic+' ('+@v_orgleveldesc+')'
			SET @v_errlevel = 3
		end	
	EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
END
