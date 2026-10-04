local driver = require("luasql.sqlite3")
local env = driver.sqlite3()
local db = env:connect("dados.db")
local std = require("class/aluno")
local mst = require("class/mister")

db:execute([[CREATE TABLE IF NOT EXISTS teacher (
   id INTEGER PRIMARY KEY, 
   nome TEXT NOT NULL, 
   sobrenome TEXT NOT NULL, 
   materia TEXT NOT NULL, 
   sala INTEGER NOT NULL, 
   turno TEXT NOT NULL
)]])
db:execute([[
   CREATE TABLE IF NOT EXISTS student (
   id INTEGER PRIMARY KEY,
   nome TEXT NOT NULL,
   sobrenome TEXT NOT NULL,
   nascimento TEXT NOT NULL,
   idade INTEGER NOT NULL,
   serie INTEGER NOT NULL,
   nota_final INTEGER NOT NULL,
   sala INTEGER NOT NULL,
   turno TEXT NOT NULL
)]])

local function showData(x)
   os.execute("clear") -- Limpa o terminal Linux
   local n = 1
   if x == 'student' then
      local cursor = db:execute("SELECT * FROM student")
      local row = cursor:fetch({},"a")
      while row do
         print(string.format("ALUNO %d --------------------------",n))
         print(string.format("NOME  | %s %s",row.nome,row.sobrenome))
         print(string.format("Nasc. | %s",row.nascimento))
         print(string.format("IDADE | %d",row.idade))
         print(string.format("SÉRIE | %d",row.serie))
         print(string.format("NOTA  | %.1f",row.nota_final))
         print(string.format("SALA  | %d",row.sala))
         print(string.format("Turno | %s",row.turno))

         n = n + 1
         row = cursor:fetch(row,"a")
      end
      cursor:close()
   else
      local cursor = db:execute("SELECT * FROM teacher")
      local row = cursor:fetch({},"a")
      while row do
         print(string.format("PROFESSOR %d ----------------------",n))
         print(string.format("NOME      | %s %s",row.nome,row.sobrenome))
         print(string.format("MATÉRIA   | %s",row.materia))
         print(string.format("SALA      | %d",row.sala))
         print(string.format("Turno     | %s",row.turno))

         n = n + 1
         row = cursor:fetch(row,"a")
      end
      cursor:close()
   end
end

print("Systema de escola V1")
while true do
   print("MENU ----------------------------")
   print("1) Professor")
   print("2) Aluno")
   print("3) Mostrar dados")
   print("4) Sair")
   io.write("> ")
   local ask = io.read("*n") io.read()

   if ask == 1 then
      mst.local_menu()
   elseif ask == 2 then
      std.local_menu()
   elseif ask == 3 then
      io.write("1) Professor \n2) Aluno\n> ")
      local typ = io.read("*n") io.read()

      if typ == 1 then 
         showData("master")
      else
         showData("student")
      end
   elseif ask == 4 then
      break
   else
      print("Ação inválida")
   end
end

db:close()
env:close()