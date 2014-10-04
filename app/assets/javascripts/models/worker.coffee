class Worker
  constructor: (@data) ->
    @id = @data.id

  getName: -> @data.name

module.exports = Worker
