-- CODE TEST 1:
-- The Script below will create the Database, table and populate it.
-- Your goal is: 
-- Write an SQL query to fetch all the Employees who are also managers from the EmployeeDetails table.
CREATE DATABASE BVM
;
CREATE SCHEMA HR
;
-- ALTER DATABASE [BVM] SET RECOVERY SIMPLE
-- Snowflake has TimeTravel
;
CREATE TABLE BVM.HR.EmployeeDetails (
    EmpID       INT PRIMARY KEY,
    FullName    VARCHAR(255),
    ManagerID   INT,
    FOREIGN KEY (ManagerID) REFERENCES EmployeeDetails(EmpID)
);

INSERT INTO BVM.HR.EmployeeDetails (EmpID, FullName, ManagerID) VALUES
    (1, 'Alice Johnson', NULL), -- Alice is a top-level manager (no manager above her)
    (2, 'Bob Smith', 1), -- Bob's manager is Alice
    (3, 'Charlie Reeds', 1), -- Charlie's manager is Alice
    (4, 'Diana Green', 2), -- Diana's manager is Bob
    (5, 'Evan Strokes', 2), -- Evan's manager is Bob
    (6, 'Fiona Cheng', 3), -- Fiona's manager is Charlie
    (7, 'George Kimmel', 3), -- George's manager is Charlie
    (8, 'Hannah Morse', 3), -- Hannah's manager is Charlie
    (9, 'Ian DeVoe', 3), -- Ian's manager is Charlie
    (10, 'Jenny Hills', 3); -- Jenny's manager is Charlie

;    

SELECT * FROM BVM.HR.EmployeeDetails

;




-- CODE TEST 2:
-- Write an SQL query to fetch only odd rows from the table EmployeeDetails.
-- Remember it is not the EmpID but the row numbers!
-- Execute this insert to add one more Employee.
INSERT INTO EmployeeDetails (EmpID, FullName, ManagerID) VALUES
(21, 'Alex Smith', 3)
;
-- Then write your query.
SELECT
    *
    -- ,ROW_NUMBER() OVER(ORDER BY EMPID)
FROM BVM.HR.EmployeeDetails
QUALIFY
    ROW_NUMBER() OVER(ORDER BY EMPID) % 2 = 1


;





-- CODE TEST 3:
-- Design a database schema for an e-commerce platform considering products, orders, customers, and payments. 
-- Provide the DDL to build the DB and tables.
-- Example:
-- Creating the Products table
CREATE SCHEMA ECOMERCE;

CREATE TABLE IF NOT EXISTS BVM.ECOMERCE.products (
    product_id      INT PRIMARY KEY,
    name            VARCHAR(255),    
    description     VARCHAR(255),
    price           FLOAT,
    current_stock   INT,
    valid_from  DATETIME, -- Slow changing dimension control
    valid_to    DATETIME, -- Slow changing dimension control
    "curren"    BOOLEAN   -- Slow changing dimension control
    
);
-- Creating the Customers table
CREATE TABLE IF NOT EXISTS BVM.ECOMERCE.customers (
    customer_id INT PRIMARY KEY,
    name        VARCHAR(255),
    email       VARCHAR(255),
    country     VARCHAR(255),
    state       VARCHAR(255),
    city        VARCHAR(255),
    zipcode     VARCHAR(20) ,-- It may have '-'
    address     VARCHAR(255),
    phone       VARCHAR(255),-- In case there are phones with +
    valid_from  DATETIME, -- Slow changing dimension control
    valid_to    DATETIME, -- Slow changing dimension control
    "current"   BOOLEAN   -- Slow changing dimension control
);
-- Creating the Orders table
CREATE TABLE IF NOT EXISTS BVM.ECOMERCE.orders (
    order_id        INT PRIMARY KEY,
    customer_id     INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT,-- No float numbers are expected.
    amount          FLOAT,
    status          VARCHAR(255),
    "date"          DATETIME,
    FOREIGN KEY (customer_id)   REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)    REFERENCES products(product_id)

)
;
-- Creating the Customers table
CREATE TABLE IF NOT EXISTS BVM.ECOMERCE.payments (
    payment_id  INT PRIMARY KEY,    
    customer_id INT NOT NULL,
    order_id    INT NOT NULL,
    method      VARCHAR(255),
    amount      FLOAT,
    status      VARCHAR(255),
    FOREIGN KEY (customer_id)   REFERENCES customers(customer_id),
    FOREIGN KEY (order_id)      REFERENCES orders(order_id)
)
;





-- CODE TEST 4:
-- Rank the sales people by their aggregate sales while providing their name, position, salary and aggregate sales amount. 
-- There must also be the column rank in the select.

