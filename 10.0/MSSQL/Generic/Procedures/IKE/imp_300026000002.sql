/******************************************************************************
**  Name: imp_300026000002
**  Desc: IKE Author Wrap-up
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/26/2016    Kusum		 Case 36763
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026000002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026000002]
GO

CREATE PROCEDURE dbo.imp_300026000002 @i_batch int,@i_row int,@i_dmlkey bigint,@i_titlekeyset varchar(500),@i_contactkeyset varchar(500),
  @i_templatekey int,@i_elementseq int,@i_level int,@i_userid varchar(50),@i_newtitleind int,@i_newcontactind int,@o_writehistoryind int output
AS

/* Author Wrap-up */

BEGIN 

	DECLARE @v_errcode     INT,
		@v_errmsg     VARCHAR(4000),
		@v_cur_displayname   VARCHAR(80),
		@v_new_displayname  VARCHAR(80),
		@v_lastnameupper   VARCHAR(75),
		@v_firstname     VARCHAR(75),
		@v_lastname     VARCHAR(75),
		@v_middlename     VARCHAR(75),
		@v_degree    VARCHAR(40),
		@v_activeind     INT,
		@v_corpcontribind   INT,
		@v_authorkey    INT,
		@v_transtype    VARCHAR(50),
		@v_bookkey    INT,
		@v_printingkey    INT,
		@v_option1    INT,
		@v_option2    INT,
		@v_suffix    VARCHAR(40),
		@v_historymsg    VARCHAR(2000),
		@v_historycode    INT,
		@v_firstname_innitial char(1),
		@v_middlename_innitial char(1),
		@v_space2 char(1),
		@v_space char(1),
		@v_comma char(2)

	BEGIN
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
		SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Author Update Wrap-up'
	  
		SET @v_space = ' '
		SET @v_space2 = ' '
		SET @v_comma = ', '
	    

		IF @i_newcontactind = 1 
			SET @v_transtype = 'insert'
		ELSE 
		   SET @v_transtype = 'update'
		

		SELECT @v_lastname = COALESCE(lastname,''),
			   @v_firstname = COALESCE(firstname,''),
			   @v_middlename = COALESCE(middlename,''),
			   @v_suffix = COALESCE(authorsuffix,''),
			   @v_degree = COALESCE(authordegree,''),
			   @v_cur_displayname = displayname,
			   @v_activeind = activeind,
			   @v_corpcontribind = corporatecontributorind  
		  FROM author
		 WHERE authorkey = @v_authorkey
	    
		SET @v_lastname = ltrim(rtrim(@v_lastname))
		SET @v_firstname = ltrim(rtrim(@v_firstname))
		SET @v_middlename = ltrim(rtrim(@v_middlename))
		SET @v_middlename_innitial = substring(@v_middlename,1, 1)
		SET @v_firstname_innitial = substring(@v_firstname, 1, 1)
		
		SET @v_lastname = IsNull(@v_lastname, '')
		SET @v_firstname = IsNull(@v_firstname, '')
		SET @v_middlename = IsNull(@v_middlename, '')
		SET @v_middlename_innitial = IsNull(@v_middlename_innitial, '')
		SET @v_firstname_innitial = IsNull(@v_firstname_innitial, '')   
	 
		IF @v_cur_displayname IS NULL OR @v_cur_displayname = '' BEGIN
			
			--When both firstname and middlename are missing, set displayname to lastname
			IF @v_firstname = '' AND @v_middlename = '' BEGIN
				SET @v_new_displayname = @v_lastname
			END
			  
			SELECT @v_option1 = optionvalue
			  FROM clientoptions
			 WHERE optionid = 26

			SELECT @v_option2 = optionvalue
			  FROM clientoptions
			 WHERE optionid = 20

			IF @v_option1 IS NULL OR @v_option2 IS NULL
				 SET @v_errmsg = 'Author Display Name Client Options are NOT set for filterkey'
			ELSE BEGIN
				--0 (default) Last, First MI; 1 will generate: Last, FirstInitial; 2 will generate First Last; 3 will generate First MI Last; 
				--4 will generate Last, First, Middle
				IF @v_option1 = 0 BEGIN
					IF @v_middlename_innitial = '' BEGIN  
						SET @v_space = '' 
					END
					IF @v_firstname = '' BEGIN 
						SET @v_space = '' 
					END 
					IF @v_middlename_innitial = '' and @v_firstname = '' BEGIN
						SET @v_space = ''
						SET @v_comma = ''
					END

					set @v_new_displayname = @v_lastname + @v_comma + @v_firstname + @v_space + @v_middlename_innitial
				END
				IF @v_option1 = 1 BEGIN  --1 will generate: Last, FirstInitial;
					IF @v_firstname_innitial = '' BEGIN 
						SET @v_comma = '' 
					END
					SET @v_new_displayname = @v_lastname + @v_comma + @v_firstname_innitial
				END
				IF @v_option1  = 2 BEGIN  --2 will generate First Last;
					IF @v_firstname = '' BEGIN 
						SET @v_space = '' 
					END
					SET @v_new_displayname = @v_firstname + @v_space + @v_lastname
				END
				IF @v_option1  = 3 BEGIN  --3 will generate First MI Last;
					IF @v_firstname <> '' and @v_middlename = '' BEGIN 
						SET @v_space = '' 
					END
					IF @v_firstname = '' and @v_middlename <> '' BEGIN 
						SET @v_space = '' 
					END
					SET @v_new_displayname = @v_firstname + @v_space + @v_middlename_innitial + @v_space2 + @v_lastname
				END
				IF @v_option1  = 4 BEGIN  ----4 will generate Last, First, Middle
					IF @v_firstname = '' and @v_middlename = '' BEGIN
						SET @v_new_displayname = @v_lastname 
					END
					IF @v_firstname <> '' and @v_middlename = '' BEGIN
						SET @v_new_displayname = @v_lastname + @v_comma + @v_firstname
					END
					IF @v_firstname = '' and @v_middlename <> '' BEGIN
						SET @v_new_displayname = @v_lastname + @v_comma + @v_middlename
					END
					IF @v_firstname <> '' and @v_middlename <> '' BEGIN
						SET @v_new_displayname = @v_lastname + @v_comma + @v_firstname + ' ' + @v_middlename
					END
				END
	          
			  --1 will include Degrees and Suffix in the generated author displayname, 0 (default) will generate author displayname without these fields
			  IF @v_option2 = 1 BEGIN
				SET @v_suffix = rtrim(ltrim(@v_suffix))
				SET @v_degree = rtrim(ltrim(@v_degree))
				
				SET @v_suffix = iSnull(@v_suffix, '')
				SET @v_degree = iSnull(@v_degree, '')
				IF @v_suffix <> '' BEGIN
					SET @v_new_displayname = @v_new_displayname + @v_comma + @v_suffix
				END
				IF @v_degree <> '' BEGIn
					set @v_new_displayname = @v_new_displayname + @v_comma + @v_degree
				END
			  END
			  
			  
			  UPDATE author SET displayname = @v_new_displayname,lastuserid = @i_userid,lastmaintdate = getdate() WHERE authorkey = @v_authorkey
	 
			  IF @@ROWCOUNT = 1  BEGIN
				  EXECUTE qtitle_update_titlehistory 'author','displayname',@v_bookkey,@v_printingkey,0,
					@v_new_displayname,@v_transtype,@i_userid,null,null,@v_historycode output, @v_historymsg output    
				  IF @v_errcode >= @i_level
					EXECUTE imp_write_feedback @i_batch, @i_row, 100026005, @i_elementseq ,@i_dmlkey , 'Author Display Name Updated', @v_errcode, 3
			  END
		   END
		END

		IF @v_activeind is null BEGIN
			UPDATE author SET activeind = 1, lastuserid = @i_userid,lastmaintdate = getdate() WHERE authorkey = @v_authorkey
			IF @v_errcode >= @i_level
			  EXECUTE imp_write_feedback @i_batch, @i_row, 100026010, @i_elementseq ,@i_dmlkey , 'Author Active Indicator is set to Yes', @v_errcode, 3
		END
	  
		IF @v_corpcontribind is null BEGIN
			UPDATE author SET corporatecontributorind = 0,lastuserid = @i_userid,lastmaintdate = getdate() WHERE authorkey = @v_authorkey
			IF @@ROWCOUNT = 1 BEGIN                              
				EXECUTE qtitle_update_titlehistory 'author','corporatecontributorind',@v_bookkey,@v_printingkey,0,'Y',@v_transtype,@i_userid,null,null,@v_historycode output, @v_historymsg output    
				IF @v_errcode >= @i_level
				  EXECUTE imp_write_feedback @i_batch, @i_row, 100026004, @i_elementseq ,@i_dmlkey , 'Corporate Contributor Indicator is set to No', @v_errcode, 3
			 END
		END

		SET @v_errmsg = 'Author Update Wrap-up'  
	 
		IF @v_errcode >= @i_level BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row, 300026000, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
		END
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300026000002] to PUBLIC 
GO
