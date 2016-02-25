# Description
#   A hubot script that alerts a channel whenever there's an alert on http://www.liberation.fr/
#
# Configuration:
#   HUBOT_LIBERATION_ALERT_CHECK_INTERVAL
#   HUBOT_LIBERATION_ALERT_CHANNEL
#
# Author:
#   Paul Joannon <hello@pauljoannon.com>

request = require 'request'

ALERT_CHECK_INTERVAL = process.env.HUBOT_LIBERATION_ALERT_CHECK_INTERVAL or 5 * 60 * 1000 # 5 minutes
ALERT_CHANNEL = process.env.HUBOT_LIBERATION_ALERT_CHANNEL or 'general'
ALERT_BRAIN_KEY = 'liberation-alert'

module.exports = (robot) ->
    # Alert long polling
    do ->
        last_alert = null

        getFullUrl = (url) -> if url[0] isnt '/' then url else "http://www.liberation.fr#{url}"

        checkAlert = ->
            request 'http://www.liberation.fr/alert/?v=beta&ajax', (error, response, body) ->
                body = JSON.parse body
                if (Object.keys body).length > 0
                    body.id = ((body.url.match /_(\d+)\/?$/) or [])[1]
                    if body.id?
                        last_alert = body
                        if (not last_alert?) or (body.id isnt last_alert.id)
                            robot.messageRoom ALERT_CHANNEL, ":loudspeaker: *#{body.slug}* #{body.title} #{getFullUrl(body.url)}"
                    else
                        last_alert = null
                robot.brain.set ALERT_BRAIN_KEY, last_alert
                setTimeout checkAlert, ALERT_CHECK_INTERVAL
                null
            null

        # Retrieve from brain
        robot.brain.once 'loaded', -> last_alert = robot.brain.get ALERT_BRAIN_KEY

        # Initial call
        do checkAlert
        null
    null
