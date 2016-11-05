/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/ActivityFeed')
global with sharing class RestPrmProviderActivityController {
    @HttpGet
    global static RestPrmActivityController.ActivityFeed doGet() {
     RestPrmActivityController.ActivityFeed response = new RestPrmActivityController.ActivityFeed();
        
        try {
            response.calls.addAll(RestPrmProviderCallController.doGet());
            response.issues.addAll(RestPrmProviderIssueController.doGet());
            response.notes.addAll(RestPrmProviderNoteController.doGet());
            response.tasks.addAll(RestPrmProviderTaskController.doGet());
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotFound);
        }

        return response;
    }
}