// Generated by CoffeeScript 1.4.0
(function() {
  var config;

  config = {
    pivotal: {
      baseUrl: "https://www.pivotaltracker.com/services/v3",
      token: process.env.PIVOTAL_TOKEN || (function() {
        throw "need PIVOTAL_TOKEN env";
      })()
    },
    hipchat: {
      baseUrl: "https://api.hipchat.com/v1",
      token: process.env.HIPCHAT_TOKEN || (function() {
        throw "need HIPCHAT_TOKEN env";
      })()
    },
    projectId: "642267",
    labels: ["needs tech-design", "needs design", "needs discussion"],
    states: ["unstarted", "started", "delivered", "accepted", "rejected"]
  };

  module.exports = config;

}).call(this);
