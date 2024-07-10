require "json"
def ParseDB(dbname)
  file = File.open(dbname)
  db = file.read
  hashdb = JSON.parse(db)
  return hashdb
end

def ParseCommand(command)
  index = 0
  commandstrings = []
  until index >= command.length do
    if IsAlphaNumeric(command[index]) then
      index, sepcommand = ParseString(index, command)
      commandstrings << sepcommand
    elsif command[index] == ";" then
      commandstrings << ";"
    elsif command[index] == "," then
      commandstrings << ","
    elsif command[index] == "*" then
      commandstrings << "*"
    end
    index += 1
  end
  return commandstrings
end

def ParseString(index, string)
  returnstring = ""
  until index >= string.length || !IsAlphaNumeric(string[index]) do
    returnstring += string[index]
    index += 1
  end
  index -= 1
  return index, returnstring
end

def IsAlphaNumeric(string)
  !string.match(/\A[a-zA-Z0-9]*\z/).nil?
end

def FindIdents(command, index, stopval, specialstop)
  returnval = []
  until index >= command.length || command[index].downcase == stopval || command[index] == ";" do
    if command[index] == specialstop then
      returnval = [specialstop]
    end
    if command[index] != "," then
      returnval << command[index]
    end
    index += 1
  end
  return returnval, index
end
