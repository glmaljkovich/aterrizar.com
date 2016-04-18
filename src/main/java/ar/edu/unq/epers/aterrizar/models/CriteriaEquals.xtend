package ar.edu.unq.epers.aterrizar.models

import ar.edu.unq.epers.aterrizar.models.Criteria
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class CriteriaEquals extends Criteria {
	
	String field
	String value
	
	new(String string, String string2) {
		field = string
		value = string2
	}
	
	override getHQL() {
		return field + "='" + value + "' "	
	}
	
}