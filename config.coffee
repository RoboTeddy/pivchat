config =
  pivotal:
    baseUrl: "https://www.pivotaltracker.com/services/v3"
    token: process.env.PIVOTAL_TOKEN || throw "need PIVOTAL_TOKEN env"
    # everything except 'unscheduled' (i.e. icebox) and 'finished'

  hipchat:
    baseUrl: "https://api.hipchat.com/v1"
    token: process.env.HIPCHAT_TOKEN || throw "need HIPCHAT_TOKEN env"

  projectId: "642267"
  labels: ["needs tech-design", "needs design", "needs discussion"]
  states: ["unstarted", "started", "delivered", "accepted", "rejected"]

module.exports = config