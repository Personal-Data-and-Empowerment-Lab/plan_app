class CalendarSourceSettingsViewItem {
  final String title;
  final String id;
  final DateTime lastUpdated;
  final bool isSetUp;
  bool isVisible;
  final bool isSyncing;
  final bool isSettingUp;

  CalendarSourceSettingsViewItem(this.title, this.id, this.lastUpdated,
      this.isSetUp, this.isVisible, this.isSyncing, this.isSettingUp);
}
