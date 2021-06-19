# time_translation_slack
[![serverless](https://github.com/limit7412/time_translation_slack/actions/workflows/serverless-prod.yml/badge.svg?branch=master)](https://github.com/limit7412/time_translation_slack/actions/workflows/serverless-prod.yml)

unixtime、UTC、JSTを相互変換するslack向けslash command

```
> /time2unix unixtime
JST: 1970-01-01 09:00:00
UTC: 1970-01-01 00:00:00
```

```
> /time2unix yyyy-MM-dd HH:mm:ss [JST|UTC]
JST: 1970-01-01 09:00:00
UTC: 1970-01-01 00:00:00
unixtime: 0
```

## 設定
### env.yml
```
ALERT_WEBHOOK_URL: <アラート通知先slack webhook>
SLACK_ID: <アラート時メンション先slack id>
```
