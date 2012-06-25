-- (C) 2010 INPE AND UFOP
M_NOMES    = 17
M_SALARIOS = 18
M_IMPOSTOS = 19
M_EMPREGOS = 20
M_EMISSION = 21

m_csa = {}
m_csa[ 1] = { 5.1,  0.0,   0.0,  9.0, 184.6,  17.6,  39.9,   62.3,  0.2,   0.0,   0.6,    0.0,   0.0,    0.0,    1.6,   0.0,  258.3, 156.3,   0.0,    0.0}
m_csa[ 2] = { 0.0, 24.9,   0.0, 10.4,  77.6,  43.9,  32.1,   35.7,  0.2,   0.0,   2.2,    0.0,   0.0,    0.0,    8.9,   0.0,  260.1,  78.3,   0.0,    0.0}
m_csa[ 3] = { 0.0,  0.0,   0.0,  0.0, 410.5,   0.0,   0.0,    0.0,  0.0,   0.0,   0.0,    0.0, 334.7,    0.0,    0.0,   0.0,    0.0,   0.0,   0.0, 4098.8}
m_csa[ 4] = { 0.0,  0.0,   0.0,  0.0,  42.9,   0.0,  10.4,    0.0,  0.0,   0.0,   0.8,    0.0,   0.0,    0.0,    0.0,   0.0,    0.3,   0.0,   0.0,    0.0}
m_csa[ 5] = { 0.0,  0.0,   0.0,  0.0,  19.5,  56.5,   4.4,  158.7,  0.0,   6.9,  40.5,  183.8,   0.0,   45.2,   31.4,  86.1,    2.6,   0.0,   0.0,  485.9}
m_csa[ 6] = { 0.0,  0.0,   0.0,  0.3,   0.0,   0.0,   0.0,  898.0,  0.0,   0.0,   0.0,    9.5,   0.0,   75.9,    0.0,  56.6,    0.0,   0.0,   0.0,    0.0}
m_csa[ 7] = { 2.2,  2.4,  32.4,  0.0,   1.6, 207.8,  22.7,  582.3, 23.5,   6.8,  50.6,    0.0,   4.5,    0.0,   28.6,   0.0,    5.0,   0.0,   0.0,    0.0}
m_csa[ 8] = {96.4, 49.9, 352.7,  0.0,   9.4,   0.0,   0.9,    0.0,  0.0,   0.0,   0.2,    0.0,   0.0,    0.0,    0.0,   0.0, 3198.9, 648.1,   0.0,    0.0}
m_csa[ 9] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,   0.0,    0.8,  0.0, 137.9, 258.5,    0.0,   0.0,    0.0,    0.0,   0.0,    0.0,   0.0,   0.0,    0.0}
m_csa[10] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,  38.8,    0.0,  0.0,   0.0, 171.0,   73.6,   0.0,    0.0,   70.1,   0.0,    0.0,   0.0,   0.0,    0.4}
m_csa[11] = { 1.6,  1.4,   5.6,  0.2,  38.0, 128.6, 340.4,  768.9, 13.5,   8.3,   5.1,  118.0,   0.9,    0.0,    0.0,   0.0,    0.0,   0.0,  41.5,   68.0}
m_csa[12] = { 0.0,  0.0,  54.2,  0.0,   0.0,   0.0,   0.0,    0.0,  0.0,   0.0,   0.0,    0.0,   0.0,    0.0,    0.0,   0.0,  277.8,   0.0, 387.7,    0.0}
m_csa[13] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,   0.0,    0.0,  0.0,  71.9,   0.0,    0.0,   0.0, 2711.1,    0.0,   0.2,    0.0,   0.0,   0.0,    0.1}
m_csa[14] = { 0.0,  0.0,   0.0,  0.0,   0.0, 108.6,  69.6,  403.5,  0.0,   0.0, 663.0,  138.1,   0.0,    0.0, 1670.7, 179.6,    0.0,   0.0,   0.0,  477.4}
m_csa[15] = { 0.0,  0.0, 526.6,  0.0,   0.0,   0.0, 297.9,  771.8,  0.0,   0.0, 156.8,    2.2,  91.9,  125.8,    6.8,   7.9,   41.0,   0.0,   0.0,   78.5}
m_csa[16] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,   0.0,    0.0, 0.01,   0.0,   0.01,   0.0,   0.0,    0.0,    0.0,   0.0,    0.0,   0.0,   0.0,  443.3}

