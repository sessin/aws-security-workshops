# Module 1: Environment build and configuration

In this module you will be configuring the threat detection controls for your environment.  You'll be running the first of two CloudFormation templates which will automate the creation of some of these controls and then you will manually configure the rest.

### Agenda

1.	Review current configurations and run the 1st CloudFormation template – 5 min
2.	Configure the remaining controls – 10 min

## Review current configurations

When you launch the first CloudFormation template you'll be prompted with questions regarding whether certain resources are already configured.  Please verify whether you already have the following configured in your account:

1.	Go to [AWS IAM](https://console.aws.amazon.com/iam/home?region=us-west-2#/roles) and see if you have the following Role created:
	![Roles](../images/01-current-roles.png)

  	> If you do not see the Inspector Role; you'll answer **No** when prompted if the Inspector Role exists when launching the CloudFormation template.

2.	Go to <a href="https://us-west-2.console.aws.amazon.com/config/home?region=us-west-2" target="_blank">AWS Config</a> (in the us-west-2 - Oregon region) and see if it is already enabled.
  
  	> If you see a **Get Started** button; you'll answer **No** when prompted if Config is enabled when launching the CloudFormation template.

## Deploy the CloudFormation template

To initiate the scenario and configure your environment you will need to run the module 1 CloudFormation template: 

Region| Deploy
------|-----
US West 2 (Oregon) | [![Deploy Module 1 in us-west-2](../images/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=BH2018-AwsForensicsWksp-EnvSetup&templateURL=https://s3-us-west-2.amazonaws.com/blackhat-vegas-2018-aws-forensics-wksp/01-environment-setup.yaml)

1. Click the **Deploy to AWS** button above.  This will automatically take you to the console to run the template.  The file for the CloudFormation template (**01-environment-setup.yaml**) is also available in the [templates](../templates/) folder if you'd like to download it and manually upload it to create a stack.

2. On the **Specify Details** section enter the necessary parameters as shown below. 
	* Enter a valid **Email Address**. This is so you can receive email alerts from AWS services during the Workshop.
	* Please use the answers you discovered during the *Review Current Configurations*.

![Parameters Example](../images/01-specify-details.png)

3. Once you have entered your parameters click **Next**, then **Next** again \(leave everything on this page at the default\).

4. Finally, acknowledge that the template will create IAM roles and click **Create**.

![IAM Capabilities](../images/iam-capabilities.png)

This will bring you back to the CloudFormation console. You can refresh the page to see the stack starting to create. Before moving on, make sure the stack is in a **CREATE_COMPLETE** status as shown below.

![Stack Complete](../images/01-stack-complete.png)

5.	You will get an email from SNS asking you to confirm the Subscription so you can receive email alerts from AWS services during the Workshop.

## Setup CloudWatch Event rules and automatic remediation

The CloudFormation template you just ran created three [CloudWatch Event Rules](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html) for alerting and remediation purposes. The steps below will walk you through creating the final rule.  After this you'll have all the necessary rules in place to receive email notifications and trigger the appropriate AWS Lambda functions for remediations.

Below are steps to create this rule through the console but you can also find out more about doing it programmatically by reviewing the [GuardDuty Documentation](http://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html).

1.	Open the [CloudWatch console](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2)
2.	In the navigation pane on the left, under **Events**, click **Rules**

	> What are the current Rules in place setup to do?
3.	Click **Create Rule**
4.	On the **Create rule** screen do the following: 
	* Under **Event Pattern** click **Build event pattern to match events by service** and select **Custom event pattern** in the drop down.
	* Paste in the custom event pattern below:
	```
	{
	  "source": [
		"aws.guardduty"
	  ],
	  "detail": {
		"type": [
		  "UnauthorizedAccess:EC2/MaliciousIPCaller.Custom"
		]
	  }
	}
	```
	* For *Targets*, click **Add Target**, select **Lambda Function**, and then select **forensics-wksp-remediation-nacl**.
	* Click **Configure details**
5.	On the **Configure rule details** screen fill out the **Name** and **Description** (suggestions below).
    * Name: **forensics-wksp-guardduty-finding-ec2-maliciousip**
    * Description: **GuardDuty Finding: UnauthorizedAccess:EC2/MaliciousIPCaller.Custom**
6. Click **Create rule**.
7.	Now let’s examine the Lambda function to see what it does.  Open the [Lambda console](https://us-west-2.console.aws.amazon.com/lambda/home?region=us-west-2)
8.	Click on the function named **forensics-wksp-remediation-nacl**

	> What will the function do when invoked?

	> What will the **forensics-wksp-remediation-inspector** function do?

## Enable GuardDuty

The next step is to enable Amazon GuardDuty, which will continuously monitor your environment for malicious or unauthorized behavior.

1.	Go to the [Amazon GuardDuty](https://us-west-2.console.aws.amazon.com/guardduty/home?region=us-west-2) console.

2.	Click the **Get Started** button.

3.	On the next screen click the **Enable GuardDuty** button.

GuardDuty is now enabled and continuously monitoring your CloudTrail logs, VPC flow logs, and DNS Query logs for threats in your environment.

## Architecture overview

Your environment is now configured and ready for operations.  Below is a diagram to depict the detective controls you now have in place.

![Detective Controls](../images/01-diagram-module1.png)

After you have successfully setup your environment, you can proceed to the next module.

### **[Module 2 - Attack Simulation](../docs/02-attack-simulation.md)**
