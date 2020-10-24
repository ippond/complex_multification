`timescale 1ns/100ps
module complex_mult
#(
parameter C_DIN_WIDTH     = 18        , 
parameter C_XILINX_DEVICE = "spartan6",
parameter C_DOUT_WIDTH    = 32        ,
parameter C_TIME          = 0
)
(
input                      I_clk      ,
input  [C_DIN_WIDTH-1:0]   I_data1_i  ,
input  [C_DIN_WIDTH-1:0]   I_data1_q  ,
input  [C_DIN_WIDTH-1:0]   I_data2_i  ,
input  [C_DIN_WIDTH-1:0]   I_data2_q  ,
input                      I_data_v   ,
output [C_DOUT_WIDTH-1:0]  O_data_i   ,
output [C_DOUT_WIDTH-1:0]  O_data_q   ,
output                     O_data_v   
);

//------------formula--------------
//(I1-Q1)Q2   I1Q2-Q1Q2
//(I2-Q2)I1   I1I2-I1Q2
//(I2+Q2)Q1   I2Q1+Q1Q2
//---------------------------------
localparam C_DA_WIDTH = (C_XILINX_DEVICE == "spartan6") ? 18 : 30;
localparam C_DB_WIDTH = (C_XILINX_DEVICE == "spartan6") ? 18 : 18;
localparam C_DD_WIDTH = (C_XILINX_DEVICE == "spartan6") ? 18 : 25;

localparam C_DA_EXT_WIDTH = C_DA_WIDTH - C_DIN_WIDTH;
localparam C_DB_EXT_WIDTH = C_DB_WIDTH - C_DIN_WIDTH;
localparam C_DD_EXT_WIDTH = C_DD_WIDTH - C_DIN_WIDTH;

localparam C_AREG0 = 2'b00;
localparam C_BREG0 = 2'b00;
localparam C_CREG0 = 1'b0;
localparam C_DREG0 = 1'b0;
localparam C_ADREG0 = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? 1'b0 : 1'b1) : 1'b0;
localparam C_MREG0 = (C_TIME==0) ? 1'b0 : 1'b1;
localparam C_PREG0 = 1'b1;
localparam C_OPMODE0 = (C_XILINX_DEVICE == "virtex6") ? 8'b00110101 : 8'b01010001;
localparam C_ALUCTL0 = 4'd0;
localparam C_INMODE0 = (C_XILINX_DEVICE == "virtex6") ? 5'b01100 : 5'd0;

localparam C_AREG1 = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? 2'b00 : 2'b10)
                                                    : ((C_TIME==0) ? 2'b00 : 2'b11);
localparam C_BREG1 = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? 2'b00 : 2'b10)
                                                    : ((C_TIME==0) ? 2'b00 : 2'b11);
localparam C_CREG1 = 1'b0;
localparam C_DREG1 = (C_TIME==0) ? 1'b0 : 1'b1;
localparam C_ADREG1 = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? 1'b0 : 1'b1) : 1'b0;
localparam C_MREG1 = 1'b1;
localparam C_PREG1 = 1'b1;
localparam C_OPMODE1 = (C_XILINX_DEVICE == "virtex6") ? 8'b00110101 : 8'b01011101;
localparam C_ALUCTL1 = 4'd0;
localparam C_INMODE1 = (C_XILINX_DEVICE == "virtex6") ? 5'b01100 : 5'd0;

localparam C_AREG2 = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? 2'b00 : 2'b10)
                                                    : ((C_TIME==0) ? 2'b00 : 2'b11);
localparam C_BREG2 = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? 2'b00 : 2'b10)
                                                    : ((C_TIME==0) ? 2'b00 : 2'b11);
localparam C_CREG2 = 1'b0;
localparam C_DREG2 = (C_TIME==0) ? 1'b0 : 1'b1;
localparam C_ADREG2 = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? 1'b0 : 1'b1) : 1'b0;
localparam C_MREG2 = 1'b1;
localparam C_PREG2 = 1'b1;
localparam C_OPMODE2 = (C_XILINX_DEVICE == "virtex6") ? 8'b00110101 : 8'b00011101;
localparam C_ALUCTL2 = 4'd0;
localparam C_INMODE2 = (C_XILINX_DEVICE == "virtex6") ? 5'b00100 : 5'd0;

wire [7:0] S_opmode0;
wire [7:0] S_opmode1;
wire [7:0] S_opmode2;
wire [3:0] S_aluctl0;
wire [3:0] S_aluctl1;
wire [3:0] S_aluctl2;
wire [4:0] S_inmode0;
wire [4:0] S_inmode1;
wire [4:0] S_inmode2;
wire [47:0] S_dsp0_out_p;
wire [47:0] S_dsp0_out_pc;
reg S_data_v = 0;
reg S_data_v_d = 0;
reg S_data_v_2d = 0;
reg S_data_v_3d = 0;
reg S_data_v_4d = 0;
reg [47:0] S_dsp0_out_p_d = 0;
wire [47:0] S_dsp1_in_c;
wire [47:0] S_dsp2_in_c;
wire [C_DA_WIDTH-1:0] S_dsp0_a;
wire [C_DB_WIDTH-1:0] S_dsp0_b;
wire [C_DD_WIDTH-1:0] S_dsp0_d;
wire [C_DA_WIDTH-1:0] S_dsp1_a;
wire [C_DB_WIDTH-1:0] S_dsp1_b;
wire [C_DD_WIDTH-1:0] S_dsp1_d;
wire [C_DA_WIDTH-1:0] S_dsp2_a;
wire [C_DB_WIDTH-1:0] S_dsp2_b;
wire [C_DD_WIDTH-1:0] S_dsp2_d;
reg [C_DIN_WIDTH-1:0] S_data1_i = 0;
reg [C_DIN_WIDTH-1:0] S_data1_q = 0;
reg [C_DIN_WIDTH-1:0] S_data2_i = 0;
reg [C_DIN_WIDTH-1:0] S_data2_q = 0;
wire [47:0] S_dataout_i;
wire [47:0] S_dataout_q;

assign O_data_i = (C_DOUT_WIDTH<2*C_DIN_WIDTH) ? S_dataout_i[2*C_DIN_WIDTH-1-:C_DOUT_WIDTH] : S_dataout_i[C_DOUT_WIDTH-1:0];
assign O_data_q = (C_DOUT_WIDTH<2*C_DIN_WIDTH) ? S_dataout_q[2*C_DIN_WIDTH-1-:C_DOUT_WIDTH] : S_dataout_q[C_DOUT_WIDTH-1:0];

always @(posedge I_clk)
begin
    S_data_v <= I_data_v;
    S_data_v_d <= S_data_v;
    S_data_v_2d <= S_data_v_d;
    S_data_v_3d <= S_data_v_2d;
    S_data_v_4d <= S_data_v_3d;
    S_dsp0_out_p_d <= S_dsp0_out_p;
    S_data2_q <= I_data2_q;
    S_data1_i <= I_data1_i;
    S_data2_i <= I_data2_i;
    S_data1_q <= I_data1_q;
end

assign S_dsp1_in_c = (C_TIME==0) ? S_dsp0_out_p : S_dsp0_out_p_d;
assign S_dsp2_in_c = (C_TIME==0) ? S_dsp0_out_p : S_dsp0_out_p_d;

assign O_data_v = (C_TIME==0) ? S_data_v_d : ((C_XILINX_DEVICE == "virtex6") ? S_data_v_4d : S_data_v_3d);
assign S_dsp0_b = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? {{C_DB_EXT_WIDTH{I_data2_q[C_DIN_WIDTH-1]}},I_data2_q}
                                                 : {{C_DB_EXT_WIDTH{S_data2_q[C_DIN_WIDTH-1]}},S_data2_q})
                                                 : {{C_DB_EXT_WIDTH{I_data1_q[C_DIN_WIDTH-1]}},I_data1_q};
assign S_dsp0_a = (C_XILINX_DEVICE == "virtex6") ? {{C_DA_EXT_WIDTH{I_data1_q[C_DIN_WIDTH-1]}},I_data1_q}
                                                 : {{C_DA_EXT_WIDTH{I_data2_q[C_DIN_WIDTH-1]}},I_data2_q};
assign S_dsp0_d = {{C_DD_EXT_WIDTH{I_data1_i[C_DIN_WIDTH-1]}},I_data1_i};

assign S_dsp1_b = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? {{C_DB_EXT_WIDTH{I_data1_i[C_DIN_WIDTH-1]}},I_data1_i}
                                                 : {{C_DB_EXT_WIDTH{S_data1_i[C_DIN_WIDTH-1]}},S_data1_i})
                                                 : {{C_DB_EXT_WIDTH{I_data2_q[C_DIN_WIDTH-1]}},I_data2_q};
assign S_dsp1_a = (C_XILINX_DEVICE == "virtex6") ? {{C_DA_EXT_WIDTH{I_data2_q[C_DIN_WIDTH-1]}},I_data2_q}
                                                 : {{C_DA_EXT_WIDTH{I_data1_i[C_DIN_WIDTH-1]}},I_data1_i};
assign S_dsp1_d = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? {{C_DD_EXT_WIDTH{I_data2_i[C_DIN_WIDTH-1]}},I_data2_i}
                                                 : {{C_DD_EXT_WIDTH{S_data2_i[C_DIN_WIDTH-1]}},S_data2_i})
                                                 : {{C_DD_EXT_WIDTH{I_data2_i[C_DIN_WIDTH-1]}},I_data2_i};

assign S_dsp2_b = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? {{C_DB_EXT_WIDTH{I_data1_q[C_DIN_WIDTH-1]}},I_data1_q}
                                                 : {{C_DB_EXT_WIDTH{S_data1_q[C_DIN_WIDTH-1]}},S_data1_q})
                                                 : {{C_DB_EXT_WIDTH{I_data2_q[C_DIN_WIDTH-1]}},I_data2_q};
assign S_dsp2_a = (C_XILINX_DEVICE == "virtex6") ? {{C_DA_EXT_WIDTH{I_data2_q[C_DIN_WIDTH-1]}},I_data2_q}
                                                 : {{C_DA_EXT_WIDTH{I_data1_q[C_DIN_WIDTH-1]}},I_data1_q};
assign S_dsp2_d = (C_XILINX_DEVICE == "virtex6") ? ((C_TIME==0) ? {{C_DD_EXT_WIDTH{I_data2_i[C_DIN_WIDTH-1]}},I_data2_i}
                                                 : {{C_DD_EXT_WIDTH{S_data2_i[C_DIN_WIDTH-1]}},S_data2_i})
                                                 : {{C_DD_EXT_WIDTH{I_data2_i[C_DIN_WIDTH-1]}},I_data2_i};

assign S_opmode0 = C_OPMODE0;
assign S_opmode1 = C_OPMODE1;
assign S_opmode2 = C_OPMODE2;
assign S_aluctl0 = C_ALUCTL0;
assign S_aluctl1 = C_ALUCTL1;
assign S_aluctl2 = C_ALUCTL2;
assign S_inmode0 = C_INMODE0;
assign S_inmode1 = C_INMODE1;
assign S_inmode2 = C_INMODE2;

test_dsp48
#(
.C_DEVICE (C_XILINX_DEVICE),
.C_AWIDTH (C_DA_WIDTH),
.C_BWIDTH (C_DB_WIDTH),
.C_DWIDTH (C_DD_WIDTH),
.C_AREG   (C_AREG0),
.C_BREG   (C_BREG0),
.C_CREG   (C_CREG0),
.C_DREG   (C_DREG0),
.C_ADREG  (C_ADREG0),
.C_MREG   (C_MREG0),
.C_PREG   (C_PREG0)
)
test_dsp48_inst0
(
.I_clk       (I_clk),
.I_rst       (1'b0),
.I_data_a    (S_dsp0_a),
.I_data_b    (S_dsp0_b),
.I_data_c    (48'd0),
.I_data_d    (S_dsp0_d),
.I_data_pc   (48'd0),
.I_aluctl    (S_aluctl0),
.I_inmode    (S_inmode0),
.I_opmode    (S_opmode0),
.O_data_p    (S_dsp0_out_p),
.O_data_pc   ()
);

test_dsp48
#(
.C_DEVICE (C_XILINX_DEVICE),
.C_AWIDTH (C_DA_WIDTH),
.C_BWIDTH (C_DB_WIDTH),
.C_DWIDTH (C_DD_WIDTH),
.C_AREG   (C_AREG1),
.C_BREG   (C_BREG1),
.C_CREG   (C_CREG1),
.C_DREG   (C_DREG1),
.C_ADREG  (C_ADREG1),
.C_MREG   (C_MREG1),
.C_PREG   (C_PREG1)
)
test_dsp48_inst1
(
.I_clk       (I_clk),
.I_rst       (1'b0),
.I_data_a    (S_dsp1_a),
.I_data_b    (S_dsp1_b),
.I_data_c    (S_dsp1_in_c),
.I_data_d    (S_dsp1_d),
.I_data_pc   (48'd0),
.I_aluctl    (S_aluctl1),
.I_inmode    (S_inmode1),
.I_opmode    (S_opmode1),
.O_data_p    (S_dataout_i),
.O_data_pc   ()
);

test_dsp48
#(
.C_DEVICE (C_XILINX_DEVICE),
.C_AWIDTH (C_DA_WIDTH),
.C_BWIDTH (C_DB_WIDTH),
.C_DWIDTH (C_DD_WIDTH),
.C_AREG   (C_AREG2),
.C_BREG   (C_BREG2),
.C_CREG   (C_CREG2),
.C_DREG   (C_DREG2),
.C_ADREG  (C_ADREG2),
.C_MREG   (C_MREG2),
.C_PREG   (C_PREG2)
)
test_dsp48_inst2
(
.I_clk       (I_clk),
.I_rst       (1'b0),
.I_data_a    (S_dsp2_a),
.I_data_b    (S_dsp2_b),
.I_data_c    (S_dsp2_in_c),
.I_data_d    (S_dsp2_d),
.I_data_pc   (48'd0),
.I_aluctl    (S_aluctl2),
.I_inmode    (S_inmode2),
.I_opmode    (S_opmode2),
.O_data_p    (S_dataout_q),
.O_data_pc   ()
);

endmodule


