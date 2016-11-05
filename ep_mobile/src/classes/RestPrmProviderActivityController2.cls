/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Providers/*/ActivityFeed')
global with sharing class RestPrmProviderActivityController2 {
	
	@HttpGet
    global static RestPrmActivityController2.ActivityFeed doGet() {
     RestPrmActivityController2.ActivityFeed response = new RestPrmActivityController2.ActivityFeed();
        
        try {
            response.calls.addAll(RestPrmProviderCallController2.doGet());
            response.issues.addAll(RestPrmProviderIssueController2.doGet());
            response.notes.addAll(RestPrmProviderNoteController2.doGet());            
            response.tasks.addAll(RestPrmProviderTaskController2.doGet());
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotFound);
        }

        return response;
    }
}