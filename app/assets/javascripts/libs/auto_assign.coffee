_ = require 'lodash'
moment = require 'moment'

class AutoAssign
  constructor: (@startDate) ->
    @channels = {}

  getDateFromIndex: (i) ->
    moment(@startDate).add(i, 'day')

  addChannel: (channel) ->
    channel.startDate = @startDate
    @channels[channel.id] = channel

  assignTask: (task) ->
    validDay = _.max (channel.nonBlockingDayToStart task for id, channel of @channels)
    workerId = task.getAssignedWorkerId() || 100
    @channels[workerId].assignTask task, validDay

class Slot
  constructor: (data) ->
    @startDay = data.startDay
    @startDayQuota = data.startDayQuota
    @endDay = data.endDay

  hasTimeAfter: (day) ->
    @endDay >= day

  clone: ->
    new Slot @

class Channel
  constructor: (@id, @name) ->
    @dailyQuota = 8 # hours by day

    @slots = [new Slot {
      startDay: 0
      startDayQuota: @dailyQuota
      endDay: Infinity
    }]
    @assignments = []
    @tasksIndexByDay = []

    @leaves = []

  addLeave: (leave) ->
    @leaves.push leave

  nonBlockingDayToStart: (task, after=0) ->
    assign = _.sortBy @assignments, 'endDay'

    i = assign.length - 1
    while i >= 0
      a = assign[i]
      t = a.task
      if a.endDay >= after
        if task.getDependencies().indexOf(t.id) != -1 or t.getParentId() == task.id
          return a.endDay + 1
      i--

    after

  assignTask: (task, afterDay) ->
    h = task.getDuration()
    h = 1 if not h

    @assignToSlots task, h, afterDay

  assignToSlots: (task, h, afterDay) ->
    return 0 unless h > 0

    slots = []
    @slots.forEach (s) =>
      unless s.hasTimeAfter afterDay
        slots.push s
        return

      if s.startDay >= afterDay
        currentDay = s.startDay
        quota = s.startDayQuota
      else
        [currentDay, quota] = @validDayAndQuota afterDay, @dailyQuota

        slot = s.clone()
        slot.endDay = currentDay - 1
        slots.push slot

      beginDay = s.startDay
      while h > 0 and currentDay <= s.endDay
        x = _.min [h, quota]
        h -= x
        quota -= x

        @assignTaskToDay task, currentDay
        endDay = currentDay
        endDayQuota = quota

        [currentDay, quota] = @validDayAndQuota currentDay, quota

      @assignments.push {task, beginDay, endDay}

      if currentDay <= s.endDay
        slot = new Slot
          startDay: currentDay
          startDayQuota: quota
          endDay: s.endDay

        slots.push slot

    @slots = slots
    h

  assignTaskToDay: (task, day) ->
    @tasksIndexByDay[day] or= []
    @tasksIndexByDay[day].push task

  validDayAndQuota: (day, quota) ->
    if @isWeekend day
      day = @skipWeekend day
      quota = @dailyQuota

    while quota == 0
      day = @skipWeekend day + 1
      quota = @quotaAfterCheckLeave day, @dailyQuota

    [day, quota]

  skipWeekend: (day) ->
    day += 1 while @isWeekend day
    day

  isWeekend: (day) ->
    moment(@startDate).add(day, 'days').isoWeekday() > 5

  quotaAfterCheckLeave: (day, quota) ->
    quota -= _(@leaves).map((l) =>
      date = moment(@startDate).add(day, 'days')
      return 0 unless l.containsDate date

      l.getHours() or @dailyQuota
    ).reduce((sum, num) ->
      sum + num
    , 0)

    if quota < 0 then 0 else quota

module.exports = {
  AutoAssign
  Slot
  Channel
}
