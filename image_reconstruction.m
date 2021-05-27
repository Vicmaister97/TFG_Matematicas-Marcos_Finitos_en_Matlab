%% Programa de reconstrucción de imágenes utilizando teoría de marcos y la transformación
%%  de Fourier. Implementado por Víctor García Carrera, victor.garciacarrera@estudiante.uam.es

%clear all;
%clc;


function image_reconstruction(origen, nombre_file)

    %tic;    % Inicio del tiempo
    % Variables para leer la imagen original y guardar la bandlimited
    %origen = 'images/original/';
    destino = 'images/reconstructed/';
    %nombre_file = 'tries';
    extension = '.jpg';
    prev = strcat(nombre_file, extension);
    tit_read = strcat(origen, prev);
    
    %myCluster = parcluster('local');
    %myCluster.NumWorkers = 4;  % 'Modified' property now TRUE
    %saveProfile(myCluster);    % 'local' profile now updated,
                           % 'Modified' property now FALSE
    
    % Declaramos el uso de 8 workers en las tareas de paralelización
    %parpool(4);

    % Primero obtenemos la imagen en RGB
    RGB = imread(tit_read);
    tam = size(RGB)
    M = tam(1);
    N = tam(2);
    
    pixeles_total = M*N;
    
    %{
    % La convertimos en una imagen de grises y la mostramos
    I_complete = rgb2gray(RGB);
    %figure (2);
    %imshow(I_complete);
    
    %% Guardamos en origen la imagen en grayscale
    nombre_file_dest = strcat(nombre_file, '_grayscale');
    extension = '.jpg';
    prev = strcat(nombre_file_dest, extension);
    tit_write = strcat(origen, prev);

    imwrite(I_complete,tit_write);
    %}

    %% Construimos la imagen con missing pixels:
    I_missing = RGB;    
    
    %% Perdemos missing píxeles ALEATORIOS
    missing=400;
    % Inicializamos el generador de números aleatorios para poder repetir
    % el experimento
    rng(0,'twister');
    % Creamos un vector de missing valores aleatorios en el intervalo
    % (1,pixeles_total)
    r = (pixeles_total-1).*rand(missing,1) + 1;
    %Comprobamos que los valores de r están dentro del rango especificado.
    r_range = [min(r) max(r)];
    r = floor(r);
    r = sort(r);     
    
    T_missing = []; % Array donde guardamos las posiciones DESCONOCIDAS
    for t=1:length(r)
        pos=r(t);
        if t>1
            if pos==T_missing(t-1) % Si se repite una posición, como está ordenado es ver el anterior
                pos=pos+1;
            end
        end
        pos_modif = pos;
        numfila=1;
        numcol=1;
        %Convertimos pos en una posición en la imagen con coordenadas (numfila,numcol)
        while pos_modif > N
            pos_modif = pos_modif-N;
            numfila = numfila+1;
        end
        numcol = pos_modif;
            
        I_missing(numfila,numcol, :) = [0,0,0];   % Para reconocer los píxeles perdidos
        T_missing(t)=pos;
    end    
    
    if length(T_missing)~=missing
        fprintf("HA FALLADO T_missing!!!!\n\n");
        %Cogemos el pool existente y lo cerramos
        %p = gcp;
        %delete(p)
        return
    end
    
    %missing
    %T_missing
    T_cardinality = pixeles_total - missing;
    
    %I_missing
    %figure (3);
    %imshow(I_missing);
    
    % Convertimos I_missing en una imagen de grises y la mostramos
    I_missing_grayscale = rgb2gray(I_missing);
    %figure (33);
    %imshow(I_missing_grayscale);
    
    %% OJO, TENEMOS QUE HACER I_missing_Fourier para mandarlo a sampling_recons
    %% PROBAR a mandarlo como está y HACER fft(v) en sampling_recons para tener vgorro
    %% Elegimos los T, que son los índices distintos de -1
    
    % Ojo, si hacemos I_Fourier, aqui ya NO ES LOS !=-1
    
    %% Guardamos en reconstructed la imagen MISSING
    nombre_file_dest = strcat(nombre_file, '_missing');
    prev = strcat(nombre_file_dest, extension);
    imagen_missing = strcat(destino, prev);

    imwrite(I_missing,imagen_missing);
    
    %% Guardamos en reconstructed la imagen MISSING EN GRAYSCALE
    nombre_file_dest2 = strcat(nombre_file, '_missing_grayscale');
    prev = strcat(nombre_file_dest2, extension);
    imagen_missing = strcat(destino, prev);

    imwrite(I_missing_grayscale,imagen_missing);
    
    %% FALLO de concepto porque LA IMAGEN TIENE QUE SER BANDLIMITED a
    %%  a unas frecuencias F de la base de Fourier !!!!!!!!!!!!!!!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%      Esto hace que la reconstrucción sea única y segura!!!!!

    %% Mejor aproximación: Cogemos la base F que MEJOR aproxime la imagen missing
        %% F serán las bandas con coeficientes más altos
                %   (y cogeremos una base con cardinalidad máxima
                %   que cumplan el PPIO INCERDITUMBRE FOURIER
    
     %% Vemos cuál es el valor máximo de número de bandas elegidas de la Base de Fourier
        %%  para cumplir con el PRINCIPIO DE INCERCITUMBRE DE FOURIER %%
    cota_Fourier = floor(T_cardinality -M*N + 2*sqrt(M*N));
    
    if cota_Fourier <1
        fprintf("La cantidad de píxeles perdidos es tan grande");
        fprintf("que no puede cumplirse el Principio de Incertidumbre de Fourier!!\n");
        %Cogemos el pool existente y lo cerramos
        %p = gcp;
        %delete(p)
        return
    end
        
    cota_Fourier = cota_Fourier + 1;
    cota_Fourier_ajustada = cota_Fourier-2;
    
    fprintf("La cota de Fourier es %d\n", cota_Fourier);
    fprintf("Comienza image_compression con num_elems_Fourier = %d\n", cota_Fourier_ajustada);
    % Obtenemos la imagen bandlimited, con los coefs de Fourier utilizados
    % en F
    
    
    %% QUIZÁS HAYA QUE HACER TRAMPAS Y HACERLO CON image_COMPLETE!!! Y NO 
    %% CON LA MISSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %[F, I_Fourier_bandlimited, I_Fourier_bandlimited_enfila] = image_compression(origen, nombre_file, cota_Fourier_ajustada, 1);
    [F, I_Fourier_bandlimited, I_Fourier_bandlimited_enfila] = image_compression(destino, nombre_file_dest2, cota_Fourier_ajustada, 1);

        % Utilizamos cota_Fourier-2 para asegurarnos que no nos pasamos, debido
        % a que a veces F tiene 1 elemento de más por ser I_Fourier simétrica
        
    %length(F)
    % Comprobamos que la base de Fourier cumple con PPIO INCERTIDUMBRE
    
    if (length(F) >= cota_Fourier)
        fprintf("BASE DE FOURIER ELEGIDA DEMASIADO GRANDE!! tam=%d\n\n\n", length(F));
        %Cogemos el pool existente y lo cerramos
        %p = gcp;
        %delete(p)
        return
    end
    
    if F==-1
        fprintf("ERROR en image_compression!!\n\n\n");
        %Cogemos el pool existente y lo cerramos
        %p = gcp;
        %delete(p)
        return
    end
    
    
    I_Fourier_bandlimited_enfila = transpose(I_Fourier_bandlimited_enfila);
    %% Aquí ya tenemos nuestra v=I_Fourier_bandlimited_enfila, con v in S(F)
    
    %% Vamos a ejecutar sampling_reconstruction para v
    %   para ello, necesitamos 
    
    
    % I_Fourier_bandlimited es la imagen I_Fourier_bandlimited en una fila(vector),
    % donde cada N términos, el coeficiente N+1 corresponde al primer coeficiente
    % de la siguiente fila de la imágen.
    
    % Lo escribimos de esta forma para poder aplicar
    % sampling_reconstruction
    
    % Hacemos lo mismo con F y T, que están en forma matricial.
    %   Las ponemos en una misma fila
    
    
    %   1-Vamos calculando Base_Fourier para los f_mn que limitan la imagen
    Base_Fourier = {};      % Lista donde guardamos la base ONB de Fourier para l^2(m x Z_N)
    %Base_Fourier = zeros(pixeles_total,1) ;      % Lista donde guardamos la base ONB de Fourier para l^2(m x Z_N)
    Base_Fourier_enfila = {};
    
    %Aprovechamos fft2, que es tremendamente rápido, para sacar los
    %elementos de la base de Fourier de la siguiente forma:
    I_Fourier = fft2(I_missing_grayscale);
    
    % Si queremos sacar Base_Fourier{6}=f_5  EJEMPLO CON sampling
    %prueba = [0,0,0,0,0,sqrt(8),0,0]; %Porque ifft no tiene en cuenta el
    %factor de reescalado.
    %prueba2 = ifft(prueba)
    %intento_four = conj(prueba2)
    
    fprintf("START calculo BASE FOURIER\n\n");
    tic;
    pos=0;
    count=0;
    for t=1:M
        for tt=1:N
            pos = (t-1)*N+tt;  % Posicion nueva en nuestra base en fila para (t,tt)
            if (ismember(pos,F))    % SOLO CALCULAMOS LOS INDICADOS EN F!!
                count=count+1;
                prueba = zeros(M,N);
                prueba(t,tt)= (1/sqrt(M))*(1/sqrt(N));  %Porque ifft no tiene 
                                           % en cuenta el factor de reescalado.
                elemento_base_Fourier = ifft2(prueba);
                Base_Fourier_enfila{pos} = elemento_base_Fourier;
            else
                Base_Fourier_enfila{pos} = -1;
            end
        end
    end
    toc;
    fprintf("FINISH calculo BASE FOURIER\n\n");
    
    if count~=length(F)
        fprintf("ALGO HA FALLO EN Base_Fourier!!!!\n\n");
        %Cogemos el pool existente y lo cerramos
        %p = gcp;
        %delete(p)
        return
    end
    
    
    
    %{
    fprintf("START calculo BASE FOURIER\n\n");
    pos=0;
    count=0;
    tic;
    for t=0:M-1       %parfor???????
        %vect = [];          % Vector para el cálculo de cada fila
        Base_Fourier_fila = {};
        for tt=0:N-1
            pos = (t)*N+tt+1;  % Posicion nueva en nuestra imagen en fila para (m,n)
            if (ismember(pos,F))    % SOLO CALCULAMOS LOS INDICADOS EN F!!
                %fprintf("ITER %d %d\n", t, tt);
                count=count+1;
                vect = [];          % Vector para el cálculo de cada fila
                for j=1:M           % Para cada vector, sus M coordenadas
                   for k=1:N
                        coord = exp( (-i*2*pi*j*t)/M )*exp( (-i*2*pi*k*tt)/N );
                        coord = (1/sqrt(M))*(1/sqrt(N))*coord;
                        vect = [vect, coord];
                   end
                end
                Base_Fourier_fila{tt+1} = vect;      % Aniadimos la matriz f_m a la base
                %(hace falta transpose???)
                
            else
                Base_Fourier_fila{tt+1} = -1;
            end
        end
        Base_Fourier{t+1} = Base_Fourier_fila;
        
    end
    toc;
    fprintf("FINISH calculo BASE FOURIER\n\n");
    
    if count~=length(F)
        fprintf("ALGO HA FALLO EN Base_Fourier!!!!\n\n");
        %Cogemos el pool existente y lo cerramos
        p = gcp;
        delete(p)
        return
    end
    %}
    
    %Cogemos el pool existente y lo cerramos
    %p = gcp;
    %delete(p)
    
    %{
    %% Faltaria leer Base_Fourier, donde cada elem es una lista con todos
    %%   los f_m,n de esa fila
    Base_Fourier_enfila = {};
    pos=0;
    for t=1:length(Base_Fourier)    % parfor??
        for tt=1:N
            pos = (t-1)*N+tt;  % Posicion nueva en nuestra imagen en fila para (m,n)
            Base_Fourier_enfila{pos}=Base_Fourier{t}(tt);
        end
    end
    %}
    
    
    % Expresamos la imagen bandlimited W, que es la mejor aproximacion que
    % tenemos de V, como producto de sus coefs de Fourier por sus elementos
    % de la Base de Fourier en F
    W=0;
    for t=1:length(F)
        pos=F(t);
        W = W + I_Fourier_bandlimited_enfila(pos)*Base_Fourier_enfila{pos};
    end
    
    fprintf("START calculo vknown\n\n");
    % Finalmente, creamos vknown, que es coger de W las posiciones
    % conocidas indicadas por T
    vknown = [];
    T_enfila = [];      % aprovechamos para indicar los T conocidos en fila
    
    tic;
    for t=1:pixeles_total       %parfor??
        if ismember(t,T_missing)==false      % Si esa posición NO está en T_missing, es known
            %{
            pos=t;
            % Traducimos la posición en la matriz
            numfila=1;
            numcol=1;
            while pos>N
                pos = pos-N;
                numfila=numfila+1;
            end
            numcol=pos;
            
            vknown = [vknown,  double(I_missing_grayscale(numfila,numcol))];
            %}
            vknown = [vknown, W(t)];
            % si es un pixel conocido
            T_enfila = [T_enfila, t];       
        end
    end
    toc;
    fprintf("FINISH calculo vknown\n\n\n");
    
    if length(T_enfila)~=T_cardinality
        fprintf("ALGO HA FALLADO en T_enfila!!!\n\n");
        %Cogemos el pool existente y lo cerramos
        %p = gcp;
        %delete(p)
        return
    end
    
    
    vgorro_recuperada = sampling_reconstruction(F, T_enfila, Base_Fourier_enfila, N, vknown);
    vgorro_recuperada_matrix = zeros(M,N);
    numfila=1;
    pos=1;
    %% Ponemos vgorro_recuperada COMO MATRIZ, hacer ifft2 y 
    %%  cogemos missing pixels!!!!!
    for t=1:length(vgorro_recuperada)
        pos = mod(t,N+1);
        if mod(t,N+1)==0  % Si está una nueva fila
            numfila = numfila+1;
            pos=pos+1;
        end
        vgorro_recuperada_matrix(numfila, pos) = vgorro_recuperada(t);
    end
    
    %% A VECES DEVUELVE EN COMPLEJOS AUN!!! Cuando NO es simétrica
    I_recuperada = ifft2(vgorro_recuperada_matrix);
    
    if isreal(I_recuperada)
        % Si es real, es correcta
    else
        %% FALLÓ ifft2, posiblemente debido a que I_Fourier_reescalada
        %    NO era simétrica
        fprintf("I_recuperada NO es real, aproximamos con abs\n\n");
        I_recuperada = abs(I_recuperada);   
    end
        
    ent_recuperada = floor(I_recuperada);

    %% VER ERROR RESPECTO DE I!!!
    
    %% Ahora sustituimos en I_missing_grayscale los píxeles perdidos por
    %% los valores recuperados en vgorro_recuperada_matrix
    for t=1:length(T_missing)
        pos=T_missing(t);
        % Traducimos la posición en la matriz
        numfila=1;
        numcol=1;
        while pos>N
            pos = pos-N;
            numfila=numfila+1;
        end
        numcol=pos;
            
        I_missing_grayscale(numfila,numcol) = ent_recuperada(numfila, numcol);
    end
    

    % Convierta la matriz en una imagen. Mostrar los valores máximo y mínimo de la imagen.
    %K = mat2gray(I_missing_grayscale);
    %min_recons = min(K(:));
    %max_recons = max(K(:));
    %% OJO, todos los valores están en el intervalo [0,1]
    %figure(4);
    %imagesc(K);
    %imshow(K);

    %comp = sprintf('_ratio_%d', compression);
    nombre_file_dest = strcat(nombre_file, '_reconstruida')
    extension = '.jpg';
    prev = strcat(nombre_file_dest, extension);
    tit_write = strcat(destino, prev);
    
    imwrite(I_missing_grayscale,tit_write);
    


end
