module NIDAQ

import Gtk.setproperty!  # what if "using NIDAQ, Gtk" ?

# tasks
export task, start, stop, clear

# channels
export analog_input, analog_output, digital_input, digital_output
export count_edges, measure_duty_cycle, quadrature_input, line_to_line, generate_pulses

# read/write
export read_analog, read_digital, write_analog, write_digital, read_counter

# properties
export devices, channel_type, getproperties, setproperty!
export analog_input_ranges, analog_output_ranges
export analog_input_channels, analog_output_channels
export digital_input_channels, digital_output_channels
export counter_input_channels, counter_output_channels

const NIDAQmx = "C:\\Windows\\System32\\nicaiu.dll"

bitstype 32 Bool32 <: Integer
export Bool32

# could only Pkg.add("Clang") on mac with BUILD_LLVM_CLANG=1 in Make.user option
# julia> using Clang
# julia> context = wrap_c.init()
# julia> context.common_file="constants.jl"
# julia> wrap_c.wrap_c_headers(context, {"NIDAQmx.h"})
# $ mv NIDAQmx.jl functions.jl
# $ sed constants.jl:  typealias bool32 uInt32 -> typealias bool32 Bool32

include("constants.jl")
include("functions.jl")

include("task.jl")
include("analog.jl")
include("digital.jl")
include("counter.jl")
include("properties.jl")

function catch_error(code::Int32, extra::ASCIIString="")
    sz = DAQmxGetErrorString(code, convert(Ptr{Uint8},C_NULL), convert(Uint32,0))
    data = zeros(Uint8,sz)
    ret = DAQmxGetErrorString(code, convert(Ptr{Uint8},data), convert(Uint32,sz))
    ret>0 && warn("DAQmxGetErrorString error $ret")
    ret<0 && error("DAQmxGetErrorString error $ret")
    data = convert(ASCIIString, data)
    code>0 && warn("NIDAQmx: "*extra*data)
    code<0 && error("NIDAQmx: "*extra*data)
end

end
