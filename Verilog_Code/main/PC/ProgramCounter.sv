module ProgramCounter(PCout, clk, reset, enablePC, load_PC, imJump, imJumpFlag);
    input clk, reset, enablePC, imJumpFlag, load_PC;
    input [8:0] imJump;
    output wire [8:0] PCout;

    reg [8:0] PCoutInCal; 

    assign PCout = PCoutInCal;

    always_ff @(posedge clk) begin 
        if(reset) begin 
            PCoutInCal <= 9'd0;
        end else begin 
            if(imJumpFlag) begin 
                PCoutInCal <= imJump;
            end else if (load_PC) begin 
                PCoutInCal <= PCoutInCal + 9'd1;
            end else begin
                PCoutInCal <= PCoutInCal;
            end
        end
    end

endmodule : ProgramCounter
