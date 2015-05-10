public with sharing class ReparentService {
	public ReparentService(ReparentParams params) {
    this.accountMap = new Map<String, Account>();
    this.params = params;
  }
  //Params from the RestRequest
  public ReparentParams params {get; set;}
  //Map to cache and hold accounts we find
  public Map<String, Account> accountMap {get; set;}
  //Store the accountId we found
  public String foundAccountId {get; set;}
  
  /*
    Entry in to our serivce
    Returns: Boolean () => Did perform an update
  */
  public Boolean run(){
    //Create the result we will return
    Boolean result = false;
    //Step 5: Query the Account table to see if an Account exists in the database with that Braintree ID
    if(brainTreeIdExists(params.braintreeId)){
      // Step 7.  Update the Account found in 5.) with a “Parent Account” using the account found in 6.)
      Account parent = findAccountByNameAndBraintreeId(params.name, params.braintreeId);
      if(parent != null){
        Account reparent = accountMap.get(foundAccountId);
        reparent.ParentId = parent.Id;
        //Use Database.saveResults to verify the transaction went through
        Database.SaveResult sr = Database.update(reparent);
        if(sr.isSuccess()){
          result = true;
        }
      }
    }else{
      //Step 8:  If an Account does not exist by Braintree ID,
      //        1.  Query for an existing Account by NAME.
      Account existingAccount = findAccountByName(params.name);
      Account newAcct;
      //        2.  If no match, create an Account with that name.  
      if(existingAccount == null){
        newAcct = createAccount(params.name);
      }else{
        //      3.  If there is a match, create a new Account with that name and assign the matching Account as the Parent Account.
        newAcct = createAccount(params.name, existingAccount.Id);
      }
      Database.SaveResult sr = Database.insert(newAcct);
      if(sr.isSuccess()){
        result = true;
      }
    }
    return result;
  }
  private Account createAccount(String name){
    return createAccount(name, null);
  }
  private Account createAccount(String name, String parentId){
    Account acct = new Account();
    acct.Name = name;
    acct.Braintree_ID__c = params.braintreeId;
    if(parentId != null) acct.ParentId = parentId;
    return acct;
  }
  private Boolean brainTreeIdExists(String braintreeId){
    findAccountByBraintreeId(braintreeId);
    if(this.accountMap.keySet().size() == 1){
      return true;
    }else{
      return false;
    }
  }

  //Step 6: issue another query to find a possible parent account in the database
  private Account findAccountByNameAndBraintreeId(String name, String braintreeId){
    /*
      1.  Name matches the name provided in the rest request
      2.  Braintree ID != the ID from the rest request
      3.  “Parent Account” is empty
      4.  Limit 1 record in the response
    */
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
  private Account findAccountByName(String name){
    List<Account> accounts = [SELECT Id, Name, Braintree_ID__c 
                              FROM Account 
                              WHERE Name = :name
                              LIMIT 1];
    if(accounts.size() == 1){
      return accounts.get(0);
    }else{
      return null;
    }
  }
  private void findAccountByBraintreeId(String braintreeId){
    List<Account> accounts = [SELECT Id, Braintree_ID__c, ParentId FROM Account WHERE Braintree_ID__c = :braintreeId];
    if(accounts.size() == 1){
      //Step 6: If an Account exists, store the Account Id.
      foundAccountId = accounts.get(0).Id;
      accountMap.put(accounts.get(0).Id, accounts.get(0));
    }
  }

}