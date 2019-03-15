/* Schedulable class for batch class : ContactSurveyEmailbatch 
    Here I have used the schedulable class to run every day.
    This class will be used in the UI under apex class to schedule batch apex
*/

global class scheduledContactSurveyEmailbatch implements Schedulable {
   
   global void execute(SchedulableContext SC) {
      ContactSurveyEmailbatch surveymail = new ContactSurveyEmailbatch();
      database.executebatch(surveymail);
   }
   
}