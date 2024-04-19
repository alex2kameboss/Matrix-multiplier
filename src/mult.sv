module mult #(
    parameter DATA_WIDTH = 8
) (
    input   [DATA_WIDTH - 1 : 0]        a,
    input   [DATA_WIDTH - 1 : 0]        b,
    output  [2 * DATA_WIDTH - 1 : 0]    c
);

assign c = a * b;

endmodule