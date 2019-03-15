/* Test class for ProductController 
    Here I created one record for account, contact,products and products inventory
    we can also created the testing for bulk records(200) from for loop and perform testing.
*/

@isTest
private class ProductsControllerTest {

    @testSetup static void setup() {
        Account a = new Account(Name='N26Customer');
        insert a;
        
        Contact con = new Contact(Email = 'balaji.munirathinam@t-systems.com',Survey_Date__c = Date.today() ,AccountId = a.Id, LastName='james', language__c = 'EN', Home_Country__c = 'EN');
        insert con;
        
        Case c = new Case(AccountId = a.Id, ContactId =con.id, Product__c ='GC1040', Type='Mechanical', origin='Email', status='New');
        insert c;
        
        Products__c p = new Products__c(Name='Standard_N27_UK', Product_Type__c = 'Standard', Country__c = 'DE',
        Cost_per_Calendar_Month__c=0.00,ATM_Fee_in_other_currencies__c='Free', Card_Replacement_Cost__c= 6);
        
        insert p;
        
        Product_Inventory__c pi = new Product_Inventory__c(Name='Standard_N27_UK', Contact__c = con.Id, Products__c = p.Id);
        insert pi;
    }
    
    static testMethod void runPositiveInsertTestCases() {
        
        //Set up user
        User u1 = [SELECT Id FROM User WHERE Alias='BM'];
        Case c = [Select Id FROM CASE Where Product__c ='GC1040' limit 1];
        contact con = [Select Id, lastName, survey_date__c From Contact WHERE LastName='james' limit 1];
        List<Products__c> finalProdsCaseId = new list<Products__c>();
        List<Products__c> finalProdsContactId = new list<Products__c>();
        //Run As U1
        System.RunAs(u1) {
            System.debug('Insert one child : single record validation)');
            ProductsController prdCon = new ProductsController();
            finalProdsCaseId = ProductsController.getProductsDetails(c.Id);
            finalProdsContactId = ProductsController.getProductsContactId(con.Id); 
            System.assertNotEquals(null, finalProdsCaseId);
            System.assertNotEquals(null, finalProdsContactId);
        }
    }
    
    static testMethod void runBatchTestCases() {
        
        //Set up user
        User u1 = [SELECT Id FROM User WHERE Alias='BM'];
        list<Contact> con = [Select Id, Email,Name,Home_Country__c,language__c ,LastName, survey_date__c From Contact WHERE LastName='james' limit 1];
        //Run As U1
        System.RunAs(u1) {
            Test.startTest();
            ContactSurveyEmailbatch surveymail = new ContactSurveyEmailbatch();
            Database.QueryLocator ql = surveymail.start(null);
            Database.BatchableContext BC;
            surveymail.execute(null,con);
            contact c = [Select Id, lastName, survey_date__c From Contact WHERE LastName='james' limit 1];
            System.assertEquals(null, c.survey_date__c);
        }
    }
}