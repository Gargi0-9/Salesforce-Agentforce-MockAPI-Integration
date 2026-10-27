# Salesforce-Agentforce-MockAPI-Integration
Salesforce Agentforce integration with a third-party MockAPI for CRUD operations.
Salesforce Agentforce -- MockAPI Integration
Overview
This project integrates Salesforce Agentforce with the third-party
MockAPI service. It provides Apex actions for
retrieving, creating, replacing, partially updating, and deleting user
records through REST API callouts.

The implementation uses Salesforce configuration and logging components
so endpoint details, HTTP methods, timeout values, success status codes,
and logging behavior can be managed outside the Apex code.
Features
- GET -- Retrieve all users or retrieve a specific user by ID.
- POST -- Create a new user.
- PUT -- Replace/update an existing user record.
- PATCH -- Partially update an existing user record.
- DELETE -- Delete a user by ID.
- Custom Metadata Types -- Store configuration for each
  integration action.
- External Credentials / Named Credential -- Manage authentication
  and the target service connection without hard-coding the full URL
  in Apex.
- Centralized logging -- Record API request/response information
  and success or error outcomes.
- Agentforce actions -- Expose the Apex methods as actions that an
  Agentforce agent can use.
Architecture
1. Agentforce invokes an Apex action.
2. The Apex class queries the matching PE_Integration_Setting__mdt
   configuration record.
3. The class builds an HTTP request using the configured target system,
   endpoint suffix, HTTP method, and timeout.
4. Salesforce sends the request through the configured Named
   Credential.
5. The Apex class returns the HTTP status code and response body.
6. Depending on the configuration, the class calls PE_Logger to
   record successful transactions or errors in PE_System_Log__c.
Apex Classes
  Apex class                  Purpose                 HTTP operation
  MockAPI_GetUsers          Retrieves all users or  GET
                              one user by ID          

  MockAPI_CreateUser        Creates a user record   POST

  MockAPI_UpdateUserPut     Replaces an existing    PUT
                              user record             

  MockAPI_UpdateUserPatch   Partially updates an    PATCH
                              existing user record    

  MockAPI_DeleteUser        Deletes a user record   DELETE
                              by ID                   

  PE_Logger                 Writes API transaction  Logging utility
                              details to the system
                          log object              
The classes use invocable request and response wrappers so their methods
can be exposed as Salesforce Flow or Agentforce actions.
Salesforce Configuration
1. Configure the external service connection
Create and configure the required Salesforce Named Credential and
External Credential (where applicable) for the MockAPI endpoint.
- Set the base URL for the MockAPI service in the credential
  configuration.
- Configure the appropriate authentication and principal settings for
  your org.
- Grant the required principal access to the user or permission set
  that executes the integration.
- Avoid hard-coding the full service URL in Apex.
The exact authentication setup depends on the MockAPI endpoint and your
Salesforce org configuration.
2. Create the custom metadata type and fields
Create the PE_Integration_Setting__mdt custom metadata type and the
fields used by the Apex classes. Based on the implementation, these
include:
- PE_Target_System__c
- PE_Endpoint_URL_Suffix__c
- PE_Method__c
- PE_Timeout__c
- PE_Log_Transaction__c
- PE_Log_Error__c
- PE_Success_Status_Codes__c
Ensure the field types match how the Apex code reads them. For example,
logging fields should be checkbox fields, timeout should be numeric, and
success status codes should be text.
3. Create custom metadata records
Create a configuration record for each Apex action. The record's
Developer Name must match the FUNCTIONALITY constant in its
corresponding class:
- MockAPI_GetUsers
- MockAPI_CreateUser
- MockAPI_UpdateUserPut
- MockAPI_UpdateUserPatch
- MockAPI_DeleteUser
For each record, configure the target system credential name, endpoint
URL suffix, HTTP method, timeout, transaction/error logging flags, and
success status codes as required.

