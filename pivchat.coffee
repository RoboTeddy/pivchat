async = require "async"
config = require "./config"
_ = require('underscore')._
request = require "request"
par = require "par"
xml2js = require('xml2js')
util = require('util')

pivotal = 
  call: (baseUrl, token, method, args...) ->
    pivotal[method](baseUrl, token, args...)

  get: (baseUrl, token, path, qs, cb) ->
    request.get(
      "#{baseUrl}#{path}",
      {qs, headers: {"X-TrackerToken": token}},
      (err, response, body) -> cb(err, body))

  filter: (props) ->

    quote = (value) ->
      # pivotal api breaks if you quote unnecessarily (wtf?)
      shouldQuote = _.any [" ", "-", "_"], (char) -> value.indexOf(char) != -1
      if shouldQuote then "\"#{value}\"" else value

    toArray = (v) -> if _.isArray(v) then v else [v]
    (k + ":" + (_.map toArray(v), quote).join(",") for k, v of props).join(" ")


hipchat =
  call: (baseUrl, token, method, args...) ->
    hipchat[method](baseUrl, token, args...)

  get: (baseUrl, token, path, qs, cb) ->
    qs = _.defaults {auth_token: token}, qs
    request.get "#{baseUrl}#{path}", {qs}, (err, response, body) ->
      cb(err, body)

  post: (baseUrl, token, path, qs, cb) ->


# Application Library

getRoomsForStories = (stories) ->
  console.log("Stories to base rooms on", stories)

  [
    name: "(P) storyname (storyId)"
    topic: "adsfasdf (label, label)"
  ]

ensureRooms = (callHipchat, desiredRooms, match) ->
  existingRooms = []
  desiredRooms = []


getTargetStories = (callPivotal, projectId, labels, states, cb) ->

  fixedStory = (story) ->
    listFields = ['labels', 'notes', 'tasks']
    _.object _.map story, (value, key) ->
      [key, if key in listFields then value else value?[0]]

  # pivotal search doesn't support OR'd labels, so make a request per label
  requests = ((par callPivotal, "get", "/projects/#{projectId}/stories",
    filter: pivotal.filter({label, state: states})) for label in labels)

  async.parallel requests, (err, xmls) ->
    throw "Pivotal request failure" if err
    parser = new xml2js.Parser(ignoreAttrs: true) # pivotal returns xml, gaah
    async.parallel (par parser.parseString, x for x in xmls), (err, results) ->
      throw "error parsing Pivotal XML" if err
      stories = _.union(
        (r.stories.story for r in results when r.stories?.story)...)
      cb _.map stories, fixedStory


# Run

callPivotal = par pivotal.call, config.pivotal.baseUrl, config.pivotal.token
callHipchat = par hipchat.call, config.hipchat.baseUrl, config.hipchat.token

{projectId, labels, states} = config
getTargetStories callPivotal, projectId, labels, states, (stories) ->
  console.log("Stories!", stories)
  #ensureRooms(callHipchat, getRoomsForStories(stories))
