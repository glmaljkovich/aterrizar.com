package ar.edu.unq.epers.aterrizar.user

import java.sql.Connection;
import java.sql.DriverManager;
import org.eclipse.xtext.xbase.lib.Functions.Function1
import java.sql.ResultSet

class UserRepo {
	
	boolean userCheckStatus = false
	User userInsideDatabase
	
	/**
	 * Checks if the username is in the database
	 * */
	 private def boolean checkForUser(String userName){
		execute[conn|
			val ps = conn.prepareStatement("SELECT * FROM usuarios WHERE username=" +userName+ ";")
			val rs = ps.executeQuery()
			
			if(rs.next()){
				this.userCheckStatus = true
			} else {
				this.userCheckStatus = false
			}
		]
	 	return userCheckStatus
	 }
	 
	 /**
	  * Registers user into the database if the user doesn't exist
	  * */
	 def registerUser(User user) throws Exception{
	 	
	 	if(!this.checkForUser(user.getNombreDeUsuario())){
		 	val nombre = user.getNombre()
		 	val apellido = user.getApellido()
		 	val nombreDeUsuario = user.getNombreDeUsuario()
			val eMail = user.getEMail()
			val fechaDeNacimiento = user.getFechaDeNacimiento()
			val password = user.getPassword()
			val validated = user.isValidated()
			
			execute[conn|
				val ps = conn.prepareStatement("INSERT INTO usuarios (name, surname, username, email, birth, password, validationstate) VALUES (?,?,?,?,?,?,?);")
				ps.setString(1, nombre)
				ps.setString(2, apellido)
				ps.setString(3, nombreDeUsuario)
				ps.setString(4, eMail)
				// ps.setString(5, fechaDeNacimiento) es una fecha, no puede ser guardada como String...
				ps.setString(6, password)
				ps.setBoolean(7, validated)
				
				ps.execute()
				
			]
	 	} else {
	 		throw new Exception("El usuario ya esta registrado.")
	 	}
	 }
	 
	 /**
	  * Retrieves the user from the database if the user exists
	  * */
	 def User getUser(String userName) throws Exception{
	 	if(this.checkForUser(userName)){
	 		execute[conn|
	 			val ps = conn.prepareStatement("SELECT * FROM usuarios WHERE username=" +userName+ ";")
	 			val rs = ps.executeQuery()
	 			rs.next()
	 			
	 			userInsideDatabase = new User(rs.getString("name"), rs.getString("surname"), rs.getString("username"), rs.getString("email"), rs.getDate("birth"), rs.getString("password"), rs.getBoolean("validationstate"))
	 			null
	 		]
	 	} else {
	 		throw new Exception("No existe un usuario con ese nombre.")
	 	}
	  	return userInsideDatabase
	 }
	 
	 /**
	  * Changes the user password in the database if the user exists
	  * */
	 def changePassword(String userName, String passWord) throws Exception{
	 	if(this.checkForUser(userName)){
	 		execute[conn|
	 			val ps = conn.prepareStatement("UPDATE usuarios SET password=" +passWord+ " WHERE username=" +userName+ ";")
	 			ps.execute()
	 		]
	 	} else {
	 		throw new Exception("El usuario al que se le quiere cambiar la password no existe.")
	 	}
	 } 
	 
	def void execute(Function1<Connection, Object> closure){
		var Connection conn = null
		try{
			conn = this.connection
			closure.apply(conn)
		}finally{
			if(conn != null)
				conn.close();
		}
	}

	def getConnection() {
		Class.forName("com.mysql.jdbc.Driver");
		return DriverManager.getConnection("jdbc:mysql://localhost:3306/epers_aterrizar?user=root&password=root")
	}
	 
}