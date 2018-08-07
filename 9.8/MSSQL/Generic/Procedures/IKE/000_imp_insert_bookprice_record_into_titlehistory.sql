/******************************************************************************
**  Name: imp_insert_bookprice_record_into_titlehistory
**  Desc: IKE 
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

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_insert_bookprice_record_into_titlehistory]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_insert_bookprice_record_into_titlehistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		mkeyser
-- Create date: 04.25.2012
-- Description:	This routine updates the titlehistory table when a bookprice record is added
-- =============================================
CREATE PROCEDURE [dbo].[imp_insert_bookprice_record_into_titlehistory] 
(
	@i_bookkey as int
	,@i_pricetypecode as int
	,@i_currencytypecode as int
	,@i_budgetprice as float
	,@i_finalprice as float
	,@i_effectivedate as datetime
	,@i_activeind as int
	,@i_lastuserid as VARCHAR(30)
	,@i_history_order as int
)
AS
BEGIN
	DECLARE @Debug as int	
			,@v_currentstringvalue varchar(255)	
			,@v_currencytypedatadesc varchar(255)	
			,@o_error_code integer 
			,@o_error_desc varchar(2000) 
			
	SET @Debug=0

	if @Debug=1 print '--- update history ---'
	
	/*get the datadesc for the @i_currencytypecode*/
	select	@v_currencytypedatadesc=datadescshort
	from	gentables 
	where	tableid=122
			and datacode=@i_currencytypecode
	
	if  @i_pricetypecode  is not null 
		begin
			set @v_currentstringvalue=cast(@i_pricetypecode as varchar(255))
			if @Debug=1 print 'execute qtitle_update_titlehistory ''bookprice'',''pricetypecode'',' + cast (@i_bookkey as varchar(max))+ ',1,0,' + cast (@v_currentstringvalue as varchar(max))+',''insert'',' +cast (@i_lastuserid as varchar(max))+','+ cast (@i_history_order as varchar(max))+',''pricetypecode'',@o_error_code output, @o_error_desc output'
			execute qtitle_update_titlehistory 'bookprice','pricetypecode',@i_bookkey,1,0,@v_currentstringvalue,'insert',@i_lastuserid,@i_history_order,'pricetypecode',@o_error_code output, @o_error_desc output
		end 
	
	if  @i_budgetprice  is not null 
		begin
			set @v_currentstringvalue=cast(@i_budgetprice as varchar(255)) + ' ' + @v_currencytypedatadesc
			if @Debug=1 print 'execute qtitle_update_titlehistory ''bookprice'',''budgetprice'',' + cast (@i_bookkey as varchar(max))+ ',1,0,' + cast (@v_currentstringvalue as varchar(max))+',''insert'',' +cast (@i_lastuserid as varchar(max))+','+ cast (@i_history_order as varchar(max))+',''budgetprice'',@o_error_code output, @o_error_desc output'
			execute qtitle_update_titlehistory 'bookprice','budgetprice',@i_bookkey,1,0,@v_currentstringvalue,'insert',@i_lastuserid,@i_history_order,'budgetprice',@o_error_code output, @o_error_desc output
		end 

	if  @i_finalprice  is not null 
		begin
			set @v_currentstringvalue=cast(@i_finalprice as varchar(255)) + ' ' + @v_currencytypedatadesc
			if @Debug=1 print 'execute qtitle_update_titlehistory ''bookprice'',''finalprice'',' + cast (@i_bookkey as varchar(max))+ ',1,0,' + cast (@v_currentstringvalue as varchar(max))+',''insert'',' +cast (@i_lastuserid as varchar(max))+','+ cast (@i_history_order as varchar(max))+',''finalprice'',@o_error_code output, @o_error_desc output'
			execute qtitle_update_titlehistory 'bookprice','finalprice',@i_bookkey,1,0,@v_currentstringvalue,'insert',@i_lastuserid,@i_history_order,'finalprice',@o_error_code output, @o_error_desc output
		end 
	
	if  @i_currencytypecode  is not null 
		begin
			set @v_currentstringvalue=cast(@i_currencytypecode as varchar(255))
			if @Debug=1 print 'execute qtitle_update_titlehistory ''bookprice'',''currencytypecode'',' + cast (@i_bookkey as varchar(max))+ ',1,0,' + cast (@v_currentstringvalue as varchar(max))+',''insert'',' +cast (@i_lastuserid as varchar(max))+','+ cast (@i_history_order as varchar(max))+',''currencytypecode'',@o_error_code output, @o_error_desc output'
			execute qtitle_update_titlehistory 'bookprice','currencytypecode',@i_bookkey,1,0,@v_currentstringvalue,'insert',@i_lastuserid,@i_history_order,'currencytypecode',@o_error_code output, @o_error_desc output
		end 

	if  @i_effectivedate  is not null 
		begin
			set @v_currentstringvalue=cast(@i_effectivedate as varchar(255))
			if @Debug=1 print 'execute qtitle_update_titlehistory ''bookprice'',''effectivedate'',' + cast (@i_bookkey as varchar(max))+ ',1,0,' + cast (@v_currentstringvalue as varchar(max))+',''insert'',' +cast (@i_lastuserid as varchar(max))+','+ cast (@i_history_order as varchar(max))+',''effectivedate'',@o_error_code output, @o_error_desc output'
			execute qtitle_update_titlehistory 'bookprice','effectivedate',@i_bookkey,1,0,@v_currentstringvalue,'insert',@i_lastuserid,@i_history_order,'effectivedate',@o_error_code output, @o_error_desc output				
		end 

	if  @i_activeind  is not null 
		begin
			set @v_currentstringvalue=cast(@i_activeind as varchar(255))
			if @Debug=1 print 'execute qtitle_update_titlehistory ''bookprice'',''activeind'',' + cast (@i_bookkey as varchar(max))+ ',1,0,' + cast (@v_currentstringvalue as varchar(max))+',''insert'',' +cast (@i_lastuserid as varchar(max))+','+ cast (@i_history_order as varchar(max))+',''activeind'',@o_error_code output, @o_error_desc output'
			execute qtitle_update_titlehistory 'bookprice','activeind',@i_bookkey,1,0,@v_currentstringvalue,'insert',@i_lastuserid,@i_history_order,'activeind',@o_error_code output, @o_error_desc output				
		end 
END
GO

GRANT EXECUTE
	ON dbo.[imp_insert_bookprice_record_into_titlehistory]
	TO PUBLIC
GO