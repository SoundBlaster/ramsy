# Ramsy Test Suite

This document describes the test suite for the Ramsy project.

## Test Script

The test suite is implemented in `test_ramsy.sh` and includes comprehensive testing of the Ramsy script functionality.

## Test Environment

The test suite creates a temporary environment in `/tmp/ramsy_test` with the following structure:
- Test project directory
- Git repository
- Test files
- Commonly excluded directories (node_modules, .idea, dist)
- System files (.DS_Store)

## Test Cases

### 1. Basic Script Execution
- **Purpose**: Verify that the script can be executed successfully
- **Test**: Run the script and check for successful execution
- **Expected**: Script executes without errors

### 2. RAM Disk Creation
- **Purpose**: Verify that the RAM disk is created correctly
- **Test**: Check if the RAM disk is mounted at the expected location
- **Expected**: RAM disk is mounted at `/Volumes/RAMDisk_test_project`

### 3. File Synchronization
- **Purpose**: Verify that file changes are synchronized correctly
- **Test**: 
  1. Create a test file
  2. Modify the file in the RAM disk
  3. Check if changes are reflected in the original location
- **Expected**: Changes are synchronized correctly

### 4. Git Directory Handling
- **Purpose**: Verify that Git directories are handled correctly
- **Test**: Check if:
  1. The .git directory is properly symlinked
  2. The original .git directory is preserved
- **Expected**: Git directory is symlinked and original is preserved

### 5. Excluded Directories
- **Purpose**: Verify that excluded directories are not copied to RAM disk
- **Test**: Check if common excluded directories (node_modules, .idea, dist) are not present in RAM disk
- **Expected**: Excluded directories are not copied to RAM disk

### 6. Error Handling
- **Purpose**: Verify that the script handles error conditions correctly
- **Test**: Try to run the script when RAM disk is already mounted
- **Expected**: Script fails gracefully with appropriate error message

## Running Tests

To run the test suite:

1. Make sure you're in the directory containing both `ramsy.sh` and `test_ramsy.sh`
2. Run `./test_ramsy.sh`

## Test Results

The test script provides:
- Colored output for better readability
- Test result tracking
- Automatic cleanup of test environment
- Detailed error messages
- Summary of passed/failed tests

Exit codes:
- 0: All tests passed
- 1: One or more tests failed

## Cleanup

The test suite includes automatic cleanup that:
- Kills any running Ramsy processes
- Unmounts the RAM disk
- Removes test directories 