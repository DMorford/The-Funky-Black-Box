# Contributing Guidelines

## Welcome Contributors! 🎉

We're excited to have you contribute to our projects. This guide will help you get started with contributing, whether you're a human developer or an AI assistant.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Celebrate diverse perspectives

## How to Contribute

### For Human Developers

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Write or update tests**
5. **Update documentation**
6. **Submit a pull request**

### For AI Assistants (Claude Code, GitHub Copilot, etc.)

1. **Review existing code structure** before making changes
2. **Follow established patterns** in the codebase
3. **Include descriptive commit messages**
4. **Update relevant documentation**
5. **Add appropriate tests**
6. **Flag for human review** when making significant changes

## Development Process

### 1. Before Starting
- Check PROJECT_STATUS.md for current priorities
- Review existing issues and PRs
- Discuss major changes in issues first

### 2. Branch Naming Convention
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test improvements
- `chore/` - Maintenance tasks

### 3. Commit Message Format
```
type(scope): brief description

Longer explanation if needed.

Fixes #issue-number
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding missing tests
- `chore`: Changes to build process or auxiliary tools

### 4. Code Standards

#### Python Projects
- Follow PEP 8
- Use type hints
- Maximum line length: 100 characters
- Use Black for formatting
- Use pylint for linting

#### JavaScript Projects
- Follow ESLint configuration
- Use Prettier for formatting
- Prefer const over let
- Use async/await over promises
- Document with JSDoc

#### General
- Write self-documenting code
- Add comments for complex logic
- Keep functions small and focused
- Write unit tests for new features
- Ensure backward compatibility

## Testing Requirements

### Unit Tests
- Required for all new features
- Maintain or improve code coverage
- Test edge cases and error conditions

### Integration Tests
- Required for API changes
- Test interaction between components
- Verify external dependencies

### Performance Tests
- Required for performance-critical code
- Compare before and after metrics
- Document performance implications

## Documentation Standards

### Code Documentation
- All public APIs must be documented
- Include examples in docstrings
- Keep documentation up-to-date with code

### README Files
- Every project needs a comprehensive README
- Include installation instructions
- Provide usage examples
- List dependencies and requirements

### Inline Comments
- Explain "why" not "what"
- Document complex algorithms
- Note any workarounds or hacks

## Pull Request Process

1. **Ensure all tests pass**
2. **Update documentation**
3. **Request review from maintainers**
4. **Address review feedback**
5. **Squash commits if requested**
6. **Celebrate when merged! 🎉**

## AI-Human Collaboration

### Best Practices
- AI-generated code must be reviewed by humans
- Document when AI assistance was used
- Validate AI suggestions against requirements
- Test AI-generated code thoroughly

### Review Process
1. AI creates initial implementation
2. Human reviews for correctness and style
3. AI can address feedback
4. Human gives final approval

## Getting Help

### Resources
- Check documentation in `/docs` folder
- Review existing code for examples
- Ask questions in issues
- Use discussions for broader topics

### Contact
- Open an issue for bugs
- Start a discussion for features
- Tag maintainers for urgent items

## Recognition

Contributors are recognized in:
- Project README files
- Release notes
- Contributors page

## License

By contributing, you agree that your contributions will be licensed under the project's license.

---

Thank you for contributing! Your efforts help make these projects better for everyone. 🚀