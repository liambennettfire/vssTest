-- Do updates so the triggers will fire and update coretitleinfo

UPDATE book
SET title = 'Inside Pine Gap'
WHERE bookkey = 52170697

UPDATE bookdetail
SET mediatypecode = 2
WHERE bookkey = 52170697
