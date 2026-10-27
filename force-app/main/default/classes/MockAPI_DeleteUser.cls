public class MockAPI_DeleteUser {
    public class Request {
        @InvocableVariable(label='User ID' required=true) public String id;
    }
    public class Response {
        @InvocableVariable(label='Status Code') public Integer statusCode;
        @InvocableVariable(label='Response Body') public String responseBody;
    }

    private static final String FUNCTIONALITY = 'MockAPI_DeleteUser';

    @InvocableMethod(label='MockAPI: DELETE User' description='Deletes a user record by ID in MockAPI')
    public static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();

        PE_Integration_Setting__mdt serviceSetting = [
            SELECT Id, DeveloperName, PE_Target_System__c, PE_Endpoint_URL_Suffix__c, 
                   PE_Method__c, PE_Timeout__c, PE_Log_Transaction__c, PE_Log_Error__c,
                   PE_Success_Status_Codes__c
            FROM PE_Integration_Setting__mdt
            WHERE DeveloperName = :FUNCTIONALITY
            WITH USER_MODE
            LIMIT 1
        ];

        for (Request req : requests) {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:' + serviceSetting.PE_Target_System__c + serviceSetting.PE_Endpoint_URL_Suffix__c + '/' + req.id);
            httpRequest.setMethod(serviceSetting.PE_Method__c);
            httpRequest.setTimeout(Integer.valueOf(serviceSetting.PE_Timeout__c));

            HttpResponse httpRes = new Http().send(httpRequest);

            String statusCodeStr = String.valueOf(httpRes.getStatusCode());
            Boolean isSuccess = String.isNotBlank(serviceSetting.PE_Success_Status_Codes__c) && 
                                serviceSetting.PE_Success_Status_Codes__c.contains(statusCodeStr);

            if (isSuccess) {
                if (serviceSetting.PE_Log_Transaction__c == true) {
                    PE_Logger.logApiTransaction(httpRequest, httpRes, FUNCTIONALITY, UserInfo.getUserId(), null);
                }
            } else {
                if (serviceSetting.PE_Log_Error__c == true) {
                    PE_Logger.logApiTransaction(httpRequest, httpRes, FUNCTIONALITY, UserInfo.getUserId(), null);
                }
            }

            Response res = new Response();
            res.statusCode = httpRes.getStatusCode();
            res.responseBody = httpRes.getBody();
            responses.add(res);
        }
        return responses;
    }
}
