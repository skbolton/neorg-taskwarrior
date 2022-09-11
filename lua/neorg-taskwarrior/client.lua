local Job = require 'plenary.job'

local Client = {}

function Client:query(query)
  query = query or ""
  return Job:new {
    command = 'task',
    -- tasks are output one per line
    -- plenary also gathers into a table for us
    args = { query, 'export', 'rc.json.array=off' },
    on_exit = function(j, return_value)
      tasks = {}
      for idx, json_task in pairs(j:result()) do
        tasks[idx] = vim.json.decode(json_task)
      end

      return tasks
    end
  }:sync()
end

function Client:add(task)
  print(vim.json.encode(task))
  return Job:new {
    command = 'task',
    writer = vim.json.encode(task),
    args = { 'rc.verbose=nothing', 'import', '-'},
    on_exit = function(j, return_value)
      print(return_value)
      vim.pretty_print(j:result())
    end
  }:sync()
end

return Client
