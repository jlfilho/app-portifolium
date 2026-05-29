-- Populando a tabela Categoria
MERGE INTO categoria (id, nome, created_at, created_by, updated_at, updated_by) KEY(id) VALUES 
(1, 'Ensino', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(2, 'Pesquisa', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(3, 'Extensão', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system');

-- Populando a tabela Tipo Curso
MERGE INTO tipo_curso (id, nome, created_at, created_by, updated_at, updated_by) KEY(id) VALUES
(1, 'Bacharelado', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(2, 'Licenciatura', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(3, 'Tecnólogo', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(4, 'Especialização', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(5, 'MBA', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(6, 'Mestrado', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(7, 'Doutorado', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system');


-- Populando a tabela Fonte Financiadora
MERGE INTO fonte_financiadora (id, nome, created_at, created_by, updated_at, updated_by) KEY(id) VALUES 
(1, 'UEA', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(2, 'FAPEAM', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(3, 'CAPES', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(4, 'CNPq', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system'),
(5, 'Outros', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system');

-- Populando a tabela Role
MERGE INTO role (id, nome) KEY(id) VALUES
(1, 'ROLE_ADMINISTRADOR'),
(2, 'ROLE_GERENTE'),
(3, 'ROLE_SECRETARIO'),
(4, 'ROLE_COORDENADOR_ATIVIDADE');

-- Recria o administrador padrao de forma idempotente.
-- Isso evita que um banco H2 persistido mantenha credenciais antigas.
DELETE FROM usuario_roles
WHERE usuario_id IN (
    SELECT id FROM usuario WHERE email = 'admin@uea.edu.br' OR id = 1
);

DELETE FROM curso_usuario
WHERE usuario_id IN (
    SELECT id FROM usuario WHERE email = 'admin@uea.edu.br' OR id = 1
);

DELETE FROM recovery_code
WHERE usuario_id IN (
    SELECT id FROM usuario WHERE email = 'admin@uea.edu.br' OR id = 1
);

DELETE FROM usuario
WHERE email = 'admin@uea.edu.br' OR id = 1;

DELETE FROM pessoa
WHERE id = 1 OR cpf = '31452012040';

-- Script SQL para criar a pessoa do administrador
MERGE INTO pessoa (id, nome, cpf, created_at, created_by, updated_at, updated_by) KEY(id) VALUES
(1, 'Administrador do Sistema', '31452012040', CURRENT_TIMESTAMP, 'system', CURRENT_TIMESTAMP, 'system');

-- Populando a tabela Usuario com níveis de acesso e senhas criptografadas
MERGE INTO usuario (id, email, senha, pessoa_id, created_at, updated_at) KEY(id) VALUES
(1, 'admin@uea.edu.br', '$2a$10$hVfJIfpLdpbxwPiRfT2eheqDQlgklnzXZu81UYBa3bjOb5QtAAz.W', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP); -- Senha: admin123



-- Populando a tabela Usuario_Roles para associar usuários a roles
INSERT INTO usuario_roles (usuario_id, role_id) VALUES
(1, 1); -- Admin
