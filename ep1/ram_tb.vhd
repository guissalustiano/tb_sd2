-- Creditos Iza Marinho e Matheus Miau

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

entity ram_tb is end;

architecture behaviour of ram_tb is
  component ram is
    generic(
      address_size_in_bits: natural := 64;
      word_size_in_bits: natural := 32;
      delay_in_clocks: positive := 1
    );
    port (
      ck, enable, write_enable: in bit;
      addr: in bit_vector(address_size_in_bits-1 downto 0);
      data: inout std_logic_vector(word_size_in_bits-1 downto 0);
      bsy: out bit
    );
  end component;

	signal one: bit := '1';
	constant address_size_in_bits: natural := 8;
	constant cache_size_in_bits: natural := 8;
	constant word_size_in_bits: natural := 8;
	constant delay_in_clocks: positive := 3;
    constant period: time := 2 ns;
	signal addrTB: bit_vector (address_size_in_bits-1 downto 0);
	signal dataTB: std_logic_vector (word_size_in_bits-1 downto 0);
	signal ckTB, enableTB, write_enableTB, bsyTB: bit;

begin

	ckTB <= one and (not ckTB) after period/2;

	dutA: ram
    generic map(
			address_size_in_bits => address_size_in_bits,
			word_size_in_bits => word_size_in_bits,
			delay_in_clocks => delay_in_clocks
    )
    port map(
      ck => ckTB,
      enable => enableTB,
      write_enable => write_enableTB,
      addr => addrTB,
      data => dataTB,
      bsy => bsyTB
    );

	testes: process begin
		report "BOT";

		-- Teste 1: Tri-State
		wait until rising_edge (ckTB);

		enableTB <= '0';

		wait until rising_edge (ckTB);

		if (dataTB = "ZZZZZZZZ") then
			report "Teste 1 - Tri-State: OK";
		elsif (dataTB /= "ZZZZZZZZ") then
			report "Teste 1 - Tri-State: ERRO";
		end if;

		-- Teste 2: Escrita e Tri-State
		wait until rising_edge (ckTB);

		enableTB <= '1';
		write_enableTB <= '1';
		dataTB <= "01010101";
		addrTB <= "00100000";

		wait until falling_edge (bsyTB);

		if (dataTB = "01010101" and addrTB = "00100000") then
			report "Teste 2 - Escrita: OK";
		else
			report "Teste 2 - Escrita: ERRO";
		end if;

		-- Teste 3: Tri-State p??s escrita
		wait until rising_edge (ckTB);

		enableTB <= '0';

		wait until rising_edge (ckTB);

		if (dataTB = "ZZZZZZZZ") then
			report "Teste 3 - Tri-State (P??s-Escrita): OK";
		elsif (dataTB /= "ZZZZZZZZ") then
			report "Teste 3 - Tri-State (P??s-Escrita): ERRO";
		end if;

        wait until rising_edge (ckTB);

        enableTB<='1';
        dataTB <= "01000100";
        addrTB<="01000000";

        wait until falling_edge(bsyTB);

		-- Teste 4: Leitura e Tri-State
		wait until rising_edge (ckTB);

        enableTB<='0';
        dataTB<=(others=>'Z');
        addrTB<="00100000";

        wait for period;

		enableTB <= '1';
		write_enableTB <= '0';

		wait until falling_edge (bsyTB);

		if (addrTB = "00100000" and dataTB = "01010101") then
			report "Teste 4 - Leitura: OK";
		else
			report "Teste 4 - Leitura: ERRO";
		end if;

        wait until rising_edge (ckTB);

        enableTB<='0';
        dataTB<=(others=>'Z');
        addrTB<="01000000";

        wait for period;

		enableTB <= '1';
		write_enableTB <= '0';

		wait until falling_edge (bsyTB);

		if (addrTB = "01000000" and dataTB = "01000100") then
			report "Teste 5 - Leitura: OK";
		else
			report "Teste 5 - Leitura: ERRO";
		end if;

		-- Teste 5: Tri-State Pos Leitura
		wait until rising_edge (ckTB);
		enableTB <= '0';
		dataTB <= (others => 'Z');

		wait until rising_edge (ckTB);

		if (dataTB = "ZZZZZZZZ") then
			report "Teste 6 - Tri-State (P??s-Leitura): OK";
		elsif (dataTB /= "ZZZZZZZZ") then
			report "Teste 6 - Tri-State (P??s-Leitura): ERRO";
		end if;
        --O ??ltimo teste s?? serve para verificar se o TB consegue atribuir 'Z' para data, n??o diz nada sobre o seu projeto.

		-- End of test
		report "Fim do Teste.";
		one <= '0';
		wait;

	end process;

end behaviour;
