library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity cache is
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
end cache;

architecture arch of cache is
  type mem_cell_t is record
    valid: bit;
    tag: bit_vector(address_size_in_bits-1 downto cache_size_in_bits);
    data: bit_vector(word_size_in_bits-1 downto 0);
  end record;
  type mem_t is array (0 to 2**cache_size_in_bits-1) of mem_cell_t;
  signal mem: mem_t;

  -- aux vars
  signal caddr : natural;
  signal cache_addr : bit_vector(cache_size_in_bits-1 downto 0);
  signal cache_tag : bit_vector(address_size_in_bits-1 downto cache_size_in_bits);
  signal is_hit: boolean;
  signal inl_enable: bit; -- output interno

  type state_t is (S0, Sstarting, Swaiting, Sfinishing);
  signal state, nstate: state_t;

begin
  nl_enable <= inl_enable;
  nl_write_enable <= write_enable and inl_enable;

  cache_addr <= addr_i(cache_size_in_bits-1 downto 0);
  cache_tag <= addr_i(address_size_in_bits-1 downto cache_size_in_bits);

  caddr <= to_integer(unsigned(cache_addr));
  data_o <= mem(caddr).data;

  is_hit <= mem(caddr).valid = '1' and mem(caddr).tag = cache_tag;

  process(ck)
  begin
    if rising_edge(ck) then
      state <= nstate;
    end if;
  end process;

  process(state, enable, nl_bsy)
  begin
    -- valores "padrões", se nenhum for setado usam esse aqui
    bsy <= '1';
    inl_enable <= '0';

    case state is
      -- desligado
      when S0 =>
        bsy <= '0';

        nstate <= Sstarting;
        -- enable = 0 verificado no final do process

      -- espera a memoria começar os trabalhos
      when Sstarting=>
        inl_enable <= '1';

        if write_enable = '0' and is_hit then -- hit usa penas um ciclo, dá pra fazer tudo aqui
          inl_enable <= '0';
          nstate <= S0;
        elsif nl_bsy = '1' then
          nstate <= Swaiting;
        else
          nstate <= Sstarting;
        end if;

      -- espera a memoria acabar de processar
      when Swaiting =>
        inl_enable <= '1';
        mem(caddr).valid <= '1';
        mem(caddr).tag <= cache_tag;
        if write_enable = '1' then -- escrita
          mem(caddr).data <= data_i;
        else -- leitura miss
          mem(caddr).data <= to_bitvector(nl_data_i);
        end if;

        if nl_bsy = '1' then
          nstate <= Swaiting;
        else
          nstate <= Sfinishing;
        end if;

      -- pra ficar igual do professor
      when Sfinishing =>
        nstate <= S0;
    end case;

    -- caso comum
    if enable = '0' then -- desligado
      nstate <= S0;
    end if;
  end process;
end architecture;
