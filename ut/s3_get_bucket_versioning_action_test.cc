/*
 * Copyright (c) 2021 Seagate Technology LLC and/or its Affiliates
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * For any questions about this software or licensing,
 * please email opensource@seagate.com or cortx-questions@seagate.com.
 *
 */
#include <gmock/gmock.h>
#include <gtest/gtest.h>


#include "mock_s3_bucket_metadata.h"
#include "mock_s3_factory.h"
#include "mock_s3_request_object.h"
#include "s3_get_bucket_versioning_action.h"

using ::testing::Invoke;
using ::testing::AtLeast;
using ::testing::ReturnRef;

class S3GetBucketVersioningActionTest : public testing::Test {
    protected:
    S3GetBucketVersioningActionTest() {
        evhtp_request_t *req = nullptr;
        EvhtpInterface *evhtp_obj_ptr = new EvhtpWrapper();
        bucket_name = "seagate";
        
        request_mock = std::make_shared<MockS3RequestObject>(req, evhtp_obj_ptr);
        EXPECT_CALL(*request_mock, get_bucket_name())
        .WillRepeatedly(ReturnRef(bucket_name));
        bucket_meta_factory =
            std::make_shared<MockS3BucketMetadataFactory>(request_mock);
        std::map<std::string, std::string> input_headers;
        input_headers["Authorization"] = "1";
        EXPECT_CALL(*request_mock, get_in_headers_copy()).Times(1).WillOnce(
        ReturnRef(input_headers));
        action_under_test = std::make_shared<S3GetBucketVersioningAction>(
            request_mock, bucket_meta_factory);
    }
    std::shared_ptr<S3GetBucketVersioningAction> action_under_test;
    std::shared_ptr<MockS3BucketMetadataFactory> bucket_meta_factory;
    std::shared_ptr<MockS3RequestObject> request_mock;
    std::string bucket_name;

};

TEST_F(S3GetBucketVersioningActionTest, Constructor) {
    EXPECT_NE(0,action_under_test->number_of_tasks());
}