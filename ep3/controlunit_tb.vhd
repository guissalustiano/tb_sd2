library ieee;
use ieee.numeric_std.std_match;
use ieee.std_logic_1164.all;

entity controlunit_tb is 
end entity;

architecture arch of controlunit_tb is

    -------------------------------------------------------------
    function to_bstring(b : bit) return string is
        variable b_str_v : string(1 to 3);  -- bit image with quotes around
    begin
        b_str_v := bit'image(b);
        return "" & b_str_v(2);  -- "" & character to get string
    end function;

    function to_bstring(bv : bit_vector) return string is
        alias    bv_norm : bit_vector(1 to bv'length) is bv;
        variable b_str_v : string(1 to 1);  -- String of bit
        variable res_v   : string(1 to bv'length);
    begin
        for idx in bv_norm'range loop
            b_str_v := to_bstring(bv_norm(idx));
            res_v(idx) := b_str_v(1);
        end loop;
        return res_v;
    end function;

    function to_bstring(sl : std_logic) return string is
        variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
      begin
        sl_str_v := std_logic'image(sl);
        return "" & sl_str_v(2);  -- "" & character to get string
      end function;
      
      function to_bstring(slv : std_logic_vector) return string is
        alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
        variable sl_str_v : string(1 to 1);  -- String of std_logic
        variable res_v    : string(1 to slv'length);
      begin
        for idx in slv_norm'range loop
          sl_str_v := to_bstring(slv_norm(idx));
          res_v(idx) := sl_str_v(1);
        end loop;
        return res_v;
      end function;
    -------------------------------------------------------------

    component controlunit is
        port(
            -- To Datapath
            reg2loc,
            uncondBranch,
            branch,
            memRead,
            memToReg: out bit;
            aluOp: out bit_vector(1 downto 0);
            memWrite,
            aluSrc,
            regWrite: out bit;
            -- From Datapath
            opcode: in bit_vector(10 downto 0)
        );
    end component;

    type test_case_type is record 
        stimulus: std_logic_vector(10 downto 0);
        response: std_logic_vector(9 downto 0);
    end record;
    type test_case_array is array(1 to 5) of test_case_type;
    constant TEST_CASES: test_case_array := (
        ( -- LDUR
            "11111000010", 
            "-001100011"),
        ( -- STUR
            "11111000000",
            "1000-00110"),
        ( -- CBZ
            "10110100---",
            "1010-01000"),
        ( -- B
            "000101-----",
            "-1-----0-0"),
        ( -- R type
            "1--0101-000",
            "0000010001")
    );

    signal opcode: bit_vector(10 downto 0);
    signal controlSignals: bit_vector(9 downto 0);

begin

	dut: controlunit port map(
        controlSignals(9),
        controlSignals(8),
        controlSignals(7),
        controlSignals(6),
        controlSignals(5),
        controlSignals(4 downto 3),
        controlSignals(2),
        controlSignals(1),
        controlSignals(0),
        opcode
    );

	tb: process
        variable expected: std_logic_vector(9 downto 0);
	begin
		report "BOT";

        for index in TEST_CASES'range loop
            opcode <= to_bitvector(TEST_CASES(index).stimulus);
            wait for 1 ps;
            expected := TEST_CASES(index).response;
            assert std_match(expected, to_stdlogicvector(controlSignals))
                report "Teste "& integer'image(index) &" falhou. "&
                    "Esperava "& to_bstring(expected) &" "&
                    "mas recebeu "& to_bstring(controlSignals)
                severity warning;
        end loop;

		report "EOT";
		wait;
	end process;

end architecture arch;