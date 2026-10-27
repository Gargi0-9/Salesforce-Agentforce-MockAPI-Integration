public class MockAPI_UpdateUserPut {
    public class Request {
        @InvocableVariable(label='User ID' required=true) public String id;
        @InvocableVariable(label='Name') public String name;
        @InvocableVariable(label='Gender') public String gender;
        @InvocableVariable(label='Job') public String job;
    }
    public class Response {
        @InvocableVariable(label='Status Code') public Integer statusCode;
        @InvocableVariable(label='Response Body') public String responseBody;
    }

    private static final String FUNCTIONALITY = 'MockAPI_UpdateUserPut';

    @InvocableMethod(label='MockAPI: PUT Replace User' description='Replaces an existing user record in MockAPI')
    public static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();

        PE_Integration_Setting__mdt serviceSetting = [
            SELECT Id, DeveloperName, PE_Target_System__c, PE_Endpoint_URL_Suffix__c, PE_Method__c, PE_Timeout__c
            FROM PE_Integration_Setting__mdt
            WHERE DeveloperName = :FUNCTIONALITY
            WITH USER_MODE
            LIMIT 1
        ];

        for (Request req : requests) {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:' + serviceSetting.PE_Target_System__c + serviceSetting.PE_Endpoint_URL_Suffix__c + '/' + req.id);
            httpRequest.setMethod(serviceSetting.PE_Method__c);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setTimeout(Integer.valueOf(serviceSetting.PE_Timeout__c));


            Map<String, String> bodyMap = new Map<String, String>();
            if (req.name != null) bodyMap.put('name', req.name);
            if (req.gender != null) bodyMap.put('gender', req.gender);
            if (req.job != null) bodyMap.put('job', req.job);

            httpRequest.setBody(JSON.serialize(bodyMap));

            HttpResponse httpRes = new Http().send(httpRequest);
            Response res = new Response();
            res.statusCode = httpRes.getStatusCode();
            res.responseBody = httpRes.getBody();
            responses.add(res);
        }
        return responses;
    }
}
