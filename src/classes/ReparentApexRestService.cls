@RestResource(urlMapping='/ReParent')
global with sharing class ReparentApexRestService {

  @HttpPost 
  global static Boolean doPost() {
    RestRequest req = RestContext.request;
    ReparentParams params = (ReparentParams)JSON.deserialize(req.requestbody.toString(), ReparentParams.class);
    if(params.isValid()){
      
    }else{
      return false;
    }
    return false;
  }
}