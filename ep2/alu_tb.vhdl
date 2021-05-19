-- OBS: ainda não consegui 10, algumas flags podem estar erradas
-- Caso descubra algum erro entre em contato

library ieee;
use ieee.numeric_bit.all;

entity alu_tb is
end entity;

architecture test of alu_tb is
  component alu is
    generic(
      size: natural := 10
    );
    port (
      A, B: in bit_vector(size-1 downto 0);
      F   : out bit_vector(size-1 downto 0);
      S   : in  bit_vector(3 downto 0);
      Z, Ov, Co: out bit
    );
  end component;

  function char2op(c: in Character) return bit_vector is
  begin
    case c is
      when '&' => return x"0";
      when '|' => return x"1";
      when '+' => return x"2";
      when '-' => return x"6";
      when '<' => return x"7";
      when '$' => return x"c"; -- nor
      when others => return x"F";
    end case;
  end;

  constant word_size: positive := 8;
  signal op: bit_vector(3 downto 0);
  signal A, B, R: bit_vector(word_size-1 downto 0);
  signal Z, Ov, Co: bit;
  signal flags: bit_vector(2 downto 0); -- Z & Ov & Co
begin
  tst: alu
        generic map (word_size)
        port map (A => A,
                  B => B,
                  F => R,
                  S => op,
                  Z => Z,
                  Ov => Ov,
                  Co => Co);
  flags <= Z & Ov & Co;

  process
    type pattern_type is record
      A: integer;
      op: Character;
      B: integer;
      R: integer;
      flags: bit_vector(2 downto 0); -- Z, Ov, Co;
    end record;
    type pattern_array is array (integer range<>) of pattern_type;
    constant patterns : pattern_array :=
      (
        ( 127, '&', 9, 9, "010"),
        ( 14,  '&', 7, 6, "000"),
        ( 112, '&', 15, 0, "100"),
        ( 127, '&', 0, 0, "100"),

        ( 127, '|', 9, 127, "010"),
        ( 14,  '|', 7, 15, "000"),
        ( 112, '|', 15, 127, "000"),
        ( 127, '|', 127, 127, "010"),

        ( 1,   '+', 1, 2, "000"),
        ( 1,   '+', -1, 0, "101"),
        ( 127, '+', 1, -128, "010"),
        ( -128,  '+', -1, 127, "011"),
        ( -128,'+', -128, 0, "111"),

        ( 1,   '-', -1, 2, "000"),
        ( 1,   '-', 1, 0, "101"),
        ( 127,  '-', -1, -128, "010"),
        ( -128, '-', 1, 127, "011"),
        ( -128,'-', -128, 0, "101"),

        ( 1,  '<', 1, 0, "101"),
        ( -1, '<', 1, 1, "001"),
        ( 1,  '<', -1, 0, "100"),
        ( 127, '<', -128, 0, "110"),
        ( -128, '<', 127, 1, "011"),

        -- NOR
        ( -16, '$', 15, 0, "100"),
        ( -4,  '$', 1, 2, "001"),

        ( 1, '&', 1, 1, "000")
      );
  begin
    report "BOT";

    for i in patterns'range loop
      wait for 2 ns;
      A <= bit_vector(to_signed(patterns(i).A, word_size));
      B <= bit_vector(to_signed(patterns(i).B, word_size));
      op <= char2op(patterns(i).op);

      wait for 2 ns;
      assert to_integer(signed(R)) = patterns(i).R and flags = patterns(i).flags
        report "Deu ruim :(" & LF &
          HT & "calculando: " & integer'image(patterns(i).A) & " " & patterns(i).op & " " & integer'image(patterns(i).B) & LF &
          HT & "esperado: R=" & integer'image(patterns(i).R) &
            HT & "Z=" & bit'image(patterns(i).flags(2)) & HT & "Ov=" & bit'image(patterns(i).flags(1)) & HT & "Co=" & bit'image(patterns(i).flags(0)) & LF &
          HT & "obtido  : R=" & integer'image(to_integer(signed(R))) &
            HT & "Z=" & bit'image(flags(2)) & HT & "Ov=" & bit'image(flags(1)) & HT & "Co=" & bit'image(flags(0)) & LF;
    end loop;

    report "EOF";
    wait;
  end process;

end architecture;

