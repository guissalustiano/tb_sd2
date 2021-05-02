library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

entity ramtb is end;

architecture behaviour of ramtb is

	component ram is

		generic (
			address_size_in_bits:	natural	:= 	8;
			word_size_in_bits	:	natural := 	8;
			delay_in_clocks		:	positive:=	1
		);

		port (
			ck, enable, write_enable: in bit;
			addr: in bit_vector (address_size_in_bits - 1 downto 0);
			data: inout std_logic_vector (word_size_in_bits - 1 downto 0);
			bsy	: out bit
		);

	end component;

	constant period: time := 2 ns;

	signal addrTB: bit_vector (7 downto 0);
	signal dataTB: std_logic_vector (7 downto 0);
	signal ckTB, enableTB, write_enableTB, bsyTB: bit;
	signal oneTB: bit := '0';

begin

	ckTB <= oneTB and (not ckTB) after period/2;

	dutA: ram port map (ckTB, enableTB, write_enableTB, addrTB, dataTB, bsyTB);

	testes: process begin

		report "BOT";
		oneTB <= '1';


		-- Teste 1: Enable = 0;
		enableTB <= '0';
		wait until rising_edge(ckTB);
		wait for 1 ns;
		-- assert dataTB = "ZZZZZZZZ" report "Vish";
	
		wait until rising_edge(ckTB);
		wait for 1 ns;

		-- Teste 2: Escrita
		enableTB <= '1';
		write_enableTB <= '1';
		dataTB <= "01010101";
		addrTB <= "00100000";

		wait until falling_edge(bsyTB);
		
		enableTB <= '1';
		write_enableTB <= '0';
		
		wait until falling_edge(bsyTB);

		assert dataTB = "01010101" report "Procedimento realizado com sucesso.";

		wait until rising_edge(ckTB);
		oneTB <= '0';
		report "EOF";

		wait;

	end process;

end behaviour;
