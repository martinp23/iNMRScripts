-- Dinit.lua 	semi-automatic deconvolution of a kinetic experiment

-- DEFINITIONS

HOME = HOME or "/Users/martinp23/Desktop/"		 -- define here your home directory
						-- never forget the initial slash !
filename = "MP150-1.txt"	--here we save the table of integrals

NumSpectra = 53	-- number of points for the kinetic study
NumRegions = 5	-- regions to deconvolute

doDeconv = false
phased = true
baselineparams = false
baseline = true

P = 1		-- first spectrum to process
R = 1		-- first region to process
			-- you can start from higher values, if you wish
			
F = {}		-- central frequencies
par = {}	-- parameter for the deconvolution
-- they must be obtained from a preliminary deconvolution performed on the first spectrum
dx = 0.2	-- (constant) region to zoom in, in ppm units, based upon experience and observation

local i = 1	-- progressive index, simplifies the editing of this script
-- for example, you can reorder the definitions below and they will still work

-- proton 1
F[i] = 9.05
par[i] = [[
Parameters for 1 peak
  frequency (Hz)     intensity      width (Hz)   Lorentzian %

      2498.5         10.0000         30.0700       100.0000
]]
i = i + 1

-- proton 2
F[i] = 6.87
par[i] = [[
Parameters for 1 peak
  frequency (Hz)     intensity      width (Hz)   Lorentzian %

      2498.5         10.0000         30.0700       100.0000
]]
i = i + 1

-- proton 3
F[i] = 7.35
par[i] = [[
Parameters for 1 peak
  frequency (Hz)     intensity      width (Hz)   Lorentzian %

      2498.5         10.0000         30.0700       100.0000
]]
i = i + 1

-- proton 4
F[i] = 4.05
par[i] = [[
Parameters for 1 peak
  frequency (Hz)     intensity      width (Hz)   Lorentzian %

      2498.5         10.0000         30.0700       100.0000
]]
i = i + 1

-- proton 5
F[i] = 6.79
par[i] = [[
Parameters for 1 peak
  frequency (Hz)     intensity      width (Hz)   Lorentzian %

      2498.5         10.0000         30.0700       100.0000
]]
i = i + 1



-- end of definitions ----------------------------------------

-- ************->    HERE WE GO:    <-***************

io.output(HOME..filename)		-- create/open the file where the results will be stored
io.write("\tpoint")	-- header
for i = 1,NumRegions do
	io.write("\tppm\tarea")
end
io.write("\n")

spectral = getf("x")				-- read some experimental parameters 
conversion = 1.0 / spectral.MHz		-- useful to convert from Hz to ppm
spectral = getf("y")
step = spectral.width / spectral.size
Y = spectral.start + step * (spectral.size -0.1 -P+1)	-- position of the first row on its dummy ppm scale

io.write( string.format("\n\t%02d\t", P ) )	-- report the experiment no.
mark('h', Y )		-- choose a row
extract()			-- extract the corresponding 1D spectrum
delint()			-- we need to normalize the intensities
region( 0.5, 9.5 )	-- region containing protons no. 1 and 9
press 'i'			-- first integral, automatically set to 1
intreg( 1, 300 )	-- we set it to 300 to have manageable numbers (>1 and <300)


print("Fix the phasing and do the baseline correction then press prep_DSTEP")

