/*
Write a query to display all of the details of the department where the youngest employee in the company works.
*/
select * from department
where id =
(select department_id from employee 
where birthdate = (select max(birthdate) from employee));

/*
Write a query to list the names of the departments that exist in the company, along with the average salary and the birthdate of the oldest employee that works in each department ordered by department id in descending order.
*/


select name, 
(select avg(salary) from employee where department_id=d.id) as average_salary,
(select min(birthdate) from employee  where department_id=d.id) as oldest_emp
from department d
order by id desc;

/*
Write a query to list the max, min, and average of salaries for every department id in the employee table, but include only departments whose max salary is greater than the double of their minimum salary.

RESTRICTION: You are not allowed to use a HAVING clause.

use inline viers and with statment
*/

select * from
(select department_id, min(salary) as min_salary, max(salary) as max_salary,
avg(salary) as average_salary from employee group by department_id)
where max_salary >min_salary*2;

with s as
(select department_id, min(salary) as min_salary, max(salary) as max_salary,
avg(salary) as avg_salary from employee group by department_id)
select department_id, min_salary, max_salary, avg_salary from s
where max_salary >min_salary*2;


/*
Write a query that uses the rownum pseudocolumn to get the top 5 earners in the employee table.*/
with salaries as
(select * from employee order by salary desc)
select * from salaries
where rownum <=5;

/*Write a query that uses the dense_rank analytic function to list the bottom 3 earners in the employee table. */
with dense as
(select e.*, dense_rank() over (order by salary) as dense 
from employee e)
select * from dense
where rownum <=3;

/*Use the row limiting clause to write a query to get the top 5 youngest employees among those who earn more than 2000 a month. */
select * from employee
where salary > 2000
order by birthdate desc
fetch first 5 rows only;

/*Write a query that segments the employee table in pages, based on the salary in ascending order, and prompts the user for the number of the page they want to see.

The size of each page must be 4 rows, and the user should be able to specify the page number by means of a substitution variable. */

select * from employee
order by salary, id 
offset 8 rows fetch first 4 rows only;


