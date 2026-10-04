-- Molde usado para o arquivo final do arquivo 'mister'

local professor = {}
professor.__index = professor

function professor:new(self,id,nome,sobrenome,materia,sala)
    local self = setmetatable({}, professor)
    self.id = id or 0
    self.nome = nome or "N/A"
    self.sobrenome = sobrenome or "N/A"
    self.materia = materia or "N/A"
    self.sala = sala or 0

    return self
end

function professor:add()
    local check_id = 1
    
    -- Adicionar for para verificar se o ID existe

    print("Informe os dados")
    io.write("Nome: ")
    local in_nome = io.read()
    io.write("Sobrenome: ")
    local in_sobre = io.read()
    io.write("Matéria: ")
    local in_mat = io.read()
    
    io.write("Informe a sala: ")
    local in_sala = io.read("*n")
    while sala < 1 or sala > 4 do
        io.write("Sala inexistente\nInforme novamente: ")
        sala = io.read("*n")
    end

    self.id = check_id
    self.nome = in_nome
    self.sobrenome = in_sobre
    self.materia = in_mat
    self.sala = in_sala
end

-- ADD | ALTERAR | REMOVER | CONSULTAR | alunos?

local test = professor:new()
test.add()

return professor