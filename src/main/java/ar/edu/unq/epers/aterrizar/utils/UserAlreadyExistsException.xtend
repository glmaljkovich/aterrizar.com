package ar.edu.unq.epers.aterrizar.utils

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class UserAlreadyExistsException extends Exception {
    Mail mail
}