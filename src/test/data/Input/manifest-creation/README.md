# Manifest Creation Sample Data

## Attribution

This sample data is taken from Florent George's [star-wars-dataset](https://github.com/fgeorges/star-wars-dataset).

It has been slightly tweaked to introduce levels of folders and zip archives.

## Purpose

The purpose is to test manifest creation from an existing source of folders and files, including zip archives.  This source will typically be generated as a result of an XProc pipeline.

The manifest produced may use a canonicalisation library to standardise certain text values that might vary from one invocation of the XProc pipeline being tested to the next.  This may include:

- Dates or timestamps, e.g.
  - 2014-12-22T18:21:15.606149Z
- GUIDs, e.g.
  - fa55dfd1-4663-4980-a0b3-be24547028fc