module MUX
#(
  parameter WIDTH = 8, // width of each channel
  parameter CHANNELS = 4 // number of channels
)
(
  input reset,          // system reset
  input clk,            // system clock
  input [(CHANNELS-1):0] selOneHot, // one hot select input
  input [(CHANNELS*WIDTH)-1:0] dataInBus, // input data bus
  output reg [(WIDTH-1):0] dataOut // output data after select
);

  // temporary array to hold input channels
  wire [(WIDTH-1):0] inputArray[0:(CHANNELS-1)];
  genvar gv;

  // generate statement to assign input channels to temp array
  generate
    for (gv = 0; gv < CHANNELS; gv = gv + 1) begin : arrayAssignments
      assign inputArray[gv] = dataInBus[((gv+1)*WIDTH)-1 : (gv*WIDTH)];
    end // arrayAssignments
  endgenerate

  // function to convert one hot to decimal
  function integer decimal;
    input [(CHANNELS-1):0] oneHotInput;
    integer i;
    begin
      decimal = 0;
      for (i = 0; i < CHANNELS; i = i + 1) begin
        if (oneHotInput[i]) begin
          decimal = i;
        end
      end
    end
  endfunction

  // select the output according to input oneHot
  always @* begin
    dataOut = inputArray[decimal(selOneHot)];
  end // always

endmodule // MUX
