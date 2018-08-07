DECLARE 
  @v_max_taqtaskkey int

begin
  select @v_max_taqtaskkey = max(taqtaskkey) 
    from taqprojecttask
   where taqtaskkey < 428683000

  update keys
     set taqtaskkey = @v_max_taqtaskkey + 1
end

