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

class Channel
  constructor: (@id, @name) ->
    @dailyQuota = 8 # hours by day

    @currentDay = 0
    @currentDayQuota = @dailyQuota
    @lastEndDay = 0
    @lastEndDayQuota = @dailyQuota

    @assignments = []
    @remainSlots = []
    @tasksIndexByDay = []

    @leaves = []

  addLeave: (leave) ->
    @leaves.push leave

  assignTask: (task, afterDay) ->
    h = task.getDuration()
    h = 1 if not h

    h = @assignToRemainSlot task, h, afterDay
    h = @assignToEnd task, h, afterDay

  assignToRemainSlot: (task, h, afterDay) ->
    return 0 unless h > 0

    slots = []
    @remainSlots.forEach (s) =>
      unless s.hasTimeAfter afterDay
        slots.push s
        return

      if s.startDay >= afterDay
        currentDay = s.startDay
        quota = s.startDayQuota
      else
        [currentDay, quota] = @validDayAndQuota afterDay, @dailyQuota

        s.endDay = currentDay - 1
        slots.push s

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

    @remainSlots = slots
    h

  assignToEnd: (task, h, beginDay) ->
    return 0 unless h > 0

    if beginDay > @currentDay
      [@currentDay, @currentDayQuota] = @validDayAndQuota beginDay, @dailyQuota
      @recordRemainSlot()

    beginDay = @currentDay
    while h > 0
      # update numbers
      x = _.min [h, @currentDayQuota]
      h -= x
      @currentDayQuota -= x

      @assignTaskToDay task, @currentDay
      endDay = @currentDay
      endDayQuota = @currentDayQuota

      [@currentDay, @currentDayQuota] = @validDayAndQuota @currentDay,
                                                          @currentDayQuota

    @assignments.push {task, beginDay, endDay}

    @lastEndDay = endDay
    @lastEndDayQuota = endDayQuota

    h

  assignTaskToDay: (task, day) ->
    @tasksIndexByDay[day] or= []
    @tasksIndexByDay[day].push task

  # base on lastEndDay and currentDay
  recordRemainSlot: () ->
    [startDay, startDayQuota] = @validDayAndQuota @lastEndDay, @lastEndDayQuota

    slot = new Slot
      startDay: startDay
      startDayQuota: startDayQuota
      endDay: @currentDay - 1

    @remainSlots.push slot

  validDayAndQuota: (day, quota) ->
    if @isWeekend day
      day = @skipWeekend day
      quota = @dailyQuota

    while quota == 0
      day = @skipWeekend day + 1
      quota = @quotaAfterCheckLeave day, @dailyQuota

    [day, quota]

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
