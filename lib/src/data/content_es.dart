// es: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesEs = [
  'manzana|Fruta roja o verde', 'pan|Se hornea cada día', 'río|Agua que corre', 'mar|Gran agua salada',
  'isla|Tierra rodeada de agua', 'montaña|Monte muy alto', 'bosque|Muchos árboles juntos', 'desierto|Tierra seca de arena',
  'nube|Flota en el cielo', 'lluvia|Cae de las nubes', 'nieve|Copos blancos de invierno', 'sol|Estrella del día',
  'luna|Satélite de la Tierra', 'estrella|Luz del cielo nocturno', 'viento|Aire en movimiento', 'hielo|Agua congelada',
  'fuego|Llamas y calor', 'piedra|Trozo de roca', 'arena|En la playa', 'flor|Crece en el jardín',
  'árbol|Tiene tronco y ramas', 'hoja|Cuelga de la rama', 'raíz|Bajo la planta', 'perro|Mascota que ladra',
  'gato|Mascota que maúlla', 'caballo|Animal de montar', 'pájaro|Tiene alas y plumas', 'pez|Nada con aletas',
  'abeja|Hace miel', 'ratón|Roedor pequeño', 'vaca|Da leche', 'oveja|Da lana',
  'pato|Ave que hace cuac', 'búho|Ave nocturna', 'conejo|Orejas largas', 'zorro|Astuto y rojizo',
  'oso|Gran animal del bosque', 'león|Rey de la selva', 'casa|Lugar donde vivir', 'puerta|Se abre para entrar',
  'ventana|Cristal en la pared', 'techo|Cubre la casa', 'pared|Separa las habitaciones', 'silla|Para sentarse',
  'mesa|Mueble para comer', 'cama|Para dormir', 'lámpara|Da luz', 'reloj|Marca la hora',
  'libro|Tiene muchas páginas', 'carta|Llega por correo', 'lápiz|Para escribir', 'escuela|Lugar para aprender',
  'maestro|Enseña a los niños', 'médico|Cura a los enfermos', 'cocinero|Trabaja en la cocina', 'jardín|Flores y plantas',
  'calle|Camino de la ciudad', 'puente|Cruza el río', 'ciudad|Muchas casas y gente', 'pueblo|Lugar pequeño',
  'coche|Tiene cuatro ruedas', 'tren|Va sobre rieles', 'barco|Navega por el mar', 'avión|Vuela por el cielo',
  'bicicleta|Dos ruedas y pedales', 'leche|Bebida blanca', 'agua|Para beber', 'queso|Hecho de leche',
  'miel|Dulce de abejas', 'azúcar|Endulza', 'sal|Da sabor', 'sopa|Plato caliente',
  'pastel|Dulce de fiesta', 'huevo|Lo pone la gallina', 'nariz|Para oler', 'ojo|Para ver',
  'oreja|Para oír', 'boca|Para hablar', 'mano|Tiene cinco dedos', 'pie|Va en el zapato',
  'corazón|Bombea la sangre', 'cabeza|Parte de arriba del cuerpo', 'pelo|Crece en la cabeza', 'diente|Sirve para morder',
  'zapato|Se lleva en el pie', 'sombrero|Se lleva en la cabeza', 'abrigo|Ropa de invierno', 'anillo|Joya del dedo',
  'color|Rojo, azul o verde', 'música|Notas y canciones', 'canción|Se canta', 'juego|Es divertido',
  'pelota|Redonda para jugar', 'mañana|Comienzo del día', 'tarde|Después del mediodía', 'noche|Hora oscura',
  'semana|Siete días', 'año|Doce meses', 'verano|Estación calurosa', 'invierno|Estación fría',
  'otoño|Caen las hojas', 'amigo|Persona querida', 'familia|Padres e hijos', 'niño|Persona pequeña',
  'nombre|Así te llamas', 'dinero|Para pagar', 'mercado|Lugar de compras', 'mapa|Muestra el camino',
  'sueño|Imágenes al dormir', 'luz|Ilumina', 'sombra|Oscura detrás de ti',
];

const List<String> kProverbsEs = [
  'Más vale tarde que nunca', 'No hay mal que por bien no venga', 'Al que madruga Dios lo ayuda', 'Quien busca encuentra',
  'Ojos que no ven corazón que no siente', 'En boca cerrada no entran moscas', 'Más vale pájaro en mano que ciento volando', 'Poco a poco se va lejos',
  'Dime con quién andas y te diré quién eres', 'No todo lo que brilla es oro', 'A caballo regalado no se le mira el diente', 'Camarón que se duerme se lo lleva la corriente',
  'El que no arriesga no gana', 'Perro que ladra no muerde', 'Cada loco con su tema', 'Querer es poder',
  'Donde hay humo hay fuego', 'A mal tiempo buena cara', 'El saber no ocupa lugar', 'Haz bien y no mires a quién',
  'Agua que no has de beber déjala correr', 'Hablando se entiende la gente', 'La práctica hace al maestro', 'Del dicho al hecho hay mucho trecho',
];

const List<String> kGroupsEs = [
  'Frutas|manzana pera cereza plátano uva limón naranja', 'Verduras|zanahoria patata cebolla tomate pepino lechuga espinaca', 'Animales|perro gato caballo vaca oveja cabra burro', 'Aves|paloma cuervo búho águila gorrión cigüeña loro',
  'Colores|rojo azul verde amarillo blanco negro marrón', 'Muebles|silla mesa cama armario sofá estante cómoda', 'Cuerpo|cabeza mano pie nariz ojo oreja rodilla', 'Ropa|camisa pantalón falda abrigo chaqueta calcetín vestido',
  'Oficios|médico maestro cocinero panadero piloto pintor jardinero', 'Bebidas|agua leche zumo café té chocolate limonada', 'Tiempo|lluvia nieve viento niebla granizo tormenta trueno', 'Vehículos|coche tren autobús barco bicicleta avión tractor',
  'Instrumentos|violín guitarra flauta tambor piano arpa trompeta', 'Herramientas|martillo sierra alicate taladro pala lima tijeras',
];

const List<String> kSynonymsEs = [
  'rápido|veloz', 'grande|enorme', 'pequeño|diminuto', 'bonito|hermoso',
  'listo|astuto', 'empezar|comenzar', 'alegre|contento', 'final|fin',
  'camino|sendero', 'valor|coraje', 'hablar|conversar', 'mirar|observar',
  'andar|caminar', 'calma|tranquilidad',
];

const List<String> kAntonymsEs = [
  'grande|pequeño', 'largo|corto', 'caliente|frío', 'claro|oscuro',
  'rápido|lento', 'viejo|joven', 'lleno|vacío', 'arriba|abajo',
  'día|noche', 'duro|blando', 'mucho|poco', 'cerca|lejos',
  'ligero|pesado', 'pobre|rico', 'temprano|tarde', 'abierto|cerrado',
  'alto|bajo', 'enfermo|sano',
];
