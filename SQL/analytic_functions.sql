/* Write a query to generate a list of employees with the following characteristics:

· All employees must be returned.

· The report must include the following columns from the table: Id, name, department_id, email.

· The report must also include the following calculated columns:

     - The length of the email.

     - The number of employees from the same department who have an email of the same length.

· The report must be ordered by department_id and length of the email column.
*/
select id, name, department_id, email, length(email) as email_length,
count(*) over (partition by department_id, length(email)) cnt
from employee e
order by 3,5;

/* Write a query to generate a report of the employees, which includes at least the following columns:

· Id

· Name

· Hire_date,

· A count of the number of employees hired in the same year than the current employee or in the previous year.

The results must be ordered by the hire date.
*/

select id, name, hire_date,
count(*) over(order by to_number(to_char(hire_date, 'YYYY')) range 1 preceding) as counts
from employee
order by hire_date;

select id, name, hire_date,
count(*) over(order by extract(year from hire_date) range 1 preceding) as counts
from employee
order by hire_date;

/* Write a query to generate a list of all of the departments including their ID, name, and monthly budget, but also include a column that shows the accumulated budget (the sum of the budget of previous departments plus the current one). To decide the order in which the budgets are accumulated you must sort them by smallest to greatest budget.
*/

select id, name, monthly_budget,
sum(monthly_budget) over (order by monthly_budget) as accumulated_budget
from department
order by monthly_budget;

/*Write a query to list all the employees. The result must include their name, department id, hire date, and a column called “hire_order” which is a number that indicates the order in which they were hired. This order is related to the department where they work only, so, the first employee that was hired in each department will have a hire_order of 1.
*/
select name, department_id, hire_date,
rank() over (partition by department_id order by hire_date) as hire_order
from employee
order by department_id, hire_date;

/*Write a query that returns the name, birthdate, and department id of an employee who was born in 1995, preferably from the ACCOUNTING department. If no employee from that department was born in 1995, return one from any other department. */

with prio as (
select name, birthdate, department_id,
row_number() over (order by
case when department_id =1 then 'A' else 'B' end) as rn
from employee
where to_char(birthdate,'YYYY')=1995)
select name, birthdate, department_id from prio
where rn =1;

/*Write a query that lists the different salaries that appear in the employee table. For each salary include a comma-separated list of the names of the employees that earn that amount. The list of employees for each salary must be ordered by the name of the employee, and the final result set must be ordered by salary from greatest to smallest.
*/
select salary,
listagg(name,',') within group(order by name) as list
from employee
group by salary
order by salary desc;

/*Write a query to generate a list of all employees from the ACCOUNTING and HUMAN RESOURCES departments, ordered by department and birth date. For every employee, the report must include the name, birth date, and the name of the employee from the same department who follows him/her if you order them by age.*/
select
name, birthdate,
lead(name) over (partition by department_id order by birthdate desc) as next_person
from employee
where department_id in (select id from department where lower(name) in ('accounting', 'human resources'))
order by department_id, birthdate desc;

/*Write a query to generate a list of employees with the following conditions:

· The list must include only the employee with the highest salary in each department.

· It must include ID, name, salary, department_id, and an additional column with the ID of the employee with the second-highest salary in his/her department. */
with rank1 as (
select id,name, salary, department_id,
lead(id) over (partition by department_id order by salary desc) as emp_2nd,
rank() over (partition by department_id order by salary desc) as rn
from employee
order by department_id,salary desc)
select id, name, salary, department_id, emp_2nd
from rank1
where rn=1;

/*Write a query to return the name and hire date of the first employee hired in each department.

The results must include the department_id, name of the employee and their hire date, and must be ordered by department id.
*/

select 
department_id, max(name) keep (dense_rank first order by hire_date) as name,
max(hire_date) as hire_date
from employee
group by department_id
order by department_id;