-- I will create all necessary data in one table for simplification since the focus of this question is the application of the Rank funtion.
CREATE TABLE IF NOT EXISTS BVM.ECOMERCE.salesperson (
    name        VARCHAR,
    "position"    VARCHAR,
    salary      FLOAT,
    sales       FLOAT
)
;
INSERT INTO BVM.ECOMERCE.salesperson (name, position, salary, sales) VALUES
    ('Alice Johnson', 'Account Director'    ,10000, 120000),
    ('Bob Smith'    , 'Account Director'    ,20000, 250000),
    ('Charlie Reeds', 'Account Director'    ,30000, 350000),
    ('Diana Green'  , 'Account Director'    ,40000, 150000),
    ('Evan Strokes' , 'Account Director'    ,20000, 120000),
    ('Fiona Cheng'  , 'Account Executive'   ,50000, 586000),
    ('George Kimmel', 'Account Executive'   ,10000, 258931),
    ('Hannah Morse' , 'Account Executive'   ,15000, 812006),
    ('Ian DeVoe'    , 'Account Executive'   ,26000, 684613),    
    ('Jenny Hills'  , 'Account Executive'   ,80000, 100050)
;
SELECT
    name,
    position,
    salary,
    sum(sales) as agg_sales,
    RANK() OVER (ORDER BY agg_sales DESC) as sales_rank
FROM 
    BVM.ECOMERCE.salesperson
GROUP BY
    name,
    position,
    salary
    ;


    

-- CODE TEST 5:
-- You have been hired by a local school to develop a database to track students. Please set up a
-- data model that will allow for the tracking of the following. design your be.
-- * Students
-- * Teachers
-- * Attendance
-- * Assignments
-- * Grades
-- * Classes
-- For this question WRITE how the model would be like. Example:
-- - Student table
-- - Teacher table
-- …
-- - A Student-Teacher-Classes table to join the following together
-- - Should have a reference to the Teacher table

--- /// ANSWER /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// ---
-- * Students
    student_id
    name
    -> Dimension table
    -> Apply slow changing dimesion type 2 to keep track of updates in the Students table
    -> Will contain basic information about the students
    -> student_id will be the primary key
    
-- * Teachers
    teacher_id
    name 
    -> Dimension table
    -> Apply slow changing dimesion type 2 to keep track of updates in the Teachers table
    -> Will contain basic information about the students
    -> teacher_id will be the primary key
    
-- * Attendance
    attendance_id
    student_id
    class_id
    status
    date
    -> Fact table
    -> To track attendance, this table will have two foreign keys student_id and class_id
    -> Date and Status presents the Attendance information 
    
-- * Assignments
    assignment_id
    class_id
    credits
    tittle
    date
    -> Fact table
    -> assignment_id primary key
    -> The sum of all credits add up to the class credits
    -> class_id is a foreign key
    
-- * Grades
    grade_id
    student_id
    assigment_id
    grade
    -> Fact table
    -> student_id and assigment_id are foreign keys, by that I mean, they reference these other two dimensions.
    -> grade is as float from 0 to 1
    -> So, to get student grade for an assigment it is just to join using column student_id
    
-- * Classes
    class_id
    teacher_id
    credits
    name
    -> Dimension table
    -> teacher_id is a foreign key
    -> Apply slow changing dimesion type 2 to keep track of updates in the Teachers table
--- /// ANSWER /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// ---
    
    

-- CODE TEST 6:
-- The school wants to be able to track student performance over time and attempting to access
-- the OLTP model above is causing performance issues. Please set up a warehouse model to
-- compliment the OLTP model.
-- Example: Looking for a simple star schema setup that includes the following:
-- - A fact table for students
-- - Aggregate GPA
-- …
-- - A dimension for Classes
--- /// ANSWER /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// ---
-- * Students
-- * Teachers
-- * Attendance
-- * Assignments
-- * Grades
-- * Classes


A fact table for students
    class_id joins with assignment_id and so we have a list of all assigments for all classes
    On top of that do a cross join to student_id, So, every student will be 'assigned' to all assignments.
    Now, join assignment_id and student_id against Grades table.
    Since a cross join(cartesian product) was made above, in case a student missed an assignment and have no grades for it, the student will have null for that specific assignemnt and can be cleaned to have 0 instead.
    With this the GPA can be calculated across time since the assigments table have dates.

From the Internet -> "An aggregate GPA, or cumulative GPA, is the average of all grade point averages (GPAs) earned throughout a program or career. 
                      It's calculated by dividing the number of quality points earned in all courses by the total number of degree-credit hours in all attempted courses. "
    - So in order to calculate the GPA:
        On top of the fact table for students
        group_by student_id 
            sum all credits
            avg all grades
            divide (avg all grades)*(sum all credits) as GPA
            
    
--- /// ANSWER /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// --- /// ---
;
-- CODE TEST 7:
-- Write a SQL query that produces that Output. Use the Name column and the first letter of the
-- Profession column, enclosed by parentheses.

-- SELECT
--     CONCAT(
--         NAME,
--         '(',
--         LEFT(POSITION,1),
--         ')'
--         ) AS OUTPUT
-- FROM
--     BVM.ECOMERCE.salesperson

SELECT
    CONCAT(
        NAME,
        '(',
        LEFT(Profession,1),
        ')'
        ) AS OUTPUT
FROM
    InputTable