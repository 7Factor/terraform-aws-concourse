# Concourse on Terraform

This module will allow you to publish concourse on your own AWS infrastructure.

## Testing

This module was built with a TDD mindset. Each folder in the module will have a corresponding ```__tests__``` directory. Inside these directories will be python unit tests that require access to a terraform state file in order to be successful. You can set this by adding an environment variable to a local .env file, or set the environment variable in your shell:

``` bash
export TF_PATH=./
```

The python tests use the terraform state file to look up dynamic identifiers for the infrastructure that you create and then live query AWS for that component.