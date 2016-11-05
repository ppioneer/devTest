/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestRestPrmProviderTaskController2 {

    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Status = 'Not Started'           
        );
        
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmProviderTaskController2.doGet();
        
        System.assertEquals(1, tasks.size());
        System.assertEquals(t.ID, tasks[0].id);
    } 
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        request.addParameter('WhoId', provider.Id);   
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue()));  
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', '__Call__'));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Type', 'Task'));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('OwnerId', UserInfo.getUserId()));
        
        RestPrmProviderTaskController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse  t = new uRestController.GenericGetResponse ();        
        RestPrmProviderTaskController2.doPut(t);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        request.addParameter('Providers', provider.Id);
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse rt = new uRestController.GenericGetResponse();
        rt.id = t.id;
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue()));  
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', '__Call__'));
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Type', 'Task'));
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Description', '_Comments__'));
        
        RestPrmProviderTaskController2.doPut(rt);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        t = [Select Id, Description from Task where Id = :rt.Id];
        
        System.assertEquals(t.Description, rt.fieldsInfo[4].value);
    }
    
    static testMethod void doPatch_ReturnsOk() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Status = 'Not Started'           
        );
        
        insert t;
        
         Task t1 = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Status = 'Not Started'           
        );
        
        insert t1;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rt = new uRestController.GenericGetResponse();
        rt.id = t.Id;
        List<String> lst = new List<String>();
        lst.add(t.Id);
        lst.add(t1.Id);        
        RestPrmProviderTaskController2.doPatch(lst);
        
        System.assertEquals(null, RestContext.response.statusCode);
        
        RestPrmProviderTaskController2.doPatch(null);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rt = new uRestController.GenericGetResponse();
        rt.id = t.Id;
        
        RestPrmProviderTaskController2.doPut(rt);
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController2.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController2.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}