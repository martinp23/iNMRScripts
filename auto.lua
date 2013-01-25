-- D_STEP.lua 	Semi-automatic deconvolution of a kinetic experiment

if onv then
  local decrows = dec(onv)  -- find number of rows in deconvolution window
  local j = 0
  local k = 0
  for k = 0,3 do              -- do the fitting procedure three times - usually gets close to where we want and saves clicking
    for j = 1,decrows do      -- fit each row 
      dec( onv, j )
      dec( onv, "++++" )		-- fit all parameters
      dec( onv, "SAME" )		-- Lorentzian line-shapes
    end
    dec( onv, "ok  " ) 		-- attempt to fit
  end
  return
else
	print "The deconvolution window (from DStep_1) needs to be open"
	return
end
