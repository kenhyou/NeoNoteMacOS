/* Copyright (c) 2016 Google Inc.
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
 */

//
//  GTLQueryDeploymentManager.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   Google Cloud Deployment Manager API (deploymentmanager/v2)
// Description:
//   Declares, configures, and deploys complex solutions on Google Cloud
//   Platform.
// Documentation:
//   https://cloud.google.com/deployment-manager/
// Classes:
//   GTLQueryDeploymentManager (15 custom class methods, 13 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLQuery.h"
#else
  #import "GTLQuery.h"
#endif

@class GTLDeploymentManagerDeployment;

@interface GTLQueryDeploymentManager : GTLQuery

//
// Parameters valid on all methods.
//

// Selector specifying which fields to include in a partial response.
@property (nonatomic, copy) NSString *fields;

//
// Method-specific parameters; see the comments below for more information.
//
@property (nonatomic, copy) NSString *createPolicy;
@property (nonatomic, copy) NSString *deletePolicy;
@property (nonatomic, copy) NSString *deployment;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *fingerprint;  // GTLBase64 can encode/decode (probably web-safe format)
@property (nonatomic, copy) NSString *manifest;
@property (nonatomic, assign) NSUInteger maxResults;
@property (nonatomic, copy) NSString *operation;
@property (nonatomic, copy) NSString *pageToken;
@property (nonatomic, assign) BOOL preview;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy) NSString *resource;

#pragma mark - "deployments" methods
// These create a GTLQueryDeploymentManager object.

// Method: deploymentmanager.deployments.cancelPreview
// Cancels and removes the preview currently associated with the deployment.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Optional:
//   fingerprint: Specifies a fingerprint for cancelPreview() requests. A
//     fingerprint is a randomly generated value that must be provided in
//     cancelPreview() requests to perform optimistic locking. This ensures
//     optimistic concurrency so that the deployment does not have conflicting
//     requests (e.g. if someone attempts to make a new update request while
//     another user attempts to cancel a preview, this would prevent one of the
//     requests).
//     The fingerprint is initially generated by Deployment Manager and changes
//     after every request to modify a deployment. To get the latest fingerprint
//     value, perform a get() request on the deployment.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerNdevCloudman
// Fetches a GTLDeploymentManagerOperation.
+ (instancetype)queryForDeploymentsCancelPreviewWithProject:(NSString *)project
                                                 deployment:(NSString *)deployment;

// Method: deploymentmanager.deployments.delete
// Deletes a deployment and all of the resources in the deployment.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerNdevCloudman
// Fetches a GTLDeploymentManagerOperation.
+ (instancetype)queryForDeploymentsDeleteWithProject:(NSString *)project
                                          deployment:(NSString *)deployment;

// Method: deploymentmanager.deployments.get
// Gets information about a specific deployment.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerDeployment.
+ (instancetype)queryForDeploymentsGetWithProject:(NSString *)project
                                       deployment:(NSString *)deployment;

// Method: deploymentmanager.deployments.insert
// Creates a deployment and all of the resources described by the deployment
// manifest.
//  Required:
//   project: The project ID for this request.
//  Optional:
//   preview: If set to true, creates a deployment and creates "shell" resources
//     but does not actually instantiate these resources. This allows you to
//     preview what your deployment looks like. After previewing a deployment,
//     you can deploy your resources by making a request with the update()
//     method or you can use the cancelPreview() method to cancel the preview
//     altogether. Note that the deployment will still exist after you cancel
//     the preview and you must separately delete this deployment if you want to
//     remove it.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerNdevCloudman
// Fetches a GTLDeploymentManagerOperation.
+ (instancetype)queryForDeploymentsInsertWithObject:(GTLDeploymentManagerDeployment *)object
                                            project:(NSString *)project;

// Method: deploymentmanager.deployments.list
// Lists all deployments for a given project.
//  Required:
//   project: The project ID for this request.
//  Optional:
//   filter: Sets a filter expression for filtering listed resources, in the
//     form filter={expression}. Your {expression} must be in the format:
//     field_name comparison_string literal_string.
//     The field_name is the name of the field you want to compare. Only atomic
//     field types are supported (string, number, boolean). The
//     comparison_string must be either eq (equals) or ne (not equals). The
//     literal_string is the string value to filter to. The literal value must
//     be valid for the type of field you are filtering by (string, number,
//     boolean). For string fields, the literal value is interpreted as a
//     regular expression using RE2 syntax. The literal value must match the
//     entire field.
//     For example, to filter for instances that do not have a name of
//     example-instance, you would use filter=name ne example-instance.
//     Compute Engine Beta API Only: When filtering in the Beta API, you can
//     also filter on nested fields. For example, you could filter on instances
//     that have set the scheduling.automaticRestart field to true. Use
//     filtering on nested fields to take advantage of labels to organize and
//     search for results based on label values.
//     The Beta API also supports filtering on multiple expressions by providing
//     each separate expression within parentheses. For example,
//     (scheduling.automaticRestart eq true) (zone eq us-central1-f). Multiple
//     expressions are treated as AND expressions, meaning that resources must
//     match all expressions to pass the filters.
//   maxResults: The maximum number of results per page that should be returned.
//     If the number of available results is larger than maxResults, Compute
//     Engine returns a nextPageToken that can be used to get the next page of
//     results in subsequent list requests. (0..500, default 500)
//   pageToken: Specifies a page token to use. Set pageToken to the
//     nextPageToken returned by a previous list request to get the next page of
//     results.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerDeploymentsListResponse.
+ (instancetype)queryForDeploymentsListWithProject:(NSString *)project;

