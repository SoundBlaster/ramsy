#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test directories
TEST_ROOT="/tmp/ramsy_test"
TEST_PROJECT="$TEST_ROOT/project"
TEST_RAMDISK="/Volumes/RAMDisk_test_project"
TEST_LOG="$TEST_ROOT/test.log"

# Function to print test results
print_result() {
    local test_name=$1
    local status=$2
    local message=$3
    
    if [ "$status" = "pass" ]; then
        echo -e "${GREEN}✓ $test_name${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ $test_name${NC}"
        echo -e "${RED}  $message${NC}"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

# Function to clean up test environment
cleanup() {
    echo -e "${YELLOW}Cleaning up test environment...${NC}"
    
    # Kill any running ramsy processes
    pkill -f "ramsy.sh" || true
    
    # Unmount RAM disk if mounted
    if [ -d "$TEST_RAMDISK" ]; then
        diskutil unmount "$TEST_RAMDISK" > /dev/null 2>&1 || true
    fi
    
    # Remove test directories
    rm -rf "$TEST_ROOT"
}

# Set up trap for cleanup
trap cleanup EXIT

# Create test environment
echo -e "${YELLOW}Setting up test environment...${NC}"
mkdir -p "$TEST_PROJECT"
cd "$TEST_PROJECT"

# Initialize git repository
git init
echo "test file" > test.txt
git add test.txt
git commit -m "Initial commit"

# Create some test directories and files
mkdir -p node_modules/test
mkdir -p .idea
mkdir -p dist
touch .DS_Store
touch node_modules/test/module.js
touch .idea/workspace.xml
touch dist/bundle.js

# Test 1: Basic script execution
echo -e "${YELLOW}Running Test 1: Basic script execution${NC}"
if ../ramsy.sh &> "$TEST_LOG"; then
    print_result "Test 1" "pass" "Script executed successfully"
else
    print_result "Test 1" "fail" "Script failed to execute"
    exit 1
fi

# Wait for RAM disk to be mounted
sleep 5

# Test 2: RAM disk creation
echo -e "${YELLOW}Running Test 2: RAM disk creation${NC}"
if [ -d "$TEST_RAMDISK" ]; then
    print_result "Test 2" "pass" "RAM disk created successfully"
else
    print_result "Test 2" "fail" "RAM disk not created"
    exit 1
fi

# Test 3: File synchronization
echo -e "${YELLOW}Running Test 3: File synchronization${NC}"
echo "new content" > "$TEST_RAMDISK/test.txt"
sleep 2
if [ "$(cat test.txt)" = "new content" ]; then
    print_result "Test 3" "pass" "File changes synchronized correctly"
else
    print_result "Test 3" "fail" "File changes not synchronized"
fi

# Test 4: Git directory handling
echo -e "${YELLOW}Running Test 4: Git directory handling${NC}"
if [ -L "$TEST_RAMDISK/.git" ] && [ -d ".git" ]; then
    print_result "Test 4" "pass" "Git directory handled correctly"
else
    print_result "Test 4" "fail" "Git directory not handled correctly"
fi

# Test 5: Excluded directories
echo -e "${YELLOW}Running Test 5: Excluded directories${NC}"
if [ ! -d "$TEST_RAMDISK/node_modules" ] && [ ! -d "$TEST_RAMDISK/.idea" ] && [ ! -d "$TEST_RAMDISK/dist" ]; then
    print_result "Test 5" "pass" "Excluded directories not copied to RAM disk"
else
    print_result "Test 5" "fail" "Excluded directories were copied to RAM disk"
fi

# Test 6: Error handling
echo -e "${YELLOW}Running Test 6: Error handling${NC}"
# Try to run script again (should fail due to already mounted RAM disk)
if ! ../ramsy.sh &> "$TEST_LOG"; then
    print_result "Test 6" "pass" "Script correctly handled error condition"
else
    print_result "Test 6" "fail" "Script did not handle error condition"
fi

# Print final results
echo -e "\n${YELLOW}Test Results:${NC}"
echo -e "Tests Run: $TESTS_RUN"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"

# Exit with appropriate status
if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi 