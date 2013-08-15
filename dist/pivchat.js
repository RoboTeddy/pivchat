// Generated by CoffeeScript 1.4.0
(function() {
  var Bacon, callHipchat, callPivotal, config, fns, hipchat, labels, notificationRoomId, par, pivotal, projectId, rooms, states, stories, _ref, _ref1;

  Bacon = require('baconjs').Bacon;

  par = require("par");

  hipchat = require('./hipchat');

  pivotal = require('./pivotal');

  fns = require("./fns");

  config = require("./config");

  callPivotal = par(pivotal.call, config.pivotal.baseUrl, config.pivotal.token);

  callHipchat = par(hipchat.call, config.hipchat.baseUrl, config.hipchat.token);

  (_ref = config.pivotal, labels = _ref.labels, projectId = _ref.projectId, states = _ref.states), (_ref1 = config.hipchat, notificationRoomId = _ref1.notificationRoomId);

  stories = fns.getTargetStories(callPivotal, projectId, labels, states);

  rooms = Bacon.fromNodeCallback(callHipchat, "get", "/rooms/list", {}).map('.rooms');

  Bacon.zipAsArray([stories, rooms]).onValues(function(_stories, _rooms) {
    return fns.updateHipchat(callHipchat, notificationRoomId, _stories, _rooms);
  });

}).call(this);