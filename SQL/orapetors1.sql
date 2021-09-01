/* Write a query to get the list of employees whose name includes the letter “O” 2 times, but not contiguously, so if there was a name “JOHN DOE”, it should be returned, but a row with name “JIM BROOKS” should not, because the 2 Os are contiguous.

Note: Since at this point we still don’t have the necessary knowledge to count the number of ‘O’s that appear in a string, assume that no name will contain more than 2 Os.
*/

select * from employee
where name like '%O_%O%';

/* Write a query to get the list of departments whose monthly budget is greater than 15000 and its name includes a “G” or starts with an “H”, sorted by the department id in descending order.
*/

select * from department
where monthly_budget > 15000
and (lower(name) like 'h%' or lower(name) like'%g%');

/*
Write a query to list all employees of the Information Technology and Human Resources departments who earn 3000 or more but not more than 5000. Please include only employees who were born between 1970 and 1990.
*/

select * from employee
where department_id in (select id from department where lower(name) like '%information%' or lower(name) like '%human%')
and salary between 3000 and 5000
and birthdate between '01-JAN-1970' and '31-DEC-1990';

/*
Write a query to list all employees who were born before 01-jan-1980 or after 01-jan-1995 and earn more than 2000 a month, and whose name does not start or end with an “N”.

When evaluating the condition about how much they earn, please take into account the BONUS column too, which was added with the script provided in the resources section of the lesson about UNDERSTANDING NULLS.
*/

select * from employee
where (birthdate < '01-JAN-1980' or birthdate > '01-JAN-1995')
and salary > 2000
and not (lower(name) like 'n%' or lower(name) like '%n');

/*
