%% Ejemplo de cómo trabajar con imágenes en Matlab: https://es.mathworks.com/help/images/ref/mat2gray.html
%clear all;
%clc;

%% Input: Nombre de la imagen (en la carpeta images/original) a muestrear con Fourier
%%
%%  NOTA: IMAGEN en JPEG!!!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Posible leer la extensión cortando la cadena por el punto!
%%
%%  NOTA2: FALTA COMPROBAR si YA EXISTE la imagen en GRAYSCALE o la imagen RESULTADO para evitar reescribir!!

%% INPUT: 
        % nombre_file = String con el nombre de la imagen a muestrear (en images/original)
        % num_elems_Fourier = Número que sirve para limitar los coefs de
        %                       Fourier con los que nos quedamos
        % simple_or_reconstruct:    
        %      Vale 0 si queremos la ejecución simple -- Muestrea y guarda
        %          las imágenes en images/bandlimited
        %      Vale TODO!=0 si queremos ejecución para image_reconstruction --
        %           Guarda la bandlimited en images/reconstructed
function F = OLD2_image_compression(nombre_file, num_elems_Fourier, simple_or_reconstruct)

    tic;    % Comenzamos a medir el tiempo
    F = {}; %% OUTPUT, F = cjto de coefs de Fourier que limitan la imagen
    index = 1;
    iterss = 0;
    
    % Variables para leer la imagen original y guardar la bandlimited
    origen = 'images/original/';
    %nombre_file = 'tries';
    extension = '.jpg';
    prev = strcat(nombre_file, extension);
    tit_read = strcat(origen, prev);
    
    %% También afecta a la hora de limitar la imagen!
    if simple_or_reconstruct == 0       %% Ejecución SIMPLE
        destino = 'images/bandlimited/';
        
        % Empezamos pasando una imagen como input y obtenemos como output la imagen
        % como matriz
        % Primero obtenemos la imagen en RGB
        RGB = imread(tit_read);
        %figure (1);
        %imshow(RGB);

        % La convertimos en una imagen de grises y la mostramos
        I = rgb2gray(RGB);
        figure (22);
        imshow(I);

        %% Guardamos en origen la imagen en grayscale
        nombre_file_dest = strcat(nombre_file, '_grayscale');
        extension = '.jpg';
        prev = strcat(nombre_file_dest, extension);
        tit_write = strcat(origen, prev);

        imwrite(I,tit_write);
    else       %% Ejecución RECONSTRUCT
        destino = 'images/reconstructed/';
        recons = strcat(destino, nombre_file);
        tit = strcat(recons, extension);
        %% Cogemos la imagen con missing pixels en grayscale
        I = imread(tit);


        % La convertimos en una imagen de grises y la mostramos
        %   COMENTAR si llamamos a la función desde
        %   image_reconstruction!!!!!!!!
            % En este caso viene ya en grayscale
        I = rgb2gray(I);
        figure (22);
        imshow(I);

    end

    % Una vez tenemos la imagen en grayscale (I), la imagen es una matriz donde
    % cada elemento representa un pixel, que solo tiene 1 valor intensidad

    % Realizamos la transformada de fourier discreta sobre la matriz de la
    % imagen

    I_Fourier = fft2(I);
    %figure (3);
    %imshow(abs(I_Fourier));
    % Vemos su valor min y max
    min_Fourier = min(abs(I_Fourier(:)))
    max_Fourier = max(abs(I_Fourier(:)))

    %media_Fourier = floor(abs(mean2(I_Fourier)))

    %% COMPARAR EN VALOR ABSOLUTO
    % Probar a restar a la matriz original por la media
    %% LUEGO SUMARLE LA MEDIA!!!
    tam = size(I_Fourier)
    M = tam(1);
    N = tam(2);

    I_Fourier_reescalada = I_Fourier;
    count = 0;
    
    %% AQUÍ VIENE LA "COMPRESIÓN"!!
    % Sustituimos los coeficientes menores que (media_Fourier*factor???) por 0
    
    %% Si estamos en el modo simple, num_elems_Fourier es el que limita las bandas elegidas
    if simple_or_reconstruct == 0
        for j=1:M
            for k=1:N
                if abs(I_Fourier_reescalada(j,k)) < (num_elems_Fourier)            %% PROBAR A VARIARLO
                    I_Fourier_reescalada(j,k) = 0;
                else
                    count = count + 1;          % Para contar con cuántos coefs nos quedamos
                    F{index} = [j,k];           % Guardamos el índice del coef de Fourier que mantenemos  
                    index = index + 1;
                end
            end
        end
        
    %% Si estamos en el modo reconstruct, num_elems_Fourier es EL MAXIMO VALOR que puede tomar count
            % Es decir, dice el MAXIMO valor de length(F) con el que
            % podemos limitar la imagen y que la reconstrucción sea única 
    else
            
        
        %%    Buscamos el valor óptimo para limitar la imagen 
        %%      en el intervalo [tries_anterior, tries]
                % Empieza con tries_anterior acotando <1 que seguro que NO lo cumple
                %   y que salga con tries LO CUMPLE y estamos por debajo de num_elems_Fourier
        %{
        tries = 1;
        count = M*N;
        while count>num_elems_Fourier
            %% En cada iter, reseteamos las variables para reiniciar la comprobación
            %%  con el nuevo tries
            iterss = iterss + 1;
            count = 0;
            clear F;
            F = {};
            index = 1;
            I_Fourier_reescalada = I_Fourier;
            
            for j=1:M
                for k=1:N
                    if abs(I_Fourier_reescalada(j,k)) < (tries)            %% PROBAR A VARIARLO
                        I_Fourier_reescalada(j,k) = 0;
                    else
                        count = count + 1;          % Para contar con cuántos coefs nos quedamos
                        F{index} = [j,k];           % Guardamos el índice del coef de Fourier que mantenemos  
                        index = index + 1;
                    end
                end
            end
            
            if count>num_elems_Fourier
                tries = tries*10
            end  
            
        end
        
        
        % Aquí por primera vez count está por debajo de num_elems_Fourier
        %%    Nuestro valor optimo para limitar la imagen 
        %%      está en el intervalo [tries_anterior, tries]
                %   con tries_anterior NO cumplía el PPIO de Incertidumbre
                %   y con tries LO CUMPLE y estamos por debajo de num_elems_Fourier
        if tries>1
            tries_anterior = tries/10;
        else
            tries_anterior = 1;     % Para que vuelva a hacerlo con 1 y se quede así
        end
        %}
        % Probamos con la media entre [low_intervalo, high_intervalo], para tratar
            % de refinar la base y coger cuantos más coefs posibles
        %% BUSQUEDA BINARIA!! Coste en el peor de los casos de O(log(n))!!!!!!!!!!
        %% Vamos buscando el óptimo en el intervalo [low_intervalo, high_intervalo]
        %   porque sabemos que con low_intervalo NO lo cumple
        %       y con high_intervalo LO CUMPLE
        %low_intervalo = tries_anterior;             %% Mejor que min_Fourier y max_Fourier
        %high_intervalo = tries;
        low_intervalo = floor(min_Fourier);
        high_intervalo = floor(max_Fourier);
        media = floor( (low_intervalo+high_intervalo)/2 );
        count = M*N;
        %cota = abs(max_Fourier/1000);       %% PROBAR A CAMBIAR
        cota = 100            % Suele ir bien con cota=100, PROBAR A CAMBIAR
        
        %% BÚSQUEDA BINARIA, vamos a tratar de reducir el intervalo al máximo
        %   OPTIMIZAMOS: Las últimas iters ya han cercado el intervalo
        %   MUCHO!! Son un poco redundantes por mejorar en pocos coefs de
        %   Fourier. Ejemplo [30.000, 30.100] que dan 324, 317 coefs respectivamente
        %   Si con una media nos sale que length(F) está en el intervalo 
            %   [num_elems_Fourier-4, num_elems_Fourier-1] NOS VALE!!

        while (high_intervalo - low_intervalo) > cota
            %% En cada iter, reseteamos las variables para reiniciar la comprobación
            %%  con el nuevo tries(media)
            low_intervalo
            high_intervalo
            media
            iterss = iterss + 1;
            count = 0;
            clear F;
            F = {};
            index = 1;
            I_Fourier_reescalada = I_Fourier;
            
            for j=1:M
                for k=1:N
                    if abs(I_Fourier_reescalada(j,k)) < (media)            %% PROBAR A VARIARLO
                        I_Fourier_reescalada(j,k) = 0;
                    else
                        count = count + 1;          % Para contar con cuántos coefs nos quedamos
                        F{index} = [j,k];           % Guardamos el índice del coef de Fourier que mantenemos  
                        index = index + 1;
                    end
                end
            end
            count
            
            %% OPTIMIZACIÓN
            % Ejemplo con num_elems_Fourier = 320
            % Si ya hemos hallado una F con count=319or318or317or316 and
            % count<320
                %% NOS VALE!! Es una gran aproximación a la óptima
            if count >= (num_elems_Fourier-4) && (count < num_elems_Fourier)
                fprintf("OPTIMIZADO a 4 valores de num_elems_Fourier!");
                high_intervalo = media;
                break;
            end
            
            if count<num_elems_Fourier
                high_intervalo = media;
                % Cambiamos el intervalo [low_intervalo, media]
                media = floor( (low_intervalo+high_intervalo)/2 );

            else
                low_intervalo = media;
                % Cambiamos el intervalo [media, high_intervalo]
                media = floor( (low_intervalo+high_intervalo)/2 );
            end  
            
        end
        
        %% Ya hemos acotado el intervalo al máximo (según cota)
                %%   o alcanzado valor aceptable de length(F)
        %% NOS QUEDAMOS CON high_intervalo que CUMPLE el PPIO INCERTIDUMBRE
        media = high_intervalo
        iterss
        fprintf('Limitamos a valores por encima de %d\n', media);
                
        %% YA TENEMOS NUESTRA BASE DE FOURIER OPTIMA!! Tan grande casi como
            %%  es posible, y cumpliendo el PPIO INCERTIDUMBRE FOURIER
            
        % Creamos la imagen bandlimited
        count = 0;
        clear F;
        F = {};
        index = 1;
        I_Fourier_reescalada = I_Fourier;
        for j=1:M
            for k=1:N
                if abs(I_Fourier_reescalada(j,k)) < (media)
                    I_Fourier_reescalada(j,k) = 0;
                else
                    count = count + 1;          % Para contar con cuántos coefs nos quedamos
                    F{index} = [j,k];           % Guardamos el índice del coef de Fourier que mantenemos  
                    index = index + 1;
                end
            end
        end
        
        
    end

    %% QUEDARNOS CON EL 50,30,20 y 10% de los coef de Fourier para ver la diferencia


    %% YA CON ESTO, ESTAMOS COGIENDO LOS coeficientes de Fourier + GRANDES (y que mejor aproximan la imagen)
    %% elegir < mitad(+ grande)
    %% ELEGIR 10% DEL MAXIMO para quedarnos

    %figure (4);
    %imshow(abs(I_Fourier_reescalada));
    I_Fourier_reescalada;

    pixeles_total = M*N;
    %pixeles_reescalada = 0.1*pixeles_total;

    % Escribimos el porcentaje de compresión alcanzado
    compression = round(pixeles_total/count);
    fprintf('El ratio de compresion respecto a la imagen original es de %d:1\n', compression);

    I_recuperada = ifft2(I_Fourier_reescalada);
    ent_recuperada = floor(I_recuperada);

    %% VER ERROR RESPECTO DE I!!!

    % Convierta la matriz en una imagen. Mostrar los valores máximo y mínimo de la imagen.
    K = mat2gray(ent_recuperada);
    min_recons = min(K(:))
    max_recons = max(K(:))
    %% OJO, todos los valores están en el intervalo [0,1]
    figure(55);
    %imagesc(K);
    imshow(K);

    comp = sprintf('_ratio_%d', compression);
    nombre_file_dest = strcat(nombre_file, comp)
    extension = '.jpg';
    prev = strcat(nombre_file_dest, extension);
    tit_write = strcat(destino, prev);
    
    imwrite(K,tit_write);
    %% AJUSTAR ANCHO Y ALTO A LA IMAGEN ORIGINAL

    toc;        % Paramos de medir el tiempo

    %{
    % Realice una operación que devuelva una matriz numérica. Esta operación busca bordes.
    J = filter2(fspecial('sobel'),I);
    min_matrix = min(J(:))

    max_matrix = max(J(:))

    % Tenga en cuenta que la matriz tiene un tipo de datos con valores fuera del intervalo [0,1], 
    % incluidos los valores negativos.double

    % Mostrar el resultado de la operación. Dado que el rango de datos de la matriz está fuera del rango de visualización 
    % predeterminado de , cada píxel con un valor positivo se muestra como blanco y 
    %   cada píxel con un valor negativo o cero se muestra como negro.imshow Es difícil ver los bordes de los granos de arroz.
    figure (3);
    imshow(J);

    % Convierta la matriz en una imagen. Mostrar los valores máximo y mínimo de la imagen.

    K = mat2gray(J);
    min_image = min(K(:))
    max_image = max(K(:))

    % Tenga en cuenta que los valores siguen siendo de tipo de datos, pero que todos los valores están en el intervalo [0, 1].double

    % Muestra el resultado de la conversión. Los píxeles muestran un rango de colores en escala de grises, lo que hace que la ubicación de los bordes sea más evidente.

    figure;
    imshow(K);
    %}

end

