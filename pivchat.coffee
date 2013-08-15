Bacon = require('baconjs').Bacon
par = require("par")

hipchat = require('./hipchat')
pivotal = require('./pivotal')

fns = require("./fns")
config = require("./config")

callPivotal = par pivotal.call, config.pivotal.baseUrl, config.pivotal.token
callHipchat = par hipchat.call, config.hipchat.baseUrl, config.hipchat.token

{pivotal: {labels, projectId, states}, hipchat: {notificationRoomId}} = config

stories = fns.getTargetStories(callPivotal, projectId, labels, states)
rooms = Bacon.fromNodeCallback(callHipchat, "get", "/rooms/list", {})
  .map('.rooms')

Bacon.zipAsArray([stories, rooms]).onValues (_stories, _rooms) ->
  fns.updateHipchat(callHipchat, notificationRoomId, _stories, _rooms)
