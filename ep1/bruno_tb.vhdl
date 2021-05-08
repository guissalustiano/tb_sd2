-- Tb seguindo os exemplos dado pelo bruno do pdf

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity bruno_tb is
end entity;

architecture arch of bruno_tb is
  component cache is
      generic (
          address_size_in_bits: natural := 16;
          cache_size_in_bits: natural := 8;
          word_size_in_bits: natural := 8
      );
      port (
          ck, enable, write_enable: in bit;
          addr_i: in bit_vector(address_size_in_bits-1 downto 0);
          data_i: in bit_vector(word_size_in_bits-1 downto 0);
          data_o: out bit_vector(word_size_in_bits-1 downto 0);
          bsy: out bit;
          nl_data_i: in std_logic_vector(word_size_in_bits-1 downto 0);
          nl_enable, nl_write_enable: out bit;
          nl_bsy: in bit
      );
  end component;

  constant pc: time := 10 ns;
  constant address_size_in_bits: natural := 16;
  constant cache_size_in_bits: natural := 8;
  constant word_size_in_bits: natural := 8;
  constant delay_in_clocks: positive := 5;
  signal sim: bit := '0';

  signal addr: bit_vector(address_size_in_bits-1 downto 0);
  signal l1di, l1do: bit_vector(word_size_in_bits-1 downto 0);
  signal rdata: std_logic_vector(word_size_in_bits-1 downto 0);
  signal ck, l1en, l1we, l1bsy, l1nlen, l1nlwe, rbsy: bit;
begin
  ck <= (sim and not(ck)) after pc/2;

  cache_0: cache
      generic map (
          address_size_in_bits => address_size_in_bits,
          cache_size_in_bits => cache_size_in_bits,
          word_size_in_bits => word_size_in_bits
      )
      port map(
          ck => ck,
          enable => l1en,
          write_enable => l1we,
          addr_i => addr,
          data_i => l1di,
          data_o => l1do,
          bsy => l1bsy,
          nl_data_i => rdata ,
          nl_enable => l1nlen,
          nl_write_enable => l1nlwe,
          nl_bsy => rbsy
      );

  process
  begin
    report "BOT";
    sim <= '1';
    l1en <= '0';
    rbsy <= '0';
    rdata <= (others => 'Z');
    wait until rising_edge(ck);

    -- escrita em 00 para dar hit dps
    l1en <= '1';
    addr <= x"0000";
    l1we <= '1';
    l1di <= x"55";

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "W1 expected l1bsy=1" severity note;
    assert l1nlen='1' report "W1 expected l1nlen=1" severity note;
    assert l1nlwe='1' report "W1 expected l1nlwe=1" severity note;

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    rbsy <= '1';

    for i in 0 to delay_in_clocks loop
      wait until rising_edge(ck);
    end loop;

    rbsy <= '0';

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "W1 expected l1bsy=1" severity note;
    assert l1nlen='0' report "W1 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "W1 expected l1nlwe=0" severity note;
    -- assert l1do=x"00" report "W1 expected l1do=0x00" severity note;

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='0' report "W1 expected l1bsy=0" severity note;
    assert l1nlen='0' report "W1 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "W1 expected l1nlwe=0" severity note;
    assert l1do=x"55" report "W1 expected l1do=0x55" severity note;

    -- Se olhar o tempo das figuras ele faz -> miss -> hit -> escrita
    -- Figura 7: Leitura Miss para o T1A2
    -- ... o que vem antes não dá pra saber
    l1we <= '0';
    l1en <= '1';
    l1di <= x"00";
    addr <= x"0001";

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "R1 expected l1bsy=1" severity note;
    assert l1nlen='1' report "R1 expected l1nlen=1" severity note;
    assert l1nlwe='0' report "R1 expected l1nlwe=0" severity note;

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    rbsy <= '1';
    assert l1bsy='1' report "R1 expected l1bsy=1" severity note;
    assert l1nlen='1' report "R1 expected l1nlen=1" severity note;
    assert l1nlwe='0' report "R1 expected l1nlwe=0" severity note;

    rdata <= (others => 'U');
    for i in 0 to delay_in_clocks loop
      wait until rising_edge(ck);
    end loop;
    wait for 1 ps; -- stable ouput

    assert l1bsy='1' report "R1 expected l1bsy=1" severity note;
    assert l1nlen='1' report "R1 expected l1nlen=1" severity note;
    assert l1nlwe='0' report "R1 expected l1nlwe=0" severity note;

    rbsy <= '0';
    rdata <= x"55";

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "R1 expected l1bsy=1" severity note;
    assert l1nlen='0' report "R1 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "R1 expected l1nlwe=0" severity note;
    -- assert l1do=x"00" report "R1 expected l1do=x"00" severity note;

    rdata <= (others => 'Z');

    wait until rising_edge(ck); -- marker B
    wait for 1 ps; -- stable ouput
    assert l1bsy='0' report "R1 expected l1bsy=0" severity note;
    assert l1nlen='0' report "R1 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "R1 expected l1nlwe=0" severity note;
    assert l1do=x"55" report "R1 expected l1do=x55" severity note;

    -- Figura 8: Leitura hit

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "R2 expected l1bsy=0" severity note;
    assert l1nlen='0' report "R2 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "R2 expected l1nlwe=0" severity note;

    wait until rising_edge(ck); -- marker C
    wait for 1 ps; -- stable ouput
    assert l1bsy='0' report "R2 expected l1bsy=1" severity note;
    assert l1nlen='0' report "R2 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "R2 expected l1nlwe=0" severity note;

    addr <= x"0000";

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "R3 expected l1bsy=0" severity note;
    assert l1nlen='0' report "R3 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "R3 expected l1nlwe=0" severity note;
    assert l1do=x"55" report "R3 expected l1do=x55" severity note;

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='0' report "R3 expected l1bsy=1" severity note;
    assert l1nlen='0' report "R3 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "R3 expected l1nlwe=0" severity note;

    -- Figura 6: Escrita para o T1A2
    -- Ponto A
    l1we <= '1';
    l1di <= x"F0";

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "W1 expected l1bsy=1" severity note;
    assert l1nlen='1' report "W1 expected l1nlen=1" severity note;
    assert l1nlwe='1' report "W1 expected l1nlwe=1" severity note;

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    rbsy <= '1';

    for i in 0 to delay_in_clocks loop
      wait until rising_edge(ck);
    end loop;

    rbsy <= '0';

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='1' report "W1 expected l1bsy=1" severity note;
    assert l1nlen='0' report "W1 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "W1 expected l1nlwe=0" severity note;
    -- assert l1do=x"00" report "W1 expected l1do=0x00" severity note;

    wait until rising_edge(ck);
    wait for 1 ps; -- stable ouput
    assert l1bsy='0' report "W1 expected l1bsy=0" severity note;
    assert l1nlen='0' report "W1 expected l1nlen=0" severity note;
    assert l1nlwe='0' report "W1 expected l1nlwe=0" severity note;
    assert l1do=x"F0" report "W1 expected l1do=0xF0" severity note;

    l1di <= x"F1";
    addr <= x"0001";

    -- ... na da pra ver o resto mas deve ser mais escritas
    wait until rising_edge(ck);

    report "EOF";
    l1en <= '0';
    sim <= '0';
    wait;
  end process;
end architecture;
