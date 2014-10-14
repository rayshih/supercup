class Worker
  constructor: (@data) ->
    @id = @data.id

  getName: -> @data.name

  getOrder: -> parseInt(@data.order, 10)
  setOrder: (o) -> @data.order = o

module.exports = Worker
