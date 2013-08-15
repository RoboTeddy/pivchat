request = require("request")
_ = require('underscore')._

pivotal = 
  call: (baseUrl, token, method, args...) ->
    pivotal[method](baseUrl, token, args...)

  get: (baseUrl, token, path, qs, cb = ->) ->
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

module.exports = pivotal