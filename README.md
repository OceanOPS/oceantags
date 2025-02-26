# flutter_application_1

A new Flutter project.

## Getting Started

- clone the repository

```bash
git clone https://github.com/OceanOPS/oceantags.git
```

- install dependencies

```bash
flutter pub get
```

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/to/resolution-aware-images).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter apps](https://flutter.dev/to/internationalization).

## Accessibiliy

Automatically scale text according to user preferences requiert to use `Theme.of(context).textTheme` each time the `style` attribut of a component need to be customised.
