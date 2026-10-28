module four_paths(input clk, input a, output y, output z);
wire q, d;
sky130_fd_sc_hd__dfxtp_1 launch (.CLK(clk), .D(a), .Q(q));
sky130_fd_sc_hd__inv_1 i0 (.A(q), .Y(d));
sky130_fd_sc_hd__dfxtp_1 capture (.CLK(clk), .D(d), .Q(y));
sky130_fd_sc_hd__inv_1 bypass (.A(a), .Y(z));
endmodule
