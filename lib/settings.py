from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Class to load settings from environment variables."""

    slack_signing_secret: str
    slack_bot_token: str
