#!/bin/bash
cd /Users/allen/DocLocal/HaveNWant/Factals
echo "=== Git Log - Last 32 commits ==="
git log --oneline -32
echo "=== Current Git Status ==="
git status --short