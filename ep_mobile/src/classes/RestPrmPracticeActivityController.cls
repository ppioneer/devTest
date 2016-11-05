/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*/ActivityFeed')
global with sharing class RestPrmPracticeActivityController {
    @HttpGet
    global static RestPrmActivityController.ActivityFeed doGet() {
     RestPrmActivityController.ActivityFeed response = new RestPrmActivityController.ActivityFeed();
        
        try {
            response.calls.addAll(RestPrmPracticeCallController.doGet());
            response.notes.addAll(RestPrmPracticeNoteController.doGet());
            response.tasks.addAll(RestPrmPracticeTaskController.doGet());
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotFound);
        }

        return response;
    }
}