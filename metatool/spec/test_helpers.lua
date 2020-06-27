
package.path = "../?.lua;./?.lua;" .. package.path

local _fixture_path = "spec/fixtures"

function fixture_path(name)
	return string.format("%s/%s", _fixture_path, name)
end

local _fixtures = {}
function fixture(name)
	if not _fixtures[name] then
		dofile(fixture_path(name) .. ".lua")
	end
	_fixtures[name] = true
end
