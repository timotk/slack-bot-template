def is_im_message(event: dict) -> bool:
    """Check if the event is a direct message."""
    return event.get("channel_type") == "im"
