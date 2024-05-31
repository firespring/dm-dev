DROP DATABASE IF EXISTS datamapper_default_tests;
CREATE DATABASE datamapper_default_tests;

DROP DATABASE IF EXISTS datamapper_alternate_tests;
CREATE DATABASE datamapper_alternate_tests;

CREATE USER 'datamapper'@'%' IDENTIFIED BY 'datamapper';
GRANT ALL ON datamapper_default_tests.* TO 'datamapper'@'%';
GRANT ALL ON datamapper_alternate_tests.* TO 'datamapper'@'%';