CREATE TABLE regions (
    region_id bigint NOT NULL,
    region_name varchar(25)
) ;
ALTER TABLE regions ADD PRIMARY KEY (region_id);


CREATE TABLE countries (
    country_id char(2) NOT NULL,
    country_name varchar(40),
    region_id bigint
) ;
ALTER TABLE countries ADD PRIMARY KEY (country_id);



CREATE TABLE departments (
    department_id smallint NOT NULL,
    department_name varchar(30),
    manager_id integer,
    location_id smallint
) ;
ALTER TABLE departments ADD PRIMARY KEY (department_id);




INSERT INTO regions (region_id, region_name) 
VALUES 
  (1, 'Europe'),
  (2, 'Americas'),
  (3, 'Asia'),
  (4, 'Middle East and Africa');


INSERT INTO countries (country_id, country_name, region_id) 
VALUES 
  ('IT', 'Italy', 1),
  ('JP', 'Japan', 3),
  ('US', 'United States of America', 2),
  ('CA', 'Canada', 2),
  ('CN', 'China', 3),
  ('IN', 'India', 3),
  ('AU', 'Australia', 3),
  ('ZW', 'Zimbabwe', 4),
  ('SG', 'Singapore', 3);

INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES 
  (10, 'Administration', 200, 1700),
  (20, 'Marketing', 201, 1800),
  (30, 'Purchasing', 114, 1700),
  (40, 'Human Resources', 203, 2400),
  (50, 'Shipping', 121, 1500),
  (60, 'IT', 103, 1400);

