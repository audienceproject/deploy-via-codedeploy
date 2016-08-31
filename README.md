# Deploy via CodeDeploy

A Wercker step for creating and deploying an artefact with the help of Amazon CodeDeploy.
The prerequisite [AWS Command Line Interface](https://aws.amazon.com/cli/) will be installed and configured by the step. 

The step takes the following arguments:
# For configuring AWS CLI
* **wercker_aws_access_key**: The AWS access key for Werker to use
* **wercker_aws_secret_access_key**: The AWS secret access key for Werker to use
# Setup application
* **aws_application_name**: The name of the application in CodeDeploy
# Setup deployment config
* **aws_deployment_config_name**: The name of the deployment configuration in CodeDeploy
* **aws_minimum_healthy_hosts**: (optional) The minimum number of healthy hosts during deployment
# Setup deployment group
* **aws_deployment_group**: Name of the deployment group in CodeDeploy
* **aws_service_role_arn**: The service role ARN to use
* **aws_auto_scaling_groups**: (optional)  
* **aws_ec2_tag_filters**: (optional)
# push application
* **aws_s3_bucket**: The S3 bucket to use when pushing app to S3
* **aws_s3_key**: The the key that identifies the file on S3 
* **app_source_location**: the location of the app to bundle and push to S3
* **aws_revision_description**: (optional) 
# Register application version    
* **aws_bundle_type**: The bundle type, defaults to zip
# Created deployment
* **aws_deployment_description**: (optional)

For more info, see [Amazon Command Line Interface](http://docs.aws.amazon.com/cli/latest/reference/deploy)

## Example

```
steps:
    - audienceproject/deploy-via-codedeploy:
        - wercker_aws_access_key: <AWS ACCESS KEY>
        - wercker_aws_secret_access_key: <AWS ACCESS KEY>
        - aws_application_name: DemoApp
        - aws_deployment_config_name: DemoApp
        - aws_deployment_group: DemoAppGroup
        - aws_service_role_arn: arn:aws:iam::80398EXAMPLE:role/CodeDeployDemoRole
        - aws_deployment_config_name: DemoAppConfig                         
        - aws_ec2_tag_filters: Key=Name,Value=DemoServer,Type=KEY_AND_VALUE 
        - aws_s3_bucket: my-apps-bucket
        - aws_s3_key: demoapp/demoapp.zip
        - app_source_location: /tmp/myapp/
        - aws_bundle_type: zip
```
