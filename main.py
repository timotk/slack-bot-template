from flask import Request
from slack_bolt import App, Say
from slack_bolt.adapter.flask import SlackRequestHandler

from lib.settings import Settings
from lib.utils import is_im_message

settings = Settings()
app = App(
    token=settings.slack_bot_token,
    signing_secret=settings.slack_signing_secret,
    raise_error_for_unhandled_request=True,
)


handler = SlackRequestHandler(app)


@app.event("app_mention")
@app.event("message", matchers=[is_im_message])
def mention(say: Say, event: dict):
    user = event["user"]
    text = event["text"]
    say(f"Hi <@{user}>! You said: {text}")


def main(request: Request):
    return handler.handle(request)
