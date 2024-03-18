#!/bin/bash

find . -type d -name "node_modules" -exec rm -rf {} +

find . -type d -name "target" -exec rm -rf {} +

echo "Cleanup complete!"
