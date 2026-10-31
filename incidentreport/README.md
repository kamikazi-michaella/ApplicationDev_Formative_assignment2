# CampusHub

CampusHub is a Flutter incident-reporting app designed for Android. The
interface follows the supplied mockup and includes a searchable incident feed,
category and status filters, report details, and a four-step reporting flow.

## Run on Android

1. Install Flutter and Android Studio, then connect an Android device with USB
   debugging enabled or start an Android emulator.
2. From this folder, run:

   ```sh
   flutter pub get
   flutter run
   ```

3. Open **Report** to create a report. Add a category, description, building,
   and room or area. A photo is optional and can be selected from the Android
   photo picker.

## Current app behavior

The app uses sample incidents to demonstrate the feed and keeps newly submitted
reports in memory while the app is open. Connecting a campus server or adding
permanent user accounts and storage is not included.

Run the automated widget tests with `flutter test`.
