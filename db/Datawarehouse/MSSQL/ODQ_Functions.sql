create or replace function dqm_app.bitAND2 (parm1 integer, parm2 integer) RETURNS integer
AS $$
output_value integer;
BEGIN
output_value :=  parm1 & parm2;
RETURNS output_value;
END ;
$$ LANGUAGE plpgsql;

********* Example

create or replace function bitAND2 (parm1 integer, parm2 integer) RETURNS integer
AS $$
select parm1 & parm2;
$$ LANGUAGE SQL;

select bitAND2(13,15)

******************

create or replace function dqm_app.bitAND3 (parm1 IN integer, parm2 IN integer, parm3 IN integer) RETURNS integer
IS
output_value integer;
BEGIN
output_value :=  bitAnd(bitAnd(parm1,parm2),parm3);
RETURNS output_value;
END bitAND3;
/

create or replace function dqm_app.bitOR (parm1 IN integer, parm2 IN integer) RETURNS integer
IS
output_value integer;
BEGIN
output_value := (parm1+parm2) - bitAnd(parm1,parm2);
RETURNS output_value;
END bitOR;
/

CREATE OR REPLACE FUNCTION dqm_app.to_binary
(pin IN NUMBER)
RETURNS VARCHAR2 
IS
v_in   NUMBER;
v_next NUMBER;
v_result varchar(2000);
BEGIN   v_in := pin;
WHILE v_in > 0 LOOP
v_next := mod(v_in,2);
v_result := to_char(v_next) || v_result;
v_in := floor(v_in / 2);
END LOOP;
RETURNS v_result;
END;
/

CREATE OR REPLACE FUNCTION dqm_app.from_binary 
(pin IN VARCHAR2) 
RETURNS NUMBER
IS
c_in VARCHAR(2000);
c_dim NUMBER;
v_cursor NUMBER;
v_power NUMBER;
v_bit NUMBER;
v_result NUMBER;
BEGIN
c_in := pin;
c_dim := length(c_in);
v_cursor := c_dim;
v_bit := 0;
v_power := 0;
v_result := 0;
WHILE v_cursor > 0 LOOP
v_bit := substr(c_in,v_cursor,1);
v_power := c_dim - v_cursor;
v_result := v_result + (v_bit * power(2,v_power)) ;
v_cursor := v_cursor - 1;
END LOOP;
RETURNS v_result;
END;
/
