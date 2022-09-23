module nrz_cdr (
    input clk, //high freq
    input rst, //sync with clk hi assert
    input nrz,
    output cdr
);
reg [1:0] nrz_d = 0;
always @(posedge clk) begin
    if(rst)begin
        nrz_d <= 0;
    end
    else begin
        nrz_d <= {nrz_d[0],nrz};
    end
end
reg nrz_pos = 0, nrz_neg = 0;
always @(posedge clk) begin
    nrz_pos <= nrz_d[0] & ~nrz_d[1];
    nrz_neg <= ~nrz_d[0] & nrz_d[1];
end
parameter C_F = 32'd14658591;// ~= 2^32*F_cdr/F_clk
reg [31:0]center_f = C_F;
reg [31:0]counter = 0;
always @(posedge clk) begin
    if(rst)begin
        counter <= 0;
    end
    else if(nrz_pos)begin
        counter <= 32'h8000_0000 | center_f;//+
    end
    else begin
        counter <= counter + center_f;
    end
end
always @(posedge clk) begin
    if(rst)begin
        center_f <= C_F;
    end
    else if(nrz_neg)begin
        // counter[31] is 2m clk
        center_f <= counter[31] ? center_f-1 : center_f+1; //
    end 
end
//independent cdr counter ... bad


assign cdr = counter[31];
    
endmodule
