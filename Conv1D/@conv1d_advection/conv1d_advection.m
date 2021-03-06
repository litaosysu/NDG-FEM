classdef conv1d_advection < conv1d
    %CONV1D_ADVECTION Summary of this class goes here
    %   Detailed explanation goes here
    properties(SetAccess=protected)
        slopelimiter
    end
    
    methods
        function obj = conv1d_advection(varargin)
            
            switch nargin
                case 1
                    mesh = varargin{1};
                case 2
                    N = varargin{1};
                    K = varargin{2};
                    mesh = uniform_mesh(N, K); % 调用私有函数构造网格
                otherwise
                    error('The number of input variable is incorrect!');
            end
            
            obj = obj@conv1d(mesh);
            obj.init; % call initial function
            obj.cfl = 0.3;
            obj.ftime = 1.5;
            obj.dt = obj.time_interval();
            obj.slopelimiter = ndg_utility.limiter.BJ(mesh);
        end% func
        
        function init(obj) 
            % Get the initial value
            K = obj.mesh.K;
            Np = obj.mesh.cell.Np;
            obj.f_Q = zeros(Np, K);
            
            x = obj.mesh.x;
            x1 = min(x(:));  
            x2 = max(x(:)); 
            x0 = (x1+x2)./2; 
            len = (x2 - x1);

            % left part
            flag = (x <= x0); x11 = (x1 + x0)./2;
%             obj.f_Q(flag) = exp( - (x(flag) - x11).^2./0.005/len^2 );
            % right part
%             x21 = (x2 + 3*x0)/4; x22 = (3*x2 + x0)/4;
%             flag = (x >= x21) & (x <= x22);
            obj.f_Q(flag) = 1;
            
            % flow field
            obj.u = 0.5*ones(Np, K);
        end% func
        
        RK45_solve( obj );
        
        function [ dt ] = time_interval(obj)
            dx = obj.mesh.cell.vol * obj.mesh.J;
            dt = obj.cfl*min( min(dx./obj.u) );
        end
    end
    
end

