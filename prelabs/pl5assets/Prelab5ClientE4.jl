using Revise
using Plots
using LibSerialPort
using JSON3
gr()
##

function serialplotting()
    global mcuCom
    time_zero = 0
    sample_no = 0
    
    # Empty the receive buffer
    flush_line = flush(mcuCom)
    
    # Create a base plot 
    plt = plot([0], [[0],[0]], linewidth=2, label=["Data 1" "Data 2"])
    ylims!((-1.5, 1.5))
    display(plt)

    while true
        # Since Julia takes a while to precompile, the receive buffer gets overloaded,
        # flush it if its big. Keep data coming in real-time
        if bytesavailable(mcuCom) > 800
            println("Flushing Serial")
            flush(mcuCom)
        end

        if bytesavailable(mcuCom) > 0
            mcu_message = readuntil(mcuCom, '\n')
            global jsonline = ""

            try
                jsonline = JSON3.read(mcu_message)

                if sample_no == 0
                    # Grab the first millis, reference time w.r.t
                    time_zero =  jsonline.time;  
                end

                sample_no += 1

                # Offset time and convert to seconds
                time = Float64(jsonline.time - time_zero) / 1000

                # Push points to plot lines
                push!(plt, 1, time, jsonline.data[1])
                push!(plt, 2, time, jsonline.data[2])
                # Alternative method
                # push!(plt, time, [jsonline.data[1], jsonline.data[2]])

                xlims!((time - 20, time + 10)) # Shift x-axis
                gui(); # refresh plot

                # Print a status message every once in a while, this also allows for capturing CTRL+C
                if mod(sample_no, 20) == 0
                    println("Running - Hold CTRL+C to Terminate")
                end

            catch e
                println("JSON parsing or plot update error")
            end
        end
    end
end

# Use try-finally to properly close the serial port after program termination
try
    global mcuCom = open("COM7", 250000); # TODO: Change COM port and baud rate to reflect that
    serialplotting()
finally
    println("Exiting and Closing Serial Port")
    closeall()
    close(mcuCom)
end
