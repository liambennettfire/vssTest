SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BordersTitle]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BordersTitle]
GO





CREATE FUNCTION dbo.qweb_get_BordersTitle (
		@i_bookkey	INT)
	
/*	Creates the title field the way that Borders wants to see it, with the formatting and abbreviating in place
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(80)
	DECLARE @in_formatbisaccode 	VARCHAR(10)
	DECLARE @in_titlewithoutprefix 	VARCHAR(255)
	DECLARE @out_title		VARCHAR(80)
	DECLARE @in_editionnumber 	DECIMAL(10, 2)
	DECLARE @out_edition 	VARCHAR (5)

select @out_title = ''
select @out_edition = ''

select @in_titlewithoutprefix=dbo.qweb_get_Title(@i_bookkey, 'T')


select @in_formatbisaccode=dbo.qweb_get_Format(@i_bookkey, 'T')


-- set prefix
		if (@in_formatbisaccode = 'BX')
		or (@in_formatbisaccode = 'WX')
		   begin
			select @out_title = 'BOXED/ '
		   end
		else if (@in_formatbisaccode = 'PD')
	             or (@in_formatbisaccode = 'WL')
	             or (@in_formatbisaccode = 'DK')
		        begin
         		 	select @out_title = 'CAL '
		        end
		else if (@in_formatbisaccode = 'DA')
	             or (@in_formatbisaccode = 'AA')
		        begin
         		 	select @out_title = 'CAS '
		        end
		else if (@in_formatbisaccode = 'CD')
		        begin
         		 	select @out_title = 'CD '
		        end
		else 
		        begin
         		 	select @out_title = ''
		        end

		if substring(@in_titlewithoutprefix, 1, 4) = 'The '
			begin
				select @in_titlewithoutprefix = substring(@in_titlewithoutprefix, 5, 251)
			end

-- set title abbreviations

		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,',','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'?','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'.','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,':','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,';','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'"','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'/',' ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'-',' ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'(','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,')','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'!','')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,' and ',' & ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,' And ',' & ')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Book','BK')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Artificial Intelligence','AI')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Adventures','ADV')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Adventure','ADV')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Americans','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'American','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Americas','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'America','AMER')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Assorted','ASST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Austrailia','AUST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Autobiographical','AUTOB')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Autobiography','AUTOB')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Bed & Breakfast','B&B')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Better Homes & Gardens','BHG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Collection','COLL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Collected','COLL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Complete','COMPL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Dungeons & Dragons','D&D')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Department','DEPT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Dictionary','DICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Doctor','DR')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Encyclopedia','ENCY')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Encyclopedic','ENCY')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Field Guide','F GD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Official Price Guide','OPG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Price Guide','P GD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Guide','GD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Housekeeping','HSKG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Government','GOVT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'History','HIST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Histories','HIST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'How To','HT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Illustrated','ILLUS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Illustration','ILLUS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Illustrator','ILLUS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'International','INTL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Introduction','INTRO')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Keyboard','KEYBD')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Literature','LIT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Metropolitan','MET')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Management','MGMT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Mystery','MYST')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Microsoft','MS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'National','NATL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'New York Times','NYT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Orchestra','ORCH')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Pictures','PICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Picture','PICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Pictoral','PICT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Organ','ORG')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Overture','OVT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Percussion','PERC')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Philharmonic','PHIL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Piano','PNO')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Prelude','PRE')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Qustions & Answers','Q&A')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Quintet','QNT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Quartet','QRT')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Rhapsody','RHAPS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Simon & Schuster','S&S')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Saxophone','SAX')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Science Fiction & Fantasy','SF&F')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Science Fiction','SCI FI')

		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selections','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selection','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selective','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Selected','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Select','SEL')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Suite','STE')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Symphony','SYM')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Transcriptions','TRANS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Teach Yourself','TYS')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'Unaccompanied','UNACCOMP')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'United States','US')
		select @in_titlewithoutprefix = REPLACE(@in_titlewithoutprefix,'World War','WW')

		select @out_title = @out_title + UPPER (@in_titlewithoutprefix)

-- set post fix
		if (@in_formatbisaccode = 'H3')
		   begin
			select @out_title = @out_title + '-DOS'
		   end
		else if (@in_formatbisaccode = 'MH')
		        begin
         		 	select @out_title = @out_title + '-MAC'
		        end

/*		if @in_editionnumber > 0
		   begin
			select @out_edition = CAST(@in_editionnumber as varchar(5))
			select @out_edition = RTRIM(REPLACE(@out_edition, '.00', ''))
			select @out_title = @out_title + '-E' + SUBSTRING(@out_edition, 1, 2)
		   end
*/


	select @RETURN = @out_title



  RETURN @RETURN
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

