/******************************************************************************
**  Name: imp_300010041001
**  Desc: IKE Propigate from EAN
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
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010041001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010041001]
GO

CREATE PROCEDURE [dbo].[imp_300010041001] 
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

/* Propigate from EAN */

DECLARE
  @v_EAN    VARCHAR(4000),
  @v_count    INT,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_taqprojectformatkey int,
  @v_taqprojectkey int,
  @v_newkey int,
  @v_elementkey    BIGINT,
  @v_bookkey     INT,  
  @v_workkey     INT,  
  @v_key_check     INT,  
  @v_ean_check    varchar(20),  
  @v_addlqualifier varchar(200),
  @v_parm_projectrolecode int,
  @v_parm_titlerolecode int,
  @v_parm_taqprojecttype int,
  @v_prop_bookkey     INT,
  @v_prop_bookkey_propagatefrombookkey INT,
  @v_bookkey_workkey INT
   

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Propagate from EAN'
  
  --initialize parameters
  SET @v_ean_check = NULL 
  SET @v_taqprojectformatkey = NULL 
  SET @v_taqprojectkey = NULL 
  SET @v_EAN = NULL 
  SET @v_workkey = NULL 
  SET @v_prop_bookkey = NULL 
  SET @v_prop_bookkey_propagatefrombookkey = NULL
  SET @v_bookkey_workkey = NULL 
  
  
  
  
  
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  -- Set parms or default
  SELECT @v_addlqualifier=td.addlqualifier
    FROM imp_template_detail td
    WHERE td.templatekey=@i_templatekey
      and td.elementkey=100010041
  set @v_parm_projectrolecode=dbo.resolve_keyset(@v_addlqualifier,1)
  set @v_parm_titlerolecode=dbo.resolve_keyset(@v_addlqualifier,2)
  set @v_parm_taqprojecttype=dbo.resolve_keyset(@v_addlqualifier,3)
  --- set defaults if nessasary
  if @v_parm_projectrolecode is null
    set @v_parm_projectrolecode=4
  if @v_parm_titlerolecode is null
    set @v_parm_titlerolecode=1
  if @v_parm_taqprojecttype is null
    set @v_parm_taqprojecttype=67

  --select @v_ean_check=ean13
  --  from isbn i, book b
  --  where workkey=@v_bookkey
  --    and i.bookkey=b.bookkey
 
   --this is the ISBN of the current propagatefrombookkey, and the current workkey     
   Select @v_ean_check = dbo.rpt_get_isbn(propagatefrombookkey, 17), @v_bookkey_workkey = workkey from book where bookkey = @v_bookkey
      
    
  
  -- get propagate from EAN - this is new ISBN of the propagatefrombookkey
	SELECT @v_EAN = LTRIM(RTRIM(originalvalue))
	FROM imp_batch_detail
	WHERE batchkey = @i_batch
	AND row_id = @i_row
	AND elementseq = @i_elementseq
	AND elementkey = 100010041

  --if @i_newtitleind=1 or (@v_ean_check is not null and @v_ean_check<>@v_EAN)
  if @i_newtitleind=1 or (coalesce(@v_ean_check,'x')<>@v_EAN)
    begin

      -- these are the workkey, bookkey and propagatefrombookkey of the "new" propagatefrombookkey
		Select @v_workkey=workkey, @v_prop_bookkey = i.bookkey, @v_prop_bookkey_propagatefrombookkey = b.propagatefrombookkey  
		from isbn i, book b
		where ean13=REPLACE(@v_EAN,'-','')
		and b.bookkey=i.bookkey
		
		--DROP TABLE dbo.PGI_IKE_test

		--CREATE TABLE dbo.PGI_IKE_Test
		--(id_num int identity(1,1),
		--msg varchar(256))
				
		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@v_ean_check: ' + @v_ean_check ) 

		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@v_bookkey: ' + CAST(@v_bookkey as varchar(20))) 

		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@v_bookkey_workkey: ' + CAST(@v_bookkey_workkey as varchar(20))) 

		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@v_prop_bookkey: ' + CAST(@v_prop_bookkey as varchar(20)) )

		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@v_workkey: ' + CAST(@v_workkey as varchar(20)) )

		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@v_prop_bookkey_propagatefrombookkey: ' + CAST(@v_prop_bookkey_propagatefrombookkey as varchar(20)) )

		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@v_EAN: ' + @v_EAN ) 

		--insert into dbo.PGI_IKE_Test (msg)
		--values ('@i_newtitleind: ' + CAST(@i_newtitleind as varchar(20)))
	
	
		
		
		
	--Check if the eBook is a primary of its own work - if it is we can't move it to another work 
    --write feedback and exit out
    if (@v_bookkey = @v_bookkey_workkey) AND EXISTS (Select * from taqproject where workkey = @v_bookkey_workkey and taqprojecttype = 67) and (@v_bookkey_workkey <> @v_workkey)
		BEGIN
			SET @v_errmsg = 'Title is the primary format of its work. It cannot be moved out of the existing work! Propagation, primary isbn and propagate from bookkey updates fail!'
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, 3,3                  
			RETURN
		END
    
    --Check to see if the propagate from isbn is also propagating from another isbn 
    --We don't allow multiple propagation, write feedback and exit out
    if (@v_prop_bookkey IS NOT NULL) AND (@v_prop_bookkey_propagatefrombookkey IS NOT NULL)
		BEGIN
			SET @v_errmsg = dbo.rpt_get_isbn(@v_prop_bookkey, 17) + ' is already propagating from ' + dbo.rpt_get_isbn(@v_prop_bookkey_propagatefrombookkey, 17) + '.! Multiple level of propagation is not allowed! Propagation, primary isbn and propagate from bookkey updates fail.' 
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, 3,3                  
			RETURN
		END
		
      -- get propagate key
		--select @v_prop_bookkey=bookkey
		--from isbn
		--where ean13=REPLACE(@v_EAN,'-','')

      --
      exec copy_work_info  @v_prop_bookkey,@v_bookkey,NULL,NUll
      -- no feedback???

      -- set workkey and linklevelcode=20
      UPDATE book 
        SET 
          workkey=@v_workkey,
          propagatefrombookkey=@v_prop_bookkey,
          linklevelcode=20,
          lastuserid=@i_userid,
          lastmaintdate=getdate()
        where bookkey=@v_bookkey
        
      -- add book to work of the primary
      Select @v_taqprojectkey = taqprojectkey --@v_count=count(*)
        FROM taqproject
        where workkey =@v_workkey and taqprojecttype = @v_parm_taqprojecttype
        
      if @@ROWCOUNT = 1
        BEGIN
			--possible that the eBook is being moved to a new work, allow it only if the eBook is not the primary title of the existing work
			IF EXISTS (Select * FROM taqprojecttitle where bookkey = @v_bookkey and taqprojectkey <> @v_taqprojectkey and projectrolecode=@v_parm_projectrolecode AND titlerolecode=@v_parm_titlerolecode)
				BEGIN
					DELETE FROM taqprojecttitle where bookkey = @v_bookkey and taqprojectkey <> @v_taqprojectkey and projectrolecode=@v_parm_projectrolecode AND titlerolecode=@v_parm_titlerolecode
				END
				
			SELECT @v_count=count(*)
			FROM taqprojecttitle 
			where bookkey=@v_bookkey
			and taqprojectkey = @v_taqprojectkey
			AND projectrolecode=@v_parm_projectrolecode
			AND titlerolecode=@v_parm_titlerolecode
			
          if @v_count = 0
            BEGIN
              
              --update keys
              --  set
              --    generickey=generickey+1,
              --    lastuserid=@i_userid,
              --    lastmaintdate=GETDATE()
              --select @v_newkey=generickey
              --  from keys
              
			  execute get_next_key 'qsiadmin',@v_newkey OUTPUT
              
              INSERT INTO taqprojecttitle
                (taqprojectformatkey,taqprojectkey,primaryformatind,bookkey,projectrolecode,titlerolecode,lastuserid,lastmaintdate, printingkey)
                values
                (@v_newkey,@v_taqprojectkey,0,@v_bookkey,@v_parm_projectrolecode,@v_parm_titlerolecode,@i_userid,getdate(), 1)
            END
        end

      SET @v_errmsg = 'Propagate from EAN - '+coalesce(@v_EAN,'error')
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
    END
END
