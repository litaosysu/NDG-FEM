classdef Triangle < StdRegions.BaseElement
    %TRIANGLE 二维标准单元
    %   标准三角形单元，采用节点基函数（nodal basis），对应节点为LGL节点分布
    %   （Hesthaven and Warburton, 2008）
    
    properties
        nFaceNode % 边界节点个数
        r       % 标准单元节点x坐标
        s       % 标准单元节点y坐标
        V       % Vandermonde矩阵
        invV    % Vandermonde逆矩阵
        M       % 质量矩阵
        Dr      % 节点基函数对r求导
        Ds      % 节点基函数对s求导
        Drw     % 
        Dsw
        Mes     % 边界节点基函数积分质量矩阵
        LIFT    % 边界通量转换矩阵
        Fmask   % 边界上节点编号
    end
    
    methods
        % ==========================
        % 构造函数
        % ==========================
        function obj = Triangle(order)
            dim = 2; vertice = 3; face = 3;
            % 继承属性包括： 
            % nDim, nVertice, nOrder, nFace, nNode 
            obj = obj@StdRegions.BaseElement(dim,vertice,order,face);
            % 继承属性设定
            obj.sName = 'Triangle';
            obj.nNode = (order+1)*(order+2)/2;
            obj.nFaceNode = (order+1)*face;
            
            % 获取节点集合
            [obj.r, obj.s] = GetCoor(order);
            % 边界上节点编号
            
            % Vandermonde矩阵
            obj.V = obj.GetVandMatrix(order,obj.r,obj.s);
            obj.invV = inv(obj.V);
            % 质量矩阵 $M = (V*V^T)^{-1} = invV^T*invV$
            obj.M = obj.invV'*obj.invV;
            % 导数矩阵
            [obj.Dr, obj.Ds] = GetGrandMatrix( order,obj.r,obj.s,obj.V );
            
            % 边界积分基函数质量矩阵
            obj.Mes = GetFaceMassMatrix( obj );
            
            % LIFT矩阵 $M^{-1} \cdot Mes$
            obj.LIFT = (obj.V*(obj.V)')*obj.Mes;
            
            % Fmask 按列存储，每列存储ith边节点编号
            nodelist = obj.GetFaceListToNodeList();
            obj.Fmask = reshape(nodelist, order+1, face);
        end% func
        
        % ==========================
        % 计算Vandermonde矩阵
        % ==========================
        V = GetVandMatrix(obj, order, r, s);
        
        % ==========================
        % 获取第ind条边上节点全局节点编号与节点个数
        % ==========================
        [ Nfp, nodelist ] = GetNodeListAtFace( obj, ind );
        [ facelist ] = GetFaceListAtFace( obj,ind );
        
        [ nodelist ] = GetFaceListToNodeList( obj );
        [ nodelist ] = GetVertexNodeList( obj );
    end
    
end

