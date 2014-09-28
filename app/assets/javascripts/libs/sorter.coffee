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

    traverse = (task, depth, milestone) =>
      @depth[task.id] or= -Infinity
      @depth[task.id] = _.max([@depth[task.id], depth])

      # TODO there is a problem if task.getMilestone() is 0
      milestone = task.getMilestone() or milestone
      @milestone[task.id] or= Infinity
      @milestone[task.id] = _.min([@milestone[task.id], milestone])

      task.getDependencies().forEach (id) =>
        t = @hash[id]
        traverse t, depth + 1, @milestone[task.id]

    @data.forEach (task) ->
      traverse task, 0

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

