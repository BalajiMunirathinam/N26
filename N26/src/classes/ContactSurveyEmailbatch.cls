/* 
    N26 - BALAJI.M - Version 1.0
    Batch class will send email to contacts by checking the survey date and language of contact.
    2 Email templates created for English and German.
    
    The batch also checks is email successfully delivered via Messaging.SendEmailResult and
    Messaging.SendEmailError
*/


global class ContactSurveyEmailbatch implements Database.Batchable<sObject>,Database.Stateful {
   
   public Id templateEng;
   public Id templateGer;
   Set<Id> contactSetId = new Set<Id>();
   global Integer recordsProcessed = 0;
   public string query = 'select Id, Name,LastName, FirstName, Language__c, Survey_date__c, Email, Account.Name, AccountId from Contact where  Account.Name = \'N26 Customer\'';
   date myDate = date.today();

   global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
   
      List <Messaging.SingleEmailMessage> emaillst = new List <Messaging.SingleEmailMessage>();
      List <Messaging.SingleEmailMessage> allEmaillst = new List <Messaging.SingleEmailMessage>();
      list<Contact> finalContactlst = new List<Contact>();
      Map<Id,Contact> contactIdMap = new Map<Id,Contact>();
      boolean isTemplate = getTemplate();
      
      Integer emailLimitsUsed = getEmailLimitsUsed();
      Integer TotalEmailLimits = getTotalEmailLimits();
      
      for(Contact c  : (list<Contact>)scope) {
          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
          system.debug('ContactName'+c.Name);
          if(c.Survey_date__c<=myDate) {
              if(c.Language__c == 'DE'){
                  email.setTemplateId(templateGer);
              } else {
                email.setTemplateId(templateEng);
              }
              email.setTargetObjectId(c.id);
              emaillst.add(email);
              contactIdMap.put(c.Id,c);
              contactSetId.add(c.Id);
          }    
      }
      
      if(emaillst !=null){
          boolean isSend = sendFinalEmail(emailLimitsUsed,TotalEmailLimits,emaillst);
          if(isSend && contactIdMap!=null && contactSetId!=null) {
              for(Id c: contactSetId) {
                  if(contactIdMap.containsKey(c)){
                      contactIdMap.get(c).Survey_date__c = null;
                      finalContactlst.add(contactIdMap.get(c));
                  }
              }
              if(finalContactlst!=null){
                  update finalContactlst;
              }
          }
      }
    }
    
    private boolean sendFinalEmail(Integer used, Integer total, List<Messaging.SingleEmailMessage> mails){
        
        boolean isProcessed=false;
        if(used < total && mails!=null) {
            Messaging.SendEmailResult[] mailResults = Messaging.sendEmail(mails);
            Messaging.SendEmailError[] emailerrorslst = new List<Messaging.SendEmailError>();
            for(Messaging.SendEmailResult result : mailResults){
                if(!result.isSuccess())
                    emailerrorslst = result.getErrors();
            }    
            if(emailerrorslst!=null) {
                for(Messaging.SendEmailError currentError : emailerrorslst) {
                    Id contactId = currentError.getTargetObjectId();
                    contactSetId.remove(contactId);
                }
            }
            isProcessed = true;
        }
        return isProcessed;
    }
    
    private boolean getTemplate() {
        boolean isSet = false;
        list<EmailTemplate>  template = [Select id,Name,DeveloperName from EmailTemplate where name IN:new list<String>{'SurveyEnglish','SurveyGerman'}];
        for(EmailTemplate temp : template){
            if(temp.name == 'SurveyGerman')
                templateGer = temp.Id;
            else
                templateEng = temp.Id;
        }
        isSet = true;
        return isSet;
    }
    
    private static Integer getEmailLimitsUsed(){
        return Limits.getEmailInvocations();
    }
    
    private static Integer getTotalEmailLimits(){
        return Limits.getLimitEmailInvocations();
    }           
   
    global void finish(Database.BatchableContext BC){
        System.debug(recordsProcessed + ' records processed!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }   
}