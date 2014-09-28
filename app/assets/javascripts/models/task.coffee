class Task
  constructor: (@data) ->
    @id = @data.id

  getName: -> @data.name
  setName: (name) -> @data.name = name

  setDependenciesString: (str) ->
    @data.dependencies = str.split(',').map((s) ->
      parseInt s.trim(), 10
    ).filter((v) -> !isNaN(v))

  getDependenciesString: ->
    return null unless @data.dependencies

    @data.dependencies.join ', '

module.exports = Task
