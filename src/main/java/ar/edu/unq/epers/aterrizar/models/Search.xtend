package ar.edu.unq.epers.aterrizar.models

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList

@Accessors
class Search {
	
	List<Criteria> criterias
	private int id
	FlightOrder flightOrder
	
	new(){
		criterias = new ArrayList<Criteria>()
	}
	
	def getHQL(){
		var res = "SELECT flights FROM Airline as airline INNER JOIN airline.flights as flights "
		if(criterias.size()>0){
			res = res + "WHERE "
			for(criteria : criterias){
				res = res + criteria.getHQL()
			}
		}
		return res + hqlForOrder()
	}
	
	def hqlForOrder(){
		switch(flightOrder){
			case Cost : "ORDER BY flights.price ASC"
			case SectionNo : "INNER JOIN flights.sections as sections GROUP BY flights ORDER BY count(*) ASC" // no se si anda.
			case Duration : "ORDER BY DATEDIFF(flights.arrivalDate, flights.departureDate) ASC" // TODO podria agregarle una property Duration...
			default : ""
			
		}
	}
	
}