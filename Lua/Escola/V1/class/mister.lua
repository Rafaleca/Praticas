local teacher = {}
teacher.__index = teacher

local driver = require("luasql.sqlite3")
local env = driver.sqlite3() 
local db = env:connect("dados.db")

function teacher:new(self,nome,sobrenome,materia,sala,turno)
    local self = setmetatable({},teacher)
    self.id = id or 0
    self.nome = nome or "N/A"
    self.sobrenome = sobrenome or "N/A"
    self.materia = materia or "N/A"
    self.turno = turno or "N/A"
    self.sala = sala or 0

    return self
end

function teacher:add()
    os.execute("clear")
    print("Informe os dados:")
    io.write("Nome: ")
    self.nome = io.read()
    io.write("Sobrenome: ")
    self.sobrenome = io.read()
    io.write("Matéria: ")
    self.materia = io.read()
    io.write("Sala: ")
    self.sala = io.read("*n") io.read()
    io.write("Turno: ")
    self.turno = io.read()

    print("Professor cadastrado!")
end

function teacher:showUser()
    os.execute("clear")
    print(string.rep("-",44-16))
    print("Nome     : "..self.nome)
    print("Sobrenome: "..self.sobrenome)
    print("Matéria  : "..self.materia)
    print("Sala     : "..self.sala)
    print("Turno    : "..self.turno)
end

function teacher:saveData()
    db:execute("INSERT INTO teacher (nome,sobrenome,materia,sala,turno) VALUES (?,?,?,?,?)",self.nome,self.sobrenome,self.materia,self.sala,self.turno)
    do -- Evita erros de envio de dados, sincronizando o arquivo e a classe
        local cursor = db:execute("SELECT * FROM teacher")
        local row = cursor:fetch({},"a")
        while row do
            if self.nome == row.nome then
                self.id = row.id
            end
            row = cursor:fetch(row,"a")
        end
    end
    print("Dados salvos!")
end

function teacher:search()
    io.write("Informe o nome:\n> ")
    local n = io.read()
    local factor = false

    local cursor = db:execute("SELECT * FROM teacher")

    local row = cursor:fetch({},"a")
    while row do
        if row.nome == n then
            print("Nome encontrado!")
            self.id = row.id
            self.nome = row.nome
            self.sobrenome = row.sobrenome
            self.materia = row.materia
            self.sala = row.sala
            self.turno = row.turno
            factor = true
            break
        end
        row = cursor:fetch(row,"a")
    end

    if factor == true then
        print("Dados encontrados!")
    else
        print("Professor não cadastrado!")
    end

    cursor:close()
    return factor
end

function teacher:change()
    os.execute("clear")
    local function update_data()
        db:execute(string.format([[
            UPDATE teacher SET nome = '%s', sobrenome = '%s', materia = '%s', sala = '%d', turno = '%s' WHERE id = '%d'
            ]],self.nome,self.sobrenome,self.materia,self.sala,self.turno,self.id)
        )
    end

    while true do
        print("Informação a ser alterado:")
        print("1) Nome")
        print("2) Matéria")
        print("3) Sala")
        print("4) Turno")
        print("5) Retornar")
        io.write("> ")
        local menu = io.read("*n") io.read()

        if menu == 1 then
            io.write("Informe os dados:\nNome:\n> ")
            self.nome = io.read()
            io.write("Sobrenome:\n> ")
            self.sobrenome = io.read()

        elseif menu == 2 then
            io.write("Informe o nova matéria:\n> ")
            self.materia = io.read()

        elseif menu == 3 then
            io.write("Informe o nova sala:\n> ")
            self.sala = io.read("*n") io.read()

        elseif menu == 4 then
            io.write("Informe o novo turno: ")
            self.turno = io.read()

        elseif menu == 5 then
            os.execute("clear")
            break
        end

        update_data()
        os.execute("clear")
        print("Dados atualizados!")
    end
end

function teacher:delete()
    os.execute("clear")
    print("Dados do professor "..self.nome)
    io.write("A ação desejada não poderá ser refeita.\nDeseja confirmar continuar [s/N]: ")
    local action = io.read()

    if action == '' or action == 'n' or action == 'N' then
        print("Ação abortada")
    elseif action == 's' or action == 'S' then
        db:execute(string.format("DELETE FROM teacher WHERE id = '%d' AND nome = '%s'",self.id,self.nome))

        print("Nome "..self.nome.." apagado")
    end
end

function teacher.local_menu()
    os.execute("clear")
    local contact = teacher:new()
    while true do
        print("1) Cadastrar professor\n2) Acessar dados")
        io.write("> ")
        local ask = io.read("*n") io.read()
        if ask == 1 then
            contact:add()
            contact:saveData()
            break
        elseif ask == 2 then
            local access = contact:search()
            if access == true then
                break
            end
        else
            print("Ação inválida!")
        end
    end
    os.execute("clear")
    while true do
        print("Menu do professor ----------")
        print("1) Alterar")
        print("2) Deletar")
        print("3) Mostrar dados")
        print("4) Trocar de usuário")
        print("5) Retornar")
        io.write("> ")
        local ask = io.read("*n") io.read()
        
        if ask == 1 then
            os.execute("clear")
            contact:change()
        elseif ask == 2 then
            contact:delete()
            break
        elseif ask == 3 then
            contact:showUser()
        elseif ask == 4 then
            os.execute("clear")
            contact:search()
        elseif ask == 5 then
            os.execute("clear")
            break
        else
            print("Ação inválida!")
        end
    end
end

return teacher