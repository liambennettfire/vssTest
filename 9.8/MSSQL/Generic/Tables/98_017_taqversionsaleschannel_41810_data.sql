DECLARE @v_taqversionsaleskey INT, @v_taqprojectformatkey INT, @v_netprice FLOAT

DECLARE taqversionsaleschannel_cur CURSOR FOR
SELECT s.taqversionsaleskey, s.taqprojectformatkey, ROUND((f.activeprice - ((f.activeprice * s.discountpercent) / 100)), 2) netprice 
FROM taqversionsaleschannel s JOIN taqversionformat f ON f.taqprojectformatkey=s.taqprojectformatkey
WHERE COALESCE(s.calcdiscountind, 0) = 0

OPEN taqversionsaleschannel_cur

FETCH NEXT FROM taqversionsaleschannel_cur INTO @v_taqversionsaleskey, @v_taqprojectformatkey, @v_netprice

WHILE @@FETCH_STATUS = 0
BEGIN
  UPDATE taqversionsaleschannel SET calcdiscountind = 0, netprice = @v_netprice WHERE taqversionsaleskey = @v_taqversionsaleskey AND taqprojectformatkey = @v_taqprojectformatkey
  FETCH NEXT FROM taqversionsaleschannel_cur INTO @v_taqversionsaleskey, @v_taqprojectformatkey, @v_netprice
END

CLOSE taqversionsaleschannel_cur
DEALLOCATE taqversionsaleschannel_cur
