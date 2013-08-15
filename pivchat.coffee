Bacon = require('baconjs').Bacon
par = require("par")
_ = require('underscore')._

hipchat = require('./hipchat')
pivotal = require('./pivotal')

fns = require("./fns")
config = require("./config")

callPivotal = par pivotal.call, config.pivotal.baseUrl, config.pivotal.token
callHipchat = par hipchat.call, config.hipchat.baseUrl, config.hipchat.token

{
  pivotal: {labels, projectId, states},
  hipchat: {notificationRoomId, ownerUserId}
} = config

console.log("Updating...")

stories = fns.getTargetStories callPivotal, projectId, labels, states
rooms = fns.getRooms callHipchat 

stories.combine(rooms, fns.getStoriesWithoutRooms).onValue (_stories) ->
  _.each _stories, (par fns.createRoomForStory, callHipchat, ownerUserId)
  _.each _stories, (par fns.notifyOfNewRoom, callHipchat, notificationRoomId)
  console.log("Done")
