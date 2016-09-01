-- module will not return anything, only register assertions with the main assert engine

-- assertions take 2 parameters;
-- 1) state
-- 2) arguments list. The list has a member 'n' with the argument count to check for trailing nils
-- 3) level The level of the error position relative to the called function
-- returns; boolean; whether assertion passed

local assert = require('luassert.assert')
local astate = require ('luassert.state')
local util = require ('luassert.util')
local s = require('say')

local function set_failure_message(state, message)
  if message ~= nil then
    state.failure_message = message
  end
end

local function tensor_comp(t1, t2)
	local th1 = torch.type(t1)
	local th2 = torch.type(t2)
	if (th1 == "table") then
		t1 = torch.Tensor(t1):type(t2:type())
	elseif (th2 == "table") then
		t2 = torch.Tensor(t2):type(t1:type())
	elseif (th1 ~= th2) then
		t1 = t1:type("torch.DoubleTensor")
		t2 = t2:type("torch.DoubleTensor")
	end

	return torch.all(t1:eq(t2))
end

local function tds_comp(t1, t2)

	if (table.exact_length(t1) ~=
	    table.exact_length(t2)) then
		return false
	end

	for pos,val in pairs(t1) do
		if (t2[pos] ~= val) then
			return false
		end
	end

	return true
end

local function format(val)
  return astate.format_argument(val) or tostring(val)
end

local isnan = function(val)
	return val ~= val
end

local function deepcompare(t1,t2,ignore_mt,cycles,thresh1,thresh2)
	local ty1 = torch.type(t1)
	local ty2 = torch.type(t2)
	-- non-table types can be directly compared
	if (ty1:match("^tds") and ty1:match("^tds")) then
		return tds_comp(t1, t2)
	elseif (ty1:match("^torch.*Tensor") and ty1:match("^torch.*Tensor")) then
		return tensor_comp(t1, t2)
	elseif (ty1 ~= 'table' or ty2 ~= 'table') then
		if (isnan(t1)) then
			return isnan(t2)
		end
		return t1 == t2
	end

	local mt1 = debug.getmetatable(t1)
	local mt2 = debug.getmetatable(t2)
	-- would equality be determined by metatable __eq?
	if mt1 and mt1 == mt2 and mt1.__eq then

	 -- then use that unless asked not to
	if not ignore_mt then
		return t1 == t2 end
	else -- we can skip the deep comparison below if t1 and t2 share identity

	 if rawequal(t1, t2) then return true end
	end

	-- handle recursive tables
	cycles = cycles or {{},{}}
	thresh1, thresh2 = (thresh1 or 1), (thresh2 or 1)
	cycles[1][t1] = (cycles[1][t1] or 0)
	cycles[2][t2] = (cycles[2][t2] or 0)
	if cycles[1][t1] == 1 or cycles[2][t2] == 1 then
		thresh1 = cycles[1][t1] + 1
		thresh2 = cycles[2][t2] + 1
	end
	if cycles[1][t1] > thresh1 and cycles[2][t2] > thresh2 then
	 return true
	end

	cycles[1][t1] = cycles[1][t1] + 1
	cycles[2][t2] = cycles[2][t2] + 1

	for k1,v1 in next, t1 do
		local v2 = t2[k1]
		if v2 == nil then
			return false, {k1}
		end

		local same, crumbs = deepcompare(v1,v2,nil,cycles,thresh1,thresh2)
		if not same then
			crumbs = crumbs or {}
			table.insert(crumbs, k1)
			return false, crumbs
		end
	end
	for k2,_ in next, t2 do
		-- only check wether each element has a t1 counterpart, actual comparison
		-- has been done in first loop above
		if t1[k2] == nil then return false, {k2} end
	end

	cycles[1][t1] = cycles[1][t1] - 1
	cycles[2][t2] = cycles[2][t2] - 1

	return true
end

