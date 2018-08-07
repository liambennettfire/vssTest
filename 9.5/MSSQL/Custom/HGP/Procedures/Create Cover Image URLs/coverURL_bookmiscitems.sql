
DECLARE @i_misckey int
DECLARE @i_fieldIdCode int

select @i_misckey = MAX(misckey) + 1 from bookmiscitems
select @i_fieldIdCode = datacode from gentables where tableid=560 and eloquencefieldtag = 'DPIDXBIZCOVERURL'

INSERT INTO bookmiscitems (misckey,miscname,misctype,activeind,lastuserid,lastmaintdate,sendtoeloquenceind,
eloquencefieldidcode,defaultsendtoeloqvalue,misclabel)
VALUES (@i_misckey,'Cover Image URL',3,1,'qsidba',GETDATE(),1,@i_fieldIdCode,1,'Cover Image URL')