// Method: deploymentmanager.deployments.patch
// Updates a deployment and all of the resources described by the deployment
// manifest. This method supports patch semantics.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Optional:
//   createPolicy: Sets the policy to use for creating new resources. (Default
//     kGTLDeploymentManagerCreatePolicyCreateOrAcquire)
//      kGTLDeploymentManagerCreatePolicyAcquire: "ACQUIRE"
//      kGTLDeploymentManagerCreatePolicyCreateOrAcquire: "CREATE_OR_ACQUIRE"
//   deletePolicy: Sets the policy to use for deleting resources. (Default
//     kGTLDeploymentManagerDeletePolicyDelete)
//      kGTLDeploymentManagerDeletePolicyAbandon: "ABANDON"
//      kGTLDeploymentManagerDeletePolicyDelete: "DELETE"
//   preview: If set to true, updates the deployment and creates and updates the
//     "shell" resources but does not actually alter or instantiate these
//     resources. This allows you to preview what your deployment will look
//     like. You can use this intent to preview how an update would affect your
//     deployment. You must provide a target.config with a configuration if this
//     is set to true. After previewing a deployment, you can deploy your
//     resources by making a request with the update() or you can
//     cancelPreview() to remove the preview altogether. Note that the
//     deployment will still exist after you cancel the preview and you must
//     separately delete this deployment if you want to remove it. (Default
//     false)
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerNdevCloudman
// Fetches a GTLDeploymentManagerOperation.
+ (instancetype)queryForDeploymentsPatchWithObject:(GTLDeploymentManagerDeployment *)object
                                           project:(NSString *)project
                                        deployment:(NSString *)deployment;

// Method: deploymentmanager.deployments.stop
// Stops an ongoing operation. This does not roll back any work that has already
// been completed, but prevents any new work from being started.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Optional:
//   fingerprint: Specifies a fingerprint for stop() requests. A fingerprint is
//     a randomly generated value that must be provided in stop() requests to
//     perform optimistic locking. This ensures optimistic concurrency so that
//     the deployment does not have conflicting requests (e.g. if someone
//     attempts to make a new update request while another user attempts to stop
//     an ongoing update request, this would prevent a collision).
//     The fingerprint is initially generated by Deployment Manager and changes
//     after every request to modify a deployment. To get the latest fingerprint
//     value, perform a get() request on the deployment.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerNdevCloudman
// Fetches a GTLDeploymentManagerOperation.
+ (instancetype)queryForDeploymentsStopWithProject:(NSString *)project
                                        deployment:(NSString *)deployment;

// Method: deploymentmanager.deployments.update
// Updates a deployment and all of the resources described by the deployment
// manifest.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Optional:
//   createPolicy: Sets the policy to use for creating new resources. (Default
//     kGTLDeploymentManagerCreatePolicyCreateOrAcquire)
//      kGTLDeploymentManagerCreatePolicyAcquire: "ACQUIRE"
//      kGTLDeploymentManagerCreatePolicyCreateOrAcquire: "CREATE_OR_ACQUIRE"
//   deletePolicy: Sets the policy to use for deleting resources. (Default
//     kGTLDeploymentManagerDeletePolicyDelete)
//      kGTLDeploymentManagerDeletePolicyAbandon: "ABANDON"
//      kGTLDeploymentManagerDeletePolicyDelete: "DELETE"
//   preview: If set to true, updates the deployment and creates and updates the
//     "shell" resources but does not actually alter or instantiate these
//     resources. This allows you to preview what your deployment will look
//     like. You can use this intent to preview how an update would affect your
//     deployment. You must provide a target.config with a configuration if this
//     is set to true. After previewing a deployment, you can deploy your
//     resources by making a request with the update() or you can
//     cancelPreview() to remove the preview altogether. Note that the
//     deployment will still exist after you cancel the preview and you must
//     separately delete this deployment if you want to remove it. (Default
//     false)
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerNdevCloudman
// Fetches a GTLDeploymentManagerOperation.
+ (instancetype)queryForDeploymentsUpdateWithObject:(GTLDeploymentManagerDeployment *)object
                                            project:(NSString *)project
                                         deployment:(NSString *)deployment;

