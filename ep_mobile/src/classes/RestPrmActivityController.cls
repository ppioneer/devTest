global with sharing class RestPrmActivityController {
	
    global class ActivityFeed {
        public List<RestPrmCallController.Call> calls { get; private set; }
        public List<RestPrmIssueController.Issue> issues { get; private set; }
        public List<RestPrmNoteController.RestNote> notes { get; private set; }
        public List<RestPrmTaskController.RestTask> tasks { get; private set; }
        
        public ActivityFeed () {
            this.calls = new List<RestPrmCallController.Call>();
            this.issues = new List<RestPrmIssueController.Issue>();
            this.notes = new List<RestPrmNoteController.RestNote>();
            this.tasks = new List<RestPrmTaskController.RestTask>();
        }
    }
}