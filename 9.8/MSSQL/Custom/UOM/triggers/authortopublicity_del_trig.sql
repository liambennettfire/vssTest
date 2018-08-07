/*****************************************************************/   
/*              Created by Althea A. 7-2-03  */
/*  		ANY AUTHOR DELETED FROM AUTHOR TABLE delete FROM CONTACT AND CONTACTADDRESS*/
/* RUN ON GENMSDEV   */
/*****************************************************************/   

if exists (select * from dbo.sysobjects where id = Object_id('dbo.authortopublicity_del_trig') and (type = 'P' or type = 'TR'))
begin
 drop trigger dbo.authortopublicity_del_trig
end

GO

CREATE TRIGGER authortopublicity_del_trig ON author
FOR DELETE AS 

DECLARE @v_authorkey int
DECLARE @v_count  int
DECLARE @err_msg varchar(100)

SELECT @v_authorkey =old.authorkey
  FROM deleted old 

IF @@error != 0
  BEGIN
	ROLLBACK TRANSACTION
	select @err_msg = 'Could not select from author table (trigger).'
	print @err_msg
  END
ELSE
  BEGIN  	
	
	 	select @v_count = count(*)
      	   		FROM contact
			WHERE contactkey = @v_authorkey

       if @v_count = 1
	  BEGIN /*DELETE*/
		DELETE FROM contact
				where contactkey= @v_authorkey

		DELETE FROM contactaddress
					where contactkey= @v_authorkey
  	  END
  END
GO

