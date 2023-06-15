Yo como usuario deberia poder conseguir la insignia pertinente si he completado un challenge

En el FrontEnd lo que he hecho es quizas un poco mas abstracto ya que no tenemos definida aun la logica para realizar los challenges.
	Lo que he hecho a sido modificar el archivo qr_screen.dart que es donde leemos los codigos qr. En este he añadido una nueva funcion que se llama
	getNewInsignia que lo que hace es llamar a la API para poder añadir la nueva insignia a tu lista.
	Esta funcion la ejecuto cuando estamos leyendo un qr y por tanto estamos validando el challenge.
