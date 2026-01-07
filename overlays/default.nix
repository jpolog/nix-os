{ prev, final }:

{
  # Custom scripts and utilities
  # Add your own packages here
  
  # Example: Custom script
  my-custom-tool = prev.writeShellScriptBin "my-tool" ''
    echo "Custom tool"
  '';
}
