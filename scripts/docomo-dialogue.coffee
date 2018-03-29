# Description
#   A Hubot script that calls the docomo dialogue API
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_DOCOMO_DIALOGUE_P
#   HUBOT_DOCOMO_DIALOGUE_API_KEY
#
# Commands:
#   hubot 雑談 <message> - 雑談対話(docomo API)
#
# Author:
#   bouzuya <m@bouzuya.net>
#   Mako N <mako@pasero.net>
#
# License:
#   Copyright (c) 2014 bouzuya, Mako N
#   Released under the MIT license
#   http://opensource.org/licenses/mit-license.php
#
# Customized by:
#   knjcode
#


module.exports = (robot) ->
  status  = {}
  loaded = false

  # 会話の状態をredisに保存
  robot.brain.on "loaded", ->
    # "loaded" event is called every time robot.brain changed
    # data loading is needed only once after a reboot
    if !loaded
      try
        status = JSON.parse robot.brain.get "hubot-docomo-dialogue-status"
      catch error
        robot.logger.info("JSON parse error (reason: #{error})")
    loaded = true
    if !status
      status = {}

  robot.respond /(.+)$/i, (res) ->
    cmds = ['image', 'img', 'animate', 'soukoban', 'formula', 'jirou', 'jirou2']
    for help in robot.helpCommands()
      cmd = help.split(' ')[1]
      cmds.push cmd if cmds.indexOf(cmd) is -1
    cmd = res.match[1].replace(/:| |　/g,'<>').split('<>')[0]
    if res.match[0].indexOf('devops') != -1
      return
    if res.match[0].indexOf('DevOps') != -1
      return
    if res.match[0].indexOf('devop') != -1
      return
    if res.match[0].indexOf('Devops') != -1
      return
    return unless cmds.indexOf(cmd) == -1

    p = parseFloat(process.env.HUBOT_DOCOMO_DIALOGUE_P ? '0.3')
    return unless Math.random() < p
    message = res.match[1]
    return if message is ''

    username = res.message.user.name
    room     = res.message.room

    d = new Date
    now = d.getTime()

    if d.getDay() is 2
    # 火曜日は関西弁
      status["t"] = 20
    else
      status["t"] = ''

    robot
      .http('https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue')
      .query(APIKEY: process.env.HUBOT_DOCOMO_DIALOGUE_API_KEY)
      .header('Content-Type', 'application/json')
      .post(JSON.stringify({ utt: message, context: status[room], mode: status['mode'], t: status['t'] })) (err, response, body) ->
        if err?
          console.log "Encountered an error #{err}"
        else
          console.log body
          res.send JSON.parse(body).utt
          status =
            "time": now
            "mode": JSON.parse(body).mode
          status[room] = JSON.parse(body).context
          console.log "status:"+JSON.stringify(status)
