_ = require 'lodash'

class Sorter
  constructor: (@data) ->
    @_genHash()
    @_findRootsAndGenSinks()

  _genHash: ->
    @hash = {} # id -> node
    @data.forEach (task) =>
      @hash[task.id] = task

  _findRootsAndGenSinks: ->
    beenRefer = []
    @sinks = {}

    @data.forEach (task) =>
      depIds = task.getDependencies()
      beenRefer = _.union beenRefer, depIds
      @sinks[task.id] or= []
      @sinks[task.id] = _.union @sinks[task.id], depIds

      parentId = task.getParentId()
      if parentId
        beenRefer = _.union beenRefer, [task.id]
        @sinks[parentId] or= []
        @sinks[parentId] = _.union @sinks[parentId], [task.id]

    ids = @data.map (task) -> task.id
    @rootIds = _.difference ids, beenRefer
    @roots = @rootIds.map (id) => @hash[id]

  _assignMilestones: ->
    @milestone = {}

    assignMilestones = (task, milestone) =>
      m = task.getMilestone()
      milestone = if m isnt null then m else milestone
      @milestone[task.id] = Infinity if @milestone[task.id] is null
      @milestone[task.id] = _.min([@milestone[task.id], milestone])

      @sinks[task.id].forEach (id) =>
        childTask = @hash[id]
        if not childTask
          console.error "task #{task.id}'s dependency #{id} not found"
          return
        assignMilestones childTask, @milestone[task.id]

    @roots.forEach (task) -> assignMilestones task

  _assignDepths: () ->
    @depth = {}

    assignDepth = (tid, depth) =>
      @depth[tid] or= -Infinity
      @depth[tid] = _.max [@depth[tid], depth]

      sinks = @sinks[tid]
      return unless sinks

      sinks.forEach (id) =>
        assignDepth id, @depth[tid] + 1

    @rootIds.forEach (id) -> assignDepth id, 0

  sort: ->
    start = Date.now()

    @_assignMilestones()
    @_assignDepths()

    shouldSwap = (a, b) =>
      return false if @sinks[b]?.indexOf(a) != -1

      ma = @milestone[a] or 10000
      mb = @milestone[b] or 10000
      return mb < ma unless ma == mb

      pa = @hash[a].getPriority() or -1
      pb = @hash[b].getPriority() or -1
      return pb > pa

    swap = (i, j) ->
      id = seq[i]
      seq[i] = seq[j]
      seq[j] = id

    seq = []
    ids = @data.map (task) ->
      task.id

    _.sortBy(ids, (id) =>
      -@depth[id]
    ).forEach (id) ->
      seq.push id
      return if seq.length < 2
      for i in [(seq.length-1)..1]
        return unless shouldSwap seq[i - 1], seq[i]
        swap i - 1, i

    @result = seq.map (id) => @hash[id]

    console.log 'sorting time spent:', Date.now() - start
    @result

module.exports = Sorter

