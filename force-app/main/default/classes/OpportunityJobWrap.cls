public class OpportunityJobWrap {

	public String id {get;set;}

	public String projectName {get;set;}

	public String address {get;set;}

	public Boolean archived {get;set;}

	public List<Location> locations {get;set;}

	public class Location{

		public Decimal latitude {get;set;}

		public Decimal longitude {get;set;}

		public Long radius {get;set;}
	}

}