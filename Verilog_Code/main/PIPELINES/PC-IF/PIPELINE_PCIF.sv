module PIPELINE_PCIF(PC, address, Flush1, Stall1, clk);
    input Flush1, Stall1, clk;
    input [8:0] PC; 
    output [8:0] address; 
    reg [8:0] address_inCal;

    assign address = address_inCal; 

    always_ff @(posedge clk) begin
        if (Flush1) begin
            address_inCal <= PC; 
        end else if (Stall1) begin
            address_inCal <= address_inCal; 
        end else begin
            address_inCal <= PC;
        end
    end

endmodule : PIPELINE_PCIF