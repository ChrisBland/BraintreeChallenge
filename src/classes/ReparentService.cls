public with sharing class ReparentService {
	public ReparentService(ReparentParams params) {
    this.accountMap = new Map<String, Account>();
    this.params = params;
  }
  public ReparentParams params {get; set;}
  public Map<String, Account> accountMap {get; set;}
  
  public Boolean run(){
    if(brainTreeIdExists(params.braintreeId)){

    }else{

    }
    return true;
  }
  public Boolean brainTreeIdExists(String braintreeId){
    findAccountByBraintreeId(braintreeId);
    if(this.accountMap.keySet().size() == 1){
      return true;
    }else{
      return false;
    }
  }
  public Account findAccountByName(String name, String braintreeId){
    List<Account> accounts = [SELECT Id, Name, Braintree_ID__c 
                              FROM Account 
                              WHERE Name = :name AND ParentId = '' AND Braintree_ID__c != :braintreeId
                              LIMIT 1];
    if(accounts.size() == 1){
      return accounts.get(0);
    }else{
      return null;
    }
  }
  public void findAccountByBraintreeId(String braintreeId){
    List<Account> accounts = [SELECT Id, Braintree_ID__c, ParentId FROM Account WHERE Braintree_ID__c = :braintreeId];
    if(accounts.size() == 1){
      accountMap.put(accounts.get(0).Id, accounts.get(0));
    }
  }

}