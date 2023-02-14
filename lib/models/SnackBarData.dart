class SnackBarData {
  final String messageText;
  final String actionLabel;
  final Function onPressed;
  final int duration;

  SnackBarData(
      {this.messageText, this.actionLabel, this.onPressed, this.duration});

  bool hasActionData() {
    return this.actionLabel != null && this.onPressed != null;
  }

  @override
  String toString() {
    return messageText;
  }
}
