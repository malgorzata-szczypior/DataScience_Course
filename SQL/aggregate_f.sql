/*Write a query to get the number of employees in the Accounting department, the total sum of their salaries, and the average salary. The average must appear 2 times in the results, one of them must be calculated using the AVG function, and one without using the AVG function. Please add column aliases to make it easy to understand the columns in the result.
*/

select count(id) as employees, sum(salary) as total_salaries, avg(salary) as average_salaries, sum(salary)/count(salary) as manual_average_salaries from employee
where department_id = (select id from department where lower(name) like 'accounting');

/*
Write a query to list the different bonuses from the employee table, along with the number of employees that earn that bonus, and the greatest salary for employees in that group. Please include only employees who were born before 1995.
*/
select  bonus,
count(*) as employee,
max(salary) as max_salary
from employee
where birthdate < '01-JAN-1995'
group by bonus
order by bonus;

/*
Write a query to list the minimum and maximum salaries and also the bonus average per department from the employee table, but please don’t include employees who don’t have a value defined for their bonus.

Also, please show in the results only departments whose smallest salary is less than 2000 or their highest salary is greater than 4000. The results must be displayed in descending order by the minimum salary.
*/
select 
department_id,
min(salary),
max(salary),
avg(bonus)
from employee
group by department_id
having min(salary) <2000 or max(salary) > 4000
order by 2 desc;

select 
e.department_id, d.name,
min(e.salary),
max(e.salary),
avg(e.bonus)
from employee e
join department d on e.department_id=d.id
group by e.department_id, d.name
having min(e.salary) <2000 or max(e.salary) > 4000
order by 3 desc;


