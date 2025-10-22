-- 1. Cria os tipos ENUM como tipos customizados (melhor prática em PG para ENUM)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'turma_enum') THEN
        CREATE TYPE turma_enum AS ENUM('25.1 - T1', '25.1 - T2', '25.2 - T1');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'escolaridade_enum') THEN
        CREATE TYPE escolaridade_enum AS ENUM('8º ano', '9º ano');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'escola_enum') THEN
        CREATE TYPE escola_enum AS ENUM('Pública', 'Privada');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'role_enum') THEN
        CREATE TYPE role_enum AS ENUM('student', 'teacher');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_enum') THEN
        CREATE TYPE status_enum AS ENUM('completed', 'current', 'future', 'cancelled');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'attendance_enum') THEN
        CREATE TYPE attendance_enum AS ENUM('P', 'F', 'Fj');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'situacao_enum') THEN
        CREATE TYPE situacao_enum AS ENUM('Ativo', 'Desistente');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'atividade_status_enum') THEN
        CREATE TYPE atividade_status_enum AS ENUM('Pendente', 'Enviada', 'Verificada');
    END IF;
END $$;

-- 2. Cria a tabela 'alunos' (sua info_alunos)
CREATE TABLE IF NOT EXISTS alunos (
    id SERIAL PRIMARY KEY, -- Equivalente a INT AUTO_INCREMENT
    turma turma_enum NOT NULL, 
    nome VARCHAR(70) NOT NULL,
    email VARCHAR(50) UNIQUE,
    telefone VARCHAR(11) UNIQUE,
    data_nascimento DATE,
    rg VARCHAR(9) UNIQUE,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    endereco VARCHAR(100),
    escolaridade escolaridade_enum NOT NULL, 
    escola escola_enum NOT NULL, 
    responsavel VARCHAR(70) NOT NULL
);

-- 3. Cria a tabela 'users'
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    student_id INT UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role role_enum NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE, -- Equivalente a DATETIME
    total_logins INT DEFAULT 0,
    online_status VARCHAR(20) DEFAULT 'Offline',
    FOREIGN KEY (student_id) REFERENCES alunos(id) ON DELETE SET NULL
);

-- 4. Cria a tabela 'classes'
CREATE TABLE IF NOT EXISTS classes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    status status_enum NOT NULL,
    description TEXT
);

