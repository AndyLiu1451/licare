import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Plant & Pet Log'**
  String get appTitle;

  /// No description provided for @plants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get plants;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @knowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeBase;

  /// No description provided for @myPlants.
  ///
  /// In en, this message translates to:
  /// **'My Plants'**
  String get myPlants;

  /// No description provided for @myPets.
  ///
  /// In en, this message translates to:
  /// **'My Pets'**
  String get myPets;

  /// No description provided for @upcomingReminders.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Reminders'**
  String get upcomingReminders;

  /// No description provided for @settingsAndData.
  ///
  /// In en, this message translates to:
  /// **'Settings & Data'**
  String get settingsAndData;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add Plant'**
  String get addPlant;

  /// No description provided for @addPet.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get addPet;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @addLogEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Log Entry'**
  String get addLogEntry;

  /// No description provided for @addNewEventType.
  ///
  /// In en, this message translates to:
  /// **'Add New Type...'**
  String get addNewEventType;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @acquisitionDate.
  ///
  /// In en, this message translates to:
  /// **'Acquisition Date'**
  String get acquisitionDate;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get room;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'(Select Date)'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'(Select Time)'**
  String get selectTime;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @selectEventType.
  ///
  /// In en, this message translates to:
  /// **'Select Event Type *'**
  String get selectEventType;

  /// No description provided for @customEventTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter custom event type *'**
  String get customEventTypeHint;

  /// No description provided for @eventTime.
  ///
  /// In en, this message translates to:
  /// **'Event Time *'**
  String get eventTime;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos (Optional, max 5)'**
  String get addPhotos;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete?'**
  String get confirmDeleteTitle;

  /// Confirmation message for deleting an item.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{itemName}\"? This action cannot be undone.'**
  String confirmDeleteContent(String itemName);

  /// No description provided for @deletePlantConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plant? Related logs and reminders will also be deleted. This action cannot be undone.'**
  String get deletePlantConfirmation;

  /// No description provided for @deletePetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this pet? Related logs and reminders will also be deleted. This action cannot be undone.'**
  String get deletePetConfirmation;

  /// No description provided for @deleteReminderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the task \"{taskName}\"? This action cannot be undone.'**
  String deleteReminderConfirmation(String taskName);

  /// No description provided for @deleteLogConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this log entry for \"{eventType}\"? This action cannot be undone.'**
  String deleteLogConfirmation(String eventType);

  /// No description provided for @deleteEventTypeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the event type \"{typeName}\"? This action cannot be undone.'**
  String deleteEventTypeConfirmation(String typeName);

  /// No description provided for @noPlants.
  ///
  /// In en, this message translates to:
  /// **'No plants added yet.\nTap the + button to add one!'**
  String get noPlants;

  /// No description provided for @noPets.
  ///
  /// In en, this message translates to:
  /// **'No pets added yet.\nTap the + button to add one!'**
  String get noPets;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reminders.'**
  String get noReminders;

  /// No description provided for @noActiveReminders.
  ///
  /// In en, this message translates to:
  /// **'No active reminders.'**
  String get noActiveReminders;

  /// No description provided for @noOverdueReminders.
  ///
  /// In en, this message translates to:
  /// **'No overdue reminders.'**
  String get noOverdueReminders;

  /// No description provided for @noInactiveReminders.
  ///
  /// In en, this message translates to:
  /// **'No inactive reminders.'**
  String get noInactiveReminders;

  /// No description provided for @noRemindersFound.
  ///
  /// In en, this message translates to:
  /// **'No reminders found matching criteria.'**
  String get noRemindersFound;

  /// No description provided for @noLogs.
  ///
  /// In en, this message translates to:
  /// **'No log entries yet.'**
  String get noLogs;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos recorded yet.'**
  String get noPhotos;

  /// No description provided for @noKnowledge.
  ///
  /// In en, this message translates to:
  /// **'No knowledge content available.'**
  String get noKnowledge;

  /// No description provided for @loadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Loading failed: {error}'**
  String loadingFailed(String error);

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found.'**
  String get errorNotFound;

  /// No description provided for @errorInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Invalid data.'**
  String get errorInvalidData;

  /// No description provided for @errorSavingFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String errorSavingFailed(String error);

  /// No description provided for @errorDeletingFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String errorDeletingFailed(String error);

  /// No description provided for @errorBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed.'**
  String get errorBackupFailed;

  /// No description provided for @errorRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed or cancelled.'**
  String get errorRestoreFailed;

  /// No description provided for @errorExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String errorExportFailed(String error);

  /// No description provided for @errorNameExists.
  ///
  /// In en, this message translates to:
  /// **'Error: Name \"{name}\" already exists.'**
  String errorNameExists(String name);

  /// No description provided for @plantDetails.
  ///
  /// In en, this message translates to:
  /// **'Plant Details'**
  String get plantDetails;

  /// No description provided for @petDetails.
  ///
  /// In en, this message translates to:
  /// **'Pet Details'**
  String get petDetails;

  /// No description provided for @editPlant.
  ///
  /// In en, this message translates to:
  /// **'Edit Plant'**
  String get editPlant;

  /// No description provided for @editPet.
  ///
  /// In en, this message translates to:
  /// **'Edit Pet'**
  String get editPet;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @editEventType.
  ///
  /// In en, this message translates to:
  /// **'Edit Event Type'**
  String get editEventType;

  /// No description provided for @addEventType.
  ///
  /// In en, this message translates to:
  /// **'Add New Event Type'**
  String get addEventType;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkTheme;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @backupDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup current data to selected location'**
  String get backupDataDesc;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @restoreDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore data from backup (overwrites current!)'**
  String get restoreDataDesc;

  /// No description provided for @exportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export Logs (CSV)'**
  String get exportLogs;

  /// No description provided for @exportLogsDesc.
  ///
  /// In en, this message translates to:
  /// **'Export log entries to a CSV file'**
  String get exportLogsDesc;

  /// No description provided for @learningHelp.
  ///
  /// In en, this message translates to:
  /// **'Learning & Help'**
  String get learningHelp;

  /// No description provided for @manageEventTypes.
  ///
  /// In en, this message translates to:
  /// **'Manage Log Event Types'**
  String get manageEventTypes;

  /// No description provided for @manageEventTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or delete custom types'**
  String get manageEventTypesDesc;

  /// No description provided for @backupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Backing up...'**
  String get backupInProgress;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup successful! Saved to selected directory.'**
  String get backupSuccess;

  /// No description provided for @backupCancelled.
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled.'**
  String get backupCancelled;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite ALL current data with the selected backup file!\n\n**Backup current data first if needed.**\n\nAfter successful restore, the app needs to be restarted.\n\nContinue?'**
  String get restoreConfirmDesc;

  /// No description provided for @restoreContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Restore'**
  String get restoreContinue;

  /// No description provided for @restoreCancelled.
  ///
  /// In en, this message translates to:
  /// **'Restore cancelled.'**
  String get restoreCancelled;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Please select backup file...'**
  String get selectBackupFile;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore successful! Please restart the app to load new data.'**
  String get restoreSuccess;

  /// No description provided for @exportingLogs.
  ///
  /// In en, this message translates to:
  /// **'Exporting logs...'**
  String get exportingLogs;

  /// No description provided for @noLogsToExport.
  ///
  /// In en, this message translates to:
  /// **'No log data to export.'**
  String get noLogsToExport;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name Z-A'**
  String get sortNameDesc;

  /// No description provided for @sortDateAddedAsc.
  ///
  /// In en, this message translates to:
  /// **'Date Added (Oldest)'**
  String get sortDateAddedAsc;

  /// No description provided for @sortDateAddedDesc.
  ///
  /// In en, this message translates to:
  /// **'Date Added (Newest)'**
  String get sortDateAddedDesc;

  /// No description provided for @sortDueDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Due Date (Earliest)'**
  String get sortDueDateAsc;

  /// No description provided for @sortDueDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Due Date (Latest)'**
  String get sortDueDateDesc;

  /// No description provided for @sortBirthDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Birth Date (Oldest)'**
  String get sortBirthDateAsc;

  /// No description provided for @sortBirthDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Birth Date (Newest)'**
  String get sortBirthDateDesc;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get filterAll;

  /// No description provided for @filterActiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Active Only'**
  String get filterActiveOnly;

  /// No description provided for @filterInactiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Inactive Only'**
  String get filterInactiveOnly;

  /// No description provided for @filterOverdueOnly.
  ///
  /// In en, this message translates to:
  /// **'Overdue Only'**
  String get filterOverdueOnly;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo Gallery'**
  String get photoGallery;

  /// No description provided for @viewPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'View Photo Gallery'**
  String get viewPhotoGallery;

  /// No description provided for @selectPhotos.
  ///
  /// In en, this message translates to:
  /// **'Select Photos ({count}/2)'**
  String selectPhotos(int count);

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel Selection'**
  String get cancelSelection;

  /// No description provided for @maxPhotosSelected.
  ///
  /// In en, this message translates to:
  /// **'Select up to 2 photos for comparison'**
  String get maxPhotosSelected;

  /// No description provided for @growthComparison.
  ///
  /// In en, this message translates to:
  /// **'Growth Comparison'**
  String get growthComparison;

  /// No description provided for @viewFullScreen.
  ///
  /// In en, this message translates to:
  /// **'View Full Screen (To be implemented)'**
  String get viewFullScreen;

  /// No description provided for @errorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Cannot load image'**
  String get errorLoadingImage;

  /// No description provided for @knowledgeBaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Base knowledge description'**
  String get knowledgeBaseDesc;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'search'**
  String get search;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Done'**
  String get markDone;

  /// No description provided for @toggleActiveOn.
  ///
  /// In en, this message translates to:
  /// **'Activate Reminder'**
  String get toggleActiveOn;

  /// No description provided for @toggleActiveOff.
  ///
  /// In en, this message translates to:
  /// **'Pause Reminder'**
  String get toggleActiveOff;

  /// No description provided for @reminderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task \"{taskName}\" completed!'**
  String reminderCompleted(String taskName);

  /// No description provided for @reminderCompletedNext.
  ///
  /// In en, this message translates to:
  /// **'Task \"{taskName}\" completed! Next due date updated.'**
  String reminderCompletedNext(String taskName);

  /// No description provided for @markDoneFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark done failed: {error}'**
  String markDoneFailed(String error);

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @typeName.
  ///
  /// In en, this message translates to:
  /// **'Type Name *'**
  String get typeName;

  /// No description provided for @cannotDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete preset type.'**
  String get cannotDeletePreset;

  /// No description provided for @confirmDeleteEventTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete?'**
  String get confirmDeleteEventTypeTitle;

  /// No description provided for @plantKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Plant Knowledge'**
  String get plantKnowledge;

  /// No description provided for @petKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Pet Knowledge'**
  String get petKnowledge;

  /// No description provided for @topicNotFound.
  ///
  /// In en, this message translates to:
  /// **'Topic content not found.'**
  String get topicNotFound;

  /// No description provided for @loadingKnowledgeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load knowledge: {error}'**
  String loadingKnowledgeFailed(String error);

  /// No description provided for @watering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get watering;

  /// No description provided for @fertilizing.
  ///
  /// In en, this message translates to:
  /// **'Fertilizing'**
  String get fertilizing;

  /// No description provided for @repotting.
  ///
  /// In en, this message translates to:
  /// **'Repotting'**
  String get repotting;

  /// No description provided for @pruning.
  ///
  /// In en, this message translates to:
  /// **'Pruning'**
  String get pruning;

  /// No description provided for @lightChange.
  ///
  /// In en, this message translates to:
  /// **'Light Change'**
  String get lightChange;

  /// No description provided for @pestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest Control'**
  String get pestControl;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @dewormingInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal Deworming'**
  String get dewormingInternal;

  /// No description provided for @dewormingExternal.
  ///
  /// In en, this message translates to:
  /// **'External Deworming'**
  String get dewormingExternal;

  /// No description provided for @grooming.
  ///
  /// In en, this message translates to:
  /// **'Grooming/Bath'**
  String get grooming;

  /// No description provided for @weightRecord.
  ///
  /// In en, this message translates to:
  /// **'Weight Record'**
  String get weightRecord;

  /// No description provided for @behaviorObservation.
  ///
  /// In en, this message translates to:
  /// **'Behavior Observation'**
  String get behaviorObservation;

  /// No description provided for @vetVisit.
  ///
  /// In en, this message translates to:
  /// **'Vet Visit'**
  String get vetVisit;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
