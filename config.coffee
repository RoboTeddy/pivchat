get = (name) -> process.env[name] || throw "missing env variable: #{name}"

config =
  pivotal:
    baseUrl: "https://www.pivotaltracker.com/services/v3"
    token: get('PIVOTAL_TOKEN')

    projectId: get('PIVOTAL_PROJECT_ID')
    labels: ["needs tech-design", "needs design", "needs discussion"]

    # everything except 'unscheduled' (i.e. icebox) and 'finished'
    states: ["unstarted", "started", "delivered", "accepted", "rejected"]

  hipchat:
    baseUrl: "https://api.hipchat.com/v1"
    token: get('HIPCHAT_TOKEN')

    ownerUserId: get('HIPCHAT_OWNER_USER_ID')
    notificationRoomId: get('HIPCHAT_NOTIFICATION_ROOM_ID')

module.exports = config
