public without sharing class PE_Logger {

    public static PE_System_Log__c logApiTransaction(
        HttpRequest req, 
        HttpResponse resp, 
        String functionality, 
        String sourceId, 
        String limitsToLog
    ) {
        String strResponseBody = resp != null ? resp.getBody() : '';
        Integer intLength = 131000;

        if (Test.isRunningTest()) {
            intLength = 1;
        }

        if (String.isNotBlank(strResponseBody) && strResponseBody.length() > intLength) {
            strResponseBody = 'Response body too large. Check attached file.';
        }

        PE_System_Log__c objLogInstance = new PE_System_Log__c(
            PE_Functionality__c = functionality,
            PE_Endpoint__c = req != null ? req.getEndpoint() : null,
            PE_Request_Body__c = req != null ? req.getBody() : null,
            PE_Response_Body__c = strResponseBody,
            PE_Response_Code__c = resp != null ? resp.getStatusCode() : null,
            PE_Response_Status__c = resp != null ? resp.getStatus() : null,
            PE_Source_ID__c = sourceId,
            PE_Executing_User__c = UserInfo.getUserId(),
            Transaction_GUID__c = req != null ? req.getHeader('GLOBAL_MESSAGE_ID') : null
        );

        try {
            insert objLogInstance;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Failed to insert PE_System_Log__c record: ' + ex.getMessage());
        }

        return objLogInstance;
    }
}
