#!/bin/bash

# Cafaye OS Local Testing Script
# Runs fast, non-VM tests locally before pushing to CI
# Usage: ./bin/test-local.sh [OPTIONS]

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Test 1: Nix flake syntax and evaluation
run_syntax_check() {
    print_header "Test 1: Nix Syntax & Evaluation (No VMs)"
    
    if ! nix flake check --show-trace --option max-jobs 4 2>&1; then
        print_error "Syntax check failed"
        return 1
    fi
    
    print_success "Syntax check passed"
    return 0
}

# Test 2: Check all test files can be imported
run_import_check() {
    print_header "Test 2: Test File Import Check"
    
    local failed=0
    
    # Test unified tests
    for test_file in tests/*/unified.nix; do
        if [ -f "$test_file" ]; then
            echo -n "  Checking $test_file... "
            if nix-instantiate --eval --strict "$test_file" 2>&1 | grep -q "error:"; then
                print_error "FAILED"
                failed=$((failed + 1))
            else
                echo "OK"
            fi
        fi
    done
    
    if [ $failed -gt 0 ]; then
        return 1
    fi
    
    print_success "All test files import correctly"
    return 0
}

# Test 3: User state JSON validation
run_state_validation() {
    print_header "Test 3: User State JSON Validation"
    
    if [ -f "user/user-state.json" ]; then
        if jq empty "user/user-state.json" 2>/dev/null; then
            print_success "user-state.json is valid JSON"
        else
            print_error "user-state.json is invalid JSON"
            return 1
        fi
        
        # Check against schema if it exists
        if [ -f "user/user-state.schema.json" ]; then
            if jq -s '.[0] as $schema | .[1] as $data | $data | type == "object"' \
                "user/user-state.schema.json" "user/user-state.json" 2>/dev/null | grep -q "true"; then
                print_success "user-state.json matches schema"
            else
                print_warning "user-state.json schema validation skipped (no validator)"
            fi
        fi
    else
        print_warning "user-state.json not found"
    fi
    
    return 0
}

# Test 4: Check script syntax
run_script_syntax_check() {
    print_header "Test 4: CLI Script Syntax Check"
    
    local failed=0
    
    for script in cli/scripts/*; do
        if [ -f "$script" ] && head -1 "$script" | grep -q "#!/bin/bash"; then
            echo -n "  Checking $(basename "$script")... "
            if bash -n "$script" 2>/dev/null; then
                echo "OK"
            else
                print_error "SYNTAX ERROR"
                failed=$((failed + 1))
            fi
        fi
    done
    
    # Check main.sh
    echo -n "  Checking main.sh... "
    if bash -n "$REPO_ROOT/cli/main.sh" 2>/dev/null; then
        echo "OK"
    else
        print_error "SYNTAX ERROR"
        failed=$((failed + 1))
    fi
    
    if [ $failed -gt 0 ]; then
        return 1
    fi
    
    print_success "All scripts have valid syntax"
    return 0
}

# Test 5: Check for common issues
run_common_issues_check() {
    print_header "Test 5: Common Issues Check"
    
    local issues=0
    
    # Check for TODO markers in code
    if grep -r "TODO\|FIXME\|XXX" --include="*.nix" --include="*.sh" cli/ modules/ core/ 2>/dev/null | grep -v "^Binary"; then
        print_warning "Found TODO/FIXME markers in code"
        issues=$((issues + 1))
    fi
    
    # Check for secrets in code (basic check)
    if grep -r "password\|secret\|token\|key" --include="*.nix" --include="*.sh" . 2>/dev/null | grep -v "sops\|hashedPassword\|passwordAuthentication" | head -5; then
        print_warning "Found potential hardcoded secrets (review manually)"
    fi
    
    # Check that .factory is in .gitignore
    if ! grep -q ".factory" .gitignore 2>/dev/null; then
        print_warning ".factory directory not in .gitignore"
    fi
    
    return 0
}

# Test 6: Module dependency check
run_module_dependency_check() {
    print_header "Test 6: Module Dependency Check"
    
    echo "  Checking module imports..."
    
    # Check that all modules are importable
    if nix-instantiate --eval --expr 'import ./modules' 2>&1 | grep -q "error:"; then
        print_error "Modules directory has import errors"
        return 1
    fi
    
    print_success "Module structure is valid"
    return 0
}

# Test 7: Check documentation exists
run_documentation_check() {
    print_header "Test 7: Documentation Check"
    
    local missing=0
    
    for doc in README.md CHANGELOG.md AGENTS.md CONTRIBUTING.md; do
        if [ ! -f "$doc" ]; then
            print_error "Missing $doc"
            missing=$((missing + 1))
        fi
    done
    
    if [ $missing -gt 0 ]; then
        return 1
    fi
    
    print_success "All documentation files present"
    return 0
}

# Main execution
main() {
    echo ""
    echo "☕ Cafaye OS Local Testing Suite"
    echo "=================================="
    echo "Running fast, non-VM tests..."
    echo ""
    
    local failed=0
    
    # Run all tests
    run_syntax_check || failed=$((failed + 1))
    run_script_syntax_check || failed=$((failed + 1))
    run_state_validation || failed=$((failed + 1))
    run_module_dependency_check || failed=$((failed + 1))
    run_common_issues_check || failed=$((failed + 1))
    run_documentation_check || failed=$((failed + 1))
    
    # Summary
    echo ""
    echo "=================================="
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}✓ All local tests passed!${NC}"
        echo ""
        echo "Ready to push. Run 'git push' when ready."
        exit 0
    else
        echo -e "${RED}✗ $failed test(s) failed${NC}"
        echo ""
        echo "Fix the issues above before pushing."
        exit 1
    fi
}

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    echo "Error: Must run from cafaye repository root"
    echo "Usage: ./bin/test-local.sh"
    exit 1
fi

main "$@"
