_ = require 'lodash'

class Sorter
  constructor: (@data) ->
    @_genHash()
    @_findRoots()

  _genHash: ->
    @hash = {} # id -> node
    @data.forEach (task) =>
      @hash[task.id] = task

  _findRoots: ->
    beenRefer = []

    @data.forEach (task) =>
      beenRefer = _.union beenRefer, task.getDependencies()
      beenRefer = _.union beenRefer, [task.id] if task.getParentId()

    ids = @data.map (task) -> task.id
    @roots = _.difference(ids, beenRefer).map (id) => @hash[id]

  _findMaxDepthFromData: ->
    maxDepth = 0

    findMaxDepth = (task, depth) =>
      maxDepth = _.max([maxDepth, depth])
      task.getDependencies().forEach (id) =>
        childTask = @hash[id]
        if not childTask
          console.error "task #{task.id}'s dependency #{id} not found"
          return

        findMaxDepth childTask, depth + 1

    @roots.forEach (task) -> findMaxDepth task, 0
    maxDepth

  _assignDepths: (maxDepth) ->
    @depth = {}
    assignDepths = (task) =>
      dependencies = task.getDependencies()
      if dependencies.length == 0
        @depth[task.id] = maxDepth
        return maxDepth - 1

      depth = _.chain(dependencies).map((id) =>
        childTask = @hash[id]
        if not childTask
          console.error "task #{task.id}'s dependency #{id} not found"
          return
        assignDepths childTask
      ).min().value()

      @depth[task.id] = depth
      depth - 1

    @roots.forEach (task) -> assignDepths task

  _assignMilestones: ->
    @milestone = {}

    assignMilestones = (task, milestone) =>
      m = task.getMilestone()
      milestone = if m isnt null then m else milestone
      @milestone[task.id] = Infinity if @milestone[task.id] is null
      @milestone[task.id] = _.min([@milestone[task.id], milestone])

      task.getDependencies().forEach (id) =>
        childTask = @hash[id]
        if not childTask
          console.error "task #{task.id}'s dependency #{id} not found"
          return
        assignMilestones childTask, @milestone[task.id]

    @roots.forEach (task) -> assignMilestones task

  sort: ->
    maxDepth = @_findMaxDepthFromData()
    @_assignDepths maxDepth
    @_assignMilestones()

    # sort
    @result = @data.sort (a, b) =>
      ma = @milestone[a.id] or 10000
      mb = @milestone[b.id] or 10000

      return ma - mb if ma - mb isnt 0

      da = @depth[a.id] or 0
      db = @depth[b.id] or 0
      return db - da if db - da isnt 0

      pa = a.getPriority() or -1
      pb = b.getPriority() or -1
      return pb - pa

    @result

module.exports = Sorter