#pragma mark - "manifests" methods
// These create a GTLQueryDeploymentManager object.

// Method: deploymentmanager.manifests.get
// Gets information about a specific manifest.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//   manifest: The name of the manifest for this request.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerManifest.
+ (instancetype)queryForManifestsGetWithProject:(NSString *)project
                                     deployment:(NSString *)deployment
                                       manifest:(NSString *)manifest;

// Method: deploymentmanager.manifests.list
// Lists all manifests for a given deployment.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Optional:
//   filter: Sets a filter expression for filtering listed resources, in the
//     form filter={expression}. Your {expression} must be in the format:
//     field_name comparison_string literal_string.
//     The field_name is the name of the field you want to compare. Only atomic
//     field types are supported (string, number, boolean). The
//     comparison_string must be either eq (equals) or ne (not equals). The
//     literal_string is the string value to filter to. The literal value must
//     be valid for the type of field you are filtering by (string, number,
//     boolean). For string fields, the literal value is interpreted as a
//     regular expression using RE2 syntax. The literal value must match the
//     entire field.
//     For example, to filter for instances that do not have a name of
//     example-instance, you would use filter=name ne example-instance.
//     Compute Engine Beta API Only: When filtering in the Beta API, you can
//     also filter on nested fields. For example, you could filter on instances
//     that have set the scheduling.automaticRestart field to true. Use
//     filtering on nested fields to take advantage of labels to organize and
//     search for results based on label values.
//     The Beta API also supports filtering on multiple expressions by providing
//     each separate expression within parentheses. For example,
//     (scheduling.automaticRestart eq true) (zone eq us-central1-f). Multiple
//     expressions are treated as AND expressions, meaning that resources must
//     match all expressions to pass the filters.
//   maxResults: The maximum number of results per page that should be returned.
//     If the number of available results is larger than maxResults, Compute
//     Engine returns a nextPageToken that can be used to get the next page of
//     results in subsequent list requests. (0..500, default 500)
//   pageToken: Specifies a page token to use. Set pageToken to the
//     nextPageToken returned by a previous list request to get the next page of
//     results.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerManifestsListResponse.
+ (instancetype)queryForManifestsListWithProject:(NSString *)project
                                      deployment:(NSString *)deployment;

#pragma mark - "operations" methods
// These create a GTLQueryDeploymentManager object.

// Method: deploymentmanager.operations.get
// Gets information about a specific operation.
//  Required:
//   project: The project ID for this request.
//   operation: The name of the operation for this request.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerOperation.
+ (instancetype)queryForOperationsGetWithProject:(NSString *)project
                                       operation:(NSString *)operation;

// Method: deploymentmanager.operations.list
// Lists all operations for a project.
//  Required:
//   project: The project ID for this request.
//  Optional:
//   filter: Sets a filter expression for filtering listed resources, in the
//     form filter={expression}. Your {expression} must be in the format:
//     field_name comparison_string literal_string.
//     The field_name is the name of the field you want to compare. Only atomic
//     field types are supported (string, number, boolean). The
//     comparison_string must be either eq (equals) or ne (not equals). The
//     literal_string is the string value to filter to. The literal value must
//     be valid for the type of field you are filtering by (string, number,
//     boolean). For string fields, the literal value is interpreted as a
//     regular expression using RE2 syntax. The literal value must match the
//     entire field.
//     For example, to filter for instances that do not have a name of
//     example-instance, you would use filter=name ne example-instance.
//     Compute Engine Beta API Only: When filtering in the Beta API, you can
//     also filter on nested fields. For example, you could filter on instances
//     that have set the scheduling.automaticRestart field to true. Use
//     filtering on nested fields to take advantage of labels to organize and
//     search for results based on label values.
//     The Beta API also supports filtering on multiple expressions by providing
//     each separate expression within parentheses. For example,
//     (scheduling.automaticRestart eq true) (zone eq us-central1-f). Multiple
//     expressions are treated as AND expressions, meaning that resources must
//     match all expressions to pass the filters.
//   maxResults: The maximum number of results per page that should be returned.
//     If the number of available results is larger than maxResults, Compute
//     Engine returns a nextPageToken that can be used to get the next page of
//     results in subsequent list requests. (0..500, default 500)
//   pageToken: Specifies a page token to use. Set pageToken to the
//     nextPageToken returned by a previous list request to get the next page of
//     results.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerOperationsListResponse.
+ (instancetype)queryForOperationsListWithProject:(NSString *)project;

