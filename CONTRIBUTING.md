# Contributing to Zeilumara Time

First off, thank you for considering contributing to Zeilumara Time! It's people like you that make this project possible.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues as you might find that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps to reproduce the problem**
* **Provide specific examples** to demonstrate the steps
* **Describe the behavior you observed** and what you expected
* **Include screenshots** if relevant
* **Include your environment details**: iOS version, device model, app version

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a detailed description** of the suggested enhancement
* **Explain why this enhancement would be useful**
* **List any similar features** in other apps if applicable

### Pull Requests

1. Fork the repository
2. Create a new branch from `develop` (not `main`)
3. Make your changes
4. Add or update tests as needed
5. Ensure all tests pass
6. Update documentation if needed
7. Commit with clear, descriptive messages
8. Push to your fork
9. Submit a pull request to `develop`

#### Pull Request Guidelines

* **Follow the Swift style guide**
* **Include tests** for new features
* **Update documentation** for public APIs
* **Keep commits atomic** (one logical change per commit)
* **Write clear commit messages** (see below)

## Development Setup

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed setup instructions.

Quick start:
```bash
git clone https://github.com/your-username/zeilumara-ios.git
cd zeilumara-ios/swift_time
open ZeilumaraTime.xcodeproj
```

## Coding Conventions

### Swift Style

* Use 4 spaces for indentation (not tabs)
* Maximum line length: 120 characters
* Use SwiftUI for all UI components
* Follow Swift naming conventions:
  - `lowerCamelCase` for variables and functions
  - `UpperCamelCase` for types
  - `UPPER_SNAKE_CASE` for constants (rarely used)

### Code Organization

* Keep files under 500 lines
* One type per file (with related small types)
* Group related functionality
* Use MARK comments for organization:

```swift
// MARK: - Public API

// MARK: - Private Helpers

// MARK: - Constants
```

### Documentation

Document public APIs with Swift documentation comments:

```swift
/// Converts Zeilumara time components to human Date
///
/// - Parameter components: The Zeilumara time components
/// - Returns: The corresponding human Date
/// - Note: This uses the service's configured epoch
func toHumanDate(from components: ZeilumaraFullComponents) -> Date {
    // Implementation
}
```

### Testing

* Write unit tests for all business logic
* Aim for >80% code coverage in Services/
* Use descriptive test names:

```swift
func testRoundTripConversionPreservesOriginalDate() { }
func testGoddessAwakensAtDreamdiem0Reverloop6() { }
```

* Follow Arrange-Act-Assert pattern:

```swift
func testExample() {
    // Arrange (Given)
    let input = setupTestData()
    
    // Act (When)
    let result = performOperation(input)
    
    // Assert (Then)
    XCTAssertEqual(result, expected)
}
```

## Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

* `feat`: New feature
* `fix`: Bug fix
* `docs`: Documentation only
* `style`: Code style changes (formatting, etc.)
* `refactor`: Code refactoring
* `test`: Adding or updating tests
* `chore`: Maintenance tasks

### Examples

```
feat(clock): Add dual clock display with live updates

Implements the main clock view showing both Zeilumara and human time
simultaneously. Updates every second using Timer.publish.

Closes #42
```

```
fix(conversion): Correct lumibeat calculation in toZeilumaraTime

The previous implementation didn't account for truncation when
converting total yaon to lumibeat. This fixes round-trip conversion
accuracy.

Fixes #56
```

```
test(conversion): Add edge case tests for negative time values

Adds tests for dates before the epoch to ensure proper handling
of negative time values.
```

## Branch Naming

* `feature/description` - New features
* `fix/description` - Bug fixes
* `docs/description` - Documentation updates
* `refactor/description` - Code refactoring

Examples:
* `feature/add-calendar-view`
* `fix/notification-scheduling-bug`
* `docs/update-readme-installation`

## Release Process

1. Version bump in project settings
2. Update CHANGELOG.md
3. Merge to `main` from `develop`
4. Tag release: `git tag v1.2.0`
5. Push tags: `git push --tags`
6. Create GitHub release
7. Deploy to TestFlight/App Store

## Questions?

Feel free to open an issue with the `question` label, or reach out to the maintainers.

---

Thank you for contributing to Zeilumara Time! 🌌
