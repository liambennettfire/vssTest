/* add elo field identifier for 

DPIDXBIZCOVERURL

*/   
declare @datacode int
select @datacode=max(datacode) +1 from gentables where tableid=560
  
   INSERT INTO gentables
   (tableid,
   datacode,
   datadesc,
   deletestatus,
   sortorder,
   tablemnemonic,
   datadescshort,
   lastuserid,
   lastmaintdate,
   acceptedbyeloquenceind,
   exporteloquenceind,
   eloquencefieldtag )
   VALUES
  (560,
   @datacode,
   'DPIDXBIZCOVERURL - Cover Image URL',
   'N',
   @datacode,
   'ValidEloFieldIds',
   'Cover Image URL',
   'FBTDBA',
   getdate(),
   1,
   1,
   'DPIDXBIZCOVERURL')



     
   