# Contributing to XProc-Baseline

Thank you for your interest in XProc-Baseline! This document explains how to contribute and what we're looking for.

## Current Status

**Note**: XProc-Baseline is in beta development. The primary developer is Tomos Hillman, with a v1.0 target around June 2026. 
Feedback, bug reports, and documentation improvements are very welcome.

## How to Contribute

### Reporting Issues

Found a bug or have a feature request? Please open a GitHub issue with:

- **XProc processor** used (Calabash or Morgana, with version)
- **Minimal reproducible example** (a small pipeline or test config that fails)
- **Expected behavior** vs. actual behavior
- **Your XProc version** (3.0+)

### Documentation and Examples

We actively welcome:
- Clarifications to existing docs
- New examples in `docs/examples/` or `test/data/pipelines/`
- Corrections to typos or reference errors
- Blog posts or tutorials (link us!)

Simply fork, edit, and submit a pull request.

### Testing and Bug Fixes

Before submitting a pull request:

1. **Test with both Calabash and Morgana** 
2. **Add test cases** in the relevant subfolder of `src/test/` for any bug fix or new feature: see ["Writing Tests"](#writing-tests)
3. **Run the full test suite**: *(coming soon)*
4. **Update docs**

### Code Style and Conventions

- **XProc formatting**: Use 2-space indentation; use whitespace for readability
- **Naming**: Use descriptive names for ports, variables, and steps
- **Comments**: Include `<!-- -->` comments for non-obvious logic
- **Modularity**: Keep XProc steps focused and reusable
- **Error handling**: Catch and report errors with clear messages

### Commit messages

#### Commit Keywords

Use these standardized keywords as prefixes followed by a colon for commit messages and as folder names in branch naming:

- **feature**:
  A new feature or enhancement; a change to functionality
- **fix**
  A bug fix that resolves incorrect behavior
- **docs**
  Documentation changes only, including code comments and external documentation
- **test**
  Adding, updating, or fixing tests without changing production code; adding or updating Continuous Integration
- **tidy**
  Code cleanup, refactoring, or formatting changes that don't affect functionality
- **chore**
  Maintenance tasks, dependency updates, updating submodules, etc

### Writing Tests

We require unit tests for bug fixes and new features, and recommend writing the tests as an executable specification that defines the desired behaviour before writing the code itself.

#### BDD test labels

Behaviour-Driven Development (BDD) encourages the use of specific keywords.  This both enables a clear and consistent understanding of test reports, as well as encouraging behavioural test writing that promotes tests as an executable specification.

Use structures in your testing frameworks (e.g. `scenario` elements in XSpec) with the following labels, which may be nested and repeated:

- **WHEN**
  Describes the activity being tested. E.g. in XSLT, this might mean calling a named template, matching in a specific mode, or invoking a function.
- **GIVEN**
  Describes the input or initial context. In XSLT testing, this typically represents input XML or parameter values that establish preconditions.
- **EXPECT**
  Describes the expected result as either a test assertion, an output XML fragment, or an error condition.
  We use EXPECT rather than THEN because some frameworks may re-order labels when exporting JUnit reports: "EXPECT an error WHEN testing rules integration" reads better than "THEN throw an error WHEN testing rules integration".

#### TDD workflow:

Test-Driven Development (TDD) is a software development practice where tests are written before the implementation code:

1. Write the test - Define what you want the code to do (using clear GIVEN/WHEN/EXPECT labels and structures)
2. Run the test - Verify it fails (because the implementation doesn't exist yet)
3. Write the code - Implement the code to make the test pass
4. Run the test again - Verify it now passes

### Feature Requests

We're currently focused on core regression testing functionality.
Large feature requests are best discussed as GitHub issues first. The maintainer may suggest waiting until post-v1.0 for major new features.

## Pull Request Process

1. **Fork** the repository
2. **Create a branch**: `git checkout -b fix/my-fix` or `feature/my-feature`
3. **Commit with clear messages**: `Fix: baseline comparison for empty elements`
   - Try to keep the first line to 50 characters or fewer
   - Use the imperative mood
   - Add necessary context on subsequent lines
4. **Test thoroughly** (see Testing and Bug Fixes above)
5. **Submit a PR** with:
   - Description of what changed and why
   - Reference to any related issues
   - Confirmation that tests pass on both processors
6. **Respond to feedback** promptly

You may be required to update/rebase your branch from the latest `main` branch before your PR will be accepted/rebased.

The maintainer will review within 1–2 weeks.

## Licensing

By contributing to XProc-Baseline, you agree that your contributions will be licensed under the Apache License 2.0, and that, once merged, your contributions will become part of the copyrighted work.

You also agree that your contribution is your own original work, or that you have permission to contribute it, and that it doesn't violate anyone else's intellectual property rights.

You retain copyright to your original (un-merged) contribution.

### Contributing Attribution

You retain attribution rights, and significant contributions may be acknowleged in the NOTICE file.

Please include your name and a brief description of your contribution in your pull request if you wish this to be included.

Try to keep descriptions to a single line; if you feel that  you have made contributions in multiple contexts, list each as a separate line.

**Example Notice entry:**

```
Contributors:
 - John Doe: Reticulated Splines
 - Josephine Bloggs:
   - Documentation Review
   - Removed Herobrine
```

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](
https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
By participating, you agree to uphold its standards of respect and inclusion.

## Questions?

Feel free to open an issue or email tomos.hillman@oup.com with questions about contributing.

**Thank you for helping make XProc-Baseline better!**