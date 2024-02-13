use company;
-- inserindo departamentos removidos por conta do gerente removido no desafio anterior
insert into departament values ('Accountin',4,444556666, null, 'São Paulo - SP'), ('Support',5,444556666, null, 'São Paulo - SP');

-- Inserindo projetos para atender as query's do desafio
insert into project values ('Projeto X', 4, 'Belo Horizonte', 3), 
						   ('New Technologies', 1, 'São Paulo', 1),
                           ('Melhoramento do SAC', 7, 'São Paulo', 5);

-- Iniciando a criação das Views

create view NumberEmployee_for_DepartmentAndLocation as
	select count(Ssn) as 'Número de funcionários', D.Dname, D.City from employee join departament D using (Dnumber) group by D.Dnumber, D.City order by D.City asc;
    
create view department_and_its_managers as
	select Dname as 'Nome Departamento', concat(Fname, ' ', Minit, ' ', Lname) as 'Gerente' from departament join employee on Manager_Ssn = Ssn;

create view Projects_number_employees as
	select Pnumber, Pname, count(Ssn) as Funcionarios_no_Projeto from (employee join departament D using (Dnumber)) join project on D.Dnumber = Dnum group by Pnumber order by Funcionarios_no_Projeto desc;
    
create view ProjectList_Departmen_and_Managers as
	select Pname, Dname, concat(Fname, ' ', Minit, ' ', Lname) as 'Gerente' from (employee join departament D on Manager_Ssn = Ssn) join project on D.Dnumber = Dnum;

create view employeeWithDependent_whoAreManager as
	SELECT DISTINCT
		CONCAT(E.Fname, ' ', E.Minit, ' ', E.Lname) AS 'Nome do Funcionário',
		CASE 
			WHEN E.Ssn = D.Manager_ssn THEN 'Sim'
			ELSE 'Não' 
		END AS 'Gerente'
	FROM 
		employee E
	LEFT JOIN 
		departament D ON E.Ssn = D.Manager_ssn
	WHERE
		E.Ssn IN (SELECT Essn FROM dependent);

select * from NumberEmployee_for_DepartmentAndLocation;
select * from department_and_its_managers;
select * from Projects_number_employees;
select * from ProjectList_Departmen_and_Managers;
select * from employeeWithDependent_whoAreManager;

   
-- TODO: Criando Usuários e definindo suas permissões

-- Criando o usuário 'funcionario'
CREATE USER 'funcionario'@'localhost' IDENTIFIED BY '12345';

-- Concedendo permissões de acesso às views desejadas para o usuário 'funcionario'
GRANT SELECT ON company.NumberEmployee_for_DepartmentAndLocation TO 'funcionario'@'localhost';
GRANT SELECT ON company.ProjectList_Departmen_and_Managers TO 'funcionario'@'localhost';

-- Criando o usuário 'gerente'
CREATE USER 'gerente'@'localhost' IDENTIFIED BY '12345';

-- Concedendo permissões de acesso a todas as views para o usuário 'gerente'
GRANT SELECT ON company.NumberEmployee_for_DepartmentAndLocation TO 'gerente'@'localhost';
GRANT SELECT ON company.department_and_its_managers TO 'gerente'@'localhost';
GRANT SELECT ON company.Projects_number_employees TO 'gerente'@'localhost';
GRANT SELECT ON company.ProjectList_Departmen_and_Managers TO 'gerente'@'localhost';
GRANT SELECT ON company.employeeWithDependent_whoAreManager TO 'gerente'@'localhost';
