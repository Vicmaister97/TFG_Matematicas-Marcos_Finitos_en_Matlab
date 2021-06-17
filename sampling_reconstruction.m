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
    
    %% I_Fourier viene escrita toda en una fila 
    
    %OPERADOR ANÁLISIS
    op_analisis_matrix = [];
    op_analisis_matrix_conj = [];

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

    %   Operador análisis en forma matricial!!!
    
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

    vgorro_recuperada_dimN = zeros(1,N);
    tt=1;                                    % Para recorrer vgorro_recuperada
    for t=1:length(F)       % Si la coordenada que estamos viendo es una de las de F
        vgorro_recuperada_dimN(F(t)) = vgorro_recuperada(tt);
        tt=tt+1;
    end
    
end
