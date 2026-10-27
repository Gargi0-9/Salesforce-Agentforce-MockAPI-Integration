public class MockAPI_CreateUser {
    public class Request {
        @InvocableVariable(label='Name') public String name;
        @InvocableVariable(label='Gender') public String gender;
        @InvocableVariable(label='Job') public String job;
    }
    public class Response {
        @InvocableVariable(label='Status Code') public Integer statusCode;
        @InvocableVariable(label='Response Body') public String responseBody;
    }

    private static final String FUNCTIONALITY = 'MockAPI_CreateUser';

    @InvocableMethod(label='MockAPI: POST Create User' description='Creates a new user record in MockAPI')
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
            httpRequest.setEndpoint('callout:' + serviceSetting.PE_Target_System__c + serviceSetting.PE_Endpoint_URL_Suffix__c);
            httpRequest.setMethod(serviceSetting.PE_Method__c);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setTimeout(Integer.valueOf(serviceSetting.PE_Timeout__c));

            Map<String, String> bodyMap = new Map<String, String>();
            if (req.name != null) bodyMap.put('name', req.name);
            if (req.gender != null) bodyMap.put('gender', req.gender);
            if (req.job != null) bodyMap.put('job', req.job);

            httpRequest.setBody(JSON.serialize(bodyMap));

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
