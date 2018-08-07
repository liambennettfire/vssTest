/******************************************************************************
**  Name: imp_200011020001
**  Desc: IKE validate Org level/relationship
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

SET NOCOUNT ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_200011020001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_200011020001]
GO

CREATE PROCEDURE dbo.imp_200011020001 
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
	,@_OrgConcat VARCHAR(4000)
	,@v_errcode INT
	,@v_errmsg VARCHAR(100)
	,@v_errlevel INT
	,@v_count INT
	,@v_OrgLevelCheckDigit BIGINT
	,@v_LoopCheckDigit INT
	,@v_OrgLevelCount INT
	,@v_OrgLevelLoop INT
	,@Debug INT

BEGIN
	-- SPROC level Debug variable (1=on, 0=off)
	set @Debug = 0

	-- Get an array (@_OrgConcat is a concatenated string) of the CORRECT org entries from MAX to MIN in the correct sequence
	select	top 1
			@_OrgConcat = coalesce(CASE  WHEN left(Orgs.orgentrydesc,36)=left(Orgs.altdesc1,36) and len(Orgs.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN Orgs.altdesc1 ELSE Orgs.orgentrydesc END,'') + coalesce(cast(orgs.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs1.orgentrydesc,36)=left(ParentOrgs1.altdesc1,36) and len(ParentOrgs1.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs1.altdesc1 ELSE ParentOrgs1.orgentrydesc END,'') + coalesce(cast(ParentOrgs1.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs2.orgentrydesc,36)=left(ParentOrgs2.altdesc1,36) and len(ParentOrgs2.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs2.altdesc1 ELSE ParentOrgs2.orgentrydesc END,'') + coalesce(cast(ParentOrgs2.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs3.orgentrydesc,36)=left(ParentOrgs3.altdesc1,36) and len(ParentOrgs3.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs3.altdesc1 ELSE ParentOrgs3.orgentrydesc END,'') + coalesce(cast(ParentOrgs3.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs4.orgentrydesc,36)=left(ParentOrgs4.altdesc1,36) and len(ParentOrgs4.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs4.altdesc1 ELSE ParentOrgs4.orgentrydesc END,'') + coalesce(cast(ParentOrgs4.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs5.orgentrydesc,36)=left(ParentOrgs5.altdesc1,36) and len(ParentOrgs5.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs5.altdesc1 ELSE ParentOrgs5.orgentrydesc END,'') + coalesce(cast(ParentOrgs5.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs6.orgentrydesc,36)=left(ParentOrgs6.altdesc1,36) and len(ParentOrgs6.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs6.altdesc1 ELSE ParentOrgs6.orgentrydesc END,'') + coalesce(cast(ParentOrgs6.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs7.orgentrydesc,36)=left(ParentOrgs7.altdesc1,36) and len(ParentOrgs7.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs7.altdesc1 ELSE ParentOrgs7.orgentrydesc END,'') + coalesce(cast(ParentOrgs7.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs8.orgentrydesc,36)=left(ParentOrgs8.altdesc1,36) and len(ParentOrgs8.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs8.altdesc1 ELSE ParentOrgs8.orgentrydesc END,'') + coalesce(cast(ParentOrgs8.orglevelkey as varchar(1)),'') + '|' +
			coalesce(CASE  WHEN left(ParentOrgs9.orgentrydesc,36)=left(ParentOrgs9.altdesc1,36) and len(ParentOrgs9.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN ParentOrgs9.altdesc1 ELSE ParentOrgs9.orgentrydesc END,'') + coalesce(cast(ParentOrgs9.orglevelkey as varchar(1)),'') 

	from	imp_batch_detail as bd
			LEFT JOIN orgentry AS orgs ON bd.originalvalue = CASE WHEN left(Orgs.orgentrydesc,36)=left(Orgs.altdesc1,36) and len(Orgs.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN Orgs.altdesc1 ELSE Orgs.orgentrydesc END
					and cast(right(cast(bd.elementkey as varchar(9)),1) as INT)=orgs.orglevelkey
					
			left join orgentry as ParentOrgs1	on orgs.orgentryparentkey=ParentOrgs1.orgentrykey
			left join orgentry as ParentOrgs2	on ParentOrgs1.orgentryparentkey=ParentOrgs2.orgentrykey
			left join orgentry as ParentOrgs3	on ParentOrgs2.orgentryparentkey=ParentOrgs3.orgentrykey
			left join orgentry as ParentOrgs4	on ParentOrgs3.orgentryparentkey=ParentOrgs4.orgentrykey
			left join orgentry as ParentOrgs5	on ParentOrgs4.orgentryparentkey=ParentOrgs5.orgentrykey
			left join orgentry as ParentOrgs6	on ParentOrgs5.orgentryparentkey=ParentOrgs6.orgentrykey
			left join orgentry as ParentOrgs7	on ParentOrgs6.orgentryparentkey=ParentOrgs7.orgentrykey
			left join orgentry as ParentOrgs8	on ParentOrgs7.orgentryparentkey=ParentOrgs8.orgentrykey
			left join orgentry as ParentOrgs9	on ParentOrgs8.orgentryparentkey=ParentOrgs9.orgentrykey
	where	bd.elementkey in (100011011,100011012,100011013,100011014,100011015,100011016,100011017,100011018,100011019)
			and bd.row_id=@i_row
			and bd.elementseq=@i_elementseq
			and bd.batchkey=@i_batch 	
	order by elementkey desc
	
	--select	bd.elementkey
	--		,bd.originalvalue
	--		,orgs.orglevelkey
	--		,orgs.orgentrydesc
	--		,case when orgs.orgentrydesc is not null 
	--			then power(10 , cast(right(cast(bd.elementkey as varchar(9)),1) as INT))
	--			else 0
	--			end AS OrgLevelCheckDigit
	
	-- This query matches the incoming Org elemnts in imp_batch _detail to the orgentry records making sure there is a match on 
	-- ... orgentry.orgentrydesc and orgentry.orglevelkey for each element
	-- It also makes sure that each element occurs in the full chain of orgs in the correct order 
	-- ... The correct order is determined by taking the MAX OrgLevel and building an array of values up to OrgLevel1
	-- ... all the elements values need to be in this CORRECT array for the incoming element value to be validated
	
	declare @IsDAB INT
	IF exists(select * from customer where customerkey=1 and customershortname='DAB') BEGIN 
		SET @IsDAB=1 
	END ELSE BEGIN 
		SET @IsDAB=0 
	END
	select	@v_OrgLevelCheckDigit=sum(case when CASE  WHEN left(Orgs.orgentrydesc,36)=left(Orgs.altdesc1,36) and len(Orgs.altdesc1)>40 and @IsDAB=1 THEN Orgs.altdesc1 ELSE Orgs.orgentrydesc END is not null 
				then power(10 , cast(right(cast(bd.elementkey as varchar(9)),1) as INT)) *
				case when CHARINDEX(bd.originalvalue + right(cast(bd.elementkey as varchar(9)),1),@_OrgConcat )>0 
					then 1
					else 0
					end				
				else 0
				end) 
			,@v_OrgLevelCount=count(bd.elementkey) 
	from	imp_batch_detail as bd
			left join orgentry	as orgs	on bd.originalvalue=CASE  WHEN left(Orgs.orgentrydesc,36)=left(Orgs.altdesc1,36) and len(Orgs.altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN Orgs.altdesc1 ELSE Orgs.orgentrydesc END
										and cast(right(cast(bd.elementkey as varchar(9)),1) as INT)=orgs.orglevelkey
	where	bd.elementkey in (100011011,100011012,100011013,100011014,100011015,100011016,100011017,100011018,100011019)
			and bd.row_id=@i_row
			and bd.elementseq=@i_elementseq
			and bd.batchkey=@i_batch 	
	
	set @v_OrgLevelLoop=@v_OrgLevelCount 
	while @v_OrgLevelLoop<>0
		begin
			set @v_LoopCheckDigit=substring(cast(@v_OrgLevelCheckDigit as varchar(max))
											,LEN(cast(@v_OrgLevelCheckDigit as varchar(max)))-@v_OrgLevelLoop
											,1)

			if @Debug<>0 print '@v_OrgLevelCheckDigit = ' + coalesce(cast(@v_OrgLevelCheckDigit as varchar(max)),'*NULL*')
			if @Debug<>0 print '@v_OrgLevelLoop = ' + coalesce(cast( @v_OrgLevelLoop as varchar(max)),'*NULL*')
			if @Debug<>0 print '@v_LoopCheckDigit = ' + coalesce(cast( @v_LoopCheckDigit as varchar(max)),'*NULL*')
			
			if @v_LoopCheckDigit=1
				begin
					SET @v_errmsg = 'OrgLevel' + CAST(@v_OrgLevelLoop as varchar(2)) + ' is valid'
					SET @v_errlevel = 1					
				end
			else
				begin
					select	@v_elementval=bd.originalvalue
					from	imp_batch_detail bd
							inner join imp_element_defs ed on bd.elementkey=ed.elementkey
					where	ed.elementmnemonic = 'OrgGroup' +CAST(@v_OrgLevelLoop as varchar(2))
							and bd.row_id=@i_row
							and bd.elementseq=@i_elementseq
							and bd.batchkey=@i_batch 	
												
					SET @v_errmsg = 'OrgLevel' + CAST(@v_OrgLevelLoop as varchar(2)) + ' (' + @v_elementval + ') is NOT valid'
					SET @v_errlevel = 3
				end	
			
			EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
			if @Debug<>0 print @v_errmsg
			set @v_OrgLevelLoop=@v_OrgLevelLoop-1
		end
END

GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_200011020001]
	TO PUBLIC
GO

