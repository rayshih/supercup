_ = require 'lodash'

class AutoAssign
  constructor: ->
    @channels = {}

  addChannel: (channel) ->
    @channels[channel.id] = channel

  assignTask: (task) ->
    validDay = _.max (channel.validDayToStart task for id, channel of @channels)
    workerId = task.getAssignedWorkerId() || 100
    @channels[workerId].assignTask task, validDay

class Channel
  constructor: (@id, @name) ->
    @currentDay = 0
    @currentDayQuota = 8 # hours by day
    @counter = 0
    @tasks = []
    @taskBegins = []
    @taskEnds = []
    @tasksIndexByDay = []

  assignTask: (task, beginDay) ->
    h = task.getDuration()
    h = 1 if not h

    if beginDay and beginDay > @currentDay
      @currentDay = beginDay
      @currentDayQuota = 8

    beginDay = @currentDay

    while h > 0
      x = _.min [h, @currentDayQuota]

      h -= x
      @currentDayQuota -= x
      @tasksIndexByDay[@currentDay] or= []
      @tasksIndexByDay[@currentDay].push task

      if @currentDayQuota == 0
        @currentDayQuota = 8
        @currentDay += 1

    endDay = @currentDay

    @tasks.push task
    @taskBegins.push beginDay
    @taskEnds.push endDay
    @counter++

  validDayToStart: (task, after=0) ->
    i = @counter - 1
    while i >= 0
      t = @tasks[i]
      if @taskEnds[i] >= after
        if task.getDependencies().indexOf(t.id) != -1 or t.getParentId() == task.id
          return @taskEnds[i] + 1

      i--

    return after

module.exports = {
  AutoAssign
  Channel
}
