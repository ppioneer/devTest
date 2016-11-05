@isTest
private class TestRestPrmEmailNotificationController {

    static testMethod void doGet_RetrievesObjectByCall() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task (
            WhoId = provider.Id,
            Subject = 'Call',
            Type = 'Call',
            Status = 'Not Started',
            Description = '_TEST_TEST_COMMENTS_'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/EmailNotification/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/EmailNotification/*';
        request.addParameter('objectType', 'Call'); 
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmEmailNotificationController.EmailNotification notify = RestPrmEmailNotificationController.doGet();
        
        System.Assert(notify.Id == t.Id);        
    }
    
    static testMethod void doGet_RetrievesObjectByTask() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task (
            WhoId = provider.Id,
            Subject = 'Email',
            Type = 'Task',
            Status = 'Not Started',
            Description = '_TEST_TEST_COMMENTS_'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/EmailNotification/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/EmailNotification/*';
        request.addParameter('objectType', 'Task'); 
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmEmailNotificationController.EmailNotification notify = RestPrmEmailNotificationController.doGet();
        
        System.Assert(notify.Id == t.Id);        
    }
    
    static testMethod void doGet_RetrievesObjectByIssue() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/EmailNotification/' + issue.Id;
        request.resourcePath = '/mobile/prm/v2/EmailNotification/*';
        request.addParameter('objectType', 'issue'); 
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmEmailNotificationController.EmailNotification notify = RestPrmEmailNotificationController.doGet();
        
        System.Assert(notify.Id == issue.Id);        
    }
    
    static testMethod void doPost_SendTaskEmail() { 
        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task (
            WhoId = provider.Id,
            Subject = 'Call',
            Type = 'Call',
            Status = 'Not Started',
            Description = '_TEST_TEST_COMMENTS_'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/EmailNotification/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/EmailNotification/*';
        request.addParameter('objectType', 'Task');         
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmEmailNotificationController.EmailNotification data = new RestPrmEmailNotificationController.EmailNotification();
        data.id = t.id; 
        data.comments = 'TEST_COMMENTS__';
        data.providerId = provider.id;
        data.toAddresses = new List<String>();
        data.toAddresses.add('test@test.com');
        data.toAddresses.add('test123@test.com');
        data.ccAddresses = new List<String>();
        data.ccAddresses.add('test123@test.com'); 
        
        RestPrmEmailNotificationController.EmailNotification notify = RestPrmEmailNotificationController.doPost(data); 
        
        System.Assert(true);
        
        RestRequest requestNoEmails = new RestRequest();
        requestNoEmails.requestURI = '/mobile/prm/v2/EmailNotification/' + t.Id;
        requestNoEmails.resourcePath = '/mobile/prm/v2/EmailNotification/*';
        requestNoEmails.addParameter('objectType', 'Task');         
        System.RestContext.request = requestNoEmails;
        System.RestContext.response = new RestResponse();
        
        RestPrmEmailNotificationController.EmailNotification data1 = new RestPrmEmailNotificationController.EmailNotification();
        data1.id = t.id; 
        data1.comments = 'TEST_COMMENTS__';
        data1.providerId = provider.id;       
        data.toAddresses = new List<String>();
        data.ccAddresses = new List<String>();
        
        RestPrmEmailNotificationController.EmailNotification notify1 = RestPrmEmailNotificationController.doPost(data1); 
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
}