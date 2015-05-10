@RestResource(urlMapping='/ReParent')
global with sharing class ReparentApexRestService {

  @HttpPost 
  global static Boolean doPost() {
    RestRequest req = RestContext.request;
    ReparentParams params = (ReparentParams)JSON.deserialize(req.requestbody.toString(), ReparentParams.class);
    if(params.isValid()){
      ReparentService service = new ReparentService(params);
      return service.run();
    }
    return false;
  }
}