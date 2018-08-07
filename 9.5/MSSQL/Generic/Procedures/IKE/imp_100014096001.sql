

/****** Object:  StoredProcedure [dbo].[imp_100014096001]    Script Date: 4/2/2016 2:00:12 AM ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_100014096001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].imp_100014096001
GO

/****** Object:  StoredProcedure [dbo].[imp_100014096001]    Script Date: 4/2/2016 2:00:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  --set @v_load_rule_parmdef = N'@i_batchkey int, @i_row int, @i_elementseq int, @i_templatekey int, @i_rulekey bigint, @i_level int,@i_userid varchar(50)' 
  --set @v_proc_call_base='exec imp_$$rulekey$$ @i_batchkey, @i_row , @i_elementseq , @i_templatekey , @i_rulekey , @i_level ,@i_userid'

CREATE PROCEDURE [dbo].imp_100014096001 
  
  @i_batchkey int,
  @i_row int,
  --@i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

BEGIN 
/* 
	*Territory IKE load*
	1000140960 This elementkey is technically the elementkey for the EXCLUSIVE rights. But this proc does the processing
				for all the Territory Elements with mnemonics of Territories_EXCLUSIVE, Territories_NONEXCLUSIVE, Territories_NOTFORSALE,
				and Territories_Desc.
				This proc takes the definitions in the source data and puts entries into imp_territory table according to each title and
				how the rights should be set up in territoryrightcountries.
	see also imp_300014096001 - The imp_300014096001 proc determines what needs to be deleted or added to the territoryrightcountries 
				table by querying the differences between that table and imp_territory.

	The assumptions made for this loader to work are:
	1) all three elementkeys are present in imp_template_detail, 100014096 (Territories_EXCLUSIVE), 100014097 (Territories_NONEXCLUSIVE),
		 100014098 (Territories_NOTFORSALE), 100014103 (Territories_DESC) even if they are blank in the source data
	2) The first three of above mentioned columns in the source data table have country codes (their BISAC codes, so two character codes, 
		GB for the UK) delimited by a space (if not a space, then put delemiter in addlqualifier in imp_template_detail)
	3) the 'WORLD' or 'ROW' appear only once in any of the columns. That means, no WORLD in one column and ROW in the other. No WORLD in 
		two columns. Just one of them can appear in one of the element values for a given title record.
	4) if elementkey 100014101,'TerritoriesTable_Desc', does not exist in the template or has no value, then there will be the default of 
		"Imported Countries" text displayed on the title summary page describing what this territory is like. 
		Example descriptors are 'World Exclusive' or 'IE and GB exc'

	THERE ARE 8 TOP LEVEL USE CASES: 
		1. Only exclusive countries are listed and there are blanks or no elements in the template for Non-exclusive or NotForSale
		2. Only exclusive and non-exclusive
		3. Only exclusive and notforsale
		4. exclusive, non_excl and notforsale
		5. only non-exclusive 
		6. only non_exclusive and notforsale
		7. only notforsale
		8. blanks in all columns (if there aren't any of these three elements in template, then this rule will never be called, but they 
			could all be blank)
		
	20160628 - JDOE - CREATED ORIGINAL

*/
DECLARE  @v_errcode 	INT,
	@v_new_seq 	INT,
	@v_template_value 	VARCHAR(max),
	@v_template_key  int,
	@v_effdate	VARCHAR(4000),	
	@v_errlevel 	INT,
	@v_msg 		VARCHAR(4000),
	@v_taqprojectkey int,
	@v_territoryrightskey int,
	@v_pricetype	VARCHAR(40),
	@v_currentterritorycode int,
	@v_debug int
	,@addl01 varchar(100)
	,@addl02 varchar(100)
	,@addl03 varchar(100)

	declare @nonexc02 varchar(max)
	declare @notforsale03 varchar(max)

	declare @charindex01 int
	declare @charindex02 int
	declare @charindex03 int
	declare @string01 varchar(max)
	declare @string02 varchar(max)
	declare @string03 varchar(max)

	declare @World01 int
	declare @World02 int
	declare @World03 int
	declare @ROW01 int
	declare @ROW02 int
	declare @ROW03 int
	declare @Cnt_Territory int

		SET @v_errcode = 0
		SET @v_errlevel = 0
		SET @v_msg = 'Territory Rights by Table - Exclusive'
		SET @v_debug=0

	  if @v_debug<>0 print 'imp_100014096001 :: @i_batchkey='+convert(varchar(10),@i_batchkey)
	  if @v_debug<>0 print 'imp_100014096001 :: @i_templatekey='+convert(varchar(10),@i_templatekey)
	  if @v_debug<>0 print 'imp_100014096001 :: @i_row='+convert(varchar(10),@i_row)

	  SELECT @v_template_value = convert(varchar(max),l.textvalue),
				@addl01 = isNull(it.addlqualifier,' ')
		FROM imp_batch_detail ib
		left join imp_template_detail it on ib.elementkey=it.elementkey  and it.templatekey=@i_templatekey
		left join imp_batch_lobs l on l.batchkey=ib.batchkey and ib.lobkey=l.lobkey
		WHERE ib.batchkey = @i_batchkey
				and row_id = @i_row
				and ib.elementseq = @i_elementseq
				and ib.elementkey = 100014096

	  SELECT @nonexc02 = convert(varchar(max),l.textvalue),
				@addl02 = isNull(addlqualifier,' ')
		FROM imp_batch_detail ib
		left join imp_template_detail it on ib.elementkey=it.elementkey  and it.templatekey=@i_templatekey
		left join imp_batch_lobs l on l.batchkey=ib.batchkey and ib.lobkey=l.lobkey
		WHERE ib.batchkey = @i_batchkey
				and row_id = @i_row
				and elementseq = @i_elementseq
				and ib.elementkey = 100014097

	  SELECT @notforsale03 = convert(varchar(max),l.textvalue),
				@addl03 = isNull(addlqualifier,' ')
		FROM imp_batch_detail ib
		left join imp_template_detail it on ib.elementkey=it.elementkey  and it.templatekey=@i_templatekey
		left join imp_batch_lobs l on l.batchkey=ib.batchkey and ib.lobkey=l.lobkey
		WHERE ib.batchkey = @i_batchkey
				and row_id = @i_row
				and elementseq = @i_elementseq
				and ib.elementkey = 100014098
	
	  delete imp_territory where batchkey=@i_batchkey and row_id=@i_row

	if isNull(@v_template_value,'')='' and isNull(@nonexc02,'')='' and isNull(@notforsale03,'')='' begin
		 if @v_debug<>0 print 'imp_100014096001 :: there are no values in any of the Rights columns'
		 select @v_msg='Nothing to set for Territories'
	end
	else begin
		 if charindex ('WORLD', @v_template_value)>0 set @World01=1 else set @World01=0
		if charindex ('ROW', @v_template_value)>0 set @ROW01=1 else set @ROW01=0
 
		if charindex ('WORLD', @nonexc02)>0 set @World02=1 else set @World02=0
		if charindex ('ROW', @nonexc02)>0 set @ROW02=1 else set @ROW02=0
 
		if charindex ('WORLD', @notforsale03)>0 set @World03=1 else set @World03=0
		if charindex ('ROW', @notforsale03)>0 set @ROW03=1 else set @ROW03=0

		select @Cnt_Territory= @World01+@ROW01+@World02+@ROW02+@World03+@ROW03

		if isNull(@Cnt_Territory,0) > 1 begin
			if @v_debug<>0 print 'imp_100014096001 :: there is more than 1 WORLD or ROW, invalid Territory Rights definition.'
			select @v_msg='There is more than 1 WORLD or ROW in the TerrioryTable_Elements, invalid Territory Rights definition.'
			select @v_errlevel=1
		end
		else begin
			if @v_debug<>0 print 'imp_100014096001 :: good to parse the country codes?'

			if (object_id('tempdb..#tbl_SRT_01')is not null ) drop table #tbl_SRT_01
			create table #tbl_SRT_01 ( countryCode varchar(255) )
			if (object_id('tempdb..#tbl_SRT_02')is not null ) drop table #tbl_SRT_02
			create table #tbl_SRT_02 ( countryCode varchar(255) )
			if (object_id('tempdb..#tbl_SRT_03')is not null ) drop table #tbl_SRT_03
			create table #tbl_SRT_03 ( countryCode varchar(255) )
			-- select * from imp_territory
			-- truncate table imp_territory
			if @World01<>1 and @ROW01<>1 begin
				if ltrim(rtrim(isNull(@v_template_value,'')))<>'' begin
					insert into #tbl_SRT_01 select * from dbo.udf_SplitStrings_IKE(@v_template_value,@addl01)
					delete from #tbl_SRT_01 where ltrim(rtrim(isNull(CountryCode,''))) = ''
					insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
												exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
					select @i_batchkey,@i_row,1,1,1,0,1,null,ltrim(rtrim(g.datadesc)), g.datacode, 1,0
					from  #tbl_SRT_01 t 
					inner join gentables g on rtrim(ltrim(g.bisacdatacode)) = rtrim(ltrim(t.countryCode))
					where g.tableid=114
				end
				else begin
					if @v_debug<>0 begin
						print 'No exclusive countries'
						--select * from #tbl_SRT_01
					end
				end
			end
			if @World02<>1 and @ROW02<>1 begin
				if ltrim(rtrim(isNull(@nonexc02,'')))<>'' begin
					insert into #tbl_SRT_02 select * from dbo.udf_SplitStrings_IKE(@nonexc02,@addl02)
					delete from #tbl_SRT_02 where ltrim(rtrim(isNull(CountryCode,''))) = ''
					insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
												exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
					select @i_batchkey,@i_row,1,1,0,0,0,null,ltrim(rtrim(g.datadesc)), g.datacode, 0,0
					from  #tbl_SRT_02 t  
					inner join gentables g on rtrim(ltrim(g.bisacdatacode)) = rtrim(ltrim(t.countryCode))
					where g.tableid=114 
				end
				else begin
					if @v_debug<>0 begin
						print 'No nonexclusive countries'
						--select * from #tbl_SRT_02
					end
				end
			end
			if @World03<>1 and @ROW03<>1 begin
				if ltrim(rtrim(isNull(@notforsale03,'')))<>'' begin
					insert into #tbl_SRT_03 select * from dbo.udf_SplitStrings_IKE(@notforsale03,@addl03)
					delete from #tbl_SRT_03 where ltrim(rtrim(isNull(CountryCode,''))) = ''
					insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
												exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
					select @i_batchkey,@i_row,1,0,0,0,0,null,ltrim(rtrim(g.datadesc)),  g.datacode, 0,0
					from  #tbl_SRT_03 t 
					inner join gentables g on rtrim(ltrim(g.bisacdatacode)) = rtrim(ltrim(t.countryCode))
					where g.tableid=114
				end
				else begin
					if @v_debug<>0 begin
						print 'No notforsale countries'