m_csa[M_SALARIOS] = {169.1,  72.9, 272.0, 2.3, 71.1, 73.3, 41.7, 366.0, 17.0, 24.9, 66.2, 60.5, 94.1, 288.6, 137.7, 54.1}
m_csa[M_IMPOSTOS] = { 12.6,   0.9, 643.2, 3.5, 45.5, 12.7,  9.1, 103.1,  4.1,  4.4, 57.3, 37.2, 98.0, 146.5,  59.1, 38.0}
m_csa[M_EMPREGOS] = { 50.7, 138.1,  13.9, 0.4, 12.0, 10.5,  7.5,  51.6,  2.2,  3.2, 11.1,  7.3, 12.6,  24.5,  17.6,  5.0}
m_csa[M_EMISSION] = {217.8,  75.4,     0,    0,   0,    0,    0,     0,    0,    0,    0,    0,    0,     0,     0,    0}

m_csa[M_NOMES] = {	"Fazendas                ", 	"Camponeses              ", 	"Mineracao               ", 	"Intermediacao           ",
					"Beneficiamento_local    ", 	"Transformacao_local     ", 	"Atacado_local           ", 	"Varejo_servicos_local   ",
					"Beneficiamento_regional ", 	"Transformacao_regional  ", 	"Atacado_regional        ", 	"Varejo_servicos_regional",
					"Beneficiamento_nacional ", 	"Transformacao_nacional  ", 	"Atacado_nacional        ", 	"Varejo_servicos_nacional"}

function f(value) return string.format("%.2f", value) end

cenario = cenario or 0 -- prompt argument

create_consumer = function(name, id)
	local agent = {tot_vr = 0, received = 0, name = name, id = id, tot_custo = 0}

	agent.execute = function(ag)
		if ag.received < 0.001 and ag.received > -0.001 then return end

		ag.tot_custo = ag.tot_custo + ag.received

		forEachRelative(ag, function(ag, neigh, weigh)
			ag:action{receiver = neigh, content = "money", value = ag.received * weigh}
		end)
		ag.received = 0
	end

	agent.print = function(ag)
		print(ag.name.."\t"..f(ag.tot_custo))
	end
	agent.onMessage = function(ag, mes)
		if mes.content == "money" then
			ag.received = ag.received + mes.value
		end
	end

	return Agent(agent)
end

create_government = function(name, id)
	local agent = {tot_vr = 0, tot_em = 0, tot_custo = 0, tot_sa = 0, tot_lu = 0, name = name, id = id, tot_co2 = 0}

	agent.onMessage = function(ag, mes)
		if mes.content == "money"   then ag.tot_vr  = ag.tot_vr  + mes.value end
		if mes.content == "emprego" then ag.tot_em  = ag.tot_em  + mes.value end
		if mes.content == "salario" then ag.tot_sa  = ag.tot_sa  + mes.value end
		if mes.content == "lucro"   then ag.tot_lu  = ag.tot_lu  + mes.value end
		if mes.content == "carbon"  then ag.tot_co2 = ag.tot_co2 + mes.value end
	end
	agent.print   = function() end
	agent.execute = function() end
	return Agent(agent)
end

familia          = create_consumer  ("Familia                 ", 17)
formacao_capital = create_consumer  ("Formacao_capital        ", 18)
government       = create_government("Goverment               ", 19)

