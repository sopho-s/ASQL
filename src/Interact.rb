require_relative "Parser"

def Interact(dbname)
  hashdb = ParseDB(dbname)
  command = ""
  until command == "exit" do
    print "#{dbname.split[0]}>"
    command = gets.chomp
    parsedcommand = ParseCommand(command)
    output = DoCommand(hashdb, parsedcommand)
    print output
    puts "\n"
  end
  puts "Exiting interact mode"
end

def DoCommand(hashdb, command)
  returnval = []
  if command[0].downcase == "select" then
    returnval = Select(hashdb, command)
  end
  return returnval
end

def Select(hashdb, command)
  index = 1
  fields, index = FindIdents(command, index, "from", "*")
  index += 1
  tables, index = FindIdents(command, index, "where", "")
  index += 1
  where, index = FindIdents(command, index, "", "")
  indicies = []
  if where.length != 0 then
    indicies = Find(hashdb, where)
  end
  returnvals = []
  if indicies.length == 0 then
    if fields[0] != "*" then
      firstfield = hashdb[tables[0]][fields[0]]
      index = 1
      restfields = []
      until index >= fields.length do
        restfields << hashdb[tables[0]][fields[index]]
        index += 1
      end
      returnvals = firstfield.zip(*restfields)
    else
      tablesarrays = []
      tables.each do |table|
        tablesarrays << SelectAll(hashdb, table)
      end

    end
  end
  return returnvals
end

def Find(hashdb, where)
  return nil
end

def SelectAll(hashdb, table)
  restfields = []
  hashdb[table].keys.each do |field|
    if field != "headers" then
      restfields << hashdb[table][field]
    end
  end
  firstfield = restfields[0]
  restfields.shift
  returnvals = firstfield.zip(*restfields)
  return returnvals
end

def InnerJoin(hashdb, tables, tablenames)
  tablerelationships = []
  tablename.each do |table|
    tableheaderkeys = hashdb[table]["headers"].keys
    tableheaderkeys.each do |key|
      if hashdb[table]["headers"][key]["foreign"]["isforeign"] then
        tablerelationships << [table, hashdb[table]["headers"][key]["index"], hashdb[table]["headers"][key]["foreign"]["table"], hashdb[table]["headers"][hashdb[table][headers][key]["foreign"]["field"]]["index"]]
      end
    end
  end
end