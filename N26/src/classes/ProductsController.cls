public class ProductsController {
  @AuraEnabled
    public static List<Products__c> getProductsDetails(Id caseId) {
        List<Products__c> allProductslst = new List<Products__c>();
        Case c = [Select Id, AccountId, CaseNumber, ContactId FROM Case Where Id=:caseId];
        if(c.ContactId !=null){
           allProductslst = finalProducts(c.contactId);
        }
        return allProductslst;   
    }
    private static list<Products__c> finalProducts(Id ContactId){
        List<Products__c> productsList = new List<Products__c>();
        List<Id> productsIds = new List<Id>();
        list<Product_Inventory__c>  prdInventorylist  = 
          [Select Name,Contact__r.Product__c,Contact__r.Home_Country__c,
            Contact__c,Products__c, Products__r.Country__c,Products__r.Product_Type__c
           FROM Product_Inventory__c WHERE Contact__c=:ContactId];
		
        	System.debug('TOTALPIs'+prdInventorylist);
        
        	For(Product_Inventory__c pi : prdInventorylist){
                if(pi.Contact__r.Product__c == 'All'){
                        productsIds.add(pi.Products__c);
                }
               else if(pi.Contact__r.Product__c == pi.Products__r.Product_Type__c &&
                    pi.Contact__r.Home_Country__c== pi.Products__r.Country__c) {
                        productsIds.add(pi.Products__c);
                }
            }
        System.debug('TotalproductsIds'+productsIds);
            For(Products__c p : [SELECT id,Name,Card_Replacement_Cost__c,Product_Type__c,Country__c,
                                        ATM_Fee_in_other_currencies__c,Cost_per_Calendar_Month__c
                                FROM Products__c
                                WHERE Id IN:productsIds]){
            productsList.add(p);
        }
        System.debug('Totalproductuctslist'+productsList);
        return productsList;
    }
    @AuraEnabled
    public static List<Products__c> getProductsContactId(Id ContactId) {
        List<Products__c> finalProdlst = new List<Products__c>();
        if(ContactId !=null){
            finalProdlst = finalProducts(contactId);
        }
         System.debug('TotalFinalproductuctslist----'+finalProdlst);
        return finalProdlst;   
    }  
}