tot_demand = 0
basic_agent = function()
	local agent = {tot_vr = 0, taxes = 0, tot_custo = 0, salaries = 0, received = 0, name = "", 
				   familia = 0, formacao_capital = 0, empregos = 0, tot_salarios=0, tot_impostos=0, tot_empregos=0, tot_r = 0}

	agent.print = function(ag)
		print(ag.name.."\t"..f(ag.tot_r))--tot_custo).."\t"..f(ag.tot_salarios).."\t"..f(ag.tot_impostos).."\t"..f(ag.tot_empregos))
	end
	agent.execute = function(ag)
        if ag.received < 0.001 and ag.received > -0.001 then return end

		vr = ag.received - ag.received * (ag.taxes + ag.salaries + ag.costs)
		custo     = ag.received * ag.costs
		salarios  = ag.received * ag.salaries
		impostos  = ag.received * ag.taxes
		empregos  = ag.received * ag.empregos
		emissoes  = ag.received * ag.emissions
		lucro     = ag.received - custo - salarios - impostos

		ag.tot_salarios = ag.tot_salarios + salarios
		ag.tot_impostos = ag.tot_impostos + impostos
		ag.tot_empregos = ag.tot_empregos + empregos
		ag.tot_custo = ag.tot_custo + custo

		ag.tot_vr = ag.tot_vr + lucro + salarios + impostos + custo

        gastos_familia = lucro * 0.2818
        gastos_capital = lucro * 0.1114
        acumulado = lucro - gastos_familia - gastos_capital

--        ag.tot_vr = ag.tot_vr + acumulado

--        if DEMANDA == 1 then
            ag:action{receiver = familia,          content = "money", value = salarios + gastos_familia}
            ag:action{receiver = formacao_capital, content = "money", value = gastos_capital}
--        elseif DEMANDA == 2 then
--            ag:action{receiver = familia,          content = "money", value = salarios}
--        end
			
		ag:action{receiver = government, content = "money",   value = impostos}
		ag:action{receiver = government, content = "emprego", value = empregos}
		ag:action{receiver = government, content = "salario", value = salarios}
		ag:action{receiver = government, content = "carbon",  value = emissoes}
		ag:action{receiver = government, content = "lucro",   value = lucro}
--		ag:action{receiver = familia,    content = "money",   value = salarios}

		forEachRelative(ag, function(ag, neigh, weigh)
			ag:action{receiver = neigh, content = "money", value = custo * weigh}
		end)
		ag.received = 0
	end

	agent.onMessage = function(ag, mes)
		if mes.content == "money" then
			value = mes.value
			ag.received = ag.received + value
			tot_demand = tot_demand + value
			ag.tot_r = ag.tot_r + value
		end
	end

	return Agent(agent)
end

read_csa = function(society, matrix)
	for idx = 1, society:size() do
		local a = society:getAgent(idx)

		local vbp = 0
		for i = 1, 20 do -- sum the line
			local value = matrix[idx][i]
			vbp = vbp + value
		end
	
		a.taxes     = matrix[M_IMPOSTOS][idx] / vbp
		a.salaries  = matrix[M_SALARIOS][idx] / vbp
		a.empregos  = matrix[M_EMPREGOS][idx] / vbp
		a.emissions = matrix[M_EMISSION][idx] / vbp
		a.name      = matrix[M_NOMES]   [idx]
		a.idx = idx

		local tot = 0
		for i = 1, 16 do -- sum the column
			local value = matrix[i][idx]
			tot = tot + value
		end
		a.costs   = tot / vbp

		for i = 1, 16 do
			local value = matrix[i][idx]
			if value > 0 then
				a:addRelative(society:getAgent(i), value/tot)
			end
		end
	end
end

read_csa_consumers = function(society, matrix)
	vp = {familia, formacao_capital}
	for idx = 1, table.getn(vp) do
		local a = vp[idx]

		local tot = 0
		for i = 1, 16 do -- sum the column
			local value = matrix[i][16 + idx]
			tot = tot + value
		end

		for i = 1, 16 do
			local value = matrix[i][16 + idx]
			if value > 0 then
				a:addRelative(society:getAgent(i), value/tot)
			end
		end
	end
end

