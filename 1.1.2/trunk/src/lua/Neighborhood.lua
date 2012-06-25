Neighborhood_ = {
    type_ = "Neighborhood",
        --Função que adiciona um vizinho à estrutura de vizinhança de uma célula recebendo como parâmetro uma referência para a célula.
	addNeighbor = function( self, cell, weight)
		if( not self:isNeighbor(cell) ) then
			return self.cObj_:addNeighbor( cell.x, cell.y, cell.cObj_, weight); 
		else
			self.cObj_:setNeighWeight( cell.x, cell.y, cell.cObj_, weight );
		end
  	end,
	addCell = function(self, index, cellularSpace, weight)
		if (weight == nil) then weight = {}; end
		-- problema sinistro com o segundo parâmetro, ele não pode ser um iterador
		if self.cObj_ == nil then error("self is nil!", 2); end
		if index.cObj_ == nil then error("index is nil!", 2); end
		if cellularSpace.cObj_ == nil then error("cellularSpace is nil!", 2); end
		return self.cObj_:addCell(index.cObj_, cellularSpace.cObj_, weight)
	end,
        -- Função que retira uma célula da estrutura de vizinhança de outra célula recebendo como parâmetro uma referência para a célula.
	eraseNeighbor = function( self, cell )
  		self.cObj_:eraseNeighbor( cell.x, cell.y, cell.cObj_ );
  	end,
	eraseCell       = function(self, index) self.cObj_:eraseCell			 (index.cObj_); end,
        -- Função que reconfigura a estrutura de vizinhança
	-- Parâmetros: 1 - cellularSpace: Espaço Celular;
	--             2 - fCondition: Função que determina se a célula faz parte ou não da vizinhança;
	--             3 - fWeight: Função que calcula o peso da relação
	reconfigure = function( self, cellularSpace, fCondition, fWeight )
		self:first();
		while( not self:isLast() ) do
			neighbor = self:getNeighbor();
			if( not fCondition(neighbor) ) then
				self:eraseNeighbor( neighbor );
			end
			self:next();
		end
		for i, cell in ipairs( cellularSpace.cells ) do
			if( fCondition(cell) ) then
				self:addNeighbor( cell, fWeight(cell) );
			end
		end
	end	,
	getCellWeight   = function(self, index) return self.cObj_:getCellWeight  (index.cObj_); end,
	getCellNeighbor = function(self, index) return self.cObj_:getCellNeighbor(index.cObj_); end,
	setCellWeight = function(self, index, weight)
		self.cObj_:setCellWeight(index.cObj_, weight)
	end,
        -- Método que altera o peso de uma relação recebendo como parâmetro uma referência para a célula vizinha.
	setNeighWeight = function( self, cell, weight )
		self.cObj_:setNeighWeight(cell.x, cell.y, cell.cObj_, weight);
	end,
	setWeight = function(self, weight)
		self.cObj_:setWeight(weight)
	end,
	sample = function(self)
		local pos = math.random(1, self:size())
		local count = 1
		self:first()
		while (not self:isLast()) do
			neigh = self:getNeighbor()
			if count == pos then return neigh end
			self:next()
			count = count + 1
		end
	end,
        -- Implementei este método para testar se duas células são vizinhas.
	isNeighbor = function( self, cell )
		return self.cObj_:isNeighbor( cell.x, cell.y, cell.cObj_ );
	end,
	getWeight   = function(self) return	self.cObj_:getWeight();		end,
	getNeighbor = function(self) return	self.cObj_:getNeighbor();	end,
	first       = function(self)		self.cObj_:first();			end,
	last        = function(self)		self.cObj_:last();			end,
	isFirst     = function(self) return	self.cObj_:isFirst();		end,
	isLast      = function(self) return	self.cObj_:isLast();		end,
	next        = function(self)		self.cObj_:next();			end,
	getCoord    = function(self) return	self.cObj_:getCoord();		end,
	isEmpty     = function(self) return	self.cObj_:isEmpty();		end,
	clear       = function(self)		self.cObj_:clear();			end,
	size        = function(self) return	self.cObj_:size();			end,
	getID       = function(self) return	self.cObj_:getID();			end
}

local metaTableNeighborhood_ = {__index = Neighborhood_}

function Neighborhood(attrTab)
	if (attrTab == nil) then attrTab = {}; end
	local cObj = nil
	if (attrTab.cObj_ == nil) then
		cObj = TeNeighborhood()
		attrTab.cObj_ = cObj
	else
		cObj = attrTab.cObj_
	end
	setmetatable(attrTab, metaTableNeighborhood_)
	cObj:setReference(attrTab)
	return attrTab
end
