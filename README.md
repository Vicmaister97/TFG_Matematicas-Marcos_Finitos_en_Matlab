# TFG_Matematicas-Marcos_Finitos_en_Matlab
El presente repositorio contiene todo el código elaborado en Matlab para mi TFG del Grado en Matemáticas. Destacar la aplicación de recuperación de imagenes, implementada en image_reconstruction.m

-   En el directorio "MN" se encuentra el método numérico del marco, implementado en el fichero "MN_Marco.m", junto con las pruebas realizadas y la obtención de gráficas, implementadas en el fichero "Marco.mlx".

-   En el directorio "versiones_anteriores" se encuentra el fichero "sampling.m", que implementa el Ejemplo 3.16 del TFG, pag 245 de la bibliografía principal. También se encuentra el fichero "OLD2_image_compression.m", detallado también en el TFG.

-   El fichero "image_compression.m" implementa como una función la compresión detallada en el TFG que hace uso de la DFT o Transformada Discreta de Fourier, esencial para obtener una imagen de banda limitada a partir de la imagen original. 
-       Un ejemplo de ejecución sería: >> [F, I_Fourier, I_Fourier_enfila]=image_compression('images/original/', 'tries', 3200, 0);
-       En este caso, guarda la imagen en grayscale en el directorio "images/original/", y la imagen de banda limitada en "images/bandlimited/".

-   El fichero "sampling_reconstruction.m" implementa como una función gran parte del algoritmo de recuperación. Todo esto se detalla en el TFG, pero en líneas generales se encarga de construir la matriz del operador análisis, la matriz de la inversa de Moore-Penrose y calcular la pseudoinversa de vknown, lo que nos da la imagen recuperada en forma de fila, de la cual extraemos los píxeles que se habían perdido en la imagen_missing para reemplazarlos por los aproximados con esta imagen recuperada.

-   El fichero "image_reconstruction.m" implementa como función la recuperación de una imagen original en RGB, que convierte a grayscale y simula la pérdida de píxeles aleatorios.
-       Un ejemplo de ejecución sería: >> image_reconstruction('images/original/', 'tries');
-       En este caso, guarda todas las imagenes resultantes en el directorio "images/reconstructed/".

Tanto en "images/bandlimited/examples" como en "images/reconstructed/examples" se encuentran algunos ejemplos de ejecuciones realizadas. Se insta al lector a verlas.
