public with sharing class ReparentParams {
	public ReparentParams() {}
  public String name {get; set;}
  public String braintreeId {get; set;}
  public Boolean isValid(){
    return (this.name != null && this.name != '' && this.braintreeId != null && this.braintreeId != '');
  }
}