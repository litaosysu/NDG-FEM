classdef swe2d_dbw < swe2d
    %SWE2D_DBW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden)
        dam_pos = 500
        h0 = 10
        h1 = 2
    end
    
    properties(Constant)
        hmin = 1e-4
    end
    
    methods
        function obj = swe2d_dbw(varargin)
            switch nargin
                case 1
                    mesh = varargin(1);
                    if ( ~isa(mesh, 'ndg_lib.mesh.tri_mesh') || ...
                            ~isa(mesh, 'ndg_lib.mesh.quad_mesh') )
                        error(['The input is not a triangle or ',... 
                            'quadrilateral mesh object!']);
                    end
                case 3
                    N = varargin{1};
                    M = varargin{2};
                    type = varargin{3};
                    mesh = uniform_mesh( N, M, type );
                otherwise
                    error('The number of input variable is incorrect.');
            end% switch
            
            obj = obj@swe2d(mesh);
            obj.cfl = 0.2;
            obj.ftime = 20;
            obj.init();
        end
        
        function init(obj)
            f_Q = obj.h1*ones(obj.mesh.cell.Np, obj.mesh.K, obj.Nfield);
            xc  = obj.mesh.cell_mean(obj.mesh.x);
            f_Q(:, xc<obj.dam_pos, 1) = obj.h0;
            obj.f_Q = f_Q;
            
            obj.bot = zeros(obj.mesh.cell.Np, obj.mesh.K); % bottom
        end% func
    end
    
end

