CREATE TEMPORARY TABLESPACE temp0
TEMPFILE 'H:\oraclexe\oradata\XE\temp0.dbf' SIZE 256M REUSE
AUTOEXTEND ON NEXT 256M MAXSIZE 10G 
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp0;
DROP TABLESPACE temp INCLUDING CONTENTS AND DATAFILES;
CREATE TEMPORARY TABLESPACE temp
TEMPFILE 'H:\oraclexe\oradata\XE\temp.dbf' SIZE 256M REUSE
AUTOEXTEND ON NEXT 256M MAXSIZE 10G 
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp;
DROP TABLESPACE temp0 INCLUDING CONTENTS AND DATAFILES;

alter database tempfile 'H:\oraclexe\oradata\XE\TEMP.DBF' resize 100M