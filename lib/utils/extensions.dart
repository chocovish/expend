// ignore_for_file: unnecessary_this

extension DateFormat on DateTime {
  String toHumanDate() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