print_connections = function()
	for idx = 1, s:getn() do
		local a = s:getAgent(idx)
		print("\nIDX: "..a.id.. "  ".. a.name)
	
		local tot = 0
		for i = 1, 16 do
			local value = m_csa[i][idx]
			tot = tot + value
		end

		forEachRelative(a, function(nei, wei)
			print(nei.name.."\t"..wei.."   "..wei * tot)
		end)
	end
end

s = Society(basic_agent, 16)
read_csa(s, m_csa)
read_csa_consumers(s, m_csa)

s:add(familia)
s:add(formacao_capital)
s:add(government)

exogenous_agent = Agent{name = "-=-=-=  exogenous  -=-=-"}

my_action = function(sender, receiver, value)
	sender:action{receiver = receiver, value = value, content = "money"}
end

cenario_padrao = function()
	for i = 1, 16 do
		for j = 19, 20 do my_action(exogenous_agent, s:getAgent(i), m_csa[i][j]) end

--		my_action(s:getAgent(17), s:getAgent(i), m_csa[i][17]*0.552)--2014)
--		my_action(s:getAgent(18), s:getAgent(i), m_csa[i][18])
	end
end

cenario_1 = function()
	print "CENARIO 1"
	cenario_padrao()
	my_action(exogenous_agent, s:getAgent(8), 435.14)
    my_action(exogenous_agent, s:getAgent(1), -367.67)
    my_action(exogenous_agent, s:getAgent(2), -287.21)
end

cenario_2 = function()
	print "CENARIO 2"
	cenario_padrao()

	my_action(exogenous_agent, s:getAgent(8), 435.14)
end

cenario_3 = function()
	print "CENARIO 3"
    cenario_padrao()
    my_action(exogenous_agent, s:getAgent(1), -735.33)
    my_action(exogenous_agent, s:getAgent(2),  735.33)
    my_action(exogenous_agent, s:getAgent(8),  435.14)
end

cenario_4 = function()
	print "CENARIO 4"
    cenario_padrao()
    my_action(exogenous_agent, s:getAgent(1), -367.67)
    my_action(exogenous_agent, s:getAgent(2), -287.21)
    my_action(exogenous_agent, s:getAgent(3), 6563.05)
    my_action(exogenous_agent, s:getAgent(8),  435.14)
end

cenario_5 = function()
	print "CENARIO 5"
    cenario_padrao()
    my_action(exogenous_agent, s:getAgent(1), 287.21*2)
    my_action(exogenous_agent, s:getAgent(2), -287.21*2)
    my_action(exogenous_agent, s:getAgent(8),  435.14)
end

cenarios = {cenario_padrao, cenario_1, cenario_2, cenario_3, cenario_4, cenario_5}

executa = function(time)
	for i = 1, time do
		synchronizeMessages()
		s:execute()
	end
end

cenarios[cenario+1]()
executa(100)

print("REPORT:")
luc = government.tot_lu
print("Salarios:\t"  ..f(government.tot_sa) .."\t"..f(government.tot_sa - 1811.7))
print("Lucro:\t\t"   ..f(government.tot_lu) .."\t"..f(government.tot_lu - 7921.4))
print("Impostos:\t"  ..f(government.tot_vr) .."\t"..f(government.tot_vr - 1275.3))
print("Emprego:\t"   ..f(government.tot_em) .."\t"..f(government.tot_em - 368.2))
print("Carbon:\t\t"  ..f(government.tot_co2).."\t"..f(government.tot_co2 - 217.8-75.4))
print("Tot Demand:\t"..f(tot_demand)        .."\t"..f(tot_demand - 25752.1))

print("\n\n")
a = s:getAgent(1)
print("Lucro:\t\t"   ..f(a.tot_vr))
print("Empregos:\t\t"   ..f(a.tot_empregos))
a = s:getAgent(2)
print("Lucro:\t\t"   ..f(a.tot_vr))
print("Empregos:\t\t"   ..f(a.tot_empregos))

--forEachAgent(s, function(ag) ag:print() end)


print("Please, press <ENTER> to quit...")
io.read()
