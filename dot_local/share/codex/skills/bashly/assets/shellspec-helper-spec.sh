# Starter template for ShellSpec source-level tests.
# Copy into spec/ and update the source path/function names.

Describe 'helper function'
  Include ./src/lib/helper.sh

  It 'returns expected output'
    When call helper_function input
    The status should be success
    The output should include 'expected'
  End
End
