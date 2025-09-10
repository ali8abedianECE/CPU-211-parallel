module isHalted(opcode, isHALT); 
    input [2:0] opcode; 
    output reg isHALT; 

    always_comb begin
        if(opcode == 3'b111) begin 
            isHALT = 1'b1; 
        end else begin 
            isHALT = 1'b0; 
        end
    end

endmodule : isHalted