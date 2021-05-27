%% Método Numérico del marco
%%  Author: Víctor García Carrera, victor.garciacarrera@estudiante.uam.es

%% vector: [a b]
%% lista: {x1, x2}

function U_metodo=MN_Marco(n, Nt, k, marco, A, B, x)
    %% Programación del método del marco para aproximar un x cualquiera como
    %%  combinación lineal de los elementos del marco
    %
    %   Sea {x_i}i=1..k  marco para H (espacio Hilbert) de dimensión n (k geq n), con
    %   límites de marco A y B (inferior y superior).
    %   Sea x in H, el algoritmo recursivo del marco se describe de la
    %   siguiente manera:
    %
    %       u_0 = VECTOR DE 0s
    %       u_k = u_{k-1} + 2/(A+B) * S(x-u_{k-1}),   k geq 1
    %
    %       Donde S(x-u_{k-1}) = Sum{i=1..n}( <x,x_i> + <u_{k-1},x_i> ) x_k
    %
    %            n: dimensión del espacio de Hilbert H (ejemplo n=2, R2)
    %            Nt: número de iteraciones temporales
    %            k: número de vectores del marco
    %            marco: Lista con los k vectores (de dim n) que forman el
    %            marco
    %            A: Limite inferior del marco
    %            B: Limite superior del marco
    %            x: vector (de dim n) a aproximar.
    %
    %   La salida U es un vector con los valores de la aproximacion u_k.
    %
    
    U_metodo = [];   % Vector donde vamos guardando las aproximaciones
    for j=1:n
        U_metodo = [U_metodo, 0];   %Condición inicial: u_0 = VECTOR 0s
    end
    
    if (k~=length(marco))   % Marco no tiene k vectores
        disp("Err: num de vectores del marco distinto de k");
        return
    end
    
    if (k < n)     % MARCO NO GENERA H
        tit = sprintf("Err: el marco debe contener al menos %d vectores", n);
        disp(tit)
        return
    end
    
    for i=1:k
        if (length(marco{i}) ~= n)   % vector x_i del marco NO es de dimension n
            disp("Err: vector del marco de dimensión incorrecta");
            return
        end
    end
    
    if (length(x) ~= n)   % vector x a aproximar NO es de dimension n
        disp("Err: vector A APROXIMAR de dimensión incorrecta");
        return
    end
    
    %% Calculo recurrente para optimizar: <x,x_i>
    coord = [];
    for j=1:k
        coord = [coord, dot(x,marco{j})];
    end
    %coord       % Visualizamos las coordenadas de x en función de los vectores del marco
    
    %% METODO
    for i=1:Nt   %Iteraciones temporales
        S=0;
        anterior = U_metodo;
        for j=1:k   % Sumatorio de S(x-anterior)
            S = S + ( vpa(coord(j)) - vpa(dot(anterior,marco{j})) )*vpa(marco{j});
        end
        U_metodo=anterior + vpa((2/(A+B)) * S);
    end
    
end