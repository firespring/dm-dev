DROP DATABASE IF EXISTS datamapper_default_tests;
CREATE DATABASE datamapper_default_tests;

DROP DATABASE IF EXISTS datamapper_alternate_tests;
CREATE DATABASE datamapper_alternate_tests;

DROP DATABASE IF EXISTS do_test;
CREATE DATABASE do_test;

CREATE USER 'datamapper'@'%' IDENTIFIED BY 'datamapper';
GRANT ALL ON datamapper_default_tests.* TO 'datamapper'@'%';
GRANT ALL ON datamapper_alternate_tests.* TO 'datamapper'@'%';
GRANT ALL ON do_test.* TO 'datamapper'@'%';
