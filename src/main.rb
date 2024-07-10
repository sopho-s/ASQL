require_relative "RequestProcess"
require_relative "Init"
require_relative "Interact"
puts "

  /$$$$$$   /$$$$$$   /$$$$$$  /$$      
 /$$__  $$ /$$__  $$ /$$__  $$| $$      
| $$  \\ $$| $$  \\__/| $$  \\ $$| $$      
| $$$$$$$$|  $$$$$$ | $$  | $$| $$      
| $$__  $$ \\____  $$| $$  | $$| $$      
| $$  | $$ /$$  \\ $$| $$/$$ $$| $$      
| $$  | $$|  $$$$$$/|  $$$$$$/| $$$$$$$$
|__/  |__/ \\______/  \\____ $$$|________/
                          \\__/          
"

control = ""
database = ""
until control == "EXIT" do
  print "ASQL>"
  input = gets.chomp
  value, control, output = InterpretInput(input)
  if output != "" then
    puts output
  else
    puts "Not a valid request"
  end
  if control == "USE" then
    database = value[0]
  elsif control == "INITDB" then
    Init(*value)
  elsif control == "INTERACT" then
    Interact(database)
  end
end