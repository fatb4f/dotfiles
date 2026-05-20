# Minimal ShellSpec template for a Bash function library.

Describe 'function_name'
  Include ./path/to/file.sh

  It 'handles the success path'
    When call function_name 'input'
    The status should be success
  End

  It 'handles invalid input'
    When call function_name ''
    The status should be failure
  End
End
