library verilog;
use verilog.vl_types.all;
entity cyclone_bmux21 is
    port(
        mo              : out    vl_logic_vector(15 downto 0);
        a               : in     vl_logic_vector(15 downto 0);
        b               : in     vl_logic_vector(15 downto 0);
        s               : in     vl_logic
    );
end cyclone_bmux21;
