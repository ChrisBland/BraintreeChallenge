@RestResource(urlMapping='/ReParent')
global with sharing class ReparentApexRestService {

  @HttpPost 
  global static Boolean doPost() {
    RestRequest req = RestContext.request;

    return false;
  }
}