# Contributing to SmartBudget

Thank you for your interest in contributing to SmartBudget! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

Be respectful and constructive in all interactions with other contributors.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Create a new issue** on [GitHub](https://github.com/lwandotsomi-svg/smartbudget/issues) with:
   - Clear title describing the bug
   - Detailed description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Device/OS information
   - App version

### Suggesting Features

1. **Check existing issues** for similar suggestions
2. **Create a new issue** on [GitHub](https://github.com/lwandotsomi-svg/smartbudget/issues) with:
   - Clear title for the feature
   - Detailed description of the proposed feature
   - Use cases and benefits
   - Possible implementation suggestions

### Submitting Code Changes

1. **Fork the repository**
   ```bash
git clone https://github.com/lwandotsomi-svg/smartbudget.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow Dart/Flutter style guidelines
   - Add comments for complex logic
   - Keep commits focused and atomic
   - Add creator attribution comments for new files

4. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit with clear messages**
   ```bash
   git commit -m "feat: brief description of changes"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Provide clear description of changes
   - Reference any related issues
   - Include screenshots if UI changes

## Coding Guidelines

### Dart/Flutter Standards

- Follow [Dart Effective Dart](https://dart.dev/guides/language/effective-dart) guide
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions focused and manageable
- Use const constructors where possible

### File Structure

- Place new screens in `lib/screens/`
- Place new models in `lib/models/`
- Place new services in `lib/services/`
- Place new providers in `lib/providers/`
- Place reusable widgets in `lib/widgets/`

### File Headers

All new files should include a header comment:

```dart
/// [Feature Name]
/// 
/// Brief description of what this file does
/// Created by: [Your Name or Username]
/// 
/// Detailed explanation if needed
```

### Commits

Follow conventional commit format:

- `feat: add new feature`
- `fix: resolve bug`
- `refactor: improve code structure`
- `docs: update documentation`
- `test: add or update tests`
- `style: format code`

## Development Setup

### Requirements

- Flutter SDK >=3.0.0
- Dart >=3.0.0
- Android Studio or VS Code with Flutter extension

### Setup

```bash
# Clone repository
git clone https://github.com/lwandotsomi/smartbudget.git
cd smartbudget

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Testing

### Run Tests

```bash
flutter test
```

### Linting

```bash
flutter analyze
```

### Build for Release

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Pull Request Process

1. Update README.md with any new features or changes
2. Ensure all tests pass
3. Follow the pull request template
4. Wait for review and respond to feedback
5. Merge when approved

## Project Structure Guidelines

```
lib/
├── models/          # Data models
├── services/        # Business logic
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/           # Utility functions
```

## Attribution

Please add yourself as a contributor:
- Update code file headers with your name for new files
- Include attribution in any features you develop
- Add your name to contributors list if making significant contributions

## Questions?

- Create an issue on [GitHub](https://github.com/lwandotsomi-svg/smartbudget/issues) for questions
- Check existing documentation
- Review similar code in the project

## License

By contributing, you agree that your contributions will be licensed under the same MIT License as the project.

---

**Thank you for contributing to SmartBudget! \ud83d\ude4b**
