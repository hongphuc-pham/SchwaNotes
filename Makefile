# Schwa Notes — common tasks.
#
# `make` is not installed by default on Windows. Either install it once:
#
#     winget install ezwinports.make
#
# or use the PowerShell twin of this file, which needs nothing installed:
#
#     .\make.ps1 ci
#
# The two must stay in step. If you change a recipe here, change it there.

# Every recipe runs inside app/, which is where the Flutter project lives.
APP := app

# Flutter is not on PATH in every shell (docs/PROGRESS.md §2). Point at the
# known-good install if the shell cannot find it, rather than failing obscurely.
FLUTTER := $(shell command -v flutter 2>/dev/null || echo /c/src/flutter/bin/flutter)
DART := $(shell command -v dart 2>/dev/null || echo /c/src/flutter/bin/dart)

# The emulator `flutter emulators` lists. Override for a different one:
#     make emulator EMULATOR=Pixel_7
EMULATOR ?= Pixel_9_Pro

.DEFAULT_GOAL := help
.PHONY: help setup gen l10n fmt fmt-check analyze licences migration-safety \
        test test-perf test-golden goldens-update test-unit test-widget \
        test-migration test-arch ci measure-scroll measure-startup \
        emulator devices run run-emulator apk aab clean doctor

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------- setting up

setup: ## Fetch packages and run every generator
	cd $(APP) && $(FLUTTER) pub get
	$(MAKE) gen l10n

gen: ## Run build_runner (riverpod, freezed, json, drift)
	# NOT --delete-conflicting-outputs: that flag was removed in build_runner 2.16.
	cd $(APP) && $(DART) run build_runner build

l10n: ## Regenerate lib/core/l10n/gen/ from app_en.arb
	cd $(APP) && $(FLUTTER) gen-l10n

# -------------------------------------------------------------------- checks

fmt: ## Format the code in place
	cd $(APP) && $(DART) format .

fmt-check: ## Fail if anything is unformatted (what CI runs)
	cd $(APP) && $(DART) format --output=none --set-exit-if-changed .

analyze: ## Static analysis, warnings and infos fatal
	cd $(APP) && $(FLUTTER) analyze --fatal-infos --fatal-warnings

licences: ## Fail on any non-permissive dependency licence (RULES §15)
	cd $(APP) && $(DART) run tool/check_licences.dart

migration-safety: ## Fail on destructive migration patterns (RULES §7)
	cd $(APP) && $(DART) run tool/check_migration_safety.dart

# --------------------------------------------------------------------- tests

test: ## Run the suite (everything except the timed measurements and the pictures)
	cd $(APP) && $(FLUTTER) test --exclude-tags "perf || golden"

test-perf: ## The wall-clock budgets, alone - see app/dart_test.yaml
	cd $(APP) && $(FLUTTER) test --tags perf -j 1

test-golden: ## The pictures of the UI - compare only; see test/flutter_test_config.dart
	cd $(APP) && $(FLUTTER) test --tags golden

goldens-update: ## Redraw the pictures after a deliberate UI change, then commit them
	cd $(APP) && $(FLUTTER) test --tags golden --update-goldens

test-unit: ## Unit tests only — domain, application, data, core
	cd $(APP) && $(FLUTTER) test test/unit

test-widget: ## Widget tests only
	cd $(APP) && $(FLUTTER) test test/widget

test-migration: ## Migration tests — blocking, never skip (RULES §29)
	cd $(APP) && $(FLUTTER) test test/migration

test-arch: ## The layer-boundary and grapheme rules (RULES §20, §21)
	cd $(APP) && $(FLUTTER) test test/architecture

# ------------------------------------------------- measurements, on a device
#
# Not part of `ci`: these need an emulator or a phone, and CI has neither.
# They print figures rather than asserting budgets - a software-GPU emulator
# is not a phone, so a gate here would either be meaningless or flaky.
# The figures go in docs/PROGRESS.md §5 with the machine named beside them.
#
# `flutter test -d <device>` cannot do this: it has no --profile, and debug
# frame times are inflated by assertions past the point of meaning.

measure-scroll: ## Frame times scrolling 5,000 words (profile; needs a device)
	cd $(APP) && $(FLUTTER) drive --driver=test_driver/integration_test.dart \
	  --target=integration_test/words_scroll_perf_test.dart --profile

measure-startup: ## Cold-start breakdown (profile; writes app/build/start_up_info.json)
	cd $(APP) && $(FLUTTER) run --profile --trace-startup

# The full gate, in CI's exact order. Run this before pushing.
ci: fmt-check licences migration-safety test-migration analyze test test-golden test-perf ## Everything CI runs, in order
	@echo "All checks passed."

# ------------------------------------------------------------------ the app

doctor: ## Flutter's own environment check
	$(FLUTTER) doctor -v

devices: ## List attached devices and running emulators
	$(FLUTTER) devices

emulator: ## Boot the Android emulator ($(EMULATOR)) and wait for it
	$(FLUTTER) emulators --launch $(EMULATOR)
	@echo "Booting $(EMULATOR). It can take a couple of minutes the first time."
	@echo "Watch with: make devices"

run: ## Run on whatever device is already attached
	cd $(APP) && $(FLUTTER) run

run-emulator: emulator ## Boot the emulator, then run the app on it
	@echo "Waiting for the emulator to finish booting..."
	adb wait-for-device shell 'while [ "$$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done'
	cd $(APP) && $(FLUTTER) run

# ------------------------------------------------------------------- builds

apk: ## Release APK
	cd $(APP) && $(FLUTTER) build apk --release

aab: ## Release App Bundle, for Play
	cd $(APP) && $(FLUTTER) build appbundle --release

clean: ## Remove build output
	cd $(APP) && $(FLUTTER) clean
