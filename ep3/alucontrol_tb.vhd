entity alucontrol_tb is 
end entity;

architecture arch of alucontrol_tb is

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

    component alucontrol is
        port(
            aluop: in bit_vector(1 downto 0);
            opcode: in bit_vector(10 downto 0);
            aluCtrl: out bit_vector(3 downto 0)
        );
    end component;

    type test_case_type is record 
        aluop: bit_vector(1 downto 0);
        opcode: bit_vector(10 downto 0);
        response: bit_vector(3 downto 0);
    end record;
    type test_case_array is array(1 to 7) of test_case_type;
    constant TEST_CASES: test_case_array := (
        ("00", "00000000000", "0010"),
        ("00", "00000000000", "0010"),
        ("01", "00000000000", "0111"),
        ("10", "10001011000", "0010"),
        ("10", "11001011000", "0110"), -- Falhou
        ("10", "10001010000", "0000"),
        ("10", "10101010000", "0001") -- Falhou
    );

    signal aluop: bit_vector(1 downto 0);
    signal opcode: bit_vector(10 downto 0);
    signal response: bit_vector(3 downto 0);

begin

	dut: alucontrol port map(aluop, opcode, response);

	tb: process
        variable expected: bit_vector(3 downto 0);
	begin
		report "BOT";

        for index in TEST_CASES'range loop
            aluop <= TEST_CASES(index).aluop;
            opcode <= TEST_CASES(index).opcode;
            wait for 1 ps;
            expected := TEST_CASES(index).response;
            assert expected = response 
                report "Teste "& integer'image(index) & " falhou"&
                    ". Esperava "& to_bstring(expected) &
                    " mas recebeu "& to_bstring(response)
                severity warning;
        end loop;

		report "EOT";
		wait;
	end process;

end architecture arch;
