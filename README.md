# XProc-Baseline

XProc-Baseline is a framework for automating regression testing of XProc pipelines and file-based workflows. Rather than comparing binary outputs directly, XProc-Baseline uses **manifest-based comparison with configurable canonicalization** to handle non-deterministic content like timestamps, UUIDs, and generated identifiers.

Built for XProc 3.0+, XProc-Baseline works across different XProc engines (Calabash, Morgana) and integrates seamlessly with modern CI/CD platforms.

## Quick Start

1. Write your test definition
  - Use `src/main/schema/xproc-baseline.rnc` for validation
  - See `test/baseline/swtest.xml` for a simple example
2. Generate your test-harness by providing your test definition as an input to `src/main/xproc/Baseline.xpl`
3. Generate baseline manifests by running the `b:update-manifest` step in your newly created test-harness.
  - This will update your test definition file
  - This step is only required when the baseline (i.e. the expected output) is created or changed.
4. Run your test suite by providing the test definition to your newly created test harness XProc.

## The Problem

Real-world XProc pipelines do far more than transform data. They orchestrate file operations, create deliverables, manage archives, and produce outputs with non-deterministic content. Testing these systems end-to-end has proven difficult:

- **File and archive management**: Validating ZIP creation, nested archives, and complex directory structures
- **Non-deterministic content**: Timestamps, UUIDs, and generated identifiers change with each run
- **Configurable canonicalization**: Different projects need different rules for what to strip, normalize, or transform
- **Engine portability**: Tests must run on the same processors (Calabash, Morgana) that production pipelines use
- **CI/CD integration**: Machine-readable output and clear reporting for automated build systems

Existing tools like **XSpec** are excellent for unit testing XSLT and individual transformations, but they don't address workflow- and artifact-level testing. XProc-Baseline complements XSpec by handling pipeline-level regression testing.

## Status & Future

XProc-Baseline is copyright 2026 Oxford University Press.  It is Open Source under the Apache 2 License. 

Feedback, bug reports, and documentation improvements are very welcome, and can be made by Pull Request.  See CONTRIBUTING.md for further details.

**Current focus**:
- Baseline comparison and human readable reporting for XProc 3.0 pipelines running on Calabash and Morgana
- Documentation
- Testing 

## Core Approach

### Manifest-Based Comparison

Instead of comparing raw ZIP files or file trees, XProc-Baseline generates **canonicalized manifests** that describe the structure and content of outputs:

- File paths and directory structures
- Content hashes of file contents
- Metadata (size, MIME type, etc.)

Manifests are text-based and version-control friendly, enabling code review of baseline changes and clear audit trails.

### Configurable Canonicalization

A framework that allows teams to define rules for handling non-deterministic content:

- Strip or remove fields entirely (timestamps, UUIDs, generated IDs)
- Normalize fields using pattern matching and replacement
- Handle both XML and binary content
- Support per-project and per-test customization through custom XProc steps

### Test Specifications

Testing is defined using a specification file format that describes:

- The pipeline to be tested
- Canonicalization process (as a pipeline step)
- Input sources for each test
- The baseline, or expected output, for each test

XProc-Baseline generates a testing pipeline from this specification, eliminating boilerplate and making tests easy to maintain.

### Engine-Agnostic Design

Built using standard XProc 3.0+, XProc-Baseline aims to work across different XProc engines and projects without modification.

