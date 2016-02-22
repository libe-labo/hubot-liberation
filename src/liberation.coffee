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

        getFullUrl = (url) ->
            return url if url[0] isnt '/'
            return "http://www.liberation.fr#{body.url}"

        checkAlert = ->
            request 'http://www.liberation.fr/alert/?v=beta&ajax', (error, response, body) ->
                body = JSON.parse body
                if (Object.keys body).length > 0
                    if last_alert == null or (body.url isnt last_alert.url and body.title isnt last_alert.title)
                        last_alert = body
                        robot.messageRoom ALERT_CHANNEL, ":loudspeaker: *#{body.slug}* #{body.title} #{getFullUrl(body.url)}"
                else
                    last_alert = null
                robot.brain.set ALERT_BRAIN_KEY, last_alert
                setTimeout checkAlert, ALERT_CHECK_INTERVAL

        robot.brain.once 'loaded', -> last_alert = robot.brain.get ALERT_BRAIN_KEY

        # Initial call
        do checkAlert
