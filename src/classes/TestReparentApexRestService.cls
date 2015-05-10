@isTest

private class TestReparentApexRestService {
	@testSetup static void setup() {
    Account parent = new Account();
    parent.Braintree_ID__c = '1';
    parent.Name = 'parent';
    insert parent;

    Account child = new Account();
    child.Braintree_ID__c = '2';
    child.name = 'parent';
    insert child;

    Account braintree = new Account();
    braintree.name = 'Braintree';
    insert braintree;
  }
  @isTest 
  static void testFailsOnMissingName() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    ReparentParams params = new ReparentParams();
    params.name = '';
    params.braintreeId = '1';
    
    req.requestURI = '/services/apexrest/ReParent';  
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(JSON.serialize(params));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
      Boolean result = ReparentApexRestService.doPost();
      System.assertEquals(false, result, 'It should return a failure for not having a name');
    Test.stopTest();
  }
  @isTest 
  static void testFailsOnMissingBrainTreeId() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    ReparentParams params = new ReparentParams();
    params.name = 'parent';
    params.braintreeId = '';
    
    req.requestURI = '/services/apexrest/ReParent';  
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(JSON.serialize(params));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
      Boolean result = ReparentApexRestService.doPost();
      System.assertEquals(false, result, 'It should return a failure for not having a braintreeId');
    Test.stopTest();
  }

  @isTest 
  static void testCanReparent() {
    Account parent = [SELECT Id, ParentId, Braintree_ID__c FROM Account WHERE Braintree_ID__c = '1'];
    Account childToReparent = [SELECT Id, ParentId, Braintree_ID__c FROM Account WHERE Braintree_ID__c = '2'];

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    ReparentParams params = new ReparentParams();
    params.name = 'parent';
    params.braintreeId = '2';
    
    req.requestURI = '/services/apexrest/ReParent';  
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(JSON.serialize(params));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
      System.assertEquals(null, childToReparent.ParentId, 'The child should not have a parent Id yet');
      Boolean result = ReparentApexRestService.doPost();
      System.assertEquals(true, result, 'It should return a success');
      childToReparent = [SELECT Id, ParentId, Braintree_ID__c FROM Account WHERE Braintree_ID__c = '2'];
      System.assertNotEquals(null, childToReparent.ParentId, 'The child should have a parent Id');
      System.assertEquals(parent.Id, childToReparent.ParentId, 'The child should have a parent Id from the Parent with same name and diff braintreeId');
    Test.stopTest();
  }

  @isTest 
  static void testNotFoundByBraintreeIdNoMatchByName() {
    Account parent = [SELECT Id, ParentId, Braintree_ID__c FROM Account WHERE Braintree_ID__c = '1'];

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    ReparentParams params = new ReparentParams();
    params.name = 'new acct';
    params.braintreeId = '3';
    
    req.requestURI = '/services/apexrest/ReParent';  
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(JSON.serialize(params));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
      Boolean result = ReparentApexRestService.doPost();
      System.assertEquals(true, result, 'It should return a success');
      List<Account> accts = [SELECT Id, ParentId FROM Account WHERE Braintree_ID__c = '3'];
      System.assertEquals(1, accts.size(), 'There should be a new account created');
      Account newAcct = accts.get(0);
      System.assertEquals(null, newAcct.ParentId, 'The new acct should not have a parent id');
    Test.stopTest();
  }

  @isTest 
  static void testNotFoundByBraintreeIdMatchByName() {
    Account parent = [SELECT Id, ParentId, Braintree_ID__c FROM Account WHERE Name = 'Braintree'];

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    ReparentParams params = new ReparentParams();
    params.name = 'braintree';
    params.braintreeId = '3';
    
    req.requestURI = '/services/apexrest/ReParent';  
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueof(JSON.serialize(params));
    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
      Boolean result = ReparentApexRestService.doPost();
      System.assertEquals(true, result, 'It should return a success');
      List<Account> accts = [SELECT Id, ParentId FROM Account WHERE Braintree_ID__c = '3'];
      System.assertEquals(1, accts.size(), 'There should be a new account created');
      Account newAcct = accts.get(0);
      System.assertEquals(parent.Id, newAcct.ParentId, 'The new acct should have a parent id based on name match');
    Test.stopTest();
  }
}