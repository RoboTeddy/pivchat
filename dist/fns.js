// Generated by CoffeeScript 1.4.0
(function() {
  var Bacon, fns, par, pivotal, xml2js, _,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Bacon = require('baconjs').Bacon;

  par = require("par");

  xml2js = require('xml2js');

  _ = require('underscore')._;

  pivotal = require('./pivotal');

  fns = {
    getRoomName: function(story) {
      return "(P) " + (story.name.substr(0, 35)) + " (" + story.id + ")";
    },
    getRoomTopic: function(story) {
      return "" + story.name + " (" + (story.labels.join(', ')) + ")";
    },
    createRoomForStory: function(callHipchat, ownerUserId, story) {
      var room;
      console.log("Creating room for " + story.name);
      room = {
        name: fns.getRoomName(story),
        topic: fns.getRoomTopic(story),
        owner_user_id: ownerUserId
      };
      return callHipchat("post", "/rooms/create", room);
    },
    notifyOfNewRoom: function(callHipchat, roomId, story) {
      return callHipchat("post", "/rooms/message", {
        from: "God",
        room_id: roomId,
        message_format: "text",
        message: "@all Hit 'lobby' and join the discussion for '" + story.name + "'",
        color: "purple"
      });
    },
    getStoriesWithoutRooms: function(stories, rooms) {
      return _.filter(stories, function(_arg) {
        var id;
        id = _arg.id;
        return _.pluck(rooms, 'name').join().indexOf(id) === -1;
      });
    },
    getTargetStories: function(callPivotal, projectId, labels, states) {
      var fixedStory, label, parse, r, requests;
      parse = new xml2js.Parser({
        ignoreAttrs: true
      }).parseString;
      fixedStory = function(story) {
        var listFields;
        listFields = ['labels', 'notes', 'tasks'];
        return _.object(_.map(story, function(value, key) {
          return [key, __indexOf.call(listFields, key) >= 0 ? value : value != null ? value[0] : void 0];
        }));
      };
      requests = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = labels.length; _i < _len; _i++) {
          label = labels[_i];
          _results.push(par(callPivotal, "get", "/projects/" + projectId + "/stories", {
            filter: pivotal.filter({
              label: label,
              state: states
            })
          }));
        }
        return _results;
      })();
      return Bacon.mergeAll((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = requests.length; _i < _len; _i++) {
          r = requests[_i];
          _results.push(Bacon.fromNodeCallback(r));
        }
        return _results;
      })()).flatMap(par(Bacon.fromNodeCallback, parse)).map(function(result) {
        var _ref;
        return _.map(result != null ? (_ref = result.stories) != null ? _ref.story : void 0 : void 0, fixedStory);
      }).scan([], '.concat').skip(labels.length);
    }
  };

  module.exports = fns;

}).call(this);
