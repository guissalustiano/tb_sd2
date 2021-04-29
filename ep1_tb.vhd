library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity cache_tb is
end entity;

architecture arch of cache_tb is
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

  constant pc: time := 10 ns;
  constant address_size_in_bits: natural := 16;
  constant cache_size_in_bits: natural := 8;
  constant word_size_in_bits: natural := 8;
  signal sim: bit := '0';

  signal clock, enable, write_enable: bit;
  signal addr_i: bit_vector(address_size_in_bits-1 downto 0);
  signal data_i: bit_vector(word_size_in_bits-1 downto 0);
  signal data_o: bit_vector(word_size_in_bits-1 downto 0);
  signal bsy: bit;
  signal nl_data_i: std_logic_vector(word_size_in_bits-1 downto 0);
  signal nl_enable, nl_write_enable: bit;
  signal nl_bsy: bit;
begin
  clock <= (sim and not(clock)) after pc/2;

  cache_0: cache
      generic map (
          address_size_in_bits => address_size_in_bits,
          cache_size_in_bits => cache_size_in_bits,
          word_size_in_bits => word_size_in_bits
      )
      port map(
          ck => clock,
          enable => enable,
          write_enable => write_enable,
          addr_i => addr_i,
          data_i => data_i,
          data_o => data_o,
          bsy => bsy,
          nl_data_i => nl_data_i ,
          nl_enable => nl_enable,
          nl_write_enable => nl_write_enable,
          nl_bsy => nl_bsy
      );

  ram_a: ram
    generic map(
          address_size_in_bits => address_size_in_bits,
          word_size_in_bits => word_size_in_bits,
          delay_in_clocks => 5
    )
    port map(
      ck => clock,
      enable => nl_enable,
      write_enable => nl_write_enable,
      addr => addr_i,
      data => nl_data_i,
      bsy => nl_bsy
    );

  nl_data_i <= to_stdlogicvector(data_i);

  process
  begin
    report "BOT";
    sim <= '1';
    enable <= '1';

    -- writing
    write_enable <= '1';
    addr_i <= x"0404";
    data_i <= x"12";

    wait until falling_edge(bsy);

    write_enable <= '1';
    addr_i <= x"0204";
    data_i <= x"56";

    wait until falling_edge(bsy);


    -- read hit
    write_enable <= '0';
    addr_i <= x"0204";

    wait until falling_edge(bsy);
    assert data_o=x"56" report "Teste hit falhou!" severity note;

    -- read miss
    write_enable <= '0';
    addr_i <= x"0404";

    wait until falling_edge(bsy);
    assert data_o=x"12" report "Teste miss falhou!" severity note;

    -- read hit 2
    write_enable <= '0';
    addr_i <= x"0404";

    wait until falling_edge(bsy);
    assert data_o=x"12" report "Teste hit 2 falhou!" severity note;

    report "EOF";
    enable <= '0';
    sim <= '0';
    wait;
  end process;

end architecture;