local function check_if_nan(state, arguments, level)
	local level = (level or 1) + 1
	local argcnt = arguments.n
	assert(argcnt > 0, s("assertion.internal.argtolittle", { "same", 1, tostring(argcnt) }), level)

	set_failure_message(state, arguments[2])
	return arguments[1] ~= arguments[1]
end

-- Adapation of the original same function for torch and Dataframe compatibility
local function torch_same(state, arguments, level)
	local level = (level or 1) + 1
	local argcnt = arguments.n
	assert(argcnt > 1, s("assertion.internal.argtolittle", { "same", 2, tostring(argcnt) }), level)

	for i=1,2 do
		if (torch.type(arguments[i]):match("Dataseries")) then
			arguments[i] = arguments[i]:to_table()
		end
	end

	if torch.type(arguments[1]) == 'table' and
	   torch.type(arguments[2]) == 'table' then

		local result, crumbs = deepcompare(arguments[1], arguments[2], true)
		-- switch arguments for proper output message
		-- util.tinsert(arguments, 1, util.tremove(arguments, 2))

		arguments.fmtargs = arguments.fmtargs or {}
		arguments.fmtargs[1] = { crumbs = crumbs }
		arguments.fmtargs[2] = { crumbs = crumbs }
		set_failure_message(state, arguments[3])
		return result
	end

	if (torch.type(arguments[1]):match("torch.*Tensor") or
	    torch.type(arguments[2]):match("torch.*Tensor")) then
		set_failure_message(state, arguments[3])
		return tensor_comp(arguments[1], arguments[2])
	end

	if(torch.type(arguments[1]):match("^tds.") or
	   torch.type(arguments[2]):match("^tds.")) then
		set_failure_message(state, arguments[3])
		return tds_comp(arguments[1], arguments[2])
	end

	local result = arguments[1] == arguments[2]

	-- switch arguments for proper output message
	-- skip the flip: util.tinsert(arguments, 1, util.tremove(arguments, 2))
	set_failure_message(state, arguments[3])
	return result
end

local function torch_same_elements(state, arguments, level)
	local level = (level or 1) + 1
	local argcnt = arguments.n
	assert(argcnt > 1, s("assertion.internal.argtolittle", { "same", 2, tostring(argcnt) }), level)

	for i=1,2 do
		if (torch.type(arguments[i]):match("Dataseries") or
		    torch.type(arguments[i]):match("torch.*Tensor")) then
			arguments[i] = arguments[i]:to_table()
		end
	end

	set_failure_message(state, arguments[3])
	for _,needle in ipairs(arguments[1]) do
		found = false
		for _,hay in ipairs(arguments[2]) do
			if (needle == hay) then
				found = true
				break
			end
		end

		if (not found) then
			return false
		end
	end

	return true
end

local function torch_same_keys(state, arguments, level)
	local level = (level or 1) + 1
	local argcnt = arguments.n
	assert(argcnt > 1, s("assertion.internal.argtolittle", { "same", 2, tostring(argcnt) }), level)

	for i=1,2 do
		if (torch.type(arguments[i]):match("Dataseries") or
		    torch.type(arguments[i]):match("torch.*Tensor")) then
			arguments[i] = arguments[i]:to_table()
		end
	end

	set_failure_message(state, arguments[3])
	for needle,_ in pairs(arguments[1]) do
		found = false
		for hay,_ in pairs(arguments[2]) do
			if (needle == hay) then
				found = true
				break
			end
		end

		if (not found) then
			return false
		end
	end

	return true
end

-- Override the original "same" with our own method
assert:register("assertion", "same",
                torch_same,
                "assertion.same.positive", "assertion.same.negative")

-- Register custom helperes
assert:register("assertion", "same_keys",
                torch_same_keys,
                "assertion.same.positive", "assertion.same.negative")

assert:register("assertion", "same_elements",
                torch_same_elements,
               "assertion.same.positive", "assertion.same.negative")

assert:register("assertion", "nan",
               check_if_nan,
              "assertion.same.positive", "assertion.same.negative")
