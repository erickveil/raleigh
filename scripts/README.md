# Build Scripts

This directory contains build and development scripts for the Raleigh project.

## Scripts

### `dev_win.ps1` - Quick Development Setup
Fastest way to get up and running for local development.

```powershell
.\scripts\dev_win.ps1
```

**What it does:**
1. Installs dependencies (`flutter pub get`)
2. Generates code (Hive adapters via `build_runner`)
3. Starts the app in debug mode (`flutter run`)

**Use this when:**
- Starting development after cloning the repo
- You just want to run the app locally
- Making changes and testing

### `build_win.ps1` - Full Windows Build
Comprehensive build script for preparing the app for distribution or final testing.

```powershell
# Standard build
.\scripts\build_win.ps1

# Build and run
.\scripts\build_win.ps1 -Run

# Clean build (removes all artifacts)
.\scripts\build_win.ps1 -Clean

# Clean and run
.\scripts\build_win.ps1 -Clean -Run
```

**Options:**
- `-Run` - Also launch the app after building
- `-Clean` - Remove all build artifacts before building

**What it does:**
1. (Optional) Cleans build artifacts
2. Installs dependencies
3. Generates code
4. Builds release-ready Windows binary
5. (Optional) Launches the app

**Use this when:**
- Creating a production build
- Testing the final binary
- Need a clean build to ensure everything works
- Preparing for distribution

### `build_android.js` - Full Android Build
Builds a release-signed APK for distribution. Passwords are kept out of the script — signing config is read from an external `key.properties` file.

```bash
node scripts\build_android.js
```

**Configuration:**
Edit the `KEYSTORE_DIR` variable at the top of the script (line 37).
Change it to whichever directory has the keystore you want to use.
Each directory is expected to contain a `key.properties` + `.jks` pair:

```
C:\AndroidPlayStore\
├── Dummy\
    ├── key.properties       ← storePassword, keyPassword, keyAlias, storeFile
    └── dummy-keystore.jks
```

The script reads `key.properties` from `KEYSTORE_DIR`, copies it into
`android\key.properties` at build time, and the `.jks` path inside it
points to the matching keystore. The whole setup lives outside the repo
so credentials never get committed.

**What it does:**
1. Regenerates Android launcher icons
2. Removes stale `build\app` artifacts
3. Copies signing config from `KEY_PROPERTIES_SOURCE` to `android\key.properties`
4. Builds a release-signed APK (`flutter build apk --release`)
5. Copies the APK to `scripts\deploy\raleigh-v<version>.apk`

**Use this when:**
- Creating a signed production APK for sideloading or store upload

## PowerShell Execution Policy

If you get an "execution policy" error, you can run scripts with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\dev_win.ps1
```

Or set it permanently:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Why These Scripts?

The Flutter/Dart build process requires several steps:
- `flutter pub get` - fetch dependencies
- `dart run build_runner build` - generate `.g.dart` files for Hive
- `flutter build/run` - build or run the app

These scripts automate those steps so you don't have to remember them.
