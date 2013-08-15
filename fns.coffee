Bacon = require('baconjs').Bacon
par = require("par")
xml2js = require('xml2js')
_ = require('underscore')._

pivotal = require('./pivotal')

fns =
  getRoomName: (story) -> "(P) #{story.name.substr(0, 35)} (#{story.id})"
  getRoomTopic: (story) -> "#{story.name} (#{story.labels.join(', ')})"

  createRoomForStory: (callHipchat, story) ->
    room =
      name: getRoomName(story),
      topic: getRoomTopic(story),
      owner_user_id: config.hipchat.ownerUserId

    callHipchat "post", "/rooms/create", room

  notifyOfNewRoom: (callHipchat, roomId, story) ->
    callHipchat "post", "/rooms/message",
      from: "God",
      room_id: roomId,
      message_format: "text"
      message: "@all Hit 'lobby' and join the discussion for '#{story.name}'",
      color: "purple"

  updateHipchat: (callHipchat, notificationRoomId, stories, rooms) ->
    storiesWithoutRooms = _.filter stories, ({id}) ->
      _.pluck(rooms, 'name').join().indexOf(id) == -1

    _.each storiesWithoutRooms, (par fns.createRoomForStory, callHipchat)
    _.each storiesWithoutRooms,
      (par fns.notifyOfNewRoom, callHipchat, config.hipchat.notificationRoomId)

  getTargetStories: (callPivotal, projectId, labels, states) ->
    # pivotal api returns xml, gaah
    parse = new xml2js.Parser(ignoreAttrs: true).parseString

    # conversion from xml is lossy; we need to know which fields are lists
    fixedStory = (story) ->
      listFields = ['labels', 'notes', 'tasks']
      _.object _.map story, (value, key) ->
        [key, if key in listFields then value else value?[0]]

    # pivotal search doesn't support OR'd labels, so make a request per label
    requests = ((par callPivotal, "get", "/projects/#{projectId}/stories",
      filter: pivotal.filter({label, state: states})) for label in labels)

    Bacon.mergeAll(Bacon.fromNodeCallback r for r in requests)
      .flatMap(par Bacon.fromNodeCallback, parse)
      .map((result) -> _.map result?.stories?.story, fixedStory)
      .scan([], '.concat')
      .skip(labels.length) # wait for all results

module.exports = fns