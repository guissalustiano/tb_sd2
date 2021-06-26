entity signExtend_tb is 
end entity;

architecture arch of signExtend_tb is

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
    -------------------------------------------------------------

    component signExtend is
        port(
            i: in  bit_vector(31 downto 0); 
            o: out bit_vector(63 downto 0)
        );
    end component;

    type test_case_type is record 
        stimulus: bit_vector(31 downto 0);
        response: bit_vector(63 downto 0);
    end record;
    type test_case_array is array(0 to 7) of test_case_type;
    constant TEST_CASES: test_case_array := (
        ( -- LDUR
            B"11111000010_000000001_00_00000_00000", 
            B"0000000000000000000000000000000000000000000000000000000_000000001"),
        ( -- LDUR
            B"11111000010_100000001_00_00000_00000",
            B"1111111111111111111111111111111111111111111111111111111_100000001"),
        ( -- STUR
            B"11111000000_000000001_00_00000_00000",
            B"0000000000000000000000000000000000000000000000000000000_000000001"),
        ( -- STUR
            B"11111000000_100000001_00_00000_00000",
            B"1111111111111111111111111111111111111111111111111111111_100000001"),
        ( -- CBZ
            B"10110100_0000000000000000001_00000",
            B"000000000000000000000000000000000000000000000_0000000000000000001"),
        ( -- CBZ
            B"10110100_1000000000000000001_00000",
            B"111111111111111111111111111111111111111111111_1000000000000000001"),
        ( -- B
            B"000101_00000000000000000000000001",
            B"00000000000000000000000000000000000000_00000000000000000000000001"),
        ( -- B
            B"000101_10000000000000000000000001",
            B"11111111111111111111111111111111111111_10000000000000000000000001")
    );

    signal i: bit_vector(31 downto 0);
    signal o: bit_vector(63 downto 0);

begin

	dut: signExtend port map(i, o);

	tb: process
        variable expected: bit_vector(63 downto 0);
	begin
		report "BOT";

        for index in TEST_CASES'range loop
            i <= TEST_CASES(index).stimulus;
            wait for 1 ps;
            expected := TEST_CASES(index).response;
            assert expected = o 
                report "Teste "& integer'image(index) & " falhou"&
                    "Esperava "& to_bstring(expected) &
                    "mas recebeu "& to_bstring(o)
                severity warning;
        end loop;

		report "EOT";
		wait;
	end process;

end architecture arch;