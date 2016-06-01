# Deploy via CodeDeploy

A Wercker step for deploying an artefact stored in S3 with the help of Amazon CodeDeploy.
As a prerequisite, the [AWS Command Line Interface](https://aws.amazon.com/cli/) needs to be already configured with the details of a user which has sufficient _AWS CodeDeploy_ management privileges.

The step takes the following arguments:

* **application-name**: The name of the CodeDeploy application as it can be found in the console.
* **deployment-group-name** Identifies the target of the deploy (instances where the CodeDeploy agent runs).
* **s3-artefact**: The S3 path to the artefact that is to be deployed.
* **bundle-type** By default it is `zip`, can be changed according to the documentation in the [Amazon Command Line Interface](http://docs.aws.amazon.com/cli/latest/reference/deploy/create-deployment.html).

## Example

```
steps:
    - audienceproject/deploy-via-codedeploy:
        - application-name: My Awesome Processing Engine
        - deployment-group-name: MyFleet
        - s3-artefact: s3://organization-storage/apps/engine.zip
```
