local driver = require("luasql.sqlite3")
local env = driver.sqlite3()
local db = env:connect("dados.db")
local aluno = {}
aluno.__index = aluno

local function calculo_notas(media_final)
    local notas = {}
    media_final = 0

    for i = 1, 6 do
        io.write(i.."ª Nota: ")
        local n = io.read("*n")
        table.insert(notas, n)
    end
    io.read()
    for _, v in ipairs(notas) do
        media_final = media_final + v
    end
    media_final = media_final / #notas
    media_final = math.ceil(media_final)
    return media_final
end

function aluno:new(self,nome,sobrenome,nascimento,idade,serie,nota_final,sala,turno)
    local self = setmetatable({}, aluno)
    self.id = id or 0
    self.nome = nome or "N/A"
    self.sobrenome = sobrenome or "N/A"
    self.nascimento = nascimento or "N/A"
    self.idade = idade or 0
    self.serie = serie or 0
    self.nota_final = nota_final or 0
    self.sala = sala or 0
    self.turno = turno or "N/A"

    return self
end

function aluno:insert()
    os.execute("clear")
    print("Informe os dados:")
    io.write("Nome: ")
    self.nome = io.read()
    io.write("Sobrenome: ")
    self.sobrenome = io.read()

    print("Data de nascimento: ")
    io.write("Dia: ")
    local dia = io.read("*n")
    io.write("Mês: ")
    local mes = io.read("*n")
    io.write("Ano: ")
    local ano = io.read("*n")

    local pc_year = os.date("%Y")
    self.idade = pc_year - ano

    io.write("Série: ")
    self.serie = io.read("*n")
    io.write("Sala: ")
    self.sala = io.read("*n")
    io.read()
    io.write("Turno: ")
    self.turno = io.read()

    self.nascimento = dia.."/"..mes.."/"..ano
    
    self.nota_final = calculo_notas()
end

function aluno:showData()
    print("Aluno "..self.id.." "..string.rep("-", 44-22))
    print("Nome       : "..self.nome.." "..self.sobrenome)
    print("Data d/nasc: "..self.nascimento)
    print("Idade      : "..self.idade)
    print("Série      : "..self.serie)
    print("Sala       : "..self.sala)
    print("Turno      : "..self.turno)
    print("Média final: "..self.nota_final)
end

function aluno:saveData()
    db:execute([[
        INSERT INTO student (nome,sobrenome,nascimento,idade,serie,nota_final,sala,turno) 
        VALUES (?,?,?,?,?,?,?,?)
    ]],self.nome,self.sobrenome,self.nascimento,self.idade,self.serie,self.nota_final,self.sala,self.turno)

    do -- Evita erros de envio de dados, sincronizando o arquivo e a classe
        local cursor = db:execute("SELECT * FROM student")
        local row = cursor:fetch({},"a")
        while row do
            if self.nome == row.nome then
                self.id = row.id
            end
            row = cursor:fetch(row,"a")
        end

        cursor:close()
    end

    print("Dados salvos!")
end

function aluno:searchStudent()
    local cursor = db:execute("SELECT * FROM student")

    io.write("Informe o nome: ")
    local value = io.read()
    local factor = false

    local row = cursor:fetch({},"a")
    while row do
        if row.nome == value then
            self.id = row.id
            self.nome = row.nome
            self.sobrenome = row.sobrenome
            self.nascimento = row.nascimento
            self.idade = row.idade
            self.serie = row.serie
            self.nota_final = row.nota_final
            self.sala = row.sala
            self.turno = row.turno
            factor = true
            break
        end
        row = cursor:fetch(row,"a")
    end

    if factor == true then
        print("Aluno encontrado!!")
    else
        print("Aluno não cadastrado!!")
    end

    cursor:close()
    return factor
end

function aluno:changeData()
    local function update_data()
        db:execute(string.format([[
            UPDATE student SET nome = '%s', sobrenome = '%s',nascimento = '%s', idade = '%d', serie = '%d', nota_final = '%d', sala = '%s', turno = '%s'
            WHERE id = '%d'
        ]],self.nome,self.sobrenome,self.nascimento,self.idade,self.serie,self.nota_final,self.sala,self.turno,self.id))
    end

    while true do
        print("Aluno: "..self.nome)
        print("1) Nome e sobrenome")
        print("2) Idade")
        print("3) Serie")
        print("4) Notas")
        print("5) Sala")
        print("6) Turno")
        print("7) Retornar")
        io.write("> ")
        local ask = io.read("*n") io.read()
        local grow_up,class,media,new_room

        if ask == 1 then
            io.write("Informe os dados:\nNome: ")
            self.nome = io.read()
            io.write("Sobrenome: ")
            self.sobrenome = io.read()

        elseif ask == 2 then
            local pc_year = os.date("%Y")
            local betriet = pc_year - self.idade
            self.idade = pc_year - betriet
            print("Idade atualizada!")

        elseif ask == 3 then
            io.write("Informe a séria: ")
            self.sala = io.read("*n") io.read()
        
        elseif ask == 4 then
            local media = calculo_notas()
            self.nota_final = media

        elseif ask == 5 then
            io.write("Informe a nova sala: ")
            self.sala = io.read("*n") io.read()

        elseif ask == 6 then
            io.write("Informe o novo turno: ")
            self.turno = io.read()

        elseif ask == 7 then
            os.execute("clear")
            break
        end

        update_data()
        os.execute("clear")
        print("Dados atualizados!")
    end
end

function aluno:delete()
    print("Dados do aluno "..self.nome)
    io.write("A ação desejada não poderá ser refeita.\nDeseja confirmar continuar [s/N]: ")
    local action = io.read()

    if action == '' or action == 'n' or action == 'N' then
        print("Ação abortada")
    elseif action == 's' or action == 'S' then
        db:execute(string.format("DELETE FROM student WHERE id = '%d' AND nome = '%s'",self.id,self.nome))

        os.execute("clear")
        print("Dados do aluno foram '"..self.nome.."' apagado")
    end
end

function aluno.local_menu()
    os.execute("clear")
    local contact = aluno:new()

    while true do
        print("1) Cadastrar aluno")
        print("2) Acessar dados")
        io.write("> ")
        local ask = io.read("*n") io.read()
        
        if ask == 1 then
            contact:insert()
            contact:saveData()
            break
        elseif ask == 2 then
            local access = contact:searchStudent()
            if access == true then
                break
            end
        else
            print("Ação inválida")
        end
    end
    os.execute("clear")
    while true do
        print("Menu do Aluno --------------")
        print("1) Alterar dados")
        print("2) Deletar dados")
        print("3) Mostrar dados")
        print("4) Trocar de usuário")
        print("5) Retornar")
        io.write("> ")
        local ask = io.read("*n") io.read()

        if ask == 1 then
            os.execute("clear")
            contact:changeData()
        elseif ask == 2 then
            contact:delete()
        elseif ask == 3 then
            os.execute("clear")
            contact:showData()
        elseif ask == 4 then
            os.execute("clear")
            contact:searchStudent()
        elseif ask == 5 then
            os.execute("clear")
            break
        else
            print("Ação inválida")
        end
    end
end

return aluno