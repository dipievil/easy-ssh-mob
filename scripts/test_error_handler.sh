#!/bin/bash

# Test script for SSH error handling
# This script tests different error conditions

echo "=== Testing SSH Error Handler ==="

echo "1. Testing permission denied:"
echo "Permission denied" >&2

echo "2. Testing file not found:"
echo "No such file or directory" >&2

echo "3. Testing timeout:"
echo "Connection timed out" >&2

echo "4. Testing normal operation:"
echo "This is normal stdout output"

echo "Test completed!"