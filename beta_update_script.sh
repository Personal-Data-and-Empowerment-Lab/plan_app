#!/bin/zsh
# Changes to make when changes were just merged from dev
# 1) pull to make sure we didn't miss any changes
printf "git pull...\n"
git pull
printf "done\n"
# 2) flutter clean
#printf "fvm flutter clean...\n"
#fvm flutter clean
#printf "done\n"
# 3) flutter doctor to check for issues
printf "fvm flutter doctor...\n"
fvm flutter doctor
printf "done\n"
# 4) flutter pub get
printf "fvm flutter pub get...\n"
fvm flutter pub get
printf "done\n"
# 5) fvm flutter pub run build_runner build --delete-conflicting-outputs
printf "fvm flutter pub run build_runner build --delete-conflicting-outputs...\n"
printf "Note: This makes sure the current serialization settings will play nicely\n"
fvm flutter pub run build_runner build --delete-conflicting-outputs
printf "done\n"

# Other changes
# - switch "study version" to true when it's ready (right now - version 19 - it's not)
# switch logs directory to "study" from "dev" in FirebaseFileUploader.dart
# possibly switch back directory to "PHASE_2" to make sure our users stay in the right places?
# really not sure of the right way to handle this, maybe we'll just have to redo it once the
#   new storage method is ready
