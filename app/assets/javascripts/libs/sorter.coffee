_ = require 'lodash'

class Sorter
  constructor: (@data) ->
    @init()

  init: ->
    @hash = {}
    @data.forEach (task) =>
      @hash[task.id] = task

  sort: ->
    # calculate depth
    @depth = {}
    @milestone = {}

    # TODO speed up by search roots

    maxDepth = 0
    findMaxDepth = (task, depth) =>
      maxDepth = _.max([maxDepth, depth])
      task.getDependencies().forEach (id) =>
        findMaxDepth @hash[id], depth + 1

    @data.forEach (task) -> findMaxDepth task, 0

    assignDepths = (task) =>
      dependencies = task.getDependencies()
      if dependencies.length == 0
        @depth[task.id] = maxDepth
        return maxDepth - 1

      depth = _.chain(dependencies).map((id) =>
        assignDepths @hash[id]
      ).min().value()

      @depth[task.id] = depth
      depth - 1

    @data.forEach (task) -> assignDepths task

    assignMilestones = (task, milestone) =>
      # TODO there is a problem if task.getMilestone() is 0
      milestone = task.getMilestone() or milestone
      @milestone[task.id] or= Infinity
      @milestone[task.id] = _.min([@milestone[task.id], milestone])

      task.getDependencies().forEach (id) =>
        t = @hash[id]
        assignMilestones t, @milestone[task.id]

    @data.forEach (task) -> assignMilestones task

    # sort
    @result = @data.sort (a, b) =>
      ma = @milestone[a.id] or 10000
      mb = @milestone[b.id] or 10000

      if ma - mb isnt 0
        return ma - mb

      da = @depth[a.id] or 0
      db = @depth[b.id] or 0
      if db - da isnt 0
        return db - da

      pa = a.getPriority() or -1
      pb = b.getPriority() or -1
      return pb - pa

    @result

module.exports = Sorter

