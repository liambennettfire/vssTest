SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/******************************************************************************
**  Name: imp_pl_accounting_data
**  Desc: IKE P&L 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_pl_accounting_data]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_pl_accounting_data]
GO

CREATE PROCEDURE [dbo].[imp_pl_accounting_data]

    @i_bookkey int,

    @i_batch int,

    @i_row int,

    @i_elementseq int,

    @i_dmlkey bigint,

    @i_userid varchar(50),

    @o_errcode int output,

    @o_errmsg varchar(500) output



AS

DECLARE

  @v_taqprojectkey int,

  @v_taqprojectkey_org int,

  @v_taqprojectformatkey int,

  @v_exitloop int,

  @v_errcode int,

  @v_errmsg varchar(500),

  @v_rowcnt int,

  @v_accountingmonth datetime,

  @v_accountingmonthtext varchar(50),

  @v_accountingcodetext varchar(20),

  @v_accountingcode int,

  @v_amount  float,

  @v_amount_org  float,

  @v_process varchar(50),

  @v_action int,

  @v_placctgcategorycode int,

  @v_gen1ind int,

  @v_usageclass  int



BEGIN



--print 'START: imp_pl_accounting_data'

  declare @ProdNum as varchar(max)

  SELECT @ProdNum =  COALESCE(originalvalue,'*NULL*')

    FROM imp_batch_detail b 

    WHERE b.batchkey = @i_batch

      AND b.row_id = @i_row

      AND b.elementkey = 100010003



  SELECT @v_action =  COALESCE(originalvalue,0)

    FROM imp_batch_detail b 

    WHERE b.batchkey = @i_batch

      AND b.row_id = @i_row

      AND b.elementseq = @i_elementseq

      AND b.elementkey = 100027000

  SELECT @v_usageclass =  COALESCE(originalvalue,0)

    FROM imp_batch_detail b 

    WHERE b.batchkey = @i_batch

      AND b.row_id = @i_row

      AND b.elementseq=@i_elementseq

      AND b.elementkey = 100027001

  SELECT @v_amount =  originalvalue

    FROM imp_batch_detail b 

    WHERE b.batchkey = @i_batch

      AND b.row_id = @i_row

      AND b.elementseq=@i_elementseq

      AND b.elementkey = 100027021



  SELECT @v_accountingmonthtext =  originalvalue

    FROM imp_batch_detail b 

    WHERE b.batchkey = @i_batch

      AND b.row_id = @i_row

      AND b.elementseq=@i_elementseq

      AND b.elementkey = 100027002

  

	set @v_accountingmonth=cast(@v_accountingmonthtext as datetime)

  

  --if datalength(@v_accountingmonthtext)=6

  --  begin

  --    set @v_accountingmonthtext = substring(@v_accountingmonthtext,1,2)+'/01/'+substring(@v_accountingmonthtext,3,4)

  --    set @v_accountingmonth = @v_accountingmonthtext

  --  end

  --else

  --  begin

  --    --set @v_accountingmonth = @v_accountingmonthtext

	 -- set @v_accountingmonth = cast(@v_accountingmonthtext as datetime)

  --  end



  SELECT @v_amount =  COALESCE(cast(originalvalue as float),0)

    FROM imp_batch_detail b 

    WHERE b.batchkey = @i_batch

      AND b.row_id = @i_row

      AND b.elementseq=@i_elementseq

      AND b.elementkey = 100027021

  SELECT @v_accountingcodetext =  COALESCE(originalvalue,'0')

    FROM imp_batch_detail b 

    WHERE b.batchkey = @i_batch

      AND b.row_id = @i_row

      AND b.elementseq=@i_elementseq

      AND b.elementkey = 100027022



  select @v_rowcnt=count(*)

    from cdlist

    where externalcode=@v_accountingcodetext

  if @v_rowcnt=1

    begin

      select @v_accountingcode=internalcode

        from cdlist

        where externalcode=@v_accountingcodetext

    end

  else

    begin

      set @v_accountingcode=0

      set @v_errcode=3

      set @v_errmsg='Missing accounting code :'+@v_accountingcodetext

      exec imp_write_feedback @i_batch,@i_row,null,@i_elementseq ,@i_dmlkey,@v_errmsg,1,2

    end



--print '@v_accountingcodetext='+@v_accountingcodetext+'/'+cast( @v_accountingcode as varchar(max))



  select @v_placctgcategorycode=placctgcategorycode

    from cdlist

    where externalcode=@v_accountingcodetext

  select @v_gen1ind=gen1ind

    from gentables 

    where tableid=571

      and datacode=@v_placctgcategorycode

  if @v_gen1ind=1

    set @v_process='income'

  else

    set @v_process='expense'



--print '*****************************************************************'

--print '@v_action='+COALESCE(cast(@v_action as varchar(max)),'*NULL*')

--print '@v_usageclass='+COALESCE(cast(@v_usageclass as varchar(max)),'*NULL*')

--print '@v_amount='+COALESCE(cast(@v_amount as varchar(max)),'*NULL*')

--print '@v_accountingmonthtext='+COALESCE(cast(@v_accountingmonthtext as varchar(max)),'*NULL*')

--print '@v_accountingmonth='+COALESCE(cast(@v_accountingmonth as varchar(max)),'*NULL*')

--print '@v_amount='+COALESCE(cast(@v_amount as varchar(max)),'*NULL*')

--print '@v_accountingcodetext='+COALESCE(cast(@v_accountingcodetext as varchar(max)),'*NULL*')

--print '@v_rowcnt='+COALESCE(cast(@v_rowcnt as varchar(max)),'*NULL*')

--print '@v_placctgcategorycode='+COALESCE(cast(@v_placctgcategorycode as varchar(max)),'*NULL*')

--print '@v_gen1ind='+COALESCE(cast(@v_gen1ind as varchar(max)),'*NULL*')

--print '@v_process='+COALESCE(cast(@v_process as varchar(max)),'*NULL*')

--print '*****************************************************************'



  declare c_projecttitles cursor fast_forward for 

    select DISTINCT taqprojectkey,taqprojectformatkey

      from taqprojecttitle

      where bookkey=@i_bookkey



--    select pt.taqprojectkey,taqprojectformatkey

--      from taqprojecttitle pt, taqproject p

--      where pt.taqprojectkey=p.taqprojectkey

--        and bookkey=@i_bookkey

--        and usageclasscode=@v_usageclass



  open c_projecttitles

  fetch c_projecttitles into @v_taqprojectkey,@v_taqprojectformatkey

  set @v_taqprojectkey_org=@v_taqprojectkey

  set @v_exitloop=0

  while @@fetch_status=0 and @v_exitloop=0

    begin

      select @v_rowcnt=count(*) 

        from taqplincome_actual

        where taqprojectkey=@v_taqprojectkey

          and taqprojectformatkey=@v_taqprojectformatkey

          and acctgcode=@v_accountingcode

          and accountingmonth=@v_accountingmonth

      if @v_process='income'

        begin

          if @v_rowcnt=0

            begin

              insert into taqplincome_actual

                (taqprojectkey,taqprojectformatkey,acctgcode,accountingmonth,

                 bookkey,amount,lastuserid,lastmaintdate)

                values

                (@v_taqprojectkey,@v_taqprojectformatkey,@v_accountingcode,@v_accountingmonth,

                 @i_bookkey,@v_amount,@i_userid,getdate())

            end

          else

            begin

              if @v_action=1

                begin

                  select @v_amount_org=coalesce(amount,0)

                    from taqplincome_actual

                      where taqprojectkey=@v_taqprojectkey

                        and taqprojectformatkey=@v_taqprojectformatkey

                        and accountingmonth=@v_accountingmonth

                        and bookkey=@i_bookkey

                  set @v_amount=@v_amount+@v_amount_org

                end

              update taqplincome_actual

                set

                  amount=@v_amount,

                  lastuserid=@i_userid,

                  lastmaintdate=getdate()

                where taqprojectkey=@v_taqprojectkey

                  and taqprojectformatkey=@v_taqprojectformatkey

                  and accountingmonth=@v_accountingmonth

                  and bookkey=@i_bookkey

				  and acctgcode=@v_accountingcode

            end

        end

     select @v_rowcnt=count(*) 

        from taqplcosts_actual

        where taqprojectkey=@v_taqprojectkey

          and taqprojectformatkey=@v_taqprojectformatkey

          and acctgcode=@v_accountingcode

          and accountingmonth=@v_accountingmonth

      if @v_process='expense'

        begin

          if @v_rowcnt=0

            begin

              insert into taqplcosts_actual

                (taqprojectkey,taqprojectformatkey,acctgcode,accountingmonth,bookkey,amount,lastuserid,lastmaintdate)

                values

                (@v_taqprojectkey,@v_taqprojectformatkey,@v_accountingcode,@v_accountingmonth,@i_bookkey,@v_amount,@i_userid,getdate() )

            end

          else

            begin

              if @v_action=1

                begin

                  select @v_amount_org=coalesce(amount,0)

                    from taqplcosts_actual

                    where taqprojectkey=@v_taqprojectkey

                      and taqprojectformatkey=@v_taqprojectformatkey

                      and accountingmonth=@v_accountingmonth

                      and bookkey=@i_bookkey

                  set @v_amount=@v_amount+@v_amount_org

                end

              update taqplcosts_actual

                set

                  amount=@v_amount,

                  lastuserid=@i_userid,

                  lastmaintdate=getdate()

                where taqprojectkey=@v_taqprojectkey

                  and taqprojectformatkey=@v_taqprojectformatkey

                  and accountingmonth=@v_accountingmonth

                  and bookkey=@i_bookkey

				  and acctgcode=@v_accountingcode

            end

        end



      fetch c_projecttitles into @v_taqprojectkey,@v_taqprojectformatkey

      if @v_taqprojectkey=@v_taqprojectkey_org and @@fetch_status=0

        begin

          set @v_exitloop=1

        end

      if @v_taqprojectkey<>@v_taqprojectkey_org and @@fetch_status=0

        begin

          set @v_errcode=2

          set @v_errmsg='Processing multiple projects for bookkey '+cast(@i_bookkey as varchar)

          exec imp_write_feedback @i_batch,@i_row,null,@i_elementseq ,@i_dmlkey,@v_errmsg,1,2

        end

    end

  close c_projecttitles

  deallocate c_projecttitles



--print 'END: imp_pl_accounting_data'

END


Go 
Grant all on imp_pl_accounting_data to public