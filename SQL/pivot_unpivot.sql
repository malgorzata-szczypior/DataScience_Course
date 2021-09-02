/* Write a query that returns a single row that has one column for each of the monthly budgets of the departments ACCOUNTING, MARKETING, and INFORMATION TECHNOLOGY. The column titles for the budgets must be the names of the departments. */

 select * from (
 select name, monthly_budget from department )
 pivot (max(monthly_budget) for name in ('INFORMATION TECHNOLOGY' ,'ACCOUNTING', 'MARKETING'));
 
 /* Write a query to generate a list of employees who work in the Accounting and Marketing departments. The report must include the name, birthdate, and hire_date, but each employee must appear in the report 2 times, and the birth date and hire date must appear in the same column but in different rows. This column must be called “date_value” and there must be an additional column that explains the kind of date that is included in the date_value column. This additional column must be called “date_type” and will contain either “Date of Birth” or “Date of Hiring”.
 */
 
  select name, data_type, date_value from employee
 unpivot(date_value for data_type in (birthdate as 'birth date', hire_date as 'hire date'))
 where department_id in (select id from department where lower(name) in ('accounting', 'marketing'));
 
