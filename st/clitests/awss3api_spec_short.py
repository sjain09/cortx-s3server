#
# Copyright (c) 2020 Seagate Technology LLC and/or its Affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# For any questions about this software or licensing,
# please email opensource@seagate.com or cortx-questions@seagate.com.
#

from awss3api import *

# Helps debugging
# Config.log_enabled = True
# Config.dummy_run = True
# Config.client_execution_timeout = 300 * 1000
# Config.request_timeout = 300 * 1000
# Config.socket_timeout = 300 * 1000


# Run before all to setup the test environment.
print("Configuring LDAP")
S3PyCliTest('Before_all').before_all()

load_test_config()

#Create account sourceAccount

test_msg = "Create account sourceAccount"
source_account_args = {'AccountName': 'sourceAccount', 'Email': 'sourceAccount@seagate.com', \
                   'ldapuser': S3ClientConfig.ldapuser, \
                   'ldappasswd': S3ClientConfig.ldappasswd}
account_response_pattern = "AccountId = [\w-]*, CanonicalId = [\w-]*, RootUserName = [\w+=,.@-]*, AccessKeyId = [\w-]*, SecretKey = [\w/+]*$"
result1 = AuthTest(test_msg).create_account(**source_account_args).execute_test()
result1.command_should_match_pattern(account_response_pattern)
print(result1.status.stdout)
account_response_elements = get_response_elements(result1.status.stdout)
source_access_key_args = {}
source_access_key_args['AccountName'] = "sourceAccount"
source_access_key_args['AccessKeyId'] = account_response_elements['AccessKeyId']
source_access_key_args['SecretAccessKey'] = account_response_elements['SecretKey']

bucket_name = "seagatebuckettest"

#******** Create Bucket ********
AwsTest('Aws can create bucket').create_bucket(bucket_name)\
    .execute_test().command_is_successful()
###########################################
##### Add your STs here to test out #######
###########################################


#******** Delete Bucket ********
AwsTest('Aws can delete bucket').delete_bucket(bucket_name)\
    .execute_test().command_is_successful()

#-------------------Delete Accounts------------------
test_msg = "Delete account sourceAccount"
s3test_access_key = S3ClientConfig.access_key_id
s3test_secret_key = S3ClientConfig.secret_key
S3ClientConfig.access_key_id = source_access_key_args['AccessKeyId']
S3ClientConfig.secret_key = source_access_key_args['SecretAccessKey']

account_args = {'AccountName': 'sourceAccount', 'Email': 'sourceAccount@seagate.com',  'force': True}
AuthTest(test_msg).delete_account(**source_account_args).execute_test()\
            .command_response_should_have("Account deleted successfully")

