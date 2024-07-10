def InterpretInput(input)
  splitin = input.split
  if splitin[0] == "usefile" then
    return [splitin[1]], "USE", "Using file: #{splitin[1]}"
  elsif splitin[0] == "initdb" then
    return [splitin[1], splitin[2], splitin[3], splitin[4]], "INITDB", "Initiating database: #{splitin[1]}\nWith file: #{splitin[2]}\nUsing: #{splitin[3]}:#{splitin[4]}"
  elsif splitin[0] == "exit" then
    return [""], "EXIT", "Exiting"
  elsif splitin[0] == "interact" then
    return [""], "INTERACT", "Loading database..."
  end
  return "", "", ""
end