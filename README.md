# PHF Money Management App

Offline-first Flutter money management app built using Clean Architecture.
No backend, no internet dependency — all data is stored locally using **Hive**
(chosen instead of Drift/SQLite so it runs lightly in Chrome without Android
Studio or extra native setup).

## Features Completed (MVP "Must have")
- Accounts (create, edit, delete, list — Cash/Bank/Card/Wallet)
- Categories (default seeded + custom, income/expense)
- Transactions (add, edit, delete, list — income/expense with validation)
- Dashboard (total balance, monthly income/expense, recent transactions)

## Not Included Yet (documented honestly, per guide's "Known Issues" rule)
- Budgets ("Should have")
- Reports/charts ("Should have")
- Settings screen ("Should have")
- CSV/JSON export, PIN lock (Stretch)

## Tech Stack
Flutter, Riverpod (AsyncNotifier), Hive (local NoSQL storage), intl, uuid.

## Folder Structure (Clean Architecture)
```
lib/
  main.dart               # Hive init + app entry
  app/app_shell.dart       # Bottom navigation shell
  core/                    # theme, utils, widgets, errors (shared)
  data/local/hive_boxes.dart  # local database setup
  features/
    accounts/
      domain/    entities + repository interface
      data/      Hive repository implementation
      presentation/  providers (Riverpod) + pages
    categories/  (same structure)
    transactions/ (same structure)
    dashboard/   presentation only (derives data from the above)
```
Dependency direction follows the guide: Presentation → domain use-case-style
notifiers → domain repository interfaces → data repository implementations →
Hive local storage. The domain layer has zero Flutter/Hive imports.

## How to Run (Chrome, no Android Studio needed)
```bash
flutter pub get
flutter run -d chrome
```
That's it — no `build_runner`, no code generation, nothing else to install.

If `flutter run -d chrome` doesn't find Chrome automatically:
```bash
flutter devices        # confirm Chrome is listed
flutter run -d chrome --web-renderer html   # lighter renderer for low RAM
```

## How to Build a Release Web Build (optional, for submission)
```bash
flutter build web
```
Output goes to `build/web/` — this folder can be zipped or hosted anywhere
as your runnable build evidence.

## Manual QA Checklist (do this before submitting)
- [ ] App opens without crashing
- [ ] Default categories appear on first launch (only once)
- [ ] Can create an account
- [ ] Can add an income transaction
- [ ] Can add an expense transaction
- [ ] Dashboard total balance updates correctly
- [ ] Monthly income/expense are correct
- [ ] Data survives closing and reopening the browser tab (refresh page)
- [ ] Edit and delete work safely (account with transactions blocks delete)
- [ ] Empty states show when there's no data
- [ ] Form validation shows errors for invalid input

## Known Issues / Next Steps
- Budgets, Reports, and Settings screens are not yet built (planned next).
- No app lock / export yet (stretch items, deferred per priority order).
