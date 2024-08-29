module arbiter #(parameter WIDTH = 4) (clk, reset, req, grant);
 
input clk, reset;
input [WIDTH-1:0] req;
output [WIDTH-1:0] grant; 
 
// 'grant' is one-hot vector, which means only one client request is granted/given green light to proceed
// note that 'base' is one-hot vector, 
// 'base' signal helps round-robin arbiter to decide which 'req' to start servicing
reg [WIDTH-1:0] base;
 
always @(posedge clk)
begin
    if(reset) base <= 1;
 
    else base <= (grant[WIDTH-1]) ? 1 : (grant == 0) ? base : ( grant << 1 );
end
 
wire [WIDTH-1:0] priority_in;
wire [(WIDTH << 1)-1:0] priority_out; // the two leftmost significant bit are left unused
 
wire [WIDTH-1:0] granting = req & priority_in;
wire [WIDTH-2:0] approval; // we only have (WIDTH-1) block F
 
genvar index;
generate
    for(index = 0; index < WIDTH; index = index + 1)
    begin
        if(index == WIDTH-1) assign grant[index] = (reset) ? 0 : granting[index];
 
        else assign grant[index] = (reset) ? 0 : ( granting[index] | approval[index] );
 
 
        if(index < (WIDTH-1)) assign approval[index] = priority_out[index+WIDTH-1] & req[index];
 
        if(index > 0) assign priority_in[index] = base[index] | priority_out[index-1];
 
        else assign priority_in[index] = base[index];
    end
endgenerate
 
 
genvar priority_index;
generate
    for(priority_index = 0; priority_index < (WIDTH << 1); priority_index = priority_index + 1)
    begin : out_priority    
 
        if(priority_index < (WIDTH))
            assign priority_out[priority_index] = (~req[priority_index]) & priority_in[priority_index];
 
        else assign priority_out[priority_index] = (~req[priority_index-WIDTH]) & priority_out[priority_index-1];
    end
endgenerate
endmodule