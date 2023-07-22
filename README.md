# Drizzle 💧

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A simple package to persist and query small dataset of data.

__Still heavily in development__ so Documentation will be written later. So for now check the [example](./example) on how to use the API. Better documentation may be written later.

## Motivation

During the some of the development of my games, I find myself in need of persisting and manipulating
small dataset of data.

Flutter/Dart have great database packages, but they always felt too much for what I needed, while
when just using `shared_preferences`, I found myself doing the same manual manipulation over and
over again. So I felt that I could build some in between.

Drizzle is based on the three pillars:

 - It is meant for small sets of data.
 - It keeps all the data in memory, and persist them in the background
 - It allow for persistence to be configured

As one can note, Drizzle was born to solve a very specific user case, so if you found it while
searching for a more complete and general use data persistence package for flutter/dart, I really
recommend trying one of the followings:

 - [ObjectBox](https://pub.dev/packages/objectbox)
 - [Isar](https://pub.dev/packages/isar)
 - [Hive](https://pub.dev/packages/hive)

## Installation 💻

**❗ In order to start using Drizzle you must have the [Dart SDK][dart_install_link] installed on your machine.**

Add `drizzle` to your `pubspec.yaml`:

```yaml
dependencies:
  drizzle:
```

Install it:

```sh
dart pub get
```

---

## Continuous Integration 🤖

Drizzle comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.2.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
