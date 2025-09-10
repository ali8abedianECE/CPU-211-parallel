module PIPELINE_EXFI(ALUout, Zflags, PC, loadsP, opcodeP, opcodePP, loadsPP, ALUoutP, ZflagsP, PCP, clk);

    input clk; 
    input [15:0] ALUout; 
    input [2:0] Zflags, opcodeP; 
    input [8:0] PC; 
    input loadsP;

    output reg [15:0] ALUoutP; 
    output reg [2:0] ZflagsP, opcodePP;
    output reg [8:0] PCP; 
    output reg loadsPP;

    always_ff @(posedge clk) begin 
        ALUoutP <= ALUout;
        ZflagsP <= Zflags; 
        PCP <= PC;
        loadsPP <= loadsP; 
        opcodePP <= opcodeP;
    end

endmodule : PIPELINE_EXFI