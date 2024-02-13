show databases;
use desafio_dio_sistemaecommerce;
show tables;
select * from vendedor;

-- Adicionando salário a tabela para atender ao escopo do Desafio DIO
alter table vendedor add Salary decimal(10,2) default 3000;

-- Triggers do Desafio (Trigger de Updade para aumento de salário)
delimiter \\
create trigger tg_AumentoSalario before update on vendedor
for each row
begin
	set new.Salary = new.Salary * 1.20;
end;
\\
delimiter ;

show triggers from desafio_dio_sistemaecommerce; -- Mostra triggers

update vendedor set Salary = 3500 where Razaosocial = 'Vendedor A'; -- Testando o trigger tg_AumentoSalario

-- Criando tabela para que o segundo trigger funcione e atenda ao Desafio DIO    
create table if not exists ClientesRemovidos(
    NumeroRemocao int auto_increment primary key,
    Identificacao varchar(45),
    CPF char(11) default null,
    CNPJ char(14) default null
);

-- Triggers do Desafio (Trigger para criação de tabela auxiliar caso ocorra exclusão de cliente)
delimiter \\
create trigger tg_tabelaAuxiliar_remocaoDeCliente after delete on cliente
	for each row
    begin    
		insert into ClientesRemovidos(Identificacao, CPF, CNPJ) values (old.Identificacao, old.CPF, old.CNPJ);
    end \\
delimiter ;

select * from cliente;

delete from cliente where Identificacao = 'Cliente Premium';
select * from  ClientesRemovidos;

/*
O MySQL não permite operações de commit dentro de triggers,
  porque isso pode levar a problemas de consistência nos dados.
O MySQL espera que as operações de commit sejam tratadas pela
  aplicação cliente e não dentro de triggers ou funções armazenadas.
  
  Por Este Motivo Não Foi Criada à table dentro do Trigger tg_tabelaAuxiliar_remocaoDeCliente;
*/

/* ↓↓↓ SEGUE UMA SEQUENCIA DE ALTERAÇÕES NAS CONSTRAINTS DAS TABELAS DO DB PARA QUE A EXCLUSÃO DO CLIENTE OCORRA SEM ERROS ↓↓↓ */
/* ESTA SEQUÊNCIA DE PASSOS É NECESSARIA POIS ESTE CÓDIGO EXECUTA EM UM BANCO DE DADOS JÁ CRIADO ANTERIORMENTE */
SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = 'cliente';

ALTER TABLE cliente DROP FOREIGN KEY fk_cliente_PFisica,
	ADD CONSTRAINT fk_cliente_PessoaFisica FOREIGN KEY (CPF) REFERENCES Pessoa_Fisica (CPF) ON DELETE CASCADE;

ALTER TABLE cliente DROP FOREIGN KEY fk_cliente_PJuridica,
	ADD CONSTRAINT fk_cliente_PessoaJuridica FOREIGN KEY (CNPJ) REFERENCES Pessoa_Juridica (CNPJ) ON DELETE CASCADE;
    
ALTER TABLE pagamento DROP FOREIGN KEY fk_Pag_idCliente,
	ADD CONSTRAINT fk_Pag_id_Cliente FOREIGN KEY (Id_Cliente) REFERENCES cliente(Id_Cliente) ON DELETE CASCADE;
    
ALTER TABLE pedido DROP FOREIGN KEY fk_Pedido_IdCliente,
	ADD CONSTRAINT fk_Pedido_Id_Cliente FOREIGN KEY (Id_Cliente) REFERENCES cliente (Id_Cliente) ON DELETE CASCADE;

ALTER TABLE entrega DROP FOREIGN KEY fk_Entrega_IdCliente,
	ADD CONSTRAINT fk_Entrega_Id_Cliente FOREIGN KEY (Logradouro) REFERENCES cliente (Logradouro) ON DELETE CASCADE;
