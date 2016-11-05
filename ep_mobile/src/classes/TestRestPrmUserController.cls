/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmUserController {
    static testMethod void doGet_RetrievesObjectById() {
        User u = new User (
            Alias = '_TALIAS_',
            UserName = '_TESTUSER_@test.test',
            Email = '_TESTUSER_@test.test',
            FirstName = '__TEST',
            LastName = '_USER__',
            ProfileId = [Select Id from Profile Limit 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        
        insert u;
        
        u = [Select Id, Name from User where Id = :u.Id];
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Users/' + u.Id;
        request.resourcePath = '/mobile/prm/v1/Users/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        
        List<RestPrmUserController.RestUser> users = RestPrmUserController.doGet();
        
        System.assertEquals(1, users.size());
        System.assertEquals(u.ID, users[0].id);
        System.assertEquals(u.Name, users[0].name);
        
        RestRequest requestAll = new RestRequest();
        requestAll.requestURI = '/mobile/prm/v1/Users';
        requestAll.resourcePath = '/mobile/prm/v1/Users/*';
        System.RestContext.request = requestAll;
        
        List<RestPrmUserController.RestUser> users1 = RestPrmUserController.doGet();
        
        RestRequest requestName = new RestRequest();
        requestName.requestURI = '/mobile/prm/v1/Users';
        requestName.resourcePath = '/mobile/prm/v1/Users/*';
        request.addParameter('q', 'TE');
        System.RestContext.request = requestName;
        
        List<RestPrmUserController.RestUser> users2 = RestPrmUserController.doGet();
        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Type = 'Call',
           Status = 'Not Started',
           OwnerId = u.Id           
        );
        insert t;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = u.Id
        );
        insert i;
        
        Note n = new Note(Title = 'TestNote', Body= 'Testing Code coverage Note', ParentId = i.Id);
        insert n; 
        
        List<RestPrmUserController.RestUser> response = new List<RestPrmUserController.RestUser>();
        for(User s : [Select id, Name from User Where IsActive = true]) {
            response.add(new RestPrmUserController.RestUser(s));
            response.add(new RestPrmUserController.RestUser(s.Id));
            response.add(new RestPrmUserController.RestUser(s.Id, s.Name));
        }
        
        response.add(new RestPrmUserController.RestUser(i));
        response.add(new RestPrmUserController.RestUser(t));
        response.add(new RestPrmUserController.RestUser(n));
        List<Task> lst = [select id, Owner.Id, Owner.Name, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from Task limit 1];
        Sobject obj = lst[0]; 
        response.add(new RestPrmUserController.RestUser(obj, 'ModifiedBy'));
        response.add(new RestPrmUserController.RestUser(obj, 'CreatedBy'));
        response.add(new RestPrmUserController.RestUser(obj, 'Owner'));
        
    }
    
    static testMethod void doGet_ReturnsNotFoundWhenBadId() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Users/' + '__BAD_ID__';
        request.resourcePath = '/mobile/prm/v1/Users/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmUserController.RestUser> users = RestPrmUserController.doGet();
        
        System.assertEquals(0, users.size());
        System.assertEquals(404, System.RestContext.response.statusCode);
    }
}