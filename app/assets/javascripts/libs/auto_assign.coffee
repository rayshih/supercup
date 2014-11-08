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
    validDay = _.max (channel.validDayToStart task for id, channel of @channels)
    workerId = task.getAssignedWorkerId() || 100
    @channels[workerId].assignTask task, validDay

class Channel
  constructor: (@id, @name) ->
    @currentDay = 0
    @currentDayQuota = 8 # hours by day
    @lastEndDay = 0
    @lastEndDayQuota = 8

    @assignments = []
    @remainSlots = []
    @tasksIndexByDay = []

    @leaves = []

  addLeave: (leave) ->
    @leaves.push leave

  # TODO rename it: beginDay is the minimum date to start
  # not the actual date to start
  assignTask: (task, beginDay) ->
    h = task.getDuration()
    h = 1 if not h

    h = @assignToRemainSlot task, h, beginDay
    h = @assignToEnd task, h, beginDay

  assignToRemainSlot: (task, h, afterDay) ->
    slots = []
    @remainSlots.forEach (s) =>
      unless s.endDay >= afterDay and h > 0
        slots.push s
        return

      if s.startDay >= afterDay
        currentDay = s.startDay
        quota = s.startDayQuota
      else
        currentDay = afterDay
        currentDay = @skipWeekend currentDay
        quota = 8

        slots.push {
          after: s.after
          startDay: s.startDay
          startDayQuota: s.startDayQuota
          endDay: currentDay - 1
        }

      while h > 0 and quota > 0 and currentDay <= s.endDay
        x = _.min [h, quota]

        h -= x
        quota -= x
        @tasksIndexByDay[currentDay] or= []
        @tasksIndexByDay[currentDay].push task

        while quota == 0 and currentDay < s.endDay
          currentDay += 1
          currentDay = @skipWeekend currentDay
          quota = 8
          quota = @dealWithLeaves currentDay, quota

      beginDay = s.startDay
      endDay = if quota is 8 then currentDay - 1 else currentDay
      @assignments.splice s.after, 0, {task, beginDay, endDay}
      if currentDay < s.endDay or (currentDay == s.endDay and quota > 0)
        slots.push {
          after: s.after + 1
          startDay: currentDay
          startDayQuota: quota
          endDay: s.endDay
        }

    @remainSlots = slots
    h

  assignToEnd: (task, h, beginDay) ->
    return 0 unless h > 0

    if beginDay and beginDay > @currentDay
      @currentDay = beginDay
      @currentDay = @skipWeekend @currentDay
      @recordRemainSlot @assignments.length # since not assign yet
      @currentDayQuota = 8
      @currentDayQuota = @dealWithLeaves @currentDay, @currentDayQuota

      # TODO refactor this
      while @currentDayQuota == 0
        @currentDay += 1
        @currentDay = @skipWeekend @currentDay
        @currentDayQuota = 8
        @currentDayQuota = @dealWithLeaves @currentDay, @currentDayQuota

    beginDay = @currentDay
    while h > 0
      x = _.min [h, @currentDayQuota]

      h -= x
      @currentDayQuota -= x
      @tasksIndexByDay[@currentDay] or= []
      @tasksIndexByDay[@currentDay].push task

      # TODO refactor this
      while @currentDayQuota == 0
        @currentDay += 1
        @currentDay = @skipWeekend @currentDay
        @currentDayQuota = 8
        @currentDayQuota = @dealWithLeaves @currentDay, @currentDayQuota

    endDay = if @currentDayQuota == 8 then @currentDay - 1 else @currentDay
    @lastEndDay = endDay
    @lastEndDayQuota = if @currentDayQuota == 8 then 0 else @currentDayQuota
    @assignments.push {task, beginDay, endDay}
    h

  recordRemainSlot: (after) ->
    startDay = if @lastEndDayQuota == 0 then @lastEndDay + 1 else @lastEndDay
    startDayQuota = if @lastEndDayQuota == 0 then 8 else @lastEndDayQuota
    @remainSlots.push {
      after: after
      startDay: startDay
      startDayQuota: startDayQuota
      endDay: @currentDay - 1
    }

  validDayToStart: (task, after=0) ->
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

  skipWeekend: (day) ->
    day += 1 while @isWeekend day
    day

  isWeekend: (day) ->
    moment(@startDate).add(day, 'days').isoWeekday() > 5

  dealWithLeaves: (day, quota) ->
    h = 0
    @leaves.forEach (l) =>
      date = moment(@startDate).add(day, 'days')
      if l.containsDate date
        h += l.getHours() or 8

    quota -= h
    quota = 0 if quota < 0
    quota

module.exports = {
  AutoAssign
  Channel
}
