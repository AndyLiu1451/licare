// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Plant & Pet Log';

  @override
  String get plants => 'Plants';

  @override
  String get pets => 'Pets';

  @override
  String get reminders => 'Reminders';

  @override
  String get settings => 'Settings';

  @override
  String get knowledgeBase => 'Knowledge Base';

  @override
  String get myPlants => 'My Plants';

  @override
  String get myPets => 'My Pets';

  @override
  String get upcomingReminders => 'Upcoming Reminders';

  @override
  String get settingsAndData => 'Settings & Data';

  @override
  String get addPlant => 'Add Plant';

  @override
  String get addPet => 'Add Pet';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get addLogEntry => 'Add Log Entry';

  @override
  String get addNewEventType => 'Add New Type...';

  @override
  String get name => 'Name';

  @override
  String get nickname => 'Nickname';

  @override
  String get optional => '(Optional)';

  @override
  String get species => 'Species';

  @override
  String get breed => 'Breed';

  @override
  String get acquisitionDate => 'Acquisition Date';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get room => 'Location';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get unknown => 'Unknown';

  @override
  String get selectDate => '(Select Date)';

  @override
  String get selectTime => '(Select Time)';

  @override
  String get eventType => 'Event Type';

  @override
  String get selectEventType => 'Select Event Type *';

  @override
  String get customEventTypeHint => 'Enter custom event type *';

  @override
  String get eventTime => 'Event Time *';

  @override
  String get notes => 'Notes';

  @override
  String get addPhotos => 'Add Photos (Optional, max 5)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDeleteTitle => 'Confirm Delete?';

  @override
  String confirmDeleteContent(String itemName) {
    return 'Are you sure you want to delete \"$itemName\"? This action cannot be undone.';
  }

  @override
  String get deletePlantConfirmation => 'Are you sure you want to delete this plant? Related logs and reminders will also be deleted. This action cannot be undone.';

  @override
  String get deletePetConfirmation => 'Are you sure you want to delete this pet? Related logs and reminders will also be deleted. This action cannot be undone.';

  @override
  String deleteReminderConfirmation(String taskName) {
    return 'Are you sure you want to delete the task \"$taskName\"? This action cannot be undone.';
  }

  @override
  String deleteLogConfirmation(String eventType) {
    return 'Are you sure you want to delete this log entry for \"$eventType\"? This action cannot be undone.';
  }

  @override
  String deleteEventTypeConfirmation(String typeName) {
    return 'Are you sure you want to delete the event type \"$typeName\"? This action cannot be undone.';
  }

  @override
  String get noPlants => 'No plants added yet.\nTap the + button to add one!';

  @override
  String get noPets => 'No pets added yet.\nTap the + button to add one!';

  @override
  String get noReminders => 'No upcoming reminders.';

  @override
  String get noActiveReminders => 'No active reminders.';

  @override
  String get noOverdueReminders => 'No overdue reminders.';

  @override
  String get noInactiveReminders => 'No inactive reminders.';

  @override
  String get noRemindersFound => 'No reminders found matching criteria.';

  @override
  String get noLogs => 'No log entries yet.';

  @override
  String get noPhotos => 'No photos recorded yet.';

  @override
  String get noKnowledge => 'No knowledge content available.';

  @override
  String loadingFailed(String error) {
    return 'Loading failed: $error';
  }

  @override
  String get errorNotFound => 'Item not found.';

  @override
  String get errorInvalidData => 'Invalid data.';

  @override
  String errorSavingFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String errorDeletingFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get errorBackupFailed => 'Backup failed.';

  @override
  String get errorRestoreFailed => 'Restore failed or cancelled.';

  @override
  String errorExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String errorNameExists(String name) {
    return 'Error: Name \"$name\" already exists.';
  }

  @override
  String get plantDetails => 'Plant Details';

  @override
  String get petDetails => 'Pet Details';

  @override
  String get editPlant => 'Edit Plant';

  @override
  String get editPet => 'Edit Pet';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get editEventType => 'Edit Event Type';

  @override
  String get addEventType => 'Add New Event Type';

  @override
  String get appearance => 'Appearance';

  @override
  String get systemTheme => 'System Default';

  @override
  String get lightTheme => 'Light Mode';

  @override
  String get darkTheme => 'Dark Mode';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupDataDesc => 'Backup current data to selected location';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreDataDesc => 'Restore data from backup (overwrites current!)';

  @override
  String get exportLogs => 'Export Logs (CSV)';

  @override
  String get exportLogsDesc => 'Export log entries to a CSV file';

  @override
  String get learningHelp => 'Learning & Help';

  @override
  String get manageEventTypes => 'Manage Log Event Types';

  @override
  String get manageEventTypesDesc => 'Add, edit, or delete custom types';

  @override
  String get backupInProgress => 'Backing up...';

  @override
  String get backupSuccess => 'Backup successful! Saved to selected directory.';

  @override
  String get backupCancelled => 'Backup cancelled.';

  @override
  String get restoreConfirmTitle => 'Confirm Restore?';

  @override
  String get restoreConfirmDesc => 'This will overwrite ALL current data with the selected backup file!\n\n**Backup current data first if needed.**\n\nAfter successful restore, the app needs to be restarted.\n\nContinue?';

  @override
  String get restoreContinue => 'Continue Restore';

  @override
  String get restoreCancelled => 'Restore cancelled.';

  @override
  String get selectBackupFile => 'Please select backup file...';

  @override
  String get restoreSuccess => 'Restore successful! Please restart the app to load new data.';

  @override
  String get exportingLogs => 'Exporting logs...';

  @override
  String get noLogsToExport => 'No log data to export.';

  @override
  String get sort => 'Sort';

  @override
  String get filter => 'Filter';

  @override
  String get sortNameAsc => 'Name A-Z';

  @override
  String get sortNameDesc => 'Name Z-A';

  @override
  String get sortDateAddedAsc => 'Date Added (Oldest)';

  @override
  String get sortDateAddedDesc => 'Date Added (Newest)';

  @override
  String get sortDueDateAsc => 'Due Date (Earliest)';

  @override
  String get sortDueDateDesc => 'Due Date (Latest)';

  @override
  String get sortBirthDateAsc => 'Birth Date (Oldest)';

  @override
  String get sortBirthDateDesc => 'Birth Date (Newest)';

  @override
  String get filterAll => 'Show All';

  @override
  String get filterActiveOnly => 'Active Only';

  @override
  String get filterInactiveOnly => 'Inactive Only';

  @override
  String get filterOverdueOnly => 'Overdue Only';

  @override
  String get language => 'language';

  @override
  String get photoGallery => 'Photo Gallery';

  @override
  String get viewPhotoGallery => 'View Photo Gallery';

  @override
  String selectPhotos(int count) {
    return 'Select Photos ($count/2)';
  }

  @override
  String get compare => 'Compare';

  @override
  String get cancelSelection => 'Cancel Selection';

  @override
  String get maxPhotosSelected => 'Select up to 2 photos for comparison';

  @override
  String get growthComparison => 'Growth Comparison';

  @override
  String get viewFullScreen => 'View Full Screen (To be implemented)';

  @override
  String get errorLoadingImage => 'Cannot load image';

  @override
  String get knowledgeBaseDesc => 'Base knowledge description';

  @override
  String get search => 'search';

  @override
  String get markDone => 'Mark Done';

  @override
  String get toggleActiveOn => 'Activate Reminder';

  @override
  String get toggleActiveOff => 'Pause Reminder';

  @override
  String reminderCompleted(String taskName) {
    return 'Task \"$taskName\" completed!';
  }

  @override
  String reminderCompletedNext(String taskName) {
    return 'Task \"$taskName\" completed! Next due date updated.';
  }

  @override
  String markDoneFailed(String error) {
    return 'Mark done failed: $error';
  }

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get typeName => 'Type Name *';

  @override
  String get cannotDeletePreset => 'Cannot delete preset type.';

  @override
  String get confirmDeleteEventTypeTitle => 'Confirm Delete?';

  @override
  String get plantKnowledge => 'Plant Knowledge';

  @override
  String get petKnowledge => 'Pet Knowledge';

  @override
  String get topicNotFound => 'Topic content not found.';

  @override
  String loadingKnowledgeFailed(String error) {
    return 'Failed to load knowledge: $error';
  }

  @override
  String get watering => 'Watering';

  @override
  String get fertilizing => 'Fertilizing';

  @override
  String get repotting => 'Repotting';

  @override
  String get pruning => 'Pruning';

  @override
  String get lightChange => 'Light Change';

  @override
  String get pestControl => 'Pest Control';

  @override
  String get feeding => 'Feeding';

  @override
  String get medication => 'Medication';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get dewormingInternal => 'Internal Deworming';

  @override
  String get dewormingExternal => 'External Deworming';

  @override
  String get grooming => 'Grooming/Bath';

  @override
  String get weightRecord => 'Weight Record';

  @override
  String get behaviorObservation => 'Behavior Observation';

  @override
  String get vetVisit => 'Vet Visit';

  @override
  String get other => 'Other';
}
