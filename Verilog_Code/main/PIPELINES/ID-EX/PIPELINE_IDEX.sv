module PIPELINE_IDEX(Rd,  Rn,  Rm,  opcode,  op,  cond,  ALUop,  shift,  sximm8,  sximm5,  data_in, PC, REGWRITE, VSEL2, SelectAIN, SelectBIn, loads,
                     RdP, RnP, RmP, opcodeP, opP, condP, ALUopP, shiftP, sximm8P, sximm5P, data_inP, PCP, REGWRITEP, VSEL2P, SelectAINP, SelectBInP, loadsP, 
                     Flush3, Stall3, clk); 

    input Flush3, Stall3, clk;
    input [2:0] Rd, Rn, Rm, opcode, cond;
    input [1:0] op, shift, ALUop; 
    input [15:0] sximm5, sximm8, data_in;
    input [8:0] PC;
    input REGWRITE, SelectAIN, SelectBIn, loads;
    input [1:0] VSEL2; 

    output [2:0] RdP, RnP, RmP, opcodeP, condP;
    output [1:0] opP, shiftP, ALUopP; 
    output [15:0] sximm5P, sximm8P, data_inP;
    output [8:0] PCP; 
    output REGWRITEP, SelectAINP, SelectBInP, loadsP;
    output [1:0] VSEL2P; 

    reg [2:0] RdP_CAL, RnP_CAL, RmP_CAL, opcodeP_CAL, condP_CAL;
    reg [1:0] opP_CAL, shiftP_CAL, ALUop_CAL; 
    reg [15:0] sximm5P_CAL, sximm8P_CAL, data_inP_CAL;
    reg [8:0] PCP_CAL; 
    reg REGWRITE_CALP, SelectAIN_CALP, SelectBIn_CALP, loads_CALP;
    reg [1:0] VSEL2_CALP; 

    assign RdP = RdP_CAL;
    assign RnP = RnP_CAL;
    assign RmP = RmP_CAL;
    assign opcodeP = opcodeP_CAL;
    assign condP = condP_CAL;
    assign opP = opP_CAL;
    assign shiftP = shiftP_CAL;
    assign sximm5P = sximm5P_CAL;
    assign sximm8P = sximm8P_CAL;
    assign data_inP = data_inP_CAL;
    assign ALUopP = ALUop_CAL;
    assign REGWRITEP = REGWRITE_CALP;
    assign SelectAINP = SelectAIN_CALP;
    assign SelectBInP = SelectBIn_CALP;
    assign loadsP = loads_CALP;
    assign VSEL2P = VSEL2_CALP;

    assign PCP = PCP_CAL;

    always_ff @(posedge clk) begin 
        if(Flush3) begin 
            RdP_CAL <= 3'd0;
            RnP_CAL <= 3'd0;
            RmP_CAL <= 3'd0;
            opcodeP_CAL <= 3'd0; 
            condP_CAL <= 3'd0;
            opP_CAL <= 2'd0;
            shiftP_CAL <= 2'd0;
            sximm5P_CAL <= 16'd0;
            sximm8P_CAL <= 16'd0; 
            data_inP_CAL <= 16'd0;
            PCP_CAL <= 9'd0;
            ALUop_CAL <= 2'd0;
            REGWRITE_CALP <= 1'b0;
            SelectAIN_CALP <= 1'b0;
            SelectBIn_CALP <= 1'b0;
            loads_CALP <= 1'b0;
            VSEL2_CALP <= 2'd0;
        end else if(Stall3) begin 
            RdP_CAL <= RdP_CAL;
            RnP_CAL <= RnP_CAL;
            RmP_CAL <= RmP_CAL;
            opcodeP_CAL <= opcodeP_CAL; 
            condP_CAL <= condP_CAL;
            opP_CAL <= opP_CAL;
            shiftP_CAL <= shiftP_CAL;
            sximm5P_CAL <= sximm5P_CAL;
            sximm8P_CAL <= sximm8P_CAL; 
            data_inP_CAL <= data_inP_CAL;
            PCP_CAL <= PCP_CAL; 
            ALUop_CAL <= ALUop_CAL;
            REGWRITE_CALP <= REGWRITE_CALP;
            SelectAIN_CALP <= SelectAIN_CALP;
            SelectBIn_CALP <= SelectBIn_CALP;
            loads_CALP <= loads_CALP;
            VSEL2_CALP <= VSEL2_CALP;
        end else begin 
            RdP_CAL <= Rd;
            RnP_CAL <= Rn;
            RmP_CAL <= Rm;
            opcodeP_CAL <= opcode; 
            condP_CAL <= cond;
            opP_CAL <= op;
            shiftP_CAL <= shift;
            sximm5P_CAL <= sximm5;
            sximm8P_CAL <= sximm8; 
            data_inP_CAL <= data_in;
            PCP_CAL <= PC; 
            ALUop_CAL <= ALUop;
            REGWRITE_CALP <= REGWRITE;
            SelectAIN_CALP <= SelectAIN;
            SelectBIn_CALP <= SelectBIn;
            loads_CALP <= loads;
            VSEL2_CALP <= VSEL2;
        end
    end

endmodule : PIPELINE_IDEX