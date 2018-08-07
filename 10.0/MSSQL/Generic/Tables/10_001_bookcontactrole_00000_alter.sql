ALTER TABLE bookcontact
ADD addresskey int
go

ALTER TABLE bookcontactrole
ADD quantity INT,
    globalcontactrelationshipkey INT,
    indicator TINYINT
go
