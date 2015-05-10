@RestResource(urlMapping='/ReParent')
global with sharing class ReparentApexRestService {

  @HttpPost 
  global static Boolean doPost() {
    RestRequest req = RestContext.request;
    //Deserialize the Requst body in to params we define.
    ReparentParams params = (ReparentParams)JSON.deserialize(req.requestbody.toString(), ReparentParams.class);
    //Verify the params needed to run this service are present
    if(params.isValid()){
      ReparentService service = new ReparentService(params);
      //Return the result of the service
      return service.run();
    }
    //If the params are not correct, return false.
    return false;
  }
}