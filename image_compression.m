%% Ejemplo de cómo trabajar con imágenes en Matlab: https://es.mathworks.com/help/images/ref/mat2gray.html

%%
%%  NOTA: IMAGEN en JPG!!!!!
%%
%%  NOTA2: FALTA COMPROBAR si YA EXISTE la imagen en GRAYSCALE o la imagen RESULTADO para evitar reescribir!!

%% INPUT:
        % origen = String con la dirección/carpeta de la que se lee la imagen
        % nombre_file = String con el nombre de la imagen a muestrear
        % num_elems_Fourier = Número que coefs de Fourier con los que nos quedamos
        % simple_or_reconstruct:
        %      Vale 0 si queremos la ejecución simple -- Muestrea y guarda
        %          las imágenes en images/bandlimited
        %      Vale TODO!=0 si queremos ejecución para image_reconstruction --
        %           Guarda la bandlimited en images/reconstructed
function [F, I_Fourier, I_Fourier_enfila] = image_compression(origen, nombre_file, num_elems_Fourier, simple_or_reconstruct)
    
    tic;    % Comenzamos a medir el tiempo
    %% OUTPUT: F = cjto de coefs de Fourier que limitan la imagen
    F = []; 
    
    % Variables para leer la imagen original y guardar la bandlimited
    %origen = 'images/original/';
    %nombre_file = 'fire';
    extension = '.jpg';
    prev = strcat(nombre_file, extension);
    tit_read = strcat(origen, prev);
    
    if simple_or_reconstruct == 0       %% Ejecución SIMPLE
        destino = 'images/bandlimited/';
        
        % Empezamos pasando una imagen como input y obtenemos la imagen
        % como matriz
        % Primero obtenemos la imagen en RGB
        RGB = imread(tit_read);
        %figure (1);
        %imshow(RGB);

        % La convertimos en una imagen de grises
        I = rgb2gray(RGB);
        %figure (22);
        %imshow(I);

        %% Guardamos en origen la imagen en grayscale
        nombre_file_dest = strcat(nombre_file, '_grayscale');
        extension = '.jpg';
        prev = strcat(nombre_file_dest, extension);
        tit_write = strcat(origen, prev);

        imwrite(I,tit_write);
    else       %% Ejecución RECONSTRUCT
        destino = 'images/reconstructed/';
        recons = strcat(origen, nombre_file);
        tit = strcat(recons, extension);
        % Empezamos pasando una imagen como input y obtenemos la imagen
        % como matriz
        
        % Cogemos la imagen con missing pixels en RGB
        %{
        % Primero obtenemos la imagen en RGB
        RGB = imread(tit);
        %figure (1);
        %imshow(RGB);

        % La convertimos en una imagen de grises y la mostramos
        I = rgb2gray(RGB);
        imshow(I);
        %}
        
        % Cogemos la imagen con missing pixels ya en grayscale
        I = imread(tit);
        %imshow(I);

    end

    % Una vez tenemos la imagen en grayscale (I), la imagen es una matriz donde
    % cada elemento representa un pixel, que solo tiene 1 valor intensidad

    % Realizamos la transformada de Fourier discreta sobre la matriz de la
    % imagen
    
    %% OUTPUT: I_Fourier=Matriz con la DFT de la imagen, que modificamos 
    %%  y de la cual dejamos solo los coeficientes mayores, realizando la
    %%  compresión.
    I_Fourier = fft2(I);
    
    %figure (3);
    %imshow(abs(I_Fourier));
    % Vemos su valor min y max
    %min_Fourier = min(abs(I_Fourier(:)));
    %max_Fourier = max(abs(I_Fourier(:)));

    %media_Fourier = floor(abs(mean2(I_Fourier)))

    %% COMPARAR EN VALOR ABSOLUTO (son complejos)
    tam = size(I_Fourier);
    M = tam(1);
    N = tam(2);
    
    %% OUTPUT: I_Fourier_enfila = Vector que contiene la imagen en la
    %%  base de Fourier tras la compresión en una fila, para poder 
    %%  aplicar sampling_reconstruction
    I_Fourier_enfila = zeros(M*N,1);    
    
    %% AQUÍ VIENE LA COMPRESIÓN!!
    %% Hacemos una lista con los coeficientes MAYORES
        % Sustituimos los coeficientes que no estén en esta lista
        %   por 0!!!   
    max_elems = {};
    %% Ahora nos vamos a quedar en max_elems con los num_elems_Fourier coeficientes
    %%  más grandes!!
    c=0;
    start=0;
    start2=0;
    for t=1:M
        for tt=1:N
            %% Cogemos los primeros num_elems_Fourier para max_elems
            if c<num_elems_Fourier
                c = c+1;
                max_elems{c} = [abs(I_Fourier(t,tt)), t, tt];       % Guardamos también la posición del coef
            else
                start=t;
                start2=tt;
                break;
            end
        end
        if c>=num_elems_Fourier
            break;
        end
    end
    
    if length(max_elems)~=num_elems_Fourier
        fprintf("ERROR en image_compression: 1era iter max_elems!!!\n\n");
        F=-1;
        return
    end
    
    %% Aquí tenemos en max_elems los primeros num_elems_Fourier coefs de I_Fourier
    %% Seguimos recorriendo la matriz desde (t,tt)

    %% Vemos cuál es el mínimo de los coefs de max_elems
        %% ASÍ, SOLO COMPARAMOS SI EL COEFICIENTE QUE LEEMOS ES > minimo 
        %% PARA GUARDARLO EN max_elems
    minimo = [10000000000, -1,-1];
    for ttt=1:num_elems_Fourier
        if (max_elems{ttt}(1) < minimo(1))    % Nos quedamos con el coef mínimo
            minimo = max_elems{ttt};
        end
    end
    
    %   Seguimos recorriendo el resto de la matriz desde start y start2
    for t=1:M
        for tt=1:N
            if t<start
                continue        % Ya lo hemos leido seguro al no haber llegado a la linea start
            else
                if t==start         % Si estamos leyendo en la línea de star
                    if tt<start2    % Si estamos columnas antes de start2
                        continue
                    end
                end
            end
            
            check=abs(I_Fourier(t,tt));  % Guardamos en check el elemento a comprobar
                                                    % si está en max_elems
            % Aquí tenemos en min=[coef_min, i,k]
            % Comprobamos si check es MAYOR que min
            if (check > minimo(1))
                % Si es así, lo aniadimos a max_elems
                % Lo aniadimos donde estaba min!! Porque ese ya se va fuera
                %% Buscamos dónde esta ese valor mínimo dentro de max_elems
                for ttt=1:num_elems_Fourier
                    if (max_elems{ttt} == minimo)    % Nos situamos en el elem a quitar (por ser mínimo)
                        max_elems{ttt} = [check, t, tt];
                        break;
                    end
                end
                
                % Si aniadimos un nuevo elem a max_elems, hay que ver cuál
                % es el nuevo mínimo (RECALCULAR)
                %% Vemos cuál es el mínimo de los coefs de max_elems
                minimo = [10000000000, -1,-1];
                for ttt=1:num_elems_Fourier
                    if (max_elems{ttt}(1) < minimo(1))    % Nos quedamos con el coef mínimo
                        minimo = max_elems{ttt};
                    end
                end
                
            end  
            
        end
    end
    
    % Ahora, recorremos la matriz I_Fourier y vamos poniendo a 0
    % todos los coeficientes que NO estén en max_elems:
    %%  SON AQUELLOS MENORES QUE MINIMO!!!
    % y vamos guardando los índices de aquellos que SI estén en max_elem
    
    % Aprovechamos a escribir I_Fourier en una fila(vector),
    % I_Fourier_enfila,
    % donde cada N términos, el coeficiente N+1 indica el primer coeficiente
    % de la siguiente fila de la imágen.
    
    % Lo escribimos de esta forma para poder aplicar
    % sampling_reconstruction
    
    % Hacemos lo mismo con F, indicando las posiciones (respecto a la
    % imagen como fila) de los coefs con los que nos quedamos

    pos=0;
    for t=1:M
        for tt=1:N
            pos = (t-1)*N+tt;  % Posicion nueva en nuestra imagen en fila para (m,n)
            check=abs(I_Fourier(t,tt));  % Guardamos en check el elemento a comprobar
                                                    % si está en max_elems
            % Aquí tenemos en min=[coef_min, i,k]
            % Comprobamos si check es MAYOR que min
            if (check >= minimo(1))
                %{
                if check==minimo(1)
                    fprintf("Aparece MINIMO!! en %d %d\n\n", t, tt);
                end
                %}
                % PERTENECE a max_elems
                F = [F,pos];           % Guardamos el índice del coef de Fourier que mantenemos
                % pos = posicion nueva en nuestra imagen en fila para (t,tt)
                I_Fourier_enfila(pos) = I_Fourier(t,tt);
                %% INTENTAR BORRAR EL ELEM DE max_elems
            else
                % No está en max_elems, lo ponemos a 0
                I_Fourier(t,tt) = 0;
            end
        end
        
    end
    
    %% YA CON ESTO, ESTAMOS COGIENDO LOS coeficientes de Fourier + GRANDES (y que mejor aproximan la imagen)

    pixeles_total = M*N;

    % Escribimos el porcentaje de compresión alcanzado
    compression = round(pixeles_total/num_elems_Fourier);
    fprintf('El ratio de compresion respecto a la imagen original es de %d:1\n', compression);

    %% A VECES DEVUELVE EN COMPLEJOS AUN!!! Cuando NO es simétrica
    I_recuperada = ifft2(I_Fourier);
    if isreal(I_recuperada)
        % Si es real, es simétrica
    else
        %    I_Fourier_reescalada NO era simétrica
        %fprintf("I_recuperada NO es real, aproximamos con abs\n\n");
        I_recuperada = abs(I_recuperada);   
    end
        
    ent_recuperada = floor(I_recuperada);
    ent_recuperada = uint8(ent_recuperada);

    %% VER ERROR RESPECTO DE I!!!

    comp = sprintf('_ratio_%d', compression);
    nombre_file_dest = strcat(nombre_file, comp)
    extension = '.jpg';
    prev = strcat(nombre_file_dest, extension);
    tit_write = strcat(destino, prev);
    
    imwrite(ent_recuperada,tit_write);

    toc;        % Paramos de medir el tiempo
end