--						select * from #tbl_SRT_03
					end
				end

			end

			if @World01=1 begin 
				if exists (select 1 from imp_territory where batchkey=@i_batchkey and row_id=@i_row ) begin
					if @v_debug<>0 print 'imp_100014096001 :: Cannot have ''WORLD'' in elementkey=100014096 when there are countries in 100014097 or 100014098. Invalid Territory Rights definition.'
					select @v_msg='WORLD is invalid in this Territory Rights definition.'
					select @v_errlevel=1
				end
				else begin
					insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
											exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
					select @i_batchkey,@i_row,1,1,1,0,1,null,ltrim(rtrim(g.datadesc)), g.datacode, 1,0
					from  gentables g 
					where g.tableid=114 and isNull(g.deletestatus,'N')<>'Y'
				end
			end
			if @World02=1 begin 
				if exists (select 1 from imp_territory where batchkey=@i_batchkey and row_id=@i_row ) begin
					if @v_debug<>0 print 'imp_100014096001 :: Cannot have ''WORLD'' in elementkey=100014097 when there are countries in 100014096 or 100014098. Invalid Territory Rights definition.'
					select @v_msg='WORLD is invalid in this Territory Rights definition.'
					select @v_errlevel=1
				end
				else begin
					insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
											exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
					select @i_batchkey,@i_row,1,1,0,0,0,null,ltrim(rtrim(g.datadesc)), g.datacode, 0,0
					from  gentables g 
					where g.tableid=114 and isNull(g.deletestatus,'N')<>'Y'
				end
			end
			if @World03=1 begin 
				if exists (select 1 from imp_territory where batchkey=@i_batchkey and row_id=@i_row ) begin
					if @v_debug<>0 print 'imp_100014096001 :: Cannot have ''WORLD'' in elementkey=100014098 when there are countries in 100014096 or 100014097. Invalid Territory Rights definition.'
					select @v_msg='WORLD is invalid in this Territory Rights definition.'
					select @v_errlevel=1
				end
				else begin
					insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
											exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
					select @i_batchkey,@i_row,1,0,0,0,0,null,ltrim(rtrim(g.datadesc)),  g.datacode, 0,0
					from  gentables g 
					where g.tableid=114 and isNull(g.deletestatus,'N')<>'Y'
				end
			end
			if @ROW01 = 1 begin
				insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
										exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
				select @i_batchkey,@i_row,1,1,1,0,1,null,ltrim(rtrim(g.datadesc)), g.datacode, 1,0
				from  gentables g 
				where g.tableid=114 and isNull(g.deletestatus,'N')<>'Y'
					and g.datacode not in (select CountryCode from imp_territory where batchkey=@i_batchkey and row_id=@i_row)
			end
			if @ROW02 = 1 begin
				insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
										exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
				select @i_batchkey,@i_row,1,1,0,0,0,null,ltrim(rtrim(g.datadesc)), g.datacode, 0,0
				from  gentables g 
				where g.tableid=114 and isNull(g.deletestatus,'N')<>'Y'
					and g.datacode not in (select CountryCode from imp_territory where batchkey=@i_batchkey and row_id=@i_row)
			end
			if @ROW03 = 1 begin
				insert into imp_territory ([batchkey] ,[row_id] ,[itemtype] ,[forsaleind] ,contractexclusiveind,[nonexclusivesubrightsoldind] ,[currentexclusiveind],
										exclusivesubrightsoldind,[CountryDesc] ,[CountryCode],[ExclusiveCode],[DeleteInd])
				select @i_batchkey,@i_row,1,0,0,0,0,null,ltrim(rtrim(g.datadesc)),  g.datacode, 0,0
				from  gentables g 
				where g.tableid=114 and isNull(g.deletestatus,'N')<>'Y'
					and g.datacode not in (select CountryCode from imp_territory where batchkey=@i_batchkey and row_id=@i_row)
			end


			drop table #tbl_SRT_01
			drop table #tbl_SRT_02
			drop table #tbl_SRT_03
		end
	END 
	IF @v_errlevel >= @i_level 
	BEGIN
		EXECUTE imp_write_feedback @i_batchkey, @i_row, null, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 1
	END


end -- proc
grant execute on  [dbo].imp_100014096001  to public