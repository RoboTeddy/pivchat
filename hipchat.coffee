request = require("request")
_ = require('underscore')._

hipchat =
  call: (baseUrl, token, method, args...) ->
    hipchat[method](baseUrl, token, args...)

  get: (baseUrl, token, path, qs, cb = ->) ->
    qs = _.defaults {auth_token: token}, qs
    request.get "#{baseUrl}#{path}", {qs}, (err, response, body) ->
      cb(err, JSON.parse(body))

  post: (baseUrl, token, path, data, cb = ->) ->
    form = _.defaults {auth_token: token}, data
    request.post "#{baseUrl}#{path}", {form}, (err, response, body) ->
      cb(err, JSON.parse(body))

module.exports = hipchat
