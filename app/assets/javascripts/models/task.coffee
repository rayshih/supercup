class Task
  constructor: (@data) ->
    @id = @data.id

  getName: -> @data.name
  setName: (name) -> @data.name = name

  getMilestone: -> @data.milestone
  setMilestone: (milestone) -> @data.milestone = milestone

  getPriority: -> @data.priority
  setPriority: (priority) -> @data.priority = priority

  getParentId: -> @data.parent_id
  setParentId: (id) -> @data.parent_id = id

  getDependencies: -> @data.dependencies or []

  setDependenciesString: (str) ->
    @data.dependencies = str.split(',').map((s) ->
      parseInt s.trim(), 10
    ).filter((v) -> !isNaN(v))

  getDependenciesString: ->
    return null unless @data.dependencies

    @data.dependencies.join ', '

module.exports = Task
