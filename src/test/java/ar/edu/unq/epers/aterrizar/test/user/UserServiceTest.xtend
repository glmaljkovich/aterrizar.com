package ar.edu.unq.epers.aterrizar.test.user

import ar.edu.unq.epers.aterrizar.models.User
import ar.edu.unq.epers.aterrizar.services.UserService
import ar.edu.unq.epers.aterrizar.utils.EnviadorDeMails
import ar.edu.unq.epers.aterrizar.exceptions.EnviarMailException
import ar.edu.unq.epers.aterrizar.utils.Mail
import ar.edu.unq.epers.aterrizar.exceptions.UserAlreadyExistsException
import ar.edu.unq.epers.aterrizar.exceptions.UserDoesNotExistsException
import ar.edu.unq.epers.aterrizar.exceptions.UserNewPasswordSameAsOldPasswordException
import java.sql.Date
import org.junit.Before
import org.junit.Test
import org.mockito.Mockito

import static org.junit.Assert.*

public class UserServiceTest {

	UserService userService;
	User user;
	EnviadorDeMails enviador
	Mail mail

	@Before
	def void setUp() {

		// Inicializaciones
		userService = new UserService()
		userService.deleteAllUsersInDB()
		user = new User("Jose", "Juarez", "josejuarez", "pe@p.com", new Date(1), "1234", false)

		// Mocks
		enviador = Mockito.mock(typeof(EnviadorDeMails))
		mail = new Mail("Su codigo es: " + "pepejuarez".hashCode(), "Codigo de validacion", "p@p.com", "admin@pp.com")

		// Register user
		userService.setEnviador(enviador)
		userService.registerUser(user);
	}

	@Test
	def void testANewUserRegistersSuccesfullyIntoTheSystem() {

		val user2 = new User("Pepe", "Juarez", "pepejuarez", "p@p.com", new Date(1), "1234", false)
		userService.registerUser(user2);
		val user = userService.checkForUser("pepejuarez");
		assertEquals(user.getNombreDeUsuario(), user2.getNombreDeUsuario());
		Mockito.verify(enviador).enviarMail(mail)
	}

	@Test(expected=UserAlreadyExistsException)
	def void testANewUserCannotRegisterIfAlreadyExists() {
		userService.registerUser(user);
	}

	@Test(expected=UserDoesNotExistsException)
	def void testAnInexistentUserCannotBeRetrieved() {
		userService.checkForUser("i_dont_exist");
	}

	@Test
	def void testAUserValidatesCorrectly() {
		assertTrue(userService.validateUser(user.nombreDeUsuario, user.nombreDeUsuario.hashCode))
	}

	@Test
	def void testAPasswordChanges() {
		userService.changePassword(user.nombreDeUsuario, "3456")
		val user2 = userService.checkForUser(user.nombreDeUsuario)
		assertEquals(user2.password, "3456")
	}

	@Test(expected=UserNewPasswordSameAsOldPasswordException)
	def void testAPasswordDoesNotChangeIfItIsSameAsOld() {
		userService.changePassword(user.nombreDeUsuario, user.password)
	}

	@Test
	def testAUserLoginsSuccessfully() {
		assertTrue(userService.login(user.nombreDeUsuario, user.password))
	}

	@Test(expected=UserDoesNotExistsException)
	def void testAUserFailsToLoginBecauseTheUserDoesNotExist() {
		userService.login("i_dont_exist", "asdasdasd")
	}

	@Test
	def void testAUserFailsToLoginBecausePasswordIsInvalid() {
		assertFalse(userService.login(user.nombreDeUsuario, "passNoValida"))
	}

	@Test(expected=EnviarMailException)
	def void testCheckForExceptionOnMailSending() {
		Mockito.doThrow(EnviarMailException).when(enviador).enviarMail(mail)
		val user2 = new User("Pepe", "Juarez", "pepejuarez", "p@p.com", new Date(1), "1234", false)
		userService.registerUser(user2);
	}

}
