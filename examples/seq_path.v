module seq_path(input clk, input a, output y);
wire q, d;
sky130_fd_sc_hd__dfxtp_1 launch (.CLK(clk), .D(a), .Q(q));
sky130_fd_sc_hd__inv_1 i0 (.A(q), .Y(d));
sky130_fd_sc_hd__dfxtp_1 capture (.CLK(clk), .D(d), .Q(y));
endmodule
