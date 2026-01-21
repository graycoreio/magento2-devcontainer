# Contributing to Magento 2 DevContainer

We would love for you to contribute to Magento 2 DevContainer and help make it even better than it is today! As a contributor, here are the guidelines we would like you to follow:

- [Code of Conduct](#code-of-conduct)
- [Got a Question or Problem?](#got-a-question-or-problem)
- [Found a Bug?](#found-a-bug)
- [Missing a Feature?](#missing-a-feature)
- [Submission Guidelines](#submission-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)

## Code of Conduct

Help us keep this project open and inclusive. Please be respectful and constructive in all interactions.

## Got a Question or Problem?

Please do not open issues for general support questions. Instead:

- Check the [README](README.md) for documentation
- Review [Adobe's official system requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements)
- Open a [GitHub Discussion](https://github.com/graycoreio/magento2-devcontainer/discussions) for questions

## Found a Bug?

If you find a bug in the source code, you can help us by [submitting an issue](https://github.com/graycoreio/magento2-devcontainer/issues/new) to our GitHub Repository. Even better, you can submit a Pull Request with a fix.

## Missing a Feature?

You can request a new feature by [submitting an issue](https://github.com/graycoreio/magento2-devcontainer/issues/new) to our GitHub Repository.

If you would like to implement a new feature:

- **Major Features**: Open an issue first to discuss before investing significant effort
- **Minor Features**: Can be submitted directly as a Pull Request

## Submission Guidelines

### Submitting an Issue

Before you submit an issue, please search the issue tracker. An issue for your problem might already exist.

Please provide:
- Which Magento version you're targeting
- Steps to reproduce the issue
- Expected vs actual behavior
- Your Docker/OS environment details

### Submitting a Pull Request

Before you submit your Pull Request (PR), consider the following:

1. Search [GitHub](https://github.com/graycoreio/magento2-devcontainer/pulls) for an open or closed PR that relates to your submission.

2. Fork the repository.

3. Create your branch from the appropriate base:
   - `main` for changes to the latest Magento version
   - `dev-v2.4.x` for changes to a specific version branch

4. Make your changes.

5. Ensure your changes align with [Adobe's system requirements](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements).

6. Commit your changes using a descriptive commit message that follows our [commit message conventions](#commit-message-guidelines).

7. Push your branch to GitHub.

8. Create a Pull Request targeting the appropriate branch.

### AI Submission Guidelines

We welcome AI-assisted contributions, but all code must meet our quality standards:

- AI-generated code must be indistinguishable from well-written human code
- Review and understand all AI-generated content before submitting
- Ensure configurations are correct and tested
- Do not submit AI-generated content that you haven't verified

## Commit Message Guidelines

We follow a structured commit message format to maintain a readable history.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

Must be one of the following:

- **feat**: A new feature or version support
- **fix**: A bug fix
- **docs**: Documentation only changes
- **chore**: Maintenance tasks
- **refactor**: Code changes that neither fix a bug nor add a feature

### Scope

The scope should be the Magento version affected (e.g., `2.4.9`, `2.4.8`).

### Subject

- Use the imperative, present tense: "change" not "changed" nor "changes"
- Don't capitalize the first letter
- No period (.) at the end

### Examples

```
feat(2.4.9): add OpenSearch 3 support

fix(2.4.8): correct PHP version requirement

docs: update README with branching documentation
```
