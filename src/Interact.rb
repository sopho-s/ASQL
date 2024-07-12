require_relative "Parser"

def Interact(dbname)
  hashdb = ParseDB(dbname)
  command = ""
  until command == "exit" do
    print "#{dbname.split[0]}>"
    command = gets.chomp
    parsedcommand = ParseCommand(command)
    table, header = DoCommand(hashdb, parsedcommand)
    PrintTable(table, header)
    puts "\n"
  end
  puts "Exiting interact mode"
end

def DoCommand(hashdb, command)
  returnval = []
  if command[0].downcase == "select" then
    returnval = Select(hashdb, command)
  else 
    return nil, nil
  end
  return returnval
end

def PrintTable(table, headers)
  if table == nil then
    puts "Invalid command"
    return
  end
  print "|"
  tabsize = []
  headers.each do |header|
    print "#{header}"
    currtabsize = ((header.length + 4.0) / 4.0).ceil
    (currtabsize * 4 - header.length).times do
      print " "
    end
    print "|"
    tabsize << currtabsize
  end
  print "\n"
  table.each do |entry|
    print "|"
    fieldindex = 0
    entry.each do |field|
      print "#{field}"
      tabam = tabsize[fieldindex] * 4 - "#{field}".length
      tabam.times do
        print " "
      end
      print "|"
      fieldindex += 1
    end
    print "\n"
  end
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
  tablearrays = []
  tablekeys = []
  tables.each do |table|
    tablearrays << SelectAll(hashdb, table)
    tablekeys << Marshal.load(Marshal.dump(hashdb[table]["headers"]["headers"]))
  end
  returnvals, returnheaders = InnerJoin(hashdb, tablearrays, tables, tablekeys)
  removeindicies = GetInverseFields(fields, returnheaders)
  returnheaders = RemoveHeaders(removeindicies, returnheaders)
  returnvals = RemoveFields(returnvals, removeindicies)
  if fields[0] != "*" then
    returnvals = OrderFields(returnvals, returnheaders, fields)
    returnheaders = fields
  end
  return returnvals, returnheaders
end

def GetInverseFields(fields, returnheaders)
  removeindicies = []
  index = 0
  returnheaders.each do |header|
    isvalid = false
    fields.each do |field|
      if field == header then
        isvalid = true
        break
      elsif field == "*" then
        isvalid = true
        break
      end
    end
    unless isvalid then
      removeindicies << index
    end
    index += 1
  end
  
  return removeindicies
end

def RemoveHeaders(removeindicies, returnheaders)
  removecount = 0
  removeindicies.each do |index|
    returnheaders.delete_at(index - removecount)
    removecount += 1
  end
  return returnheaders
end

def RemoveFields(entries, removeindicies)
  entryindex = 0
  entries.each do |entry|
    removecount = 0
    removeindicies.each do |index|
      entries[entryindex].delete_at(index - removecount)
      removecount += 1
    end
    entryindex += 1
  end
  return entries
end

def OrderFields(entries, headers, orders)
  orderindex = []
  orders.each do |order|
    index = 0
    headers.each do |header|
      if order == header then
        orderindex << index
        break
      end
      index += 1
    end
  end
  returnvals = []
  entries.each do |entry|
    temp = []
    orderindex.each do |index|
      temp << entry[index]
    end
    returnvals << temp
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

def InnerJoin(hashdb, tables, tablenames, tablekeys)
  relations = []
  tablenames.length.times do |i|
    relations << [i]
  end
  tablerelationships = []
  table1index = 0
  tablenames.each do |table|
    tableheaderkeys = hashdb[table]["headers"].keys
    tableheaderkeys.each do |key|
      unless key == "headers" then
        if hashdb[table]["headers"][key]["foreign"]["isforeign"] then
          table2index = 0
          tablenames.each do |table2|
            if table2 == hashdb[table]["headers"][key]["foreign"]["table"] then
              break
            end
            table2index += 1
          end
          unless table2index == tablenames.length then
            tablerelationships << [table1index, key, table2index, hashdb[table]["headers"][key]["foreign"]["field"]]
          end
        end
      end
    end
    table1index += 1
  end
  tablerelationships.each do |relation|
    table = tables[relation[2]]
    index = 0
    hashtable = {}
    index = 0
    until tablekeys[relation[0]][index] == relation[1] do
      index += 1
    end
    table1field = index
    index = 0
    until tablekeys[relation[2]][index] == relation[3] do
      index += 1
    end
    table2field = index
    table.each do |entry|
      hashtable[entry[table2field]] = index
      index += 1
    end
    joinertable = tables[relation[0]]
    newtable = []
    joinertable.each do |entry|
      index = hashtable[entry[table1field]]
      temp = Marshal.load(Marshal.dump(table[index]))
      temp.delete_at(table2field)
      temp = entry.concat(temp)
      newtable << temp
    end
    newkey = tablekeys[relation[2]]
    newkey.delete_at(table2field)
    newkey = tablekeys[relation[0]].concat(newkey)
    relations[relation[0]] = relations[relation[0]] | relations[relation[2]]
    relations[relation[0]].each do |tablenum|
      relations[tablenum] = relations[relation[0]]
      tablekeys[tablenum] = newkey
      tables[tablenum] = newtable
    end
  end
  return tables[0], tablekeys[0]
end