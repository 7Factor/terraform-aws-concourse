import boto3
import unittest
import json
import botocore
import os
from testutil import find_module

terraform_state = os.environ.get('TF_STATE_PATH') + '/terraform.tfstate'
module_path = 'root/concourse_cluster'


class DBInstanceTests(unittest.TestCase):
    def setUp(self):
        self.ec2 = boto3.resource('ec2')
        if os.path.exists(terraform_state):
            statefile = open(terraform_state)
            self.tfstate = json.load(statefile)
        else:
            self.fail("No terraform state file exists. Cannot run tests.")

    def test_instanceExists(self):
        module = find_module(module_path, self.tfstate)
        instance_id = module['resources']['aws_instance.concourse_db']['primary']['id']
        instance = self.ec2.Instance(instance_id)
        self.assertIsNotNone(instance)