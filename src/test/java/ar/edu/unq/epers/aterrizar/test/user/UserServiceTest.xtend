package ar.edu.unq.epers.aterrizar.test.user

import ar.edu.unq.epers.aterrizar.models.User
import ar.edu.unq.epers.aterrizar.services.UserService
import ar.edu.unq.epers.aterrizar.utils.EnviadorDeMails
import ar.edu.unq.epers.aterrizar.utils.EnviarMailException
import ar.edu.unq.epers.aterrizar.utils.Mail
import java.sql.Date
import org.junit.Before
import org.junit.Test
import org.mockito.Mockito

import static org.junit.Assert.*

public class UserServiceTest {

    UserService userService;
    User u;
    EnviadorDeMails enviador
    Mail mail

    @Before
    def void setUp() {
        // Inicializaciones
        userService = new UserService()
        userService.cleanDatabase()
        u = new User("Jose", "Juarez", "josejuarez", "pe@p.com", new Date(1), "1234", false)

        // Mocks
        enviador = Mockito.mock(typeof(EnviadorDeMails))
        mail = new Mail("Su codigo es: " + "pepejuarez".hashCode(), "Codigo de validacion", "p@p.com", "admin@pp.com")

        // Register user
        userService.setEnviador(enviador)
        userService.registerUser(u);
    }

    @Test
    def void testANewUserRegistersSuccesfullyIntoTheSystem() {

        try {
            val u2 = new User("Pepe", "Juarez", "pepejuarez", "p@p.com", new Date(1), "1234", false)
            userService.registerUser(u2);
            val user = userService.getUser("pepejuarez");
            assertEquals(user.getNombreDeUsuario(), u2.getNombreDeUsuario());
            Mockito.verify(enviador).enviarMail(mail)
        } catch(Exception e) {
            fail
        }
    }

    @Test
    def void testAUserValidatesCorrectly() {
        try {
            assertTrue(userService.validateUser(u.nombreDeUsuario, u.nombreDeUsuario.hashCode))
        } catch(Exception e) {
            fail
        }
    }

    @Test
    def void testAPasswordChanges() {
        try {

            userService.changePassword(u.nombreDeUsuario, "3456")
            val u2 = userService.getUser(u.nombreDeUsuario)
            assertEquals(u2.password, "3456")
        } catch(Exception e) {
            fail
        }
    }

    @Test
    def void testARepeatedPasswordDoesntChange() {
        try {
            userService.changePassword(u.nombreDeUsuario, u.password)
            fail
        } catch(Exception e) {
            assertEquals(e.getMessage(), "La nueva contraseña no puede ser igual a la anterior.")
        }
    }

    @Test
    def testAUserLoginsSuccessfully() {
        assertTrue(userService.login(u.nombreDeUsuario, u.password))
    }

    @Test(expected = EnviarMailException)
    def void testCheckForExceptionOnMailSending(){
        Mockito.doThrow(EnviarMailException).when(enviador).enviarMail(mail)
        val u2 = new User("Pepe", "Juarez", "pepejuarez", "p@p.com", new Date(1), "1234", false)
        userService.registerUser(u2);
    }


}