#pragma mark - "resources" methods
// These create a GTLQueryDeploymentManager object.

// Method: deploymentmanager.resources.get
// Gets information about a single resource.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//   resource: The name of the resource for this request.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerResource.
+ (instancetype)queryForResourcesGetWithProject:(NSString *)project
                                     deployment:(NSString *)deployment
                                       resource:(NSString *)resource;

// Method: deploymentmanager.resources.list
// Lists all resources in a given deployment.
//  Required:
//   project: The project ID for this request.
//   deployment: The name of the deployment for this request.
//  Optional:
//   filter: Sets a filter expression for filtering listed resources, in the
//     form filter={expression}. Your {expression} must be in the format:
//     field_name comparison_string literal_string.
//     The field_name is the name of the field you want to compare. Only atomic
//     field types are supported (string, number, boolean). The
//     comparison_string must be either eq (equals) or ne (not equals). The
//     literal_string is the string value to filter to. The literal value must
//     be valid for the type of field you are filtering by (string, number,
//     boolean). For string fields, the literal value is interpreted as a
//     regular expression using RE2 syntax. The literal value must match the
//     entire field.
//     For example, to filter for instances that do not have a name of
//     example-instance, you would use filter=name ne example-instance.
//     Compute Engine Beta API Only: When filtering in the Beta API, you can
//     also filter on nested fields. For example, you could filter on instances
//     that have set the scheduling.automaticRestart field to true. Use
//     filtering on nested fields to take advantage of labels to organize and
//     search for results based on label values.
//     The Beta API also supports filtering on multiple expressions by providing
//     each separate expression within parentheses. For example,
//     (scheduling.automaticRestart eq true) (zone eq us-central1-f). Multiple
//     expressions are treated as AND expressions, meaning that resources must
//     match all expressions to pass the filters.
//   maxResults: The maximum number of results per page that should be returned.
//     If the number of available results is larger than maxResults, Compute
//     Engine returns a nextPageToken that can be used to get the next page of
//     results in subsequent list requests. (0..500, default 500)
//   pageToken: Specifies a page token to use. Set pageToken to the
//     nextPageToken returned by a previous list request to get the next page of
//     results.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerResourcesListResponse.
+ (instancetype)queryForResourcesListWithProject:(NSString *)project
                                      deployment:(NSString *)deployment;

#pragma mark - "types" methods
// These create a GTLQueryDeploymentManager object.

// Method: deploymentmanager.types.list
// Lists all resource types for Deployment Manager.
//  Required:
//   project: The project ID for this request.
//  Optional:
//   filter: Sets a filter expression for filtering listed resources, in the
//     form filter={expression}. Your {expression} must be in the format:
//     field_name comparison_string literal_string.
//     The field_name is the name of the field you want to compare. Only atomic
//     field types are supported (string, number, boolean). The
//     comparison_string must be either eq (equals) or ne (not equals). The
//     literal_string is the string value to filter to. The literal value must
//     be valid for the type of field you are filtering by (string, number,
//     boolean). For string fields, the literal value is interpreted as a
//     regular expression using RE2 syntax. The literal value must match the
//     entire field.
//     For example, to filter for instances that do not have a name of
//     example-instance, you would use filter=name ne example-instance.
//     Compute Engine Beta API Only: When filtering in the Beta API, you can
//     also filter on nested fields. For example, you could filter on instances
//     that have set the scheduling.automaticRestart field to true. Use
//     filtering on nested fields to take advantage of labels to organize and
//     search for results based on label values.
//     The Beta API also supports filtering on multiple expressions by providing
//     each separate expression within parentheses. For example,
//     (scheduling.automaticRestart eq true) (zone eq us-central1-f). Multiple
//     expressions are treated as AND expressions, meaning that resources must
//     match all expressions to pass the filters.
//   maxResults: The maximum number of results per page that should be returned.
//     If the number of available results is larger than maxResults, Compute
//     Engine returns a nextPageToken that can be used to get the next page of
//     results in subsequent list requests. (0..500, default 500)
//   pageToken: Specifies a page token to use. Set pageToken to the
//     nextPageToken returned by a previous list request to get the next page of
//     results.
//  Authorization scope(s):
//   kGTLAuthScopeDeploymentManagerCloudPlatform
//   kGTLAuthScopeDeploymentManagerCloudPlatformReadOnly
//   kGTLAuthScopeDeploymentManagerNdevCloudman
//   kGTLAuthScopeDeploymentManagerNdevCloudmanReadonly
// Fetches a GTLDeploymentManagerTypesListResponse.
+ (instancetype)queryForTypesListWithProject:(NSString *)project;

@end
