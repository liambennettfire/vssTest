/******************************************************************************
**  Name: imp_load_xml_explicit
**  Desc: IKE long mics value update
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_300028100001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_300028100001]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[imp_300028100001]   
  @i_batch int, 
  @i_row int , 
  @i_dmlkey bigint, 
  @i_titlekeyset varchar(500),
  @i_contactkeyset varchar(500),
  @i_templatekey int,
  @i_elementseq int,
  @i_level int,
  @i_userid varchar(50),
  @i_newtitleind int,
  @i_newcontactind int,
  @o_writehistoryind int output
AS

DECLARE
  @v_elementval    VARCHAR(4000),
  @v_elementkey    INT,
  @v_elementdesc     VARCHAR(4000),
  @v_addlqualifier     VARCHAR(4000),
  @v_authorkey    INT,
  @v_tableid     INT,
  @v_misckey     INT,
  @v_bookkey     INT,
  @v_printingkey     INT,
  @v_count     INT,
  @v_datacode     INT,
  @v_misctype     INT,
  @v_datasubcode     INT,
  @v_datacode_org     INT,
  @v_old_value     INT,
  @v_transtype varchar(20),
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000),
  @v_sendtoeloquenceind INT,
  @DEBUG INT
 
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
  SET @DEBUG=0

  SELECT 
      @v_elementval= LTRIM(RTRIM(b.originalvalue)),
      @v_elementkey=b.elementkey,
      @v_elementdesc=elementdesc,
      @v_addlqualifier=td.addlqualifier
    FROM imp_batch_detail b ,imp_DML_elements d,imp_element_defs e,imp_template_detail td
    WHERE b.batchkey=@i_batch
      AND b.row_id=@i_row
      AND b.elementseq=@i_elementseq
      AND d.dmlkey=@i_dmlkey
      AND d.elementkey=b.elementkey
      and td.templatekey=@i_templatekey
      and b.elementkey=td.elementkey

  set @v_misckey=cast(@v_addlqualifier as int)
  
  IF @DEBUG>0 PRINT CHAR(13)+CHAR(10)
  IF @DEBUG>0 PRINT '@v_elementval = ' + coalesce (cast(@v_elementval as varchar(max)),'*NULL*')
  IF @DEBUG>0 PRINT '@v_elementkey = ' + coalesce (cast(@v_elementkey as varchar(max)),'*NULL*')
  IF @DEBUG>0 PRINT '@v_addlqualifier = ' + coalesce (cast(@v_addlqualifier as varchar(max)),'*NULL*')
  IF @DEBUG>0 PRINT '@v_misckey = ' + coalesce (cast(@v_misckey as varchar(max)),'*NULL*')

  select @v_datacode=datacode , @v_misctype=misctype
    from bookmiscitems
    where misckey=@v_misckey
    
  select @v_datasubcode=datasubcode 
    from subgentables
    where tableid=525
      and datacode=@v_datacode
      and datadesc=@v_elementval
  
  if @v_datasubcode is null
    select @v_datasubcode=datasubcode 
      from subgentables
      where tableid=525
        and datacode=@v_datacode
        and externalcode=@v_elementval

  if @v_datasubcode is null
    select @v_datasubcode=datasubcode 
      from subgentables
      where tableid=525
        and datacode=@v_datacode
        and eloquencefieldtag=@v_elementval
  
  IF @DEBUG>0 PRINT '@v_datacode = ' + coalesce (cast(@v_datacode as varchar(max)),'*NULL*')
  IF @DEBUG>0 PRINT '@v_datasubcode = ' + coalesce (cast(@v_datasubcode as varchar(max)),'*NULL*')  
  IF @DEBUG>0 PRINT '@v_misctype = ' + coalesce (cast(@v_misctype as varchar(max)),'*NULL*')  
  
  IF @v_datasubcode is null and @v_misctype=5
  BEGIN
	SET @v_errmsg='Misc long value was not inserted because the value ''' + coalesce (cast(@v_elementval  as varchar(max)),'*NULL*')  + ''' could not be found'
	EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,2,3     
	IF @DEBUG>0 PRINT @v_errmsg
	RETURN
  END
  
  IF @v_datasubcode is null and @v_misctype <> 5 and ISNUMERIC(@v_elementval)=0
  BEGIN
	SET @v_errmsg='Misc long value was not inserted because the value ''' + coalesce (cast(@v_elementval  as varchar(max)),'*NULL*')  + ''' could not be found be found and it is not a number'
	EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,2,3     
	IF @DEBUG>0 PRINT @v_errmsg
	RETURN
  END
    
  select @v_count=count(*)
    from bookmisc
    where bookkey=@v_bookkey
      and misckey=@v_misckey
      
  IF @DEBUG>0 PRINT '@v_count @ LINE#99 = ' + coalesce (cast(@v_count as varchar(max)),'*NULL*')  
      
  if @v_datacode is null
    begin
      if @v_count=1
        begin
          select @v_old_value=longvalue
            from bookmisc
            where bookkey=@v_bookkey
              and misckey=@v_misckey
          IF @v_old_value<>cast(@v_elementval as int) OR @v_old_value IS null
            BEGIN
				IF @DEBUG>0 PRINT 'update bookmisc'				
              update bookmisc 
                set longvalue=@v_elementval
                where bookkey=@v_bookkey
                  and misckey=@v_misckey
              SET @v_errmsg='Misc long value updated'
              set @v_transtype='update'
              SET @o_writehistoryind = 1
            END
        end
      else
        begin
			IF @DEBUG>0 PRINT 'insert bookmisc'

			--mk20131003>
			--... if bookmiscitems.eloquencefieldidcode=null then bookmisc.sendtoeloquenceind=0
			--... if bookmiscitems.eloquencefieldidcode!=null then bookmisc.sendtoeloquenceind=bookmiscitems.defaultsendtoeloqvalue
			SELECT @v_sendtoeloquenceind = CASE 
					WHEN eloquencefieldidcode IS NULL THEN 0
					ELSE bookmiscitems.defaultsendtoeloqvalue
					END
			FROM bookmiscitems
			WHERE misckey = @v_misckey
			
          insert into bookmisc
            (bookkey,misckey,longvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
            values
            (@v_bookkey,@v_misckey,@v_elementval,@i_userid,getdate(),@v_sendtoeloquenceind)
          SET @v_errmsg='Misc long value inserted'
          set @v_transtype='insert'
          SET @o_writehistoryind = 1
        end
    end
  else
    begin
	  
	  IF @DEBUG>0 PRINT 'DATA CODE IS NOT NULL'
	  
      if @v_count=1
        begin
          select @v_old_value=longvalue
            from bookmisc
            where bookkey=@v_bookkey
              and misckey=@v_misckey
      
		  IF @DEBUG>0 PRINT '@v_old_value = ' + coalesce (cast(@v_old_value as varchar(max)),'*NULL*')  
		  IF @DEBUG>0 PRINT '@v_datasubcode = ' + coalesce (cast(@v_datasubcode as varchar(max)),'*NULL*')  
		      
          IF @v_old_value<>@v_datasubcode OR @v_old_value IS null
            BEGIN
			  
			  IF @DEBUG>0 PRINT 'update bookmisc'
			  
              update bookmisc 
                set longvalue=@v_datasubcode,
                    lastuserid=@i_userid,
                    lastmaintdate=getdate()
                where bookkey=@v_bookkey
                  and misckey=@v_misckey
              SET @v_errmsg='Misc long value updated'
              set @v_transtype='update'
              SET @o_writehistoryind = 1
            END
            else begin
            IF @DEBUG>0 PRINT '@v_old_value=@v_datasubcode ... No update required'
            end
        end
      else
        begin
		  IF @DEBUG>0 PRINT 'insert into bookmisc'

          insert into bookmisc
            (bookkey,misckey,longvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
            values
            (@v_bookkey,@v_misckey,@v_datasubcode,@i_userid,getdate(),1)
          SET @v_errmsg='Misc long value inserted'
          set @v_transtype='insert'
          SET @o_writehistoryind = 1
        end
    end
    
  if @o_writehistoryind = 1
    begin
      --need to handle history differently
      set @o_writehistoryind = 0
      DECLARE
        @v_miscname varchar(40),
        @v_errorcode int,
        @v_errormessage varchar(400)
      select @v_miscname=miscname
        from bookmiscitems 
        where misckey=@v_misckey
      exec qtitle_update_titlehistory 
        'bookmisc','longvalue',@v_bookkey,@v_printingkey,null,
        @v_elementval,@v_transtype,@i_userid,null,@v_miscname,
        @v_errorcode output, @v_errormessage output
    end

  IF @v_errcode < 2 and @v_errmsg IS NOT null
    BEGIN
      EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,@i_level,3     
    END

IF @DEBUG>0 PRINT @v_errmsg    
END
