require_relative "RequestProcess"
require_relative "Init"
require_relative "Interact"
puts "
           (              (     
   (       )\\ )     (     )\\ )  
   )\\     (()/(   ( )\\   (()/(  
((((_)(    /(_))  )((_)   /(_)) 
 )\\ _ )\\  (_))   ((_)_   (_))   
 (_)_\\(_) / __|   / _ \\  | |    
  / _ \\   \\__ \\  | (_) | | |__  
 /_/ \\_\\  |___/   \\__\\_\\ |____| 

 
"

control = ""
database = ""
settings = {"tabsize" => 4}
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
    Interact(database, settings)
  elsif control == "SET" then
    settings[value[0]] = Integer(value[1])
  end
end