library ieee;
use ieee.numeric_bit.all;

entity rom_tb is
end rom_tb;

architecture testbench of rom_tb is

    component rom is
        port(
            addr : in   bit_vector(7 downto 0);
            data : out  bit_vector(31 downto 0)
        );
    end component;

    signal addr_t : bit_vector(7 downto 0);
    signal data_t : bit_vector(31 downto 0);

begin

    dut: rom port map(addr_t, data_t);

    test: process 
    begin
        report "BOT";

        addr_t <= (others => '0');
        wait for 1 ns;
        assert data_t="11111000010000000000001111100001" report "falhou em mem[0]" severity note;

        addr_t <= "00000001";
        wait for 1 ns;
        assert data_t="11111000010000001000001111100010" report "falhou em mem[1]" severity note;
        
        addr_t <= "00001011";
        wait for 1 ns;
        assert data_t="11111000000000001000001111100010" report "falhou em mem[11]" severity note;
        
        for i in 13 to 255 loop
            addr_t <= bit_vector(to_unsigned(i, 8));
            wait for 1 ns;
            if(data_t /= "00000000000000000000000000000000") then
                report "falhou em mem["&integer'image(i)&"]";
            end if;
        end loop;


        report "EOT";
        wait;
    end process test;

end architecture testbench;