-- 5. Cria a tabela 'attendance_records'
CREATE TABLE IF NOT EXISTS attendance_records (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    attendance_status attendance_enum NOT NULL, 
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Equivalente a DATETIME DEFAULT CURRENT_TIMESTAMP
    UNIQUE (student_id, class_id),
    FOREIGN KEY (student_id) REFERENCES alunos(id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
);

-- 6. Cria a tabela 'materials'
CREATE TABLE IF NOT EXISTS materials (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    file_path VARCHAR(255)
);

-- 7. Cria a tabela 'status_alunos'
CREATE TABLE IF NOT EXISTS status_alunos (
    id INT PRIMARY KEY REFERENCES alunos(id) ON DELETE CASCADE,
    faltas SMALLINT DEFAULT 0,
    situacao situacao_enum DEFAULT 'Ativo'
);

-- 8. Cria a tabela 'atividades_alunos'
CREATE TABLE IF NOT EXISTS atividades_alunos (
    id INT PRIMARY KEY REFERENCES alunos(id) ON DELETE CASCADE,
    aula_1 atividade_status_enum DEFAULT 'Pendente',
    aula_2 atividade_status_enum DEFAULT 'Pendente',
    aula_3 atividade_status_enum DEFAULT 'Pendente',
    aula_4 atividade_status_enum DEFAULT 'Pendente',
    aula_5 atividade_status_enum DEFAULT 'Pendente',
    aula_6 atividade_status_enum DEFAULT 'Pendente',
    aula_7 atividade_status_enum DEFAULT 'Pendente',
    aula_8 atividade_status_enum DEFAULT 'Pendente',
    aula_9 atividade_status_enum DEFAULT 'Pendente',
    aula_10 atividade_status_enum DEFAULT 'Pendente',
    total_enviadas SMALLINT DEFAULT 0
);

-- INSERÇÕES DE DADOS (usando ON CONFLICT (coluna_unique) DO NOTHING/UPDATE para evitar duplicatas em PG)

-- Insere o aluno 'Fulano de Tal' e 'João Oliveira'
INSERT INTO alunos (turma, nome, email, telefone, data_nascimento, rg, cpf, endereco, escolaridade, escola, responsavel) VALUES
('25.1 - T1', 'Fulano de Tal', 'fulanodetal@gmail.com', '81912345678', '2010-01-01', '1234567', '12345678910', 'Rua dos Bobos - nº 0', '8º ano', 'Pública', 'Fulana de Tal'),
('25.1 - T1', 'João Oliveira', 'joao.oliveira@gmail.com', '81933334444', '2010-08-25', '2345678', '23456789012', 'Rua das Palmeiras, nº 20', '8º ano', 'Pública', 'Carlos Oliveira')
ON CONFLICT (cpf) DO NOTHING; 

-- Insere usuários iniciais na tabela 'users' (Professores)
INSERT INTO users (student_id, username, password_hash, full_name, role) VALUES
(NULL, 'programacao', 'scrypt:32768:8:1$MQN1vNMTRKLalFNe$60a78c8315739dc1198bedab10e6e7bbabad29e7c12917d748306fea4ca1f8cc721a7ae616e6ff842c792bffb3872e4949cf5759a96b6feecaba6b7c97678632', 'Prof. 2', 'teacher'),
(NULL, 'professor', 'scrypt:32768:8:1$t7OyXy7NDbPAqplM$a0e9a7ba25f8308f5b92e54b357a6a9db5dfe6c6bbef4f0238443c39c1e2e701dae69b710dbe1debd86eedd6bfc46e7c2c01f69c9c77fdfb8c940f05696007bc', 'Prof. 1', 'teacher')
ON CONFLICT (username) DO UPDATE SET password_hash = EXCLUDED.password_hash, full_name = EXCLUDED.full_name, role = EXCLUDED.role; 

-- Inserção dos 30 novos alunos
INSERT INTO alunos (turma, nome, email, telefone, data_nascimento, rg, cpf, endereco, escolaridade, escola, responsavel) VALUES
('25.2 - T1', 'Ana Silva', 'ana.silva@email.com', '81910000001', '2011-02-01', '1100001', '10000000001', 'Rua das Flores, 1', '8º ano', 'Pública', 'Marcos Silva'),
('25.2 - T1', 'Bruno Costa', 'bruno.costa@email.com', '81910000002', '2011-03-10', '1100002', '10000000002', 'Avenida Principal, 2', '9º ano', 'Pública', 'Carla Costa'),
('25.2 - T1', 'Clara Mendes', 'clara.mendes@email.com', '81910000003', '2010-11-05', '1100003', '10000000003', 'Travessa da Escola, 3', '8º ano', 'Privada', 'Roberto Mendes'),
('25.2 - T1', 'Daniel Moreira', 'daniel.moreira@email.com', '81910000004', '2011-01-15', '1100004', '10000000004', 'Rua Nova, 4', '8º ano', 'Pública', 'Juliana Moreira'),
('25.2 - T1', 'Elisa Ferreira', 'elisa.ferreira@email.com', '81910000005', '2011-05-20', '1100005', '10000000005', 'Rua da Praça, 5', '9º ano', 'Pública', 'Fernando Ferreira'),
('25.2 - T1', 'Felipe Barros', 'felipe.barros@email.com', '81910000006', '2010-12-30', '1100006', '10000000006', 'Avenida Central, 6', '8º ano', 'Privada', 'Sandra Barros'),
('25.2 - T1', 'Gabriela Lima', 'gabriela.lima@email.com', '81910000007', '2011-04-12', '1100007', '10000000007', 'Rua do Sol, 7', '8º ano', 'Pública', 'Ricardo Lima'),
('25.2 - T1', 'Heitor Almeida', 'heitor.almeida@email.com', '81910000008', '2011-06-07', '1100008', '10000000008', 'Rua da Lua, 8', '9º ano', 'Pública', 'Beatriz Almeida'),
('25.2 - T1', 'Isabela Santos', 'isabela.santos@email.com', '81910000009', '2010-10-10', '1100009', '10000000009', 'Avenida Norte, 9', '8º ano', 'Pública', 'Tiago Santos'),
('25.2 - T1', 'Jonas Pereira', 'jonas.pereira@email.com', '81910000010', '2011-07-22', '1100010', '10000000010', 'Rua Sul, 10', '8º ano', 'Privada', 'Camila Pereira'),
('25.2 - T1', 'Karina Rocha', 'karina.rocha@email.com', '81910000011', '2011-08-01', '1100011', '10000000011', 'Rua Leste, 11', '9º ano', 'Pública', 'Lucas Rocha'),
('25.2 - T1', 'Leonardo Gomes', 'leonardo.gomes@email.com', '81910000012', '2010-09-14', '1100012', '10000000012', 'Rua Oeste, 12', '8º ano', 'Pública', 'Patrícia Gomes'),
('25.2 - T1', 'Manuela Dias', 'manuela.dias@email.com', '81910000013', '2011-09-03', '1100013', '10000000013', 'Avenida Beira Mar, 13', '8º ano', 'Privada', 'Rodrigo Dias'),
('25.2 - T1', 'Nicolas Azevedo', 'nicolas.azevedo@email.com', '81910000014', '2011-10-18', '1100014', '10000000014', 'Rua da Matriz, 14', '9º ano', 'Pública', 'Fernanda Azevedo'),
('25.2 - T1', 'Olívia Nogueira', 'olivia.nogueira@email.com', '81910000015', '2010-08-25', '1100015', '10000000015', 'Rua do Comércio, 15', '8º ano', 'Pública', 'Gustavo Nogueira'),
('25.2 - T1', 'Pedro Henrique', 'pedro.henrique@email.com', '81910000016', '2011-11-11', '1100016', '10000000016', 'Rua da Indústria, 16', '8º ano', 'Privada', 'Sara Henrique'),
('25.2 - T1', 'Quintino Bastos', 'quintino.bastos@email.com', '81910000017', '2011-12-01', '1100017', '10000000017', 'Avenida das Árvores, 17', '9º ano', 'Pública', 'Vitor Bastos'),
('25.2 - T1', 'Rafaela Cunha', 'rafaela.cunha@email.com', '81910000018', '2011-01-28', '1100018', '10000000018', 'Rua das Pedras, 18', '8º ano', 'Pública', 'Vanessa Cunha'),
('25.2 - T1', 'Samuel Vieira', 'samuel.vieira@email.com', '81910000019', '2010-07-07', '1100019', '10000000019', 'Rua da Areia, 19', '8º ano', 'Privada', 'Diego Vieira'),
('25.2 - T1', 'Tatiana Andrade', 'tatiana.andrade@email.com', '81910000020', '2011-02-14', '1100020', '10000000020', 'Avenida do Rio, 20', '9º ano', 'Pública', 'Elaine Andrade'),
('25.2 - T1', 'Ubiratan Medeiros', 'ubiratan.medeiros@email.com', '81910000021', '2011-03-23', '1100021', '10000000021', 'Rua da Serra, 21', '8º ano', 'Pública', 'Fábio Medeiros'),
('25.2 - T1', 'Vitória Sampaio', 'vitoria.sampaio@email.com', '81910000022', '2010-06-19', '1100022', '10000000022', 'Rua do Vale, 22', '8º ano', 'Privada', 'Gabriela Sampaio'),
('25.2 - T1', 'William Farias', 'william.farias@email.com', '81910000023', '2011-04-30', '1100023', '10000000023', 'Avenida da Praia, 23', '9º ano', 'Pública', 'Heitor Farias'),
('25.2 - T1', 'Xavier Pires', 'xavier.pires@email.com', '81910000024', '2011-05-17', '1100024', '10000000024', 'Rua do Lago, 24', '8º ano', 'Pública', 'Irene Pires'),
('25.2 - T1', 'Yasmin Correia', 'yasmin.correia@email.com', '81910000025', '2010-05-12', '1100025', '10000000025', 'Rua da Lagoa, 25', '8º ano', 'Privada', 'João Correia'),
('25.2 - T1', 'Zilda Matos', 'zilda.matos@email.com', '81910000026', '2011-07-01', '1100026', '10000000026', 'Avenida do Mar, 26', '9º ano', 'Pública', 'Luan Matos'),
('25.2 - T1', 'Arthur Dantas', 'arthur.dantas@email.com', '81910000027', '2011-08-16', '1100027', '10000000027', 'Rua do Cais, 27', '8º ano', 'Pública', 'Miguel Dantas'),
('25.2 - T1', 'Bárbara Queiroz', 'barbara.queiroz@email.com', '81910000028', '2010-04-22', '1100028', '10000000028', 'Rua da Ponte, 28', '8º ano', 'Privada', 'Nicole Queiroz'),
('25.2 - T1', 'Caio Rangel', 'caio.rangel@email.com', '81910000029', '2011-09-29', '1100029', '10000000029', 'Avenida do Forte, 29', '9º ano', 'Pública', 'Otávio Rangel')
ON CONFLICT (cpf) DO NOTHING;

-- Popula 'status_alunos' e 'atividades_alunos' (usando ON CONFLICT (id) DO NOTHING para evitar duplicatas em PG)
INSERT INTO status_alunos (id)
SELECT id FROM alunos
ON CONFLICT (id) DO NOTHING;

INSERT INTO atividades_alunos (id)
SELECT id FROM alunos
ON CONFLICT (id) DO NOTHING;