Check that endpoint suffixes match the paths provided by your MockAPI
project. For operations on a specific user, the Apex code appends
/{id} to the configured suffix.
4. Create the system log object
Create the PE_System_Log__c custom object and the fields referenced by
PE_Logger, including:
- PE_Functionality__c
- PE_Endpoint__c
- PE_Request_Body__c
- PE_Response_Body__c
- PE_Response_Code__c
- PE_Response_Status__c
- PE_Source_ID__c
- PE_Executing_User__c
- Transaction_GUID__c
Use field types and lengths appropriate for the data being stored.
Review access to logs because request and response bodies may contain
sensitive information.
5. Configure permissions
Create or update the MockAPI Access permission set (or the permission
set used in your org). Grant only the access required to run the
integration, including:
- Apex class access for the five API classes and PE_Logger, as
  appropriate.
- Access to the PE_System_Log__c object and its required fields.
- Access to the PE_Integration_Setting__mdt custom metadata type
  where required by your org's security model.
- Access to the External Credential principal / Named Credential as
  applicable.
Assign the permission set to the user that executes the integration,
including the Agentforce execution user if that is the configured
runtime user. Verify the exact access requirements in your org before
testing.
6. Configure Agentforce actions
In Agentforce, create actions using the invocable Apex methods for the
required operations:
- Get users
- Create user
- Update user (PUT)
- Update user (PATCH)
- Delete user
Add the actions to the appropriate agent or topic, provide clear action
instructions and input descriptions, and test each action with
representative inputs.
Example Request Data
Create a user (POST)
{
  "name": "Alex Johnson",
  "gender": "male",
  "job": "developer"
}
Update a user (PUT or PATCH)
{
  "name": "Alex Johnson",
  "gender": "male",
  "job": "senior developer"
}
For PUT/PATCH and DELETE, supply the user ID. For PATCH, only non-null
fields are added to the request body by the Apex implementation.
Testing Checklist
- [ ] Verify the Named Credential base URL and External
  Credential/principal configuration.
- [ ] Confirm that all five custom metadata records exist and their
  Developer Names match the Apex FUNCTIONALITY constants.
- [ ] Verify the HTTP method, endpoint suffix, timeout, and success
  status codes for each record.
- [ ] Test GET for all users and for a specific ID.
- [ ] Test POST with valid user data.
- [ ] Test PUT and PATCH with a valid user ID.
- [ ] Test DELETE with a valid user ID.
- [ ] Confirm that the returned status code and response body are
  populated.
- [ ] Enable transaction/error logging and verify records in
  PE_System_Log__c.
- [ ] Verify permissions for the user running the Apex actions and the
  Agentforce runtime user.
- [ ] Test error responses, missing configuration, and invalid IDs.
Repository Structure
The Apex source and metadata files should be stored under the Salesforce
DX source directory:
force-app/
└── main/
    └── default/
        └── classes/
            ├── MockAPI_GetUsers.cls
            ├── MockAPI_GetUsers.cls-meta.xml
            ├── MockAPI_CreateUser.cls
            ├── MockAPI_CreateUser.cls-meta.xml
            ├── MockAPI_UpdateUserPut.cls
            ├── MockAPI_UpdateUserPut.cls-meta.xml
            ├── MockAPI_UpdateUserPatch.cls
            ├── MockAPI_UpdateUserPatch.cls-meta.xml
            ├── MockAPI_DeleteUser.cls
            ├── MockAPI_DeleteUser.cls-meta.xml
            ├── PE_Logger.cls
            └── PE_Logger.cls-meta.xml
Keep each .cls file beside its matching .cls-meta.xml file. Avoid
creating a second nested force-app directory inside
force-app/main/default/classes.
Notes
- This README describes the intended configuration based on the
  project implementation and setup screenshots. Confirm exact field
  types, endpoint suffixes, status codes, API version, and credential
  names against your Salesforce org.
- Do not commit secrets, access tokens, private keys, or sensitive
  response data to GitHub.
- The Apex classes should be tested in the Salesforce org. A
  successful GitHub commit alone does not deploy or validate the code
  in Salesforce.
