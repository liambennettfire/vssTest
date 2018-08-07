UPDATE taqscaleadminspecitem
SET scaletabkey = 5003894
WHERE scaletabkey = 0 AND 
scaleadminspeckey IN 
(
5003921,
5003922,
5003924,
5003927,
5003928,
5003929,
5003930,
5003931,
5003932,
5003947
) 

UPDATE taqscaleadminspecitem 
SET scaletabkey = 5003896
WHERE scaletabkey = 0 AND 
scaleadminspeckey IN 
(
5003970,
5003936,
5003939,
5003942,
5003943,
5003944,
5003945
)

UPDATE taqscaleadminspecitem 
SET scaletabkey = 5003901,  varcostlabel = 'Printing/Paper Cost'
WHERE scaletabkey = 0 AND
scaleadminspeckey = 5003967