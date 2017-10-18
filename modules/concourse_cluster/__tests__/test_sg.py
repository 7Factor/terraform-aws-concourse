import boto3
import unittest
import json
import botocore
import os
from testutil import find_module

terraform_state = os.environ.get('TF_STATE_PATH') + '/terraform.tfstate'
module_path = 'root/concourse_cluster'

class SecurityGroupTests(unittest.TestCase):
    def setUp(self):
        self.ec2 = boto3.resource('ec2')
        if os.path.exists(terraform_state):
            statefile = open(terraform_state)
            self.tfstate = json.load(statefile)
            self.module = find_module(module_path, self.tfstate)
        else:
            self.fail("No terraform state file exists. Cannot run tests.")

    def test_concourseWebSgOpensTheCorrectPorts(self):
        sgid = self.module['resources']['aws_security_group.conc_web_sg']['primary']['id']
        sg = self.ec2.SecurityGroup(sgid)
        self.assertEqual(sg.ip_permissions[0]['FromPort'], 8080)
        self.assertEqual(sg.ip_permissions[0]['ToPort'], 8080)

    def test_sshSgOpensTheCorrectPorts(self):
        sgid = self.module['resources']['aws_security_group.conc_ssh_access']['primary']['id']
        sg = self.ec2.SecurityGroup(sgid)
        self.assertEqual(sg.ip_permissions[0]['FromPort'], 22)
        self.assertEqual(sg.ip_permissions[0]['ToPort'], 22)

    def test_dbSgOpensTheCorrectPorts(self):
        sgid = self.module['resources']['aws_security_group.conc_db_sg']['primary']['id']
        sg = self.ec2.SecurityGroup(sgid)
        self.assertEqual(sg.ip_permissions[0]['FromPort'], 5432)
        self.assertEqual(sg.ip_permissions[0]['ToPort'], 5432)
