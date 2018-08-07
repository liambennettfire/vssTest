-- Recalculate displayname for all rows with autodisplayind=1

DECLARE @v_globalcontactkey INT,
        @v_individualind INT,
        @v_lastname VARCHAR(max), 
        @v_firstname VARCHAR(max), 
        @v_middlename VARCHAR(max), 
        @v_suffix VARCHAR(max), 
        @v_degree VARCHAR(max),
        @v_displayname VARCHAR(max), 
        @o_error_code INT, 
        @o_error_desc VARCHAR(max)

DECLARE contact_cur CURSOR FOR
SELECT globalcontactkey, individualind, lastname, firstname, middlename, suffix, degree FROM globalcontact WHERE autodisplayind=1

OPEN contact_cur
FETCH contact_cur INTO
  @v_globalcontactkey, @v_individualind, @v_lastname, @v_firstname, @v_middlename, @v_suffix, @v_degree

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC globalcontact_displayname @v_individualind, @v_lastname, @v_firstname, @v_middlename, @v_suffix, @v_degree, @v_displayname OUT, @o_error_code OUT, @o_error_desc OUT

  IF @o_error_code = 0
    UPDATE globalcontact SET displayname = @v_displayname
    WHERE globalcontactkey = @v_globalcontactkey

  FETCH contact_cur INTO
    @v_globalcontactkey, @v_individualind, @v_lastname, @v_firstname, @v_middlename, @v_suffix, @v_degree
END

CLOSE contact_cur
DEALLOCATE contact_cur