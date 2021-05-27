%% Reconstrucción de las coordenadas perdidas de un vector
%%  Author: Víctor García Carrera, victor.garciacarrera@estudiante.uam.es


%%  Basado en ejemplo 9.15, pag 245 de la Bibliografía principal
%%  Ejemplo de recuperar las coordenadas perdidas de un vector durante la transmision.
%%    Vector en l^2(Z_MN), M*N coordenadas v[k]. Conocemos T coordenadas:
%%      CUMPLE PPIO DE INCERTIDUMBRE DE FOURIER!!!

%%   Ejemplo: v=a0*f0 + a2*f2 + a5*f5       F={0,2,5}

%% vector: [a b]
%% lista: {x1, x2}

%F = [1,3,6]     % Elementos de la base de Fourier con los que LIMITAMOS LA BANDA DEL VECTOR
%T = [1,3,4,5,7,8]   % Coordenadas que CONOCEMOS de v!!!!!

% vgorro es la imagen escrita como un vector

function vgorro_recuperada_dimN = sampling_reconstruction(F, T, Base_Fourier_enfila, N, v_known)
%{
    % Cálculo de la base de Fourier f_m,n
    Base_Fourier_mn = {};      % Lista donde guardamos la base ONB de Fourier para l^2(fila x Z_N)
    pos = 0;            % Variable para ir recorriendo la lista y guardando las matrices de Fourier
    m = fila;
    for n=1:N
        pos = pos + 1;
        f_mn = {};          % MATRIZ f_m,n de la base: LO VEMOS COMO UNA LISTA
                                % donde cada pos es una fila!!!
        vect = [];          % Vector para el cálculo de cada fila
        for j=1:M           % Para cada vector, sus M coordenadas
           for k=1:N
                coord = exp( (-i*2*pi*j*m)/M )*exp( (-i*2*pi*k*n)/N );
                coord = (1/sqrt(M))*(1/sqrt(N))*coord;
                vect = [vect, coord];
            end
            % Aquí acaba con una fila entera
            f_mn{j} = vect;    % Aniadimos la fila a la matriz de f_mn
        end
        Base_Fourier{pos} = f_mn;      % Aniadimos la matriz f_m a la base
        %(hace falta transpose???)
    end

    Base_Fourier_mn
%}


    %{
    Base_Fourier = {};      % Lista donde guardamos la base ONB de Fourier para l^2(Z_8)
    for n=1:8               % Calculamos los 8 vectores de la base
        f_n = [];           % vector f_n de la base
        for k=1:8           % Para cada vector, sus 8 coordenadas
            coord = exp( (-i*2*pi*k*n)/8 );        % OJO, el signo es diferente en pag 144 vs 245
            coord = (1/sqrt(8))*coord;             %%%%%%%DESCOMENTAR%%%%%%
            f_n = [f_n, coord];
        end
        Base_Fourier{n} = transpose(f_n);      % Aniadimos el vector f_n a la base
    end

    Base_Fourier;
    %}

    %% Si nos dan v en ONB estandar, tenemos que calcular vgorro, es decir, fft(v)
    %% El único problema con esto es que fft NO tiene en cuenta el factor de normalización
    %% Es decir, hay que multiplicar fft(v)/8 para tener la verdadera fft
    %{
    prueba = [1,1,1,1,1,1,1,1];
    tries = fft(prueba)         % NO NORMALIZA CON 1/sqrt(N) PQ ifft YA LO TIENE EN CUENTA!
    real_tries = (1/sqrt(8))*tries
    tries2 = ifft(tries)
    %}


    %Definimos el valor del vector v in l^2(Z8), el cual vamos a recuperar tras perder 2
    %coordenadas
    %a1=1;
    %a3=3;
    %a6=6;
    %TRANSFORMADA FOURIER QUE TIENE QUE SALIR
    %vgorro = transpose([a1, 0, a3, 0, 0, a6, 0, 0]);        %% Probar a meter en a4=9 por ejemplo.
    %vgorro = fft(v);
    
    % vgorro ya viene de I_Fourier_reescalada, por lo que es bandlimited a
    % F (porque todos los coeficientes son nulos salvo los indicados por F.
    % !!!!!!!!!!!!!!!
    
    %% YA VIENE COMO vgorro!! Porque es I_Fourier escrita todo en una fila 
    
    
    %vgorro = transpose([a0, a2, a5]);   % en l^2(F)
    %v = a0.*Base_Fourier{1} + a2.*Base_Fourier{3} + a5.*Base_Fourier{6};
    
    %v = ifft(vgorro)
    
    % v = ifft(vgorro)*8
    %v_known1 = [v(1), v(3), v(4), v(5), v(7), v(8)];
    %tries = fft(v)     % Debe salir vgorro de nuevo


    %transf = fft(v);
    %transf

    %{
    v_known = [];
    %v_known_conj = [];
    for j=1:length(T)
        %v_known_conj = [v_known, transpose(vgorro)*conj( Base_Fourier{T{j}+1} ) ];
        v_known = [v_known, vgorro* transpose( Base_Fourier_enfila{T(j)} ) ];
    end
    %}

    %Conocemos 6 de las 8 coordenadas: FALTAN 1,5


    %OPERADOR ANÁLISIS
    op_analisis_matrix = [];
    op_analisis_matrix_conj = [];

    %%%%%%%%%%%%%%%%%%% LA DIM DE op_analisis_matrix va a ser 6x3 SI
    %%%%%%%%%%%%%%%%%%% l^2(F) dim 3

    for j=1:length(F)        % El operador análisis trabaja con los vectores de Fourier con coef en T
        %Base_Fourier{T{i}+1}
        f = [];
        vector_four = Base_Fourier_enfila{F(j)};
        if vector_four==-1
            fprintf("FALLO!!!\n");
        end
        for jj=1:length(T)
            f = [f, vector_four( T(jj) ) ];
        end
        op_analisis_matrix = [op_analisis_matrix, transpose(f)];
        op_analisis_matrix_conj = [op_analisis_matrix_conj, conj( transpose(f) ) ];
    end


    %op_analisis_matrix_conj = transpose(op_analisis_matrix_conj);
    %op_analisis_matrix = transpose(op_analisis_matrix);

    %   Operador análisis en forma matricial!!!
    %   El producto escalar en l^2(Zn) de v,w: <v,w> = <v;conj(w)>
    %   Pero al sacar la matriz, ya hemos tenido esto en cuenta.

    %% OJO, SE MULTIPLICA LA MATRIZ DEL OPERADOR POR LA IZQUIERDA

    %   Una vez hemos obtenido v[n] con n in T.
    %   Calculamos la inversa de Moore-Penrose para recuperar
    %   vgorro a partir de vknown

    %   Primero calculamos la matriz del operador síntesis
    op_sintesis_matrix = transpose(op_analisis_matrix_conj);
    op_sintesis_matrix;

    %   Con la matriz del operador análisis y la del operador síntesis, podemos
    %   calcular la matriz de la inversa de Moore-Penrose
    prod = op_sintesis_matrix*op_analisis_matrix;
    %inversa = (1/det(prod)) * adjoint(transpose( conj(prod) ) );
    inv_prod = inv(prod);

    % En ocasiones el cálculo de la inversa daba problemas, hacemos una
    % comprobación rápida:
    %prueba = prod*inv_prod

    inversa_moore_penrose_matrix = inv_prod *op_sintesis_matrix;

    % Recuperamos vgorro a partir de v_known, con la inversa de
    % Moore-Penrose
    vgorro_recuperada = inversa_moore_penrose_matrix*transpose(v_known);
    %vgorro_recuperada2 = inversa_moore_penrose_matrix*transpose(v_known_conj);
    %vgorro_recuperada3 = inversa_moore_penrose_matrix*transpose(v_known1);
    
    %vgorro_recuperada

    %% vgorro_recuperada es un vector de longitud 3. Está codificado con f0, f2 y f5.
    %% Lo escribimos como un vector de longitud 8, donde el resto de coordenadas son 0
    %   Esto es debido a que la v original era bandlimited a estas frecuencias
    vgorro_recuperada_dimN = zeros(1,N);
    tt=1;                                    % Para recorrer vgorro_recuperada
    for t=1:length(F)       % Si la coordenada que estamos viendo es una de las de F
        vgorro_recuperada_dimN(F(t)) = vgorro_recuperada(tt);
        tt=tt+1;
    end

    %vgorro_recuperada_dim8 = [vgorro_recuperada(1),0,vgorro_recuperada(2),0,0, vgorro_recuperada(3),0,0]

    % Finalmente, recuperamos el vector v con las coordenadas que faltaban!
    %v_recuperada = ifft(vgorro_recuperada_dimN)
    %% NO HACER AQUI ifft, devolver vgorro y hacer ifft2!!!!!!!!!!!!!
    %% QUIZAS FALLE EN LA NORMALIZACIÓN y sea ifft()*8!!!!!!!!!!!!
